lib_path = File.expand_path(File.join(__FILE__, '..', '..', 'lib'))
$: << lib_path

require 'triply'
require 'logger'

Triply.config do |c|
  c.module_path = "vendor/modules"
  c.environment = "test"
  c.logger = Logger.new(STDERR)
  c.git_url = "gitlab@gitlab.xxx.com:yyy"
end

Triply.resolve!

#Triply.generate_files!
