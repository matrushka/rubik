# Prequisities
require 'rubygems'
require 'bundler'
# Load gems
Bundler.require(:default, :development)
# Configure redis
$redis = Redis.new
require 'awesome_print'