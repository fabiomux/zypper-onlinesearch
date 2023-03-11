# frozen_string_literal: true

require "iniparse"

module Zypper
  module Onlinesearch
    #
    # Current release classification.
    #
    class Release
      def initialize
        @filename = File.exist?("/etc/SuSE-release") ? "/etc/SuSE-release" : "/etc/os-release"
        @ini = IniParse.parse(File.read(@filename))
      end

      def name
        ini["NAME"].delete('"')
      end

      def version
        ini["VERSION"].delete('"')
      end

      def id
        ini["ID"].delete('"')
      end

      def pretty_name
        ini["PRETTY_NAME"].delete('"')
      end

      def arch
        `uname -i`.strip.chomp.to_sym
      end

      private

      def ini
        @ini["__anonymous__"]
      end
    end
  end
end
