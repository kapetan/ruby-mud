$:.unshift File.expand_path(File.dirname(__FILE__))

#require 'active_support/core_ext'

require 'sinatra/base'
require 'thor'
require 'hpricot'

require 'net/http'
require 'uri'
require 'json'
require 'erb'

%w(utils context dependency js_result html_result module installed_module server).each { |f| require "mud/#{f}" }

module Mud
  extend Mud::Utils
end
