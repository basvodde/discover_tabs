require 'spec_helper.rb'

describe "It can discover tabs" do

  it "Can discover tabs in one file" do
    DiscoverTabs.should_receive(:puts).with(/file_with_tabs.rb/)
    DiscoverTabs.in_file(test_data("file_with_tabs.rb")).should== true
  end

  it "Won't discover tabs in one file without tabs" do
    DiscoverTabs.should_not_receive(:puts)
    DiscoverTabs.in_file(test_data("file_without_tabs.rb")).should== false
  end

  it "Won't discover any files with tabs in a directory when there are none" do
    DiscoverTabs.should_not_receive(:puts)
    DiscoverTabs.in_dir(test_data("dir_without_tabbled_files")).should== false
  end

  it "Won't discover any files with tabs in a directory when there are none" do
    DiscoverTabs.should_receive(:puts).with(/dir_with_some_tabbed_files\/1.rb/)
    DiscoverTabs.should_receive(:puts).with(/dir_with_some_tabbed_files\/8\/1.rb/)
    DiscoverTabs.should_receive(:puts).with(/dir_with_some_tabbed_files\/dir\/4.rb/)
    DiscoverTabs.in_dir(test_data("dir_with_some_tabbed_files")).should== true
  end

  it "Can deal with the current dir" do
    DiscoverTabs.should_receive(:puts).at_least(1).times
    DiscoverTabs.in_dir(".").should== true
  end

  it "Should swallow ArgumentError expections" do
    DiscoverTabs.stub(:in_file).and_raise(ArgumentError)
    DiscoverTabs.in_dir(".").should== false
  end

  it "Makes sure the pathname is clean" do
    DiscoverTabs.should_receive(:puts).with(/dir_with_some_tabbed_files_and_different_extensions\/tabs.rb/)
    DiscoverTabs.should_receive(:puts)
    DiscoverTabs.in_dir(test_data("dir_with_some_tabbed_files_and_different_extensions/")).should== true
  end

  it "will only find the files with a certain extension" do
    DiscoverTabs.should_receive(:puts).with(/dir_with_some_tabbed_files_and_different_extensions\/tabs.rb/)
    DiscoverTabs.should_not_receive(:puts).with(/dir_with_some_tabbed_files_and_different_extensions\tabs.cpp/)
    DiscoverTabs.in_dir(test_data("dir_with_some_tabbed_files_and_different_extensions"), "*.rb").should== true
  end

  it "will discover tabs in a file when a filename it passed (success)" do
    DiscoverTabs.should_receive(:in_file).with(test_data("file_with_tabs.rb")).and_return(true)
    DiscoverTabs.cmdline_run([ test_data("file_with_tabs.rb") ]).should== 0
  end

  it "will discover tabs in a dir when a directory it passed (failed)" do
    DiscoverTabs.should_receive(:in_dir).with(test_data("dir_with_some_tabbed_files")).and_return(false)
    DiscoverTabs.cmdline_run([ test_data("dir_with_some_tabbed_files") ]).should== 1
  end

  it "will discover a pattern (based on having an * in the filename) and it passes the pattern (success)" do
    DiscoverTabs.should_receive(:in_dir).with(test_data("dir_with_some_tabbed_files"), "*").and_return(true)
    DiscoverTabs.cmdline_run([ test_data("dir_with_some_tabbed_files/*") ]).should== 0
  end

  it "Defaults to the current dir" do
    DiscoverTabs.should_receive(:in_dir).with(".").and_return(true)
    DiscoverTabs.cmdline_run([])
  end
end
