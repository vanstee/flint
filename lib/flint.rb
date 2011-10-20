require 'rubygems'
require 'em-http'
require 'active_support'
require 'json'

require 'flint/client'
require 'flint/dsl'
require 'flint/version'

include Flint::DSL

at_exit { client.run }