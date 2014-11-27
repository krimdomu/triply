module Triply
  
  class Dependency_Resolver
   
    require 'yaml'
    require 'fileutils'
    require 'tmpdir'
    require 'digest/md5'
    
    def initialize(opts)
      @app = opts[:app]
      @app.logger.debug "initialized Dependency_Resolver"
    end
    
    def resolve!(file = 'dist.yml')
      deps = Hash.new
      
      if file =~ /Modulefile$/ and ! File.exists?(file)
        @app.logger.info "no Modulefile found. Seems to have no dependencies."
        return
      end
      
      if ! File.exists?(file)
        @app.logger.info "no #{file} found. Looking for Modulefile..."
        
        module_file_path = File.expand_path(File.join(file, '..', 'Modulefile'))
        @app.logger.debug "looking for modulefile at #{module_file_path}"
        
        if File.exists?(module_file_path)
          @app.logger.debug "found modulefile #{module_file_path}"
          deps = get_deps_from_modulefile module_file_path
        end
      else
        deps = get_deps file
      end
      
      @app.logger.debug "got deps:"
      @app.logger.debug deps
      
      begin
        @app.logger.debug "resolving dependencies for #{file}"
        iterate_deps deps
      rescue => e
        p e.message
        p e.backtrace
      end
    end
    
    def get_deps_from_modulefile(file)
      @app.logger.debug "try to read deps from Modulefile #{file}"
      
      # shameless stolen from librarian-puppet
      ret = Hash.new
      File.read(file).lines.each do |line|
        line.chomp!
        regexp = /^\s*dependency\s+('|")([^'"]+)\1\s*(?:,\s*('|")([^'"]+)\3)?/
        if regexp =~ line
          @app.logger.debug "found line: #{line} (#{$2} / #{$4})"
          # rewrite to internal git
          module_name      = get_module_name $2
          git_path         = get_module_git_path $2
          @app.logger.debug "converted module #{module_name} to: #{git_path}"
          ret[module_name] = {
            'url'    => git_path,
            'branch' => 'master'
          }
        end
      end
      
      ret
    end
    
    def get_module_name(puppet_module_name)
      puppet_module_name.split('/')[1]
    end
    
    def get_module_git_path(puppet_module_name)
      module_name = puppet_module_name.gsub /\//, '-'
      "#{@app.config.git_url}/#{module_name}.git"
    end
    
    def get_deps(file)
      @app.logger.debug "reading yaml file #{file}"
      
      ref = YAML.load_file file
      if ! ref.has_key?('puppet-modules')
        @app.logger.info "no puppet module dependencies defined."
        return
      end

      if ! ref['puppet-modules'].has_key?(@app.config.environment)
        @app.logger.info "no puppet module dependencies defined for environment #{@app.config.environment}."
        return
      end
      
      modules = ref['puppet-modules'][@app.config.environment]
      return modules
    end
    
    def iterate_deps(deps)
      @app.logger.debug "iterating over all deps:"
      deps.each do |name, git|
        @app.logger.debug "   -> #{name}"
        if ! File.exists? "#{@app.config.module_path}/#{name}"
          checkout_repo name, git
        elsif File.exists? "#{@app.config.module_path}/#{name}/.git"
          update_repo name
        end
      end
    end
    
    def update_repo(name)
      @app.logger.debug "updating #{name}"
      
      Dir.chdir("#{@app.config.module_path}/#{name}") do
        %x{git pull origin}
      end
      
      resolve_module_deps name
    end
    
    def checkout_repo(name, _git)
      @app.logger.debug "checking out repository: #{name}"
      
      git    = _git
      branch = "master"
      sparse = nil
      local_copy = nil
      
      if _git.class.to_s == "Hash"
        git    = _git['url']
        branch = _git['branch'] || "master"
        if _git.has_key?('sparse')
          sparse = _git['sparse']
        end
        if _git.has_key?('path')
          local_copy = _git['path']
        end
      end
      
      if sparse
        # this is a sparse checkout, so checkout mighty sourcetree to tmp and
        # copy over the files
        tmp_dir = "#{Pathname.new(Dir.tmpdir).join(Digest::MD5.hexdigest(git))}"
        @app.logger.debug "creating tmp directory: #{tmp_dir}"
        
        unless File.exists?(tmp_dir)
          FileUtils.mkdir_p tmp_dir
        end
        
        target_module_path = File.expand_path(File.join(@app.config.module_path, name))
        
        Dir.chdir(tmp_dir) do
          %x{git init .}
          %x{git remote add origin #{git}}
          %x{git fetch origin}
          %x{git checkout origin/#{branch}}
          FileUtils.mkdir_p @app.config.module_path
          @app.logger.debug "copying #{sparse} -> #{target_module_path}"
          FileUtils.cp_r sparse, "#{target_module_path}"
        end
      elsif local_copy
        target_module_path = File.expand_path(File.join(@app.config.module_path, name))
        FileUtils.mkdir_p @app.config.module_path
        
        @app.logger.debug "copying #{local_copy} -> #{target_module_path}"
        FileUtils.cp_r local_copy, "#{target_module_path}"
      else

        @app.logger.debug "creating directory: #{@app.config.module_path}"
        FileUtils.mkdir_p @app.config.module_path
        cmd = "git clone #{git} -b #{branch} #{@app.config.module_path}/#{name}"
        @app.logger.debug "running: #{cmd}"
        %x{#{cmd}}
        
 
      end
      
      resolve_module_deps name
    end
    
    def resolve_module_deps(name)
      # get deps recursive deps
      resolve!("#{@app.config.module_path}/#{name}/dist.yml")
    end
  
  end
  
end
