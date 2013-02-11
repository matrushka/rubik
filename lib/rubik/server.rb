require 'sinatra'
require 'awesome_print'
require 'active_support/core_ext/object'
require 'active_support/core_ext/string'
require 'digest/sha1'

module Rubik
  class Server < Sinatra::Base

    helpers do
      def url
        request.script_name
      end
    end

    def parse expression
      expression.match(/^([a-z]+)\((.*)\)$/).to_a[1,2]
    end

    get '/1.0/metric' do
      # JSON headers
      content_type 'application/json', :charset => 'utf-8'
      # Get expression, start, stop and step
      fn, key = parse(params[:expression])
      start   = params[:start].try(:to_time).to_i
      stop    = params[:stop].try(:to_time).to_i
      step    = params[:step].try(:to_i) / 1000

      # Prepare the result hash
      response = []
      Rubik.query(key, start, stop, step).each do |time, values|
        if values.empty?
          response << { time: time, value: 0 }
        else
          case fn
          when "sum"
            response << { time: time, value: values.inject{|sum,x| sum + x } }
          when "avg"
            response << { time: time, value: values.inject{|sum,x| sum + x } / values.length }
          end
        end
      end
      # Render JSON
      MultiJson.dump(response)
    end

    get '/1.0/types' do
      # JSON headers
      content_type 'application/json', :charset => 'utf-8'
      # Return metrics
      MultiJson.dump(Rubik.metrics)
    end

    get '/assets/:asset' do
      expires 3600, :public, :must_revalidate
      filename = params[:asset]
      case File.extname filename
      when ".css"
        content_type 'text/css', :charset => 'utf-8'
      when ".js"
        content_type 'application/javascript', :charset => 'utf-8'
      end
      @cache ||= {}
      begin
        if @cache[filename].nil?
          file = IO.read(Rubik.root + "/assets/" + File.basename(params[:asset]))
          @cache[filename] = {
            contents: file,
            digest: Digest::SHA1.hexdigest(file)
          }
        end
        etag @cache[filename][:digest], :weak
        @cache[filename][:contents]
      rescue
        404
      end
    end

    get '/' do
      expires 3600, :public, :must_revalidate
      content_type 'text/html', :charset => 'utf-8'
      # Fetch the dashboard html
      if @html.nil?
        raw_html = IO.read(Rubik.root + "/assets/dashboard.html")
        @html = Mustache.render raw_html, { url: url }
        @digest = Digest::SHA1.hexdigest @html
      end
      # HTTP headers (CACHEABLE)
      etag @digest, :weak
      # Render
      @html
    end
  end
end