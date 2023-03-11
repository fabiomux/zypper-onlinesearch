# frozen_string_literal: true

require "zypper/onlinesearch/cache"
require "zypper/onlinesearch/request"
require "zypper/onlinesearch/data"
require "zypper/onlinesearch/release"
require "zypper/onlinesearch/utils"
require "zypper/onlinesearch/view"

module Zypper
  module Onlinesearch
    #
    # Facade class for all the operations.
    #
    class Builder
      def initialize(options)
        return unless options.operation != :cache_clean

        @search = RequestList.new operation: options.operation == :links ? :page : options.operation,
                                  engine: options.engine,
                                  timeout: options.timeout,
                                  refresh: options.refresh,
                                  query: options.query
        @release = Release.new
        @formats = options.formats
        @distributions = options.distributions
        @format = options.format
        @types = options.types
        @num = options.number
        @view_class = Zypper::Onlinesearch::View.const_get options.operation.to_s.split("_").map(&:capitalize).join
        @view_class = @view_class.const_get options.view.to_s.capitalize
      end

      def search
        raise QueryStringTooShort, @search.query if @search.query.length < 3

        @search.engines.each do |k, v|
          @view_class.parameters engine: k,
                                 refresh: @search.refresh,
                                 query: @search.query,
                                 cache_time: v.cache_time
          if v.available?
            data = v.to_data
            if data.empty?
              @view_class.no_packages if data.empty?
            else
              @view_class.header first_col: data.max_column(:name)
              data.each_with_index do |i, idx|
                next if @num.positive? && idx.next != @num

                @view_class.package num: idx.next,
                                    name: i[:name],
                                    description: i[:description],
                                    url: i[:url]
              end
            end
          else
            @view_class.no_packages
          end
        end
      end

      def page
        @search.engines.each do |engine, x|
          packages = []
          next unless x.available?

          data = x.to_data
          versions = data[:versions].select { |y| package_select?(y) }
                                    .group_by { |v| "#{v[:repo]}##{v[:distro]}##{v[:version]}" }
          versions.each do |collection|
            collection = collection.pop
            packages << collection.pop
          end
          print_packages(data, packages, first_col: :repo, second_col: :distro, view: :package, engine: engine,
                                         distro: @release.pretty_name, cache_time: x.cache_time)
        end
      end

      def links
        raise MissingItemNumber unless @num.positive?

        @search.engines.each do |engine, x|
          packages = []
          next unless x.available?

          data = x.to_data
          versions = data[:versions].select { |y| package_select?(y) }
                                    .group_by { |v| "#{v[:repo]}##{v[:distro]}#{v[:version]}" }

          versions.each_with_index do |collection, idx|
            next if idx.next != @num

            collection = collection.pop
            collection.each do |pack|
              if (pack[:link] =~ /rpm$/) || (pack[:format] == :ymp)
                packages << pack
              else
                result = RequestList.new operation: :links,
                                         engine: engine,
                                         timeout: @search.timeout,
                                         refresh: @search.refresh,
                                         query: pack[:link]

                result.engines.each do |_k, v|
                  next unless v.available?

                  v.to_data[:versions].each do |f|
                    f[:type] = pack[:type]
                    f[:repo] = pack[:repo]
                    f[:version] ||= pack[:version]
                    f[:distro] ||= pack[:distro]
                    packages << f if package_select?(f)
                  end
                end
              end
            end
          end
          print_packages(data, packages, first_col: :format, second_col: :link, view: :link,
                                         engine: engine, cache_time: x.cache_time)
        end
      end

      def cache_clean
        View::CacheClean.reset Cache.reset!
      end

      private

      def print_packages(data, packages, args)
        @view_class.general name: data[:name] || @search.query,
                            short_description: data[:short_description] || "",
                            description: data[:description] || "",
                            engine: args[:engine],
                            distro: @distributions == :compatible ? @release.pretty_name : "All",
                            architecture: architecture,
                            refresh: @search.refresh,
                            cache_time: args[:cache_time]

        if packages.count.positive?
          @view_class.header first_col: packages.max_column(args[:first_col]),
                             second_col: packages.max_column(args[:second_col])

          packages.each_with_index do |pack, idx|
            @view_class.send args[:view], { num: idx.next, pack: pack, args: args }
          end
        else
          @view_class.no_packages(!data[:versions].empty?)
        end
      end

      def pretty_name
        @distributions == :compatible ? @release.pretty_name : "All"
      end

      def architecture
        @formats == :compatible ? @release.arch : :all
      end

      def package_select?(package)
        res = true
        res = [:ymp, :src, :extra, @release.arch].include?(package[:format]) if @formats == :compatible
        res &&= (@format == package[:format]) unless @format == :all
        if @distributions == :compatible
          res &&= ((package[:distro] == :current) ||
                   package[:distro].match?(Regexp.new(@release.pretty_name, "i")))
        end
        res = false unless @types.include?(package[:type])

        res
      end
    end
  end
end
