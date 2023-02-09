require 'nokogiri'

module Zypper
  module Onlinesearch

    class PageData

      FORMATS = {
        'aarch64': 'ARM v8.x 64-bit',
        'aarch64_ilp32': 'ARM v8.x 64-bit ilp32 mode',
        'all': 'All',
        'armv6l': 'ARM v6',
        'armv7l': 'ARM v7',
        'extra': 'Extra',
        'i586': 'Intel 32-bit',
        'i686': 'Intel Pentium 32-bit',
        'lang': 'Language',
        'lsrc': 'Language source',
        'noarch': 'No architecture',
        'ppc64le': 'PowerPC 64-bit little-endian',
        'ppc64': 'PowerPC 64-bit',
        'ppc': 'PowerPC',
        'repo': 'Repository',
        'riscv64': 'Risc v64',
        's390x': 'IBM System/390',
        'src': 'Source',
        'x86_64': 'Intel/AMD 64-bit',
        'ymp': '1 Click Install',
      }

      def initialize(page)
        @page = Nokogiri::HTML(page)
      end

      def expand_link(link)
        link = [self.class::URL, link].join('/') unless link =~ /:\/\//
        URI(link).to_s.gsub(/([^:])\/\//, '\1/')
      end
    end


    module Data

      module Search
        class Opensuse < PageData

          URL = 'https://software.opensuse.org'
          XPATH_CARDS = '//div[@id="search-result-list"]//div[@class="card-body"]'
          XPATH_NAME = './/h4[@class="card-title"]'
          XPATH_DESC = './/p[@class="card-text"]'
          XPATH_URL = './/h4[@class="card-title"]/a/@href'

          XPATH_ERROR = './/div[@id="search-result-error"]'

          def data
            res = []
            cards = @page.xpath(XPATH_CARDS)

            cards.each do |c|
              url = expand_link(c.xpath(XPATH_URL).text)
              name = c.xpath(XPATH_NAME).text
              name = (File.basename(url) == name) ? name : (File.basename(url) + ' (' + name + ')')
              res << { name: name, description: c.xpath(XPATH_DESC).text.strip.gsub(/\n|\ +/, ' '), url: url }
            end

            if res.empty?
              if @page.xpath(XPATH_ERROR).text.empty?
                name = @page.xpath(Page::Opensuse::XPATH_NAME).text

                unless name.to_s.empty?
                  res << { name: name, description: @page.xpath(Page::Opensuse::XPATH_SHORTDESC).text.strip }
                end
              end
            end

            res
          end
        end

        class Packman < PageData

          URL = 'http://packman.links2linux.org'

          XPATH_PACKAGE = '//table[@id="packagelist"]//tr'
          XPATH_NAME = './/td[@class="package-name"]/a'
          XPATH_DESC = './/td[@class="package-descr"]'
          XPATH_URL = './/td[@class="package-name"]/a/@href'

          def data
            res = []

            @page.xpath(XPATH_PACKAGE).each do |pack|
              name = pack.xpath(XPATH_NAME).text
              res << { name: name, description: pack.xpath(XPATH_DESC).text.strip.gsub(/\n|\ +/,' '), url: expand_link(pack.xpath(XPATH_URL).text) } unless name.empty?
            end

            if res.empty?
              name = @page.xpath(Page::Packman::XPATH_NAME).text

              unless name.to_s.empty?
                res << { name: name, description: @page.xpath(Page::Packman::XPATH_DESC).text.strip }
              end
            end

            res
          end

        end
      end


      module Page

        class Opensuse < PageData

          URL = 'https://software.opensuse.org'
          XPATH_NAME = '//h1'
          XPATH_SHORTDESC = '//h1/following::p/strong'
          XPATH_DESC = '//*[@id="pkg-desc"]'

          XPATH_SUPPORTED = '//div[@id="other-distributions-listing"]/h4'

          XPATH_SUPPORTED_DISTRO = './h4'
          XPATH_SUPPORTED_LABEL = './/following-sibling::div[@class="card mb-2"][1]//a'
          XPATH_SUPPORTED_LINK = './/@href'
          XPATH_SUPPORTED_VERSION =  '../..//div[@class="col-md-2"]'

          XPATH_COMMUNITY = './/following-sibling::div[contains(@id,"community-packages")][1]//div/div/a'
          XPATH_COMMUNITY_LINK = './/@href'
          XPATH_COMMUNITY_VERSION =  '../..//div[@class="col-md-2"]'

          XPATH_EXPERIMENTAL = './/following-sibling::div[contains(@id,"experimental-packages")][1]//div/div/a'
          XPATH_EXPERIMENTAL_LINK = './/@href'
          XPATH_EXPERIMENTAL_VERSION = '../..//div[@class="col-md-2"]'

          def data
            res = {}

            res[:name] = @page.xpath(XPATH_NAME).text
            res[:short_description] = @page.xpath(XPATH_SHORTDESC).text.strip
            res[:description] = @page.xpath(XPATH_DESC).text.chomp
            res[:versions] = []

            @page.xpath(XPATH_SUPPORTED).each do |ver|
              extract(ver, res, :supported, XPATH_SUPPORTED_LABEL, XPATH_SUPPORTED_VERSION, XPATH_SUPPORTED_LINK)
              extract(ver, res, :community, XPATH_COMMUNITY, XPATH_COMMUNITY_VERSION, XPATH_COMMUNITY_LINK)
              extract(ver, res, :experimental, XPATH_EXPERIMENTAL, XPATH_EXPERIMENTAL_VERSION, XPATH_EXPERIMENTAL_LINK)
            end

            res
          end


          private

          def extract(ver, res, type, xpath_group, xpath_version, xpath_link)
            repo = ''; format = ''; version = nil

            ver.xpath(xpath_group).each do |pack|

              version = pack.xpath(xpath_version).text.strip

              if version.empty?
                version = @old_version
              else
                @old_version = version
              end

              if format? pack.text.strip
                format = PageData::FORMATS.key(pack.text.strip)
              else
                repo = pack.text.strip
                if repo.empty?
                  repo = @old_repo
                else
                  @old_repo = repo unless repo =~ /Expert Download/
                end
              end

              #puts repo, link, format
              link = expand_link(pack.xpath(xpath_link).text)

              if repo =~ /Expert Download/
                res[:versions] << { distro: ver.text, link: link, type: type, repo: @old_repo, format: :extra, version: version}
                next
              end

              next if format.to_s.empty? || (link.include?('/package/show/'))

              res[:versions] << { distro: ver.text, link: link, type: type, repo: repo, format: format, version: version }
            end

          end

          def format?(str)
            PageData::FORMATS.has_value? str
          end

        end


        class Packman < PageData

          URL = 'http://packman.links2linux.org'

          XPATH_NAME = '//td[@id="package-details-header-name"]'
          XPATH_DESC = '//div[@id="package-description"]'

          XPATH_PACKAGES = '//td[@id="package-details-left"]//tbody/tr'
          XPATH_VERSION = './/td[1]'
          XPATH_DISTRO = './/td[2]'
          XPATH_FORMAT = './/td[3]'
          XPATH_LINK = './/a/@href'

          def data
            res = {}

            res[:name] = @page.xpath(XPATH_NAME).text
            res[:short_description] = ''
            res[:description] = @page.xpath(XPATH_DESC).text
            res[:versions] = []


            @page.xpath(XPATH_PACKAGES).each do |pack|

              version = pack.xpath(XPATH_VERSION).text.split('-')[0].to_s
              distro = pack.xpath(XPATH_DISTRO).text.gsub(/_/, ' ')
              format = pack.xpath(XPATH_FORMAT).text.strip.to_sym
              link = pack.xpath(XPATH_LINK).text

              res[:versions] << { format: format, version: version, distro: distro,
                                  type: :supported, link: "http://packman.links2linux.org#{link}",
                                  repo: 'Packman' }
            end

            res
          end
        end

      end


      module Links

        class Opensuse < PageData

          XPATH_REPO = '//*[@id="manualopenSUSE"]/h5'
          XPATH_REPO_DISTRO = './strong[1]'
          XPATH_REPO_LINK = 'following-sibling::pre[1]'

          XPATH_PACKAGE_GROUP = '//*[@id="directopenSUSE"]/div/div'
          XPATH_PACKAGE_DISTRO = './p/strong'
          XPATH_PACKAGE_LINK = './/@href'

          def data
            res = { versions: [] }

            extract(res, -1, XPATH_REPO, XPATH_REPO_DISTRO, XPATH_REPO_LINK)
            extract(res, -2, XPATH_PACKAGE_GROUP, XPATH_PACKAGE_DISTRO, XPATH_PACKAGE_LINK)

            res
          end


          private

          def extract(res, format_idx, xpath_group, xpath_distro, xpath_link)
            @page.xpath(xpath_group).each do |section|
              distro = ''
              section.xpath(xpath_distro).each do |subsection|
                distro = subsection.text
                distro = "openSUSE Leap #{distro}" if distro =~ /^\d\d.\d$/
              end

              #p distro
              section.xpath(xpath_link).each do |subsection|
                link = subsection.text
                link = link.gsub("\n", ' ').scan(/(https:\/\/[^ \n]+)/).pop.pop
                res[:versions] << {
                  distro: distro,
                  format: File.basename(link).split('.')[format_idx].to_sym,
                  link: link,
                }
                #p link
              end
            end

          end
        end

        class Packman < PageData

          XPATH_LINK_DISTRO = '//*[@id="selected-release"]/td[2]'
          XPATH_LINK_BIN = '//*[@id="package-details-binfiles"]//a/@href'
          XPATH_LINK_SRC = '//*[@id="package-details-srcfile-heading"]//a/@href'
          XPATH_LINK_YMP = '//*[@class="ymp"]//a/@href'

          URL = 'http://packman.links2linux.org'

          def data
            res = { versions: [] }

            distro = @page.xpath(XPATH_LINK_DISTRO).text.gsub(/\_/, ' ')

            @page.xpath(XPATH_LINK_BIN).each do |pack|
              link = pack.text
              res[:versions] << {
                distro: distro,
                format: File.basename(link).split('.')[-2].to_sym,
                link: URL + link
              }
            end

            link = res[:versions].last[:link]
            is_lang = (File.basename(link) =~ /-lang/) && (res[:versions].last[:format] == :noarch)

            link = @page.xpath(XPATH_LINK_SRC).text
            res[:versions] << {
              distro: distro,
              format: is_lang ? :lsrc : File.basename(link).split('.')[-2].to_sym,
              link: URL + link
            }

            unless is_lang
              link = @page.xpath(XPATH_LINK_YMP).text
              res[:versions] << {
                distro: distro,
                format: :ymp,
                link: URL + link
              }
            end

            res
          end
        end

      end

    end # Data module

  end
end
