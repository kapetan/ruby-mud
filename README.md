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
  
This includes a Rails after filter which checks all responses for dependencies and inserts them into the document just after the `<head>` tag (or raises a ResolveError if a required module is not installed). Mud looks for modules in `public/javascripts/js_modules` and the global module directory. This is not meant to be used in production environment only for development.

There are a couple Rake tasks defined which can be used to prepare the javascript modules for the production environment. These include

    rake mud:dependencies

Which by default lists all dependencies for files in the javascripts directory. It is also possible to specify which files should be checked for dependencies, by giving the path to the directory as the first argument to the task.

    rake mud:build
    
As with `mud:dependencies` it checks the files in the javascripts directory. This can also be changed as mentioned above. Every file in the directory is checked for dependencies and these are then compiled and saved in `public/javascripts/mud`.
  
## Rack

Rack middleware is also available. Add something like the following to the `config.ru` file

    require 'mud/integrations/rack'
    use Mud::Integrations::Rack if ENV['RACK_ENV'] == 'development'
    
## License 

**This software is licensed under "MIT"**

> Copyright (c) 2012 Mirza Kapetanovic
> 
> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
> 
> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
> 
> THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

