Gem::Specification.new do |s|
  s.name = %q{jasperserver-client}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matt Zukowski"]
  s.date = %q{2010-04-27}
  s.description = %q{Ruby-based client for JasperServer. Allows for requesting and fetching reports using Ruby from a networked JasperServer over SOAP.}
  s.email = ["matt@zukowski.ca"]
  s.extra_rdoc_files = ["History.txt", "License.txt", "Manifest.txt", "README.rdoc"]
  s.files = ["History.txt", "License.txt", "Manifest.txt", "README.rdoc", "Rakefile", "config/hoe.rb", "config/requirements.rb", "init.rb", "lib/jasper_server/client.rb", "lib/jasper_server/error.rb", "lib/jasper_server/protocols/basic.rb", "lib/jasper_server/protocols/soap.rb", "lib/jasper_server/protocols/soap_monkeypatch.rb", "lib/jasper_server/report_request.rb", "lib/jasper_server/version.rb", "lib/jasperserver-client.rb", "script/console", "script/destroy", "script/generate", "script/txt2html", "setup.rb", "tasks/deployment.rake", "tasks/environment.rake", "tasks/website.rake", "test/test_helper.rb", "test/test_jasperserver-client.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://jasper-client.rubyforge.org}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{jasper-client}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Ruby-based client for JasperServer.}
  s.test_files = ["test/test_jasperserver-client.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_development_dependency(%q<hoe>, [">= 1.7.0"])
    else
      s.add_dependency(%q<hoe>, [">= 1.7.0"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.7.0"])
  end
end
