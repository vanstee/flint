$:.push File.expand_path("../lib", __FILE__)

require 'flint'

# stop the eventmachine reactor from running at_exit
class Flint::Client
  def run; end
end