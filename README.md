# triply

With triply you can manage your puppet dependencies. Triply will also iterate 
over all modules you download to install their dependencies as well.

## Installation
```
gem install release/triply-0.1.0.gem
```

## Usage

There is an example script in the *bin* directory.

## Rake

You can also use Triply inside a Rakefile:

```ruby
require 'triply/rake'
require 'logger'

# configure triply
Triply.config do |c|
  c.module_path = "spec/fixtures/modules"
  c.environment = "test"
  c.logger = Logger.new(STDERR)
  c.git_url = "gitlab@gitlab.xxx.com:lxpuppet"
end

# example test task
desc "Run syntax, lint, and spec tests."
task :test => [
  'triply:dependencies',
  :setup,
  :syntax,
  :lint,
  :spec,
  :teardown,
]
```

## Rake Tasks

There are 2 rake tasks. One to resolve and download all dependencies and one to generate the release files (like the Modulefile).

!! Currently only the Modulefile will be generated. !!

```
rake triply:dependencies
rake triply:release
```

# dist.yml

Inside *dist.yml* file you can define all meta data for your module

```
name: ajp_proxy
version: 0.1.0
source: git://gitlab.xxx.com/yyy/ajp_proxy.git
author: zzz
license: internal
summary: Module to create AJP proxies
description: Module to create AJP proxies
project_page: http://www.xxx.com/

puppet-modules:
  test:
    apache: 
      url: "gitlab@gitlab.xxx.com:yyy/puppetlabs-apache.git"
      branch: foo
    sysctl: "gitlab@gitlab.xxx.com:yyy/thias-sysctl.git"
  release:
    apache: 
      module: 'puppetlabs/apache'
      version: '>= 1.2'
    sysctl:
      module: 'thias/sysctl'
```

# Dependeny resolving

Triply first try to read the *dist.yml* file. If this file is found it will read the dependencies for the configured environment.

If the *dist.yml* is not found, it will try to read the *Modulefile*. The dependencies inside the Modulefile will be replaced by git urls defined in the Triply::Config object. (see the example).
Triply will always use the master branch for those dependencies.
