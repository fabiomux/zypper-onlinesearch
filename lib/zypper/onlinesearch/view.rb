# frozen_string_literal: true

module Zypper
  module Onlinesearch
    module View
      TYPE_COLORS = { experimental: :yellow, supported: :green, community: :red }.freeze
      SEPARATOR_LENGTH = 100

      #
      # Cache clean view.
      #
      class CacheClean
        def self.reset(size)
          puts "Cache cleared! #{size.to_f.to_human.bold.red} freed."
        end
      end

      module Search
        #
        # Common methods for the search operation.
        #
        class Common
          def self.separator
            puts "-" * SEPARATOR_LENGTH
          end

          def self.no_packages
            puts "#{" " * 3} - | No packages found!"
            separator
          end

          def self.no_compatible_packages
            puts "#{" " * 3} - | No compatible packages found!"
            separator
          end

          def self.parameters(args)
            engine = args[:engine].bold.red
            query = args[:query].bold
            cache = if args[:refresh]
                      "Off".bold
                    elsif args[:cache_time]
                      "#{"On".bold.yellow} (#{args[:cache_time].strftime("%Y-%m-%d %H:%M")})"
                    else
                      "#{"On".bold.yellow} (Now)"
                    end

            puts ""
            puts "=" * SEPARATOR_LENGTH
            puts "#{"Parameters:".bold} Engine: #{engine} | Query: #{query} | Cache: #{cache}"
            puts "=" * SEPARATOR_LENGTH
          end
        end

        #
        # Report view for the search operation.
        #
        class Report < Common
          def self.header(_args)
            puts "#{" " * 3} # | Info"
            separator
          end

          def self.package(args)
            name = args[:name]
            name = if name =~ / /
                     name.split.map.with_index do |x, i|
                       x = x.bold if i.zero?
                       x
                     end.join " "
                   else
                     name.bold
                   end

            puts "#{" " * (5 - args[:num].to_s.length)}#{args[:num]} | Page: #{name}"
            puts "#{" " * 5} | Description: #{args[:description]}"
            separator
          end
        end

        #
        # Table view for search operation.
        #
        class Table < Common
          def self.header(args)
            @@first_col = args[:first_col]
            nl = (args[:first_col] - 4) / 2

            puts "#{" " * 4}# | #{" " * nl} Page#{" " * nl} | Description"
            separator
          end

          def self.package(args)
            name = args[:name]
            name = if name =~ / /
                     name.split.map.with_index do |x, i|
                       x = x.bold if i.zero?
                       x
                     end.join " "
                   else
                     name.bold
                   end

            nl = 5 - args[:num].to_s.length
            fl = @@first_col - args[:name].length
            puts "#{" " * nl}#{args[:num]} | #{name}#{" " * fl} | #{args[:description]}"
            separator
          end
        end

        class Urls < Table
        end
      end

      module Page
        #
        # Common view elements for page operation.
        #
        class Common
          def self.separator
            puts "-" * SEPARATOR_LENGTH
          end

          def self.general(args)
            engine = args[:engine].bold.red
            distro = args[:distro].bold.blue
            arch = PageData::FORMATS[args[:architecture]].bold
            cache = if args[:refresh]
                      "Off".bold
                    elsif args[:cache_time]
                      "#{"On".bold.yellow} (#{args[:cache_time].strftime("%Y-%m-%d %H:%M")})"
                    else
                      "#{"On".bold.yellow} (Now)"
                    end

            puts ""
            puts "=" * SEPARATOR_LENGTH
            puts "#{"Parameters: ".bold} Engine: #{engine} | OS: #{distro} | Architecture: #{arch} | Cache: #{cache}"
            puts "=" * SEPARATOR_LENGTH
            puts "#{"Name:        ".bold}#{args[:name]}"
            puts "#{"Summary:     ".bold}#{args[:short_description]}" if args[:short_description]
            puts "#{"Description: ".bold}#{args[:description].chomp}" if args[:description]
          end

          def self.no_packages(compatible)
            separator
            puts "#{" " * 3} - | No #{compatible ? "compatible" : ""} packages found!"
            separator
          end

          def self.no_item(num)
            separator
            puts "#{" " * 3} - | Invalid item number #{num}"
          end
        end

        #
        # Table view for page operation.
        #
        class Table < Common
          def self.header(args)
            @@first_col = args[:first_col]
            @@second_col = args[:second_col]

            first_col = (args[:first_col] - 4) / 2
            second_col = args[:second_col].positive? ? ((args[:second_col] - 6) / 2) : 0
            np = " " * 3
            fcp = " " * first_col
            scp = " " * second_col

            separator
            if second_col.positive?
              puts "#{np} # | Version | #{fcp}Repo #{fprefix} | #{scp} Distro #{scp}"
            else
              puts "#{np} # | Version | #{fcp}Repo"
            end
            separator
          end

          def self.package(args)
            num = args[:num].to_s.bold.send(TYPE_COLORS[args[:pack][:type]])
            repo = args[:pack][:repo].bold.send(TYPE_COLORS[args[:pack][:type]])
            distro = if args[:args][:distro] == args[:pack][:distro]
                       args[:pack][:distro].bold.blue
                     else
                       args[:pack][:distro]
                     end
            version = args[:pack][:version].to_s[0..6]

            nl = 5 - args[:num].to_s.length
            rl = @@first_col - args[:pack][:repo].to_s.length
            dl = @@second_col.positive? ? @@second_col - args[:pack][:distro].to_s.length : 0
            vl = 7 - version.length

            if @@second_col.positive?
              puts "#{" " * nl}#{num} | #{" " * vl}#{version} | #{repo}#{" " * rl} | #{distro}#{" " * dl}"
            else
              puts "#{" " * nl}#{num} | #{" " * vl}#{version} | #{repo}"
            end
            separator
          end
        end

        #
        # Report view for page operation.
        #
        class Report < Common
          def self.header(args)
            @@second_col = args[:second_col]
            separator
            puts "#{" " * 3} # | Info"
            separator
          end

          def self.package(args)
            n_length = args[:num].to_s.length
            num = args[:num].to_s.bold.send(TYPE_COLORS[args[:pack][:type]])
            repo = args[:pack][:repo].bold.send(TYPE_COLORS[args[:pack][:type]])
            distro = if args[:args][:distro] == args[:pack][:distro]
                       args[:pack][:distro].bold.blue
                     else
                       args[:pack][:distro]
                     end
            version = args[:pack][:version].to_s
            type = args[:pack][:type].to_s.capitalize.bold.send(TYPE_COLORS[args[:pack][:type]])
            prefix = " " * 5

            puts "#{" " * (5 - n_length)}#{num} | Version: #{version}"
            puts "#{prefix} | Repository: #{repo}"
            puts "#{prefix} | Distribution: #{distro}" if @@second_col.positive?
            # puts #{prefix} | Formats: ' + args[:formats].join(', ')
            puts "#{prefix} | Type: #{type}"
            separator
          end
        end

        class Urls < Table
        end
      end

      module Links
        #
        # Common class for links view.
        #
        class Common < Page::Common
          def self.info_package(args)
            separator
            repo = args[:repo].bold.send(TYPE_COLORS[args[:type]])
            distro = args[:distro].bold
            ver = args[:version].bold
            puts "#{"Selected Item:".bold} Repository: #{repo} | Distribution: #{distro} | Version: #{ver}"
            separator
          end

          def self.header(args)
            @@first_col = args[:first_col]
          end
        end

        #
        # Table view for links operation.
        #
        class Table < Common
          def self.header(args)
            super args
            separator
            puts "#{" " * 3} # | Format | Link"
            separator
          end

          def self.package(args); end

          def self.link(args)
            nl = args[:num].to_s.length
            fl = args[:pack][:format].to_s.length
            puts "#{" " * (5 - nl)}#{args[:num]} | #{" " * (6 - fl)}#{args[:pack][:format]} | #{args[:pack][:link]}"
            separator
          end
        end

        #
        # Report view for links operation.
        #
        class Report < Common
          def self.header(_args)
            separator
            puts "#{" " * 3} # | Links"
            separator
          end

          def self.link(args)
            alt_format = if args[:pack][:format].to_s == PageData::FORMATS[args[:pack][:format]]
                           ""
                         else
                           " (#{PageData::FORMATS[args[:pack][:format]]})"
                         end
            n_length = args[:num].to_s.length
            puts "#{" " * (5 - n_length)}#{args[:num]} | Format: #{args[:pack][:format].to_s.bold}#{alt_format}"
            puts "#{" " * 5} | Distribution: #{args[:pack][:distro]}"
            puts "#{" " * 5} | Link: #{args[:pack][:link]}"

            separator
          end
        end

        #
        # URLs view for links operation.
        #
        class Urls
          def self.general(args); end

          def self.info_package(args); end

          def self.header(args); end

          def self.separator; end

          def self.package(args); end

          def self.link(args)
            puts args[:pack][:link]
          end

          def self.no_packages(args); end
        end
      end
    end
  end
end
