require 'pathname'
require 'ptools'

module DiscoverTabs

  def self.files_with_tab_indenting(full_path)
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

  def self.files_with_tab_indenting_in_dir(dir, pattern = "*")
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

  def self.file_has_tabs_indenting?(filename)
    File.readlines(filename).each do |line|
      return true if line =~ /^\t+/
    end
    false
  end

  def self.cmdline_run(argv)
    full_path = argv[0] || "."
    files_with_tabs = files_with_tab_indenting(full_path)
    files_with_tabs.each { |file| puts Pathname.new(file).cleanpath.to_s }
    files_with_tabs.empty? ? 1 : 0
  end
end
