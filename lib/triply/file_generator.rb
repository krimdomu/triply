module Triply
  class File_Generator
    require 'yaml'
    
    def initialize(opts)
      @app = opts[:app]
    end
    
    def modulefile!(opts = Hash.new)
      file      = opts[:modulefile]  || 'Modulefile'
      dist_file = opts[:distfile]    || 'dist.yml'
      env       = opts[:environment] || 'release'
      
      @app.logger.debug "reading information from #{dist_file}"
      
      dist = YAML.load_file dist_file
      
      @app.logger.debug "writing module file #{file}"
      
      File.open(file, 'w') do |file|
        file.write "name '#{dist['name']}'\n"
        file.write "version '#{dist['version']}'\n"
        file.write "source '#{dist['source']}'\n" if dist.has_key?('source')
        file.write "author '#{dist['author']}'\n" if dist.has_key?('author')
        file.write "license '#{dist['license']}'\n" if dist.has_key?('license')
        file.write "summary '#{dist['summary']}'\n" if dist.has_key?('summary')
        file.write "description '#{dist['description']}'\n" if dist.has_key?('description')
        file.write "project_page '#{dist['project_page']}'\n" if dist.has_key?('project_page')
        
        dist['puppet-modules'][env].each do |name, opt|
          if opt.has_key?('version')
            file.write "dependency '#{opt['module']}', '#{opt['version']}'\n"
          else
            file.write "dependency '#{opt['module']}'\n"
          end        
        end
      end

    end
  end
end
