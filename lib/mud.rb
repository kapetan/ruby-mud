$:.unshift File.expand_path(File.dirname(__FILE__))

require 'fileutils'
require 'net/http'
require 'uri'
require 'json'
require 'erb'
require 'rbconfig'

require 'sinatra/base'
require 'thor'
require 'hpricot'

module Mud
  require 'mud/utils'
  extend Mud::Utils
end

%w(api exceptions context dependency js_result html_result module installed_module).each { |f| require "mud/#{f}" }