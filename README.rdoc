= JasperServer-Client

* http://jasper-client.rubyforge.org
* http://github.com/gunark/jasperserver-client

== DESCRIPTION:

JasperServer-Client is -- you guessed it -- a Ruby-based client for JasperServer. 
The library allows for requesting and fetching reports from a networked JasperServer over SOAP.

== USAGE:

Here we request a report to be generated in PDF format and then save the resulting data
to a local file:

  # Create a new client instance for the JasperServer running at 
  # http://example.com/jasperserver
  client = JasperServer::Client.new("http://example.com/jasperserver/services/repository",
                                    "jasperadmin", "secret!")
                                    
  # Create a request for a report. The first parameter is the full path of the 
  # report unit, the second is the desired output format, and the last is an 
  # optional hash of parameters to be fed into the report.
  request = JasperServer::Request.new("/example/my-report", "PDF", {'fruit' => 'apple'})
  
  # Send the report request to the server and return the output data.
  pdf_data = client.request_report(request)
  
  # Write the report data to a file (instead you could send the data to the user's
  # browser if you're doing this in, for example, a Rails controller action).
  File.open('/tmp/report.pdf', 'w') do |f|
    f.puts(pdf_data)
  end

== REQUIREMENTS:

* A Ruby interpreter.
* The *soap4r* gem, version 1.5.8 or greater. (This should be automatically
  installed as a dependency; otherwise run <tt>gem install soap4r</tt>.)
* A running JasperServer instance. The client has been tested  with versions 2.0 through 
  to 3.0 of JasperServer.

== INSTALL:

* Via RubyGems: 
    gem install jasperserver-client

== LICENSE:

JasperServer-Client is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published 
by the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.


JasperServer-Client is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
