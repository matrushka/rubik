require 'mustache'

module Rubik
  class Script
    class << self
      def [](script_name)
        Rubik::Script.new script_name
      end
    end

    def initialize script_name
      @script_name = script_name
      @template = IO.read(Rubik.root + "/lua/" + script_name.to_s + ".lua")
    end

    def run hash
      Rubik.check_redis
      contents = Mustache.render @template, hash
      Rubik.redis.eval(contents)
    end
  end
end