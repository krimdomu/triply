require 'triply'
require 'rake'

namespace :triply do
  desc "resolve and download all dependencies"
  task :dependencies do
    Triply.resolve!
  end
  
  desc "Generate Modulefile and other things from dist.yml"
  task :release do
    Triply.generate_files!
  end
end
