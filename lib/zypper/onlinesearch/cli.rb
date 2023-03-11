# frozen_string_literal: true

require "optparse"
require "ostruct"
require "zypper/onlinesearch"
require "zypper/onlinesearch/version"

module Zypper
  module Onlinesearch
    #
    # Parsing the input data.
    #
    class OptParseMain
      def self.parse(args)
        options = Struct.new
        options.operation = :search
        options.query = ""
        options.refresh = false
        options.engine = :all # :opensuse, :packman
        options.timeout = 20
        options.formats = :compatible # :all
        options.distributions = :compatible # :all
        options.types = %i[supported community experimental]
        options.number = 0
        options.view = :table
        options.format = :all # or single format
        # options.preload = nil #used by :links or :page operations

        opt_parser = OptionParser.new do |opt|
          command = ENV["ZYPPER_ONLINESEARCH"] ? "zypper onlinesearch" : "onlinesearch"
          opt.banner = "Usage: #{command} [OPTIONS] [OPERATION]"

          opt.separator ""
          opt.separator "Operations:"

          opt.on("-s", "--search <STRING>", "Search for STRING to the online engines available") do |o|
            options.operation = :search
            options.query = o
          end

          opt.on("-p", "--page <PAGE_NAME>", "Get info about the PAGE_NAME") do |o|
            options.operation = :page
            options.query = o
          end

          opt.on("-l", "--links <PAGE_NAME>,<NTH>", Array,
                 "Print all the links of the NTH item in the PAGE_NAME") do |o|
            options.operation = :links
            options.query = o[0]
            options.number = o[1].to_i
            # options.preload = :page
          end

          opt.on("--clean-cache", "Clean the whole cache") do
            options.operation = :cache_clean
          end

          opt.separator ""
          opt.separator "General Options"

          alt = Request::Search.constants.map(&:to_s).map(&:downcase).join(", ")
          opt.on("--engine <ENGINE>",
                 "Use only ENGINE to search for (default: #{options.engine}, alternatives: #{alt})") do |o|
            options.engine = o.to_sym
          end

          opt.on("--refresh", "Refresh the cached values.") do
            options.refresh = true
          end

          opt.on("--timeout <SECONDS>", "The SECONDS before an HTTP Timeout Error (Default: #{options.timeout})") do |o|
            options.timeout = o.to_f
          end

          opt.separator ""
          opt.separator "View options:"

          opt.on("--table", "Show the results as a table [DEFAULT]") do
            options.view = :table
          end

          opt.on("--report", "Show the results as report") do
            options.view = :report
          end

          opt.separator ""
          opt.separator '"Page" and "Links" options:'

          opt.on("--all-formats", "Show all the available formats") do
            options.formats = :all
          end

          opt.on("--all-distributions", "Show all the available distributions") do
            options.distributions = :all
          end

          opt.on("--no-supported", "Hide supported packages.") do
            options.types.delete :supported
          end

          opt.on("--no-experimental", "Hide experimental packages.") do
            options.types.delete :experimental
          end

          opt.on("--no-community", "Hide community packages.") do
            options.types.delete :community
          end

          opt.separator ""
          opt.separator '"Links" options:'

          opt.on("--format FORMAT", "Filter for packages with the specified FORMAT") do |o|
            options.format = o.to_sym
          end

          opt.on("--urls", "Show only the urls without headers") do
            options.view = :urls
          end

          unless ENV["ZYPPER_ONLINESEARCH"]
            opt.separator ""
            opt.separator "Other:"

            opt.on_tail("-h", "--help", "Show this message") do
              puts opt
              exit
            end

            opt.on_tail("-v", "--version", "Show version") do
              puts VERSION
              exit
            end
          end
        end

        if ARGV.empty?
          puts opt_parser
          exit
        else
          opt_parser.parse!(args)
        end

        options
      end
    end

    #
    # Interface class to run the application.
    #
    class CLI
      def self.start
        options = OptParseMain.parse(ARGV)
        Onlinesearch::Builder.new(options).send(options.operation)
      rescue StandardError => e
        Messages.error e
        exit e.error_code
      end
    end
  end
end
