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

  it "will only find the files with a certain extension" do
    DiscoverTabs.should_receive(:puts).with(/dir_with_some_tabbed_files_and_different_extensions\/tabs.rb/)
    DiscoverTabs.should_not_receive(:puts).with(/dir_with_some_tabbed_files_and_different_extensions\tabs.cpp/)
    DiscoverTabs.in_dir(test_data("dir_with_some_tabbed_files_and_different_extensions"), "*.rb").should== true
  end
end
