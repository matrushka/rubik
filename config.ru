require './test/boot'
require 'rubik/server'


use Rack::Deflater
run Rack::URLMap.new('/rubik' => Rubik::Server)
