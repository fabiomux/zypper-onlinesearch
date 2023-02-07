module Zypper
  module Onlinesearch

    class ::String
      def black;          "\033[30m#{self}\033[0m" end
      def red;            "\033[31m#{self}\033[0m" end
      def green;          "\033[32m#{self}\033[0m" end
      def yellow;         "\033[33m#{self}\033[0m" end
      def blue;           "\033[34m#{self}\033[0m" end
      def magenta;        "\033[35m#{self}\033[0m" end
      def cyan;           "\033[36m#{self}\033[0m" end
      def gray;           "\033[37m#{self}\033[0m" end
      def bg_black;       "\033[40m#{self}\0330m"  end
      def bg_red;         "\033[41m#{self}\033[0m" end
      def bg_green;       "\033[42m#{self}\033[0m" end
      def bg_brown;       "\033[43m#{self}\033[0m" end
      def bg_blue;        "\033[44m#{self}\033[0m" end
      def bg_magenta;     "\033[45m#{self}\033[0m" end
      def bg_cyan;        "\033[46m#{self}\033[0m" end
      def bg_gray;        "\033[47m#{self}\033[0m" end
      def bold;           "\033[1m#{self}\033[22m" end
      def reverse_color;  "\033[7m#{self}\033[27m" end
      def cr;             "\r#{self}" end
      def clean;          "\e[K#{self}" end
      def new_line;       "\n#{self}" end
      def none;           self end
    end

    class ::Float
      def to_human
        conv = {
          1024=>'B',
          1024*1024=>'KB',
          1024*1024*1024=>'MB',
          1024*1024*1024*1024=>'GB',
          1024*1024*1024*1024*1024=>'TB',
          1024*1024*1024*1024*1024*1024=>'PB',
          1024*1024*1024*1024*1024*1024*1024=>'EB'
        }
        conv.keys.sort.each { |mult|
          next if self >= mult
          suffix=conv[mult]
          return "%.2f %s" % [ self / (mult / 1024), suffix ]
        }
      end
    end

    class ::Array
      def max_column(field)
        self.max_by { |x| x[field].to_s.length }[field].to_s.length
      end
    end

    class ::StandardError
      def error_code
        1
      end
    end

    class Messages

      def self.error(e)
        if e.class == String
          puts ' [E] '.bold.red + e
        else
          STDERR.puts 'Error! '.bold.red + e.message
        end
      end
    end

    class QueryStringTooShort < StandardError
      def initialize(query)
        super "The query string '#{query}' is too short, be sure to use more than 3 characters."
      end

      def error_code
        2
      end
    end

    class TooManyRedirections < StandardError
      def initialize(url)
        super "#{url} generates too many redirections!"
      end
    end

    class InvalidEngine < StandardError
      def initialize(engine)
        super "#{engine} is not a valid engine!"
      end

      def error_code
        4
      end
    end

    class MissingItemNumber < StandardError
      def initialize
        super 'No item number has been provided!'
      end
    end

    class EmptyCache < StandardError
      def initialize
        super 'The cache folder is already empty!'
      end
    end

    class NoConnection < StandardError
      def initialize
        super 'Internet connection has some trouble'
      end

      def error_code
        6
      end
    end

    class Interruption < StandardError
      def initialize
        super 'Ok ok... Exiting!'
      end
    end

    Signal.trap('INT') { raise Interruption }

    Signal.trap('TERM') { raise Interruption }

  end
end
