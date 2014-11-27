require 'triply/dependency_resolver'
require 'triply/config'
require 'triply/file_generator'

module Triply
  @config = Triply::Config.new
  
  def self.config
    yield @config if block_given?
    @config
  end
  
  def self.logger
    @config.logger
  end
  
  def self.resolve!
    begin
      Triply::Dependency_Resolver.new(:app => self).resolve!
    rescue => e
      p e.message
      p e.backtrace
    end
  end
  
  def self.generate_files!
    fg = Triply::File_Generator.new(:app => self)
    fg.modulefile!
  end
end
