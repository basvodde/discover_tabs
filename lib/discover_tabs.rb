require 'pathname'
require 'ptools'

module DiscoverTabs

  def self.in_dir(dir, pattern = "*")
    files_with_tabs = false
    Dir["#{dir}/**/#{pattern}"].each do |file|
      begin
        has_tabs = false
        unless File.directory?(file) || File.binary?(file)
          has_tabs = in_file(file)
        end
      rescue ArgumentError
      end
      files_with_tabs ||= has_tabs
    end
    files_with_tabs
  end

  def self.in_file(filename)
    File.readlines(filename).each do |line|
      if line =~ /^\t+/
        puts Pathname.new(filename).cleanpath.to_s
        return true
      end
    end
    false
  end

  def self.cmdline_run(argv)
    full_path = argv[0] || "."
    filename = File.basename(full_path)
    dirname = File.dirname(full_path)

    found_tabs = if File.directory?(full_path)
      in_dir(full_path)
    elsif filename.include?("*")
       in_dir(dirname, filename)
    else
      in_file(full_path)
    end
    found_tabs ? 0 : 1
  end
end
