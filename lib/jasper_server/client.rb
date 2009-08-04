require 'jasper_server/protocols/soap'

module JasperServer

  # The client through which all report requests are sent to the JasperServer.
  class Client
    
    # Create a new instance of the client.
    #
    # url :: The URL of the JasperServer. This should look something like:
    #        "http://<hostname>:<port>/jasperserver/services/repository"
    # username :: The username used to connect to the JasperServer.
    # password :: The password used to connect to the JasperServer.
    # timeout  :: Maximum time to wait for a response from the JasperServer (default it 60 seconds).
    def initialize(url, username, password, timeout = 60)
      unless url =~ /\/services\/repository\/?$/
        # add the /services/repository suffix to the URL if the user forgot
        # to include it
        url << "/services/repository"
        
        puts "WARNING: You may have forgotten to add the '/services/repository' "+
              "to your JasperServer URL. Your URL has been automatically changed to #{url.inspect}."
      end
      
      @jasper_url       = url
      @jasper_username  = username
      @jasper_password  = password
      @timeout = timeout
    end
    
    # Request a report from the server based on the ReportRequest object you provide.
    # Returns the report data. 
    # 
    # For example if your request specifies <tt>PDF</tt> as the output format, PDF 
    # binary data will be returned. 
    #
    #   client = JasperServer::Client.new("http://example.com/jasperserver/services/repository",
    #                                     "jasperadmin", "secret!")
    #   request = JasperServer::Request.new("/example/my-report", "PDF", {'fruit' => 'apple'})
    #   pdf_data = client.request_report(request)
    #   File.open('/tmp/report.pdf', 'w') do |f|
    #     f.puts(pdf_data)
    #   end
    #
    # For debugging purposes, try requesting output in <tt>CSV</tt> format, since 
    # request_report will then return an easily readable String.
    def request_report(request)
      soap = JasperServer::Protocols::SOAP.new
      soap.connect(@jasper_url, @jasper_username, @jasper_password, @timeout)
      soap.request_report_via_soap(request)
    end

  end
end

