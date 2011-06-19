Ruby port of Mud (package manager for client-side Javascript). See [http://github.com/mafintosh/mud](http://github.com/mafintosh/mud) for documentation. Ruby-mud's command line interface follows the same conventions as those of Javascript Mud. Usage information can be obtained by running `$ mud help` after installation.

## Install

Ruby-mud is available through RubyGems:

### Gem

    $ gem install mud

### Bundler

Add following line to the project's Gemfile

    gem 'mud'

## Dependencies

* hpricot 0.8.4
* sinatra 1.1.2
* thor 0.14.6

## Rails

Mud can be used with Rails for developing javascript modules. Add following line to the Gemfile

  gem 'mud', :require => 'mud/integrations/rails'
  
This includes a Rack module which checks all responses for dependencies and inserts them into the document just after the `<head>` tag (or raises a ResolveError if a required module is not installed). Mud looks for modules in `public/javascripts/js_modules` and the global module directory. This is not meant for production environment only for development.
  
The same middleware can be used in other Rack environments. Add something like the following to the `config.ru` file

  require 'mud/integrations/rack'
  use Mud::Integrations::Rack if ENV['RACK_ENV'] == 'development'


