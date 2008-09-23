require 'soap/rpc/driver'

# Modify SOAP::RPC::Proxy class to return SOAP Message in addition to object mapping 
# to access the SOAP attachments
# Taken from: http://www.jasperforge.org/index.php?option=com_joomlaboard&Itemid=&func=view&catid=10&id=31754#31754
module SOAP
  module RPC
    
    class Proxy
      include SOAP
      
      def call(name, *params)
        unless op_info = @operation[name]
          raise MethodDefinitionError, "method: #{name} not defined"
        end
        mapping_opt = create_mapping_opt
        req_header = create_request_header
        req_body = SOAPBody.new(
          op_info.request_body(params, @mapping_registry,
            @literal_mapping_registry, mapping_opt)
        )
        reqopt = create_encoding_opt(
          :soapaction => op_info.soapaction || @soapaction,
          :envelopenamespace => @options["soap.envelope.requestnamespace"],
          :default_encodingstyle =>
            @default_encodingstyle || op_info.request_default_encodingstyle,
          :elementformdefault => op_info.elementformdefault,
          :attributeformdefault => op_info.attributeformdefault
        )
        resopt = create_encoding_opt(
          :envelopenamespace => @options["soap.envelope.responsenamespace"],
          :default_encodingstyle =>
            @default_encodingstyle || op_info.response_default_encodingstyle,
          :elementformdefault => op_info.elementformdefault,
          :attributeformdefault => op_info.attributeformdefault
        )
        env = route(req_header, req_body, reqopt, resopt)
        raise EmptyResponseError unless env
        receive_headers(env.header)
        begin
          check_fault(env.body)
        rescue ::SOAP::FaultError => e
          op_info.raise_fault(e, @mapping_registry, @literal_mapping_registry)
        end
        response_obj = op_info.response_obj(env.body, @mapping_registry,
          @literal_mapping_registry, mapping_opt)
        response_obj.instance_variable_set(:@env, env)
        return response_obj
      end
    end
  
  end
end

