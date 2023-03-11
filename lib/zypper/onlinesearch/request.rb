# frozen_string_literal: true

require "net/http"
require "uri"

module Zypper
  module Onlinesearch
    #
    # Handles the list of requests.
    #
    class RequestList
      attr_reader :engines, :refresh, :timeout, :query

      def initialize(args)
        @engines = {}
        @refresh = args[:refresh]
        @timeout = args[:timeout]
        @query = args[:query]
        m = Request.const_get(args[:operation].to_s.capitalize)

        if args[:engine] == :all
          m.constants.each do |k|
            @engines[k.to_s.downcase] = m.const_get(k).new(args[:query], args[:refresh], args[:timeout])
          end
        else
          klass = args[:engine].to_s.capitalize.to_sym
          raise InvalidEngine, args[:engine] unless m.constants.include? klass

          @engines[args[:engine].to_s.downcase] = m.const_get(klass).new(args[:query], args[:refresh], args[:timeout])
        end
      end

      def self.class?(operation, engine)
        Request.const_get(operation.to_s.capitalize).constants.include?(engine.to_s.capitalize.to_sym)
      end
    end

    #
    # The single page request.
    #
    class PageRequest
      attr_reader :page

      USER_AGENT = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0"

      def initialize(query, refresh, timeout = 60, cookies = [])
        @query = query.strip
        @cache = Cache.new(*self.class.to_s.split("::")[-2..].map(&:downcase))
        @refresh = refresh
        @cookies = cookies
        @timeout = timeout
      end

      def available?
        ping.is_a?(Net::HTTPSuccess)
      end

      def redirected?
        ping.is_a?(Net::HTTPRedirection)
      end

      def redirected_to
        ping["location"]
      end

      def not_found?
        ping.is_a?(Net::HTTPNotFound)
      end

      def forbidden?
        ping.is_a?(Net::HTTPForbidden)
      end

      def timeout?
        ping.is_a?(Net::HTTPRequestTimeOut)
      end

      def status
        ping.class.to_s
      end

      def cache!
        @page = nil
      end

      def to_data
        klass = self.class.to_s.split("::")[-2..]
        Data.const_get(klass[0].to_sym).const_get(klass[1].to_sym).new(@page.body).data
      end

      def cache_time
        @cache.mtime(@query) if @query
      end

      private

      def get_request(request_uri = nil, limit = 10)
        request_uri = if request_uri
                        request_uri =~ %r{://} ? URI(request_uri).request_uri : request_uri
                      else
                        uri.request_uri
                      end

        request = Net::HTTP::Get.new(request_uri)
        request["User-Agent"] = USER_AGENT
        request["Cookie"] = @cookies.join(";") unless @cookies.empty?

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")
        http.open_timeout = @timeout

        res = http.request(request)

        if res.is_a? Net::HTTPRedirection
          raise TooManyRedirections, uri.to_s if limit.negative?

          res = get_request(res["location"], limit - 1)
        end

        res
      end

      def ping(force: false)
        begin
          @page = @cache.get(@query) unless @refresh
          if @page.nil? || force
            @page = get_request
            @cache.set(@query, @page)
          end
        rescue SocketError
          raise NoConnection
        rescue Net::OpenTimeout
          @page = Net::HTTPRequestTimeOut.new("1.1", "", "")
        end
        @page
      end
    end

    module Request
      module Search
        #
        # Handles the search on openSUSE.
        #
        class Opensuse < PageRequest
          URL = "https://software.opensuse.org/search"

          def initialize(query, cache, timeout, cookies = [])
            super query, cache, timeout,
                  cookies << "baseproject=ALL;search_devel=true;search_debug=false;search_lang=false"
          end

          def uri
            u = URI(URL)
            u.query = URI.encode_www_form(q: @query)
            u
          end
        end

        #
        # Handles the search on Packman.
        #
        class Packman < PageRequest
          URL = "http://packman.links2linux.org/search"

          def uri
            u = URI(URL)
            u.query = URI.encode_www_form({ q: @query, scope: "name" })
            u
          end
        end
      end

      module Page
        #
        # Handle the page on openSUSE.
        #
        class Opensuse < PageRequest
          URL = "https://software.opensuse.org/package/"

          def initialize(query, cache, timeout, cookies = [])
            super query, cache, timeout,
                  cookies << "baseproject=ALL;search_devel=true;search_debug=false;search_lang=false"
          end

          def uri
            URI(URL + URI.encode(@query))
          end
        end

        #
        # Handle the page on Packman.
        #
        class Packman < PageRequest
          URL = "http://packman.links2linux.org/package/"

          def uri
            URI(URL + URI.encode(@query))
          end
        end
      end

      module Links
        #
        # Handles the links on openSUSE
        #
        class Opensuse < PageRequest
          URL = "https://software.opensuse.org/download/package"

          def initialize(query, refresh, timeout = 60, cookies = [])
            query = URI(query).query
            super query, refresh, timeout, cookies
          end

          def uri
            URI(@query =~ %r{://} ? @query : "#{URL}?#{@query}")
          end
        end

        #
        # Handles the links on Packman.
        #
        class Packman < PageRequest
          URL = "http://packman.links2linux.org/package/"

          def initialize(query, refresh, timeout = 60, cookies = [])
            query = query.split("/")[-2..].join("/") if query =~ %r{://}
            super query, refresh, timeout, cookies
          end

          def uri
            URI(@query =~ %r{://} ? @query : "#{URL}#{URI.encode(@query)}")
          end
        end
      end
    end
  end
end
