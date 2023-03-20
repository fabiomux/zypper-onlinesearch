# Zypper-Onlinesearch

Zypper-Onlinesearch brings the ability to find packages from *software.opensuse.org* and *Packman*,
directly in your terminal.

Basically it is just a command-line frontend to these search engines, it executes a query to them,
arrange the results and display them in a table or report view.

[![Ruby](https://github.com/fabiomux/zypper-onlinesearch/actions/workflows/main.yml/badge.svg)][wf_main]
[![Gem Version](https://badge.fury.io/rb/zypper-onlinesearch.svg)][gem_version]

## Installation

There are a couple of options to install this application.

### Rubygem

Install it as a regular Ruby gem with:
```shell
$ gem install zypper-onlinesearch
```

### From the openSUSE Build Service repository

This application has been packaged in my personal OBS repository so you can install It
as a common RPM package:
- Add the repository URL in your list;
- install the package from Yast or Zypper.

Being the repository URL slightly changing from a version to another, I included all the steps
in the related [project page][project_page] at my blog.

## Usage

To query for the string :
```shell
$ onlinesearch -s <string>
```

When the pages are returnerd they are identified in the *Page* field and can be read with the `-p` switch:
```shell
$ onlinesearch -p <page>
```

To list the links from that page:
```shell
$ onlinesearch -l <page>,<link_number>
```

## Get help

Where to start:
```shell
$ onlinesearch --help
```

## More Help:

More info is available at:
- the [Zypper-Onlinesearch Project page][project_page];
- the [Zypper-Onlinesearch Github wiki][zypper_onlinesearch_wiki].

[project_page]: https://freeaptitude.altervista.org/projects/zypper-onlinesearch.html "Zypper-Onlinesearch project page"
[zypper_onlinesearch_wiki]: https://github.com/fabiomux/zypper-onlinesearch/wiki "Zypper-Onlinesearch wiki page on GitHub"
[wf_main]: https://github.com/fabiomux/zypper-onlinesearch/actions/workflows/main.yml
[gem_version]: https://badge.fury.io/rb/zypper-onlinesearch
