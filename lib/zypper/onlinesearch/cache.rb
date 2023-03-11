# frozen_string_literal: true

require "fileutils"
require "uri"

module Zypper
  module Onlinesearch
    #
    # Handles the cached data.
    #
    class Cache
      def initialize(operation, engine)
        @base_folder = File.join(Dir.home, ".cache", "zypper-onlinesearch", engine, operation)
        FileUtils.mkdir_p @base_folder
      end

      def set(query, response)
        File.write(File.join(@base_folder, query_to_filename(query)), Marshal.dump(response))
      end

      def get(query)
        fname = query_to_filename(query)
        Marshal.load(File.read(File.join(@base_folder, fname))) if exist? query
      end

      def exist?(query)
        File.exist?(File.join(@base_folder, query_to_filename(query)))
      end

      def self.reset!
        base_folder = File.join(Dir.home, ".cache", "zypper-onlinesearch")
        raise EmptyCache unless Dir.exist? base_folder

        size = Dir.glob(File.join(base_folder, "**", "*")).map { |f| File.size(f) }.inject(:+)
        FileUtils.remove_dir base_folder
        size
      end

      def mtime(query)
        fname = File.join(@base_folder, query_to_filename(query))
        File.mtime(fname) if File.exist? fname
      end

      private

      def query_to_filename(query)
        URI.encode query.delete("./")
      end
    end
  end
end
