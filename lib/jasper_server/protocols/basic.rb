require 'jasper_server/error'

module JasperServer
  module Protocols
    
    # <b>THIS PROTOCOL ADAPTER DOES NOT YET WORK!!!</b>
    #
    # This was an attempt at fetching reports using scraping... unfortunately
    # I can't figure out how to fake the Spring authentication session :(
    class Basic
      # EXAMPLE URL FOR FETCHING REPORT
      # http://jas01:8080/jasperserver/flow.html?_flowId=viewReportFlow&reportUnit=/u-track/project-totals-for-orgunit&standAlone=true&ParentFolderUri=/u-track&orgunit-id=2&start-date=20080801040000&end-date=20080831040000&output=swf&decorate=no

      def request_report_via_url(request)
        report_unit   = request.report_unit
        output_format = request.output_format
        report_params = request.report_params
        
        params = {}
        report_params.each do |name, value|
          if value.kind_of? Time
            params[name] = ReportRequest.convert_time_to_jasper_timestamp(value) 
          else
            params[name] = value
          end
        end
        
        params['_flowId']    = 'viewReportFlow'
        params['standAlone'] = 'true'
        #params['parentFolderUri'] = '/u-track'
        params['decorate']   = 'no'
        
        params['reportUnit'] = report_unit
        params['output']     = output_format
        
        puts "FETCHING LOGIN PAGE"
        uri = URI.parse("http://jas01:8080/jasperserver/login.html")
        res = Net::HTTP.start(uri.host, uri.port) do |http|
          http.get(uri.path)
        end
        res['set-cookie'] =~ /JSESSIONID=([a-z0-9]*);/i
        jsessionid = $~[1]
        puts "SESSION ID IS #{jsessionid}"

        sleep 1
        
        uri = URI.parse("http://jas01:8080/jasperserver/j_acegi_security_check")
        
        # FIXME: logging in doesn't work :(
        
        puts "LOGGING IN"
        req = Net::HTTP::Post.new(uri.path)
        req.set_form_data({'j_username' => 'jasperadmin', 'j_password' => 'jasper!', 'btnsubmit' => 'Login', 'jsessionid' => jsessionid})
        
        client = Net::HTTP.new(uri.host, uri.port)
        result = client.start do |http|
          puts "LOGIN REQ"
          puts req.to_hash.inspect
          http.request(req)
        end
        #res = Net::HTTP.post_form(uri, {'j_username' => 'jasperadmin', 'j_password' => 'jasper!', 'btnsubmit' => 'Login'})
        puts "LOGIN RESP HEADERS"
        puts res.to_hash.inspect
        puts res.inspect
        
        
        
        uri = URI.parse("http://jas01:8080/jasperserver/flow.html")
        #
        #req = Net::HTTP::Post.new(uri.path)
        #req.set_form_data(params, '&')
        
        sleep 1
        
        # FIXME: this should fetch the report, but instead we get redirected to the login page
        #        since I can't seem to get the fake login to work :(
        
        params['jsessionid'] = 
        q = params.collect{|k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"}.join("&")
        uri.query = q
        req = Net::HTTP::Get.new(uri.request_uri)
        puts uri.request_uri
        
        client = Net::HTTP.new(uri.host, uri.port)
        result = client.start do |http|
          puts req.to_hash.inspect
          http.request(req)
        end
                
        return result
      end
      
      class Error < JasperServer::Error
      end
    end
  end
end
