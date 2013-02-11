require "./lib/version"
require 'active_support/concern'
require 'redis'
require 'multi_json'

module Rubik
  extend ActiveSupport::Concern

  class << self
    SAMPLE_SIZE = 500
    attr_accessor :redis

    def check_redis
      self.redis = $redis if defined?($redis) and self.redis.nil?
      raise "Invalid redis instance for Rubik. Please configure before tracking." if self.redis.nil?
      return true
    end

    def query key, start , stop , step = 10
      raise "Minimum step can be 10" if step < 10
      values = parse(Rubik::Script[:filter].run(key: key, start: start, stop: stop))
      result = {}

      (start..stop).step(step) do |i|
        result[i] = []
        time = Time.at(i).utc
        values.delete_if do |t, v|
          condition = ((t >= i) and t < (i+step))
          result[i] << v if condition
          condition
        end
      end

      result
    end

    def root
      File.expand_path(File.dirname(__FILE__) + '/../')
    end


    def parse dump
      bucket = {}
      dump.each do |string|
        row = MultiJson.load(string, symbolize_keys: true)
        bucket[row[:t].to_i] = row[:v].to_f
      end
      bucket
    end

    def reset
      check_redis
      metrics.each do |metric|
        redis.del "rubik:metrics:#{metric}"
        redis.srem "rubik:metrics", metric
      end
    end

    def stepped_time time
      # LOWER THE COLLECTION RESOLUTION TO 10 SEC
      time - ( time % 100 )
    end

    def push key, value
      check_redis
      timestamp = Time.now.utc.to_i
      # Add the metric to metric set
      self.redis.sadd "rubik:metrics", key
      # Check if there is an event at the same spot
      self.redis.lpush "rubik:metrics:#{key}", MultiJson.dump({ t: timestamp, v: value })
      self.redis.ltrim "rubik:metrics:#{key}", 0, SAMPLE_SIZE
      return timestamp
    end

    def history key
      check_redis
      parse(self.redis.lrange("rubik:metrics:#{key}", 0, -1))
    end

    def metrics
      check_redis
      self.redis.smembers "rubik:metrics"
    end
  end

  included do |base|
    base.trackable_methods ||= []
    base.tracked_methods ||= []
  end

  module ClassMethods
    attr_accessor :trackable_methods, :tracked_methods

    def track_method method
      self.trackable_methods ||= []
      self.tracked_methods ||= []
      self.trackable_methods << method
    end

    private
    def trackable_method_key method
      self.name + "." + method.to_s
    end

    def method_hookable? method
      instance_methods.include?(method) && !self.trackable_methods.include?(method)
    end

    def method_added method
      if !self.tracked_methods.include?(method) and self.trackable_methods.include?(method)
        self.tracked_methods << self.trackable_methods.delete(method)
        hook_method method
      end
    end

    def hook_method method
      hooked_method_name = "#{method.to_s}_without_tracking"
      alias_method hooked_method_name, method
      private hooked_method_name
      method_key = trackable_method_key(method)
      define_method method do |*args|
        start = Time.now.to_f
        return_value = __send__ hooked_method_name, *args
        delta = ((Time.now.to_f - start) * 1000).ceil
        Rubik.push method_key, delta
        return return_value
      end
    end
  end
end

require 'rubik/script'