module Zypper
  module Onlinesearch

    module View

      TYPE_COLORS = { experimental: :yellow, supported: :green, community: :red }
      SEPARATOR_LENGTH = 100


      class CacheClean
        def self.reset(size)
          puts "Cache cleared! " + size.to_f.to_human.bold.red + ' freed.'
        end
      end


      module Search

        class Common

          def self.separator
            puts '-' * SEPARATOR_LENGTH
          end

          def self.no_packages
            puts  (' ' * 3) + ' - | No packages found!'
            self.separator
          end

          def self.no_compatible_packages
            puts  (' ' * 3) + ' - | No compatible packages found!'
            self.separator
          end

          def self.parameters(args)
            puts ''
            puts '=' * SEPARATOR_LENGTH
            puts 'Parameters: '.bold + 'Engine: ' + args[:engine].to_s.bold.red + ' | ' +
                 'Query: ' + args[:query].bold + ' | ' +
                 'Cache: ' + (args[:cached] ? "#{'On'.bold.yellow} (#{args[:cache_time] ? args[:cache_time].strftime('%Y-%m-%d %H:%M') : 'Now'})" : 'Off'.bold)
            puts '=' * SEPARATOR_LENGTH
          end
        end

        class Report < Common

          def self.header(args)
            puts ' ' * 3 + ' # | Info '
            self.separator
          end

          def self.package(args)
            name = args[:name]
            name = (name =~ / /) ? (name.split(' ').map.with_index { |x, i| x = x.bold if i == 0; x }.join ' ') : name.bold

            puts "#{' ' * (5 - args[:num].to_s.length)}" + args[:num].to_s + ' | Page: ' + name
            puts "#{' ' * 5}" + ' | Description: ' + args[:description].to_s
            self.separator
          end
        end


        class Table < Common

          def self.header(args)
            @@first_col = args[:first_col]
            n_length = ( args[:first_col] - 4 ) / 2

            puts (' ' * 4) + '#' +
                 ' | ' + (' ' * n_length) + 'Page' + (' ' * n_length) +
                 ' | Description '
            self.separator
          end

          def self.package(args)
            name = args[:name]
            name = (name =~ / /) ? (name.split(' ').map.with_index { |x, i| x = x.bold if i == 0; x }.join ' ') : name.bold

            puts (' ' * (5 - args[:num].to_s.length)) + args[:num].to_s +
                 ' | ' + name + (' ' * (@@first_col - args[:name].length)) +
                 ' | ' + args[:description]
            self.separator
          end

        end

        class Urls < Table

        end

      end


      module Page

        class Common

          def self.separator
            puts '-' * SEPARATOR_LENGTH
          end

          def self.general(args)
            puts ''
            puts '=' * SEPARATOR_LENGTH
            puts 'Parameters:  '.bold +
                 'Engine: ' + args[:engine].bold.red + ' | ' +
                 'OS: ' + args[:distro].bold.blue + ' | ' +
                 'Architecture: ' + PageData::FORMATS[args[:architecture]].bold + ' | ' +
                 'Cache: ' + (args[:refresh] ? 'Off'.bold : "#{'On'.bold.yellow} (#{args[:cache_time] ? args[:cache_time].strftime('%Y-%m-%d %H:%M') : args[:cache_time].strftime('%Y-%m-%d %H:%M')})")
            puts '=' * SEPARATOR_LENGTH
            puts 'Name:        '.bold + args[:name]
            puts 'Summary:     '.bold + args[:short_description] if args[:short_description]
            puts 'Description: '.bold + args[:description].chomp if args[:description]

          end

          def self.no_packages(compatible)
            self.separator
            puts (' ' * 3) + ' - | No ' + (compatible ? 'compatible ' : '' ) + 'packages found!'
            self.separator
          end

          def self.no_item(num)
            self.separator
            puts (' ' * 3) + ' - | Invalid item number ' + num.to_s
          end
        end


        class Table < Common

          def self.header(args)
            @@first_col = args[:first_col]
            @@second_col = args[:second_col]
            first_col = ((args[:first_col] - 4) / 2)
            second_col = (args[:second_col] > 0) ? ((args[:second_col] - 6) / 2) : 0

            self.separator
            if second_col > 0
              puts "#{' ' * 3} # | Version | #{' ' * first_col}Repo #{' ' * first_col} | #{' ' * second_col} Distro #{' '  * second_col}" # | Formats"
            else
              puts "#{' ' * 3} # | Version | #{' ' * first_col}Repo #{' ' * first_col}" # | Formats"
            end
            self.separator
          end

          def self.package(args)
            r_length = @@first_col - args[:pack][:repo].to_s.length
            n_length = args[:num].to_s.length
            d_length = @@second_col > 0 ? @@second_col - args[:pack][:distro].to_s.length : 0

            num = args[:num].to_s.bold.send(TYPE_COLORS[args[:pack][:type]])
            repo = args[:pack][:repo].bold.send(TYPE_COLORS[args[:pack][:type]])
            distro = (args[:args][:distro] == args[:pack][:distro] ? args[:pack][:distro].bold.blue : args[:pack][:distro])
            version = args[:pack][:version].to_s[0..6]

            if @@second_col > 0
              puts (' ' * (5 - n_length)) + num +
                ' | ' + (' ' * ( 7 - version.length )) + version +
                ' | ' + repo.to_s + (' ' * r_length) +
                ' | ' + distro + (' ' * d_length) # +
            else
              puts (' ' * (5 - n_length)) + num +
                ' | ' + (' ' * ( 7 - version.length )) + version +
                ' | ' + repo.to_s + (' ' * r_length)  #+
            end

            self.separator
          end

        end


        class Report < Common

          def self.header(args)
            @@second_col = args[:second_col]
            self.separator
            puts "#{' ' * 3} # | Info"
            self.separator
          end

          def self.package(args)
            n_length = args[:num].to_s.length

            #p args
            num = args[:num].to_s.bold.send(TYPE_COLORS[args[:pack][:type]])
            repo = args[:pack][:repo].bold.send(TYPE_COLORS[args[:pack][:type]])
            distro = (args[:args][:distro] == args[:pack][:distro] ? args[:pack][:distro].bold.blue : args[:pack][:distro])
            version = args[:pack][:version].to_s

            puts (' ' * (5 - n_length)) + num.to_s + ' | Version: ' + version
            puts (' ' * 5) + ' | Repository: ' + repo
            puts (' ' * 5) + ' | Distribution: ' + distro if @@second_col > 0
            #puts (' ' * 5) + ' | Formats: ' + args[:formats].join(', ')
            puts (' ' * 5) + ' | Type: ' + args[:pack][:type].to_s.capitalize.bold.send(TYPE_COLORS[args[:pack][:type]])
            self.separator
          end

        end


        class Urls < Table

        end

      end # Module Page


      module Links

        class Common < Page::Common

          def self.info_package(args)
            self.separator
            puts 'Selected Item: '.bold +
                 'Repository: ' + args[:repo].bold.send(TYPE_COLORS[args[:type]]) + ' | ' +
                 'Distribution: ' + args[:distro].bold + ' | ' +
                 'Version: ' + args[:version].bold
            self.separator
          end

          def self.header(args)
            @@first_col = args[:first_col]
          end
        end

        class Table < Common

          def self.header(args)
            super args
            self.separator
            puts (' ' * 3) + ' # | Format | Link'
            self.separator
          end

          def self.package(args)
          end

          def self.link(args)
            #puts args,@@first_col
            n_length = args[:num].to_s.length
            puts (' ' * (5 - n_length)) + args[:num].to_s + ' | ' +
              (' ' * (6 - args[:pack][:format].to_s.length)) + args[:pack][:format].to_s + ' | ' + args[:pack][:link]
            self.separator
          end
        end

        class Report < Common

          def self.header(args)
            self.separator
            puts "#{' ' * 3} # | Links"
            self.separator
          end

          def self.link(args)
            alt_format = args[:pack][:format].to_s == PageData::FORMATS[args[:pack][:format]] ? '' : " (#{PageData::FORMATS[args[:pack][:format]]})"
            n_length = args[:num].to_s.length
            puts (' ' * (5 - n_length)) + args[:num].to_s + ' | Format: ' + args[:pack][:format].to_s.bold + alt_format
            puts (' ' * 5) + ' | Distribution: ' + args[:pack][:distro]
            puts (' ' * 5) + ' | Link: ' + args[:pack][:link]

            #puts (' ' * 5) + ' |' + ( '-' * 94)
            self.separator
          end
        end

        class Urls
          def self.general(args)
          end

          def self.info_package(args)
          end

          def self.header(args)
          end

          def self.separator
          end

          def self.package(args)
          end

          def self.link(args)
            puts args[:pack][:link]
          end

          def self.no_packages(args)
          end
        end

      end # Module Links

    end
  end
end
