require 'jasper_server/protocols/soap_monkeypatch'
require 'jasper_server/error'

gem 'xml-simple'
require 'xmlsimple'

if Object.const_defined?(:XmlSimple) && !XmlSimple.respond_to?(:xml_in_string)
  class XmlSimple
    # Same as xml_in but doesn't try to smartly shoot itself in the foot.
    def xml_in_string(string, options = nil)
      handle_options('in', options)

      @doc = parse(string)
      result = collapse(@doc.root)

      if @options['keeproot']
        merge({}, @doc.root.name, result)
      else
        result
      end
    end

    def self.xml_in_string(string, options = nil)
      new.xml_in_string(string, options)
    end
  end
end

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
          case value
          when Array
            value.each do |item|
              params_xml << %{<parameter name="#{name}" isListItem="true">#{@@html_encoder.encode(item, :decimal)}</parameter>\n}
            end
          when Time, DateTime, Date
            ts = ReportRequest.convert_time_to_jasper_timestamp(value)
            params_xml << %{<parameter name="#{name}">#{ts}</parameter>\n}
          else
            unless value.blank?
              params_xml << %{<parameter name="#{name}"><![CDATA[#{value}]]></parameter>\n}
            end
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
        
        RAILS_DEFAULT_LOGGER.debug "#{self.class.name} Request:\n#{request}" if Object.const_defined?('RAILS_DEFAULT_LOGGER')
    
        result = @driver.runReport(request)
        
        RAILS_DEFAULT_LOGGER.debug "#{self.class.name} Response:\n#{result}" if Object.const_defined?('RAILS_DEFAULT_LOGGER')

        if Object.const_defined?(:ActiveSupport) && ActiveSupport.const_defined?(:XmlMini)
          # for Rails 2.3+
          xml = ActiveSupport::XmlMini.parse(result)
          xml = xml['operationResult']
          xml.each do |k,v|
            if v.kind_of?(Hash) && v[ActiveSupport::XmlMini.backend::CONTENT_KEY]
              xml[k] = [v[ActiveSupport::XmlMini.backend::CONTENT_KEY]]
            end
          end
        else
          xml = XmlSimple.xml_in_string(result)
        end

        unless xml['returnCode'].first.to_i == 0
          raise JasperServer::Error, "JasperServer replied with an error: #{xml['returnMessage'] ? xml['returnMessage'].first : xml.inspect}"
        end
        
        result.instance_variable_get(:@env).external_content['report'].data.content
      end
      
      def connect(url, username, password, timeout = 60)
        @driver = connect_to_soap_service(url, username, password, timeout)
      end
      
      protected
      def connect_to_soap_service(url, username, password, timeout = 60)
        driver = ::SOAP::RPC::Driver.new(url, JASPER_URN)
        driver.options['protocol.http.basic_auth'] << [url, username, password]
        driver.options['receive_timeout'] = timeout

        
        driver.add_method('runReport', 'requestXmlString')
        return driver
      end
    end
  end
end
