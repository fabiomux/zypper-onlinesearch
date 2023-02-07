require 'optparse'
require 'ostruct'
require 'zypper/onlinesearch'
require 'zypper/onlinesearch/version'

module Zypper

  module Onlinesearch

    class OptParseMain

      def self.parse(args)
        options = OpenStruct.new
        options.operation = :search
        options.query = ''
        options.refresh = false
        options.engine = :all # :opensuse, :packman
        options.timeout = 20
        options.formats = :compatible # :all
        options.distributions = :compatible # :all
        options.types = [:supported, :community, :experimental]
        options.number = 0
        options.view = :table
        options.format = :all # or single format
        #options.preload = nil #used by :links or :page operations

        opt_parser = OptionParser.new do |opt|

          if ENV['ZYPPER_ONLINESEARCH']
            opt.banner = 'Usage: zypper onlinesearch [OPTIONS] [OPERATION]'
          else
            opt.banner = 'Usage: zypper-onlinesearch [OPTIONS] [OPERATION]'
          end

          opt.separator ''
          opt.separator 'Operations:'

          opt.on('-s', '--search <STRING>', 'Search for STRING to the online engines available') do |o|
            options.operation = :search
            options.query = o
          end

          opt.on('-p', '--page <PAGE_NAME>', 'Get info about the PAGE_NAME') do |o|
            options.operation = :page
            options.query = o
          end

          opt.on('-l', '--links <PAGE_NAME>,<NTH>', Array, 'Print all the links of the NTH item in the PAGE_NAME') do |o|
            options.operation = :links
            options.query = o[0]
            options.number = o[1].to_i
            #options.preload = :page
          end

          opt.on('--clean-cache', 'Clean the whole cache') do |o|
            options.operation = :cache_clean
          end

          opt.separator ''
          opt.separator 'General Options'

          opt.on('--engine <ENGINE>', 'Use ENGINE to search for (default: ' + options.engine.to_s + ')') do |o|
            options.engine = o.to_sym
          end

          opt.on('--refresh', 'Refresh the cached values.') do |o|
            options.refresh = true
          end

          opt.on('--timeout <SECONDS>', "Adjust the waiting SECONDS used to catch an HTTP Timeout Error (Default: #{options.timeout})") do |o|
            options.timeout = o.to_f
          end

          opt.on('--report', 'Show the results as report') do |o|
            options.view = :report
          end

          opt.separator ''
          opt.separator '"Page" and "Links" options:'

          opt.on('--all-formats', 'Show all the available formats') do |o|
            options.formats = :all
          end

          opt.on('--all-distributions', 'Show all the available distributions') do |o|
            options.distributions = :all
          end

          opt.on('--no-supported', 'Hide supported packages.') do |o|
            options.types.delete :supported
          end

          opt.on('--no-experimental', 'Hide experimental packages.') do |o|
            options.types.delete :experimental
          end

          opt.on('--no-community', 'Hide community packages.') do |o|
            options.types.delete :community
          end

          opt.separator ''
          opt.separator '"Links" options:'

          opt.on('--format FORMAT', 'Filter for packages with the specified FORMAT') do |o|
            options.format = o.to_sym
          end

          opt.on('--urls', 'Show only the urls without headers') do |o|
            options.view = :urls
          end

          unless ENV['ZYPPER_ONLINESEARCH']
            opt.separator ''
            opt.separator 'Other:'

            opt.on_tail('-h', '--help', 'Show this message') do |o|
              puts opt
              exit
            end

            opt.on_tail('-v', '--version', 'Show version') do |o|
              puts VERSION
              exit
            end
          end

        end


        if ARGV.empty?
          puts opt_parser; exit
        else
          opt_parser.parse!(ARGV)
        end

        options
      end
    end


    class CLI
      def self.start
        begin
          options = OptParseMain.parse(ARGV)
          Onlinesearch::Builder.new(options).send(options.operation)
         rescue => e
           Messages.error e
           exit e.error_code
         end
      end
    end

  end
end

