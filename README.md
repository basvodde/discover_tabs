discover_tabs
=============

Discover which files use tabs (and potentially replace them with spaces if you like)

### Usage

After installation, there should be a command line app called "discover_tabs" on your path.

    usage: discover_tabs [options] [filename|directory]
        -r N                             Replace tabs intending with N spaces
        -h, --help                       Show this message

It will output all of the files that have indentation with tabs. The -r options will replace them with spaces.

examples:

* discover_tabs *.cpp
* discover_tabs *.cpp -r4

### Installation

gem discover_tabs
