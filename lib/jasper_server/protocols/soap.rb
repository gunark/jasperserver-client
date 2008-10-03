require 'jasper_server/protocols/soap_monkeypatch'
require 'jasper_server/error'

module JasperServer
  module Protocols
    class SOAP
      JASPER_URN = "urn:"
      
      def request_report_via_soap(request)
        raise Error, "Must connect to JasperServer first!" if @driver.nil?
        
        report = request.report_unit
        format = request.output_format
        params = request.report_params
        
        params_xml = ""
        params.each do |name, value|
          if value.kind_of? Array
            value.each do |item|
              params_xml << %{<parameter name="#{name}" isListItem="true">#{@@html_encoder.encode(item, :decimal)}</parameter>\n}
            end
          elsif value.kind_of? Time
            ts = ReportRequest.convert_time_to_jasper_timestamp(value)
            params_xml << %{<parameter name="#{name}">#{ts}</parameter>\n}
          elsif !value.blank?
            params_xml << %{<parameter name="#{name}"><![CDATA[#{value}]]></parameter>\n}
          end
        end
        
        request = %Q|<request operationName="runReport" locale="en">
          <argument name="RUN_OUTPUT_FORMAT">#{format}</argument>
          <resourceDescriptor name="" wsType=""
              uriString="#{report}"
              isNew="false">
            <label>null</label>
            #{params_xml}
          </resourceDescriptor>
        </request>|
        
        RAILS_DEFAULT_LOGGER.debug "#{self.name} Request:\n#{request}" if Object.const_defined?('RAILS_DEFAULT_LOGGER')
    
        result = @driver.runReport(request)
        
        RAILS_DEFAULT_LOGGER.debug "#{self.name} Response:\n#{result}" if Object.const_defined?('RAILS_DEFAULT_LOGGER')
        
        xml = XmlSimple.xml_in_string(result)
        unless xml['returnCode'].first.to_i == 0
          raise JasperServer::Error, "JasperServer replied with an error: #{xml['returnMessage'] ? xml['returnMessage'].first : xml.inspect}"
        end
        
        result.instance_variable_get(:@env).external_content['report'].data.content
      end
      
      def connect(url, username, password)
        @driver = connect_to_soap_service(url, username, password)
      end
      
      protected
      def connect_to_soap_service(url, username, password)
        driver = ::SOAP::RPC::Driver.new(url, JASPER_URN)
        driver.options['protocol.http.basic_auth'] << [url, username, password]
        
        driver.add_method('runReport', 'requestXmlString')
        return driver
      end
    end
  end
end
