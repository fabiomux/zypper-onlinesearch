require 'fileutils'
require 'uri'

module Zypper
  module Onlinesearch

    class Cache

      def initialize(operation, engine)
        @base_folder = File.join(ENV['HOME'], '.cache', 'zypper-onlinesearch', engine, operation)
        FileUtils.mkdir_p @base_folder unless Dir.exists? @base_folder
      end

      def set(query, response)
        File.open(File.join(@base_folder, query_to_filename(query)), 'w+') do |f|
          f.write Marshal.dump(response)
        end
      end

      def get(query)
        fname = query_to_filename(query)
        Marshal.load(File.read(File.join(@base_folder, fname))) if exists? query
      end

      def exists?(query)
        File.exists?(File.join(@base_folder, query_to_filename(query)))
      end

      def self.reset!
        base_folder = File.join(ENV['HOME'], '.cache', 'zypper-onlinesearch')
        if Dir.exist? base_folder
          size = Dir.glob(File.join(base_folder, '**', '*')).map{ |f| File.size(f) }.inject(:+)
          FileUtils.remove_dir base_folder
          return size
        else
          raise EmptyCache
        end
      end

      def mtime(query)
        fname = File.join(@base_folder, query_to_filename(query))
        File.mtime(fname) if File.exist? fname
      end

      private

      def query_to_filename(query)
        URI.encode query.delete('./')
      end
    end

  end
end

