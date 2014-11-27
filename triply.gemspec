Gem::Specification.new do |s|
  s.name        = 'triply'
  s.version     = '0.2.4'
  s.date        = '2014-04-10'
  s.summary     = "Manage Puppet dependencies"
  s.description = "Small tool to manage puppet dependencies"
  s.authors     = ["Jan Gehring"]
  s.email       = 'jan.gehring@inovex.de'
  s.files       = ["lib/triply.rb", "README.md", "lib/triply/config.rb",
                    "lib/triply/dependency_resolver.rb", "lib/triply/file_generator.rb",
                    "lib/triply/rake.rb"]
  s.homepage    =
    'http://www.inovex.de'
  s.license       = 'internal'
end
