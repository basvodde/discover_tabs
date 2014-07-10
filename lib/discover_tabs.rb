

module DiscoverTabs

  def self.in_dir(dir, pattern = "*")
    files_with_tabs = false
    Dir["#{dir}/**/#{pattern}"].each do |file|
      has_tabs = in_file(file) unless File.directory?(file)
      files_with_tabs ||= has_tabs
    end
    files_with_tabs
  end

  def self.in_file(filename)
    File.readlines(filename).each do |line|
      if line =~ /^\t+/
        puts filename
        return true
      end
    end
    false
  end
end
