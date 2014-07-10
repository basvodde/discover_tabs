require 'pathname'
require 'ptools'
require 'optparse'

module DiscoverTabs

  class << self

    def files_with_tab_indenting(full_path)
      filename = File.basename(full_path)
      dirname = File.dirname(full_path)

      files_with_tabs = []
      if File.directory?(full_path)
        files_with_tabs += files_with_tab_indenting_in_dir(full_path)
      elsif filename.include?("*")
        files_with_tabs += files_with_tab_indenting_in_dir(dirname, filename)
      else
        files_with_tabs << full_path if file_has_tabs_indenting?(full_path)
      end
      files_with_tabs
    end

    def files_with_tab_indenting_in_dir(dir, pattern = "*")
      files_with_tabs = []
      Dir["#{dir}/**/#{pattern}"].each do |file|
        begin
          unless File.directory?(file) || File.binary?(file)
            files_with_tabs << file if file_has_tabs_indenting?(file)
          end
        rescue ArgumentError
        end
      end
      files_with_tabs
    end

    def file_has_tabs_indenting?(filename)
      File.readlines(filename).each do |line|
        return true if line =~ /^\t+/
      end
      false
    end

    def parse_argv(argv)
      options = {}

      opt_parser = OptionParser.new do |opts|
        opts.banner = "usage: discover_tabs [options] [filename|directory]"

        opts.on("-r N", Integer, "Replace tabs intending with N spaces") do |n|
          options[:replace_tabs] = n
        end

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts.to_s
          exit(0)
        end
      end
      opt_parser.parse!(argv)

      options[:files] = argv
      options[:files] = ["."] if argv.empty?


      options
    rescue OptionParser::InvalidOption => error
      puts error.message
      exit 1
    end

    def cmdline_run(argv)
      options = parse_argv(argv)

      files_with_tabs = []
      options[:files].each do |full_path|
        files_with_tabs += files_with_tab_indenting(full_path)
      end

      files_with_tabs.each { |file| puts Pathname.new(file).cleanpath.to_s }

      if options[:replace_tabs]
        replace_tabs_in_files(files_with_tabs, options[:replace_tabs])
      end

      files_with_tabs.empty? ? 1 : 0
    end

    def replace_tabs_in_files(files, amount_of_spaces_per_tab)
      files.each do |file|
        content = File.read(file)
        new_content = replace_tabs_with_spaces(content, amount_of_spaces_per_tab)
        File.write(file, new_content)
      end
    end

    def replace_tabs_with_spaces(content, amount_of_spaces_per_tab)
      new_content = ""
      content.lines.each { |line| new_content += replace_tabs_with_spaces_on_line(line, amount_of_spaces_per_tab)}
      new_content
    end

    def replace_tabs_with_spaces_on_line(string, amount_of_spaces_per_tab)
      new_string = string
      if string =~ /^(\t+)/
        replacement_spaces = " " * amount_of_spaces_per_tab * $1.size
        new_string = string.gsub(/^#{$1}/, replacement_spaces)
      end
      new_string
    end
  end
end

