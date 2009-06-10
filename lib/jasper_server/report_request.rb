module JasperServer
  # Represents a request for a report, to be sent to the JasperServer via
  # the JasperServer::Client.
  class ReportRequest    
    
    attr_accessor :report_unit, :output_format, :report_params
    
    # The request consists of three arguments:
    #
    # report_unit :: The path on the JasperServer to the "report unit" (i.e.
    #                a bundle consisting of the JRXML file and other
    #                resources used in the report). E.g.: <tt>/example/my-report</tt>
    # output_format :: The desired output format. E.g.: <tt>PDF</tt>, <tt>CSV</tt>, 
    #                  <tt>HTML</tt>, etc.
    # report_params :: Hash of parameters to be fed into the report. The client
    #                  will take care of performing the appropriate type conversions
    #                  (for example, Time values are turned into integer timestamps and
    #                  are automatically adjusted for timezone).
    #                  E.g. <tt>{ 'fruit' => "Apple", 'date' => Time.now}</tt>
    def initialize(report_unit, output_format, report_params = {})
      raise ArgumentError, "Missing output_format in report request!" if output_format.nil? || output_format.empty?
      @report_unit   = report_unit
      @output_format = output_format.upcase
      @report_params = report_params
    end
    
    # Converts the given Time into a timestamp integer acceptable by JasperServer.
    # The timezone adjustment is performed (converted to UTC).
    def self.convert_time_to_jasper_timestamp(time)
      # convert to milisecond timestamp
      ts = time.to_i * 1000
      # adjust for timezone
      ts -= time.utc_offset * 1000
      return ts
    end
    
  end
end
