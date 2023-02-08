# Zypper-Onlinesearch

Zypper-Onlinesearch brings the ability to find packages from *software.opensuse.org* and *Packman*,
directly in your terminal.

Basically it is just a command-line frontend to these search engines, it executes a query to them,
arrange the results and display them in a table or report view.

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

For example looking for *Qmmp*:
```shell
$ onlinesearch -s qmmp

====================================================================================================
Parameters: Engine: packman | Query: qmmp | Cache: On (2023-02-23 16:37)
====================================================================================================
    # |       Page       | Description 
----------------------------------------------------------------------------------------------------
    1 | qmmp             | Qt-based Multimedia Player
----------------------------------------------------------------------------------------------------
    2 | qmmp-plugin-pack | Extra plugins for Qmmp
----------------------------------------------------------------------------------------------------

====================================================================================================
Parameters: Engine: opensuse | Query: qmmp | Cache: On (2023-02-23 16:37)
====================================================================================================
    # |              Page              | Description 
----------------------------------------------------------------------------------------------------
    1 | qmmp                            | Qt-based Multimedia Player
----------------------------------------------------------------------------------------------------
    2 | libqmmp1                        | Qmmp library
----------------------------------------------------------------------------------------------------
    3 | libqmmp-devel                   | Development files for libqmmp
----------------------------------------------------------------------------------------------------
...
```

We get among the results a page called *qmmp* for both engines, so to read that pages:
```shell
$ onlinesearch -p qmmp

====================================================================================================
Parameters:  Engine: packman | OS: openSUSE Leap 15.4 | Architecture: 64 Bit | Cache: On (2023-02-07 16:57)
====================================================================================================
Name:        qmmp
Summary:     
Description: 
Qt-based Multimedia Player
----------------------------------------------------------------------------------------------------
    # | Version |  Repo   |        Distro       
----------------------------------------------------------------------------------------------------
    1 |   2.1.2 | Packman | openSUSE Leap 15.4
----------------------------------------------------------------------------------------------------

====================================================================================================
Parameters:  Engine: opensuse | OS: openSUSE Leap 15.4 | Architecture: 64 Bit | Cache: On (2023-02-07 16:57)
====================================================================================================
Name:        qmmp
Summary:     Qt-based Multimedia Player
Description: This program is an audio-player, written with help of Qt library.
----------------------------------------------------------------------------------------------------
    # | Version |         Repo          |        Distro       
----------------------------------------------------------------------------------------------------
    1 |   2.1.2 | home:plater           | openSUSE Leap 15.4
----------------------------------------------------------------------------------------------------
    2 |   1.4.4 | home:ykoba:multimedia | openSUSE Leap 15.4
----------------------------------------------------------------------------------------------------
    3 |   2.1.2 | multimedia:apps       | openSUSE Leap 15.4
----------------------------------------------------------------------------------------------------
```

To show the page from one engine only, just append the `--engine <engine_name>` param:
```shell
$ onlinesearch -p qmmp --engine opensuse
```

To list the links in the third repository listed in the *opensuse* engine:
```shell
$ onlinesearch -l qmmp,3 --engine opensuse

====================================================================================================
Parameters:  Engine: opensuse | OS: openSUSE Leap 15.4 | Architecture: 64 Bit | Cache: On (2023-02-07 16:57)
====================================================================================================
Name:        qmmp
Summary:     Qt-based Multimedia Player
Description: This program is an audio-player, written with help of Qt library.
----------------------------------------------------------------------------------------------------
    # | Format | Link
----------------------------------------------------------------------------------------------------
    1 |    ymp | https://software.opensuse.org/ymp/multimedia:apps/15.4/qmmp.ymp?base=openSUSE%3ALeap%3A15.4&query=qmmp
----------------------------------------------------------------------------------------------------
    2 |    src | https://download.opensuse.org/repositories/multimedia:/apps/15.4/src/qmmp-2.1.2-lp154.182.3.src.rpm
----------------------------------------------------------------------------------------------------
    3 | x86_64 | https://download.opensuse.org/repositories/multimedia:/apps/15.4/x86_64/qmmp-2.1.2-lp154.182.3.x86_64.rpm
----------------------------------------------------------------------------------------------------
```

To print only the raw URLs:
```shell
$ onlinesearch -l qmmp,3 --urls
https://software.opensuse.org/ymp/multimedia:apps/15.4/qmmp.ymp?base=openSUSE%3ALeap%3A15.4&query=qmmp
https://download.opensuse.org/repositories/multimedia:/apps/15.4/src/qmmp-2.1.2-lp154.182.3.src.rpm
https://download.opensuse.org/repositories/multimedia:/apps/15.4/x86_64/qmmp-2.1.2-lp154.182.3.x86_64.rpm
```

And in case we are interested to a specific format:
```shell
$ onlinesearch -l qmmp,3 --urls --format ymp
https://software.opensuse.org/ymp/multimedia:apps/15.4/qmmp.ymp?base=openSUSE%3ALeap%3A15.4&query=qmmp
```

## Get help

Where to start:
```shell
$ onlinesearch --help
```

## More Help:

More info is available at:
- the [Zypper-Onlinesearch Project page][project_page].

[project_page]: https://freeaptitude.altervista.org/projects/zypper-onlinesearch.html "Zypper-Onlinesearch project page"

