require 'spec_helper.rb'

describe "It can discover tabs" do

  context "Discovering files with tab indentation" do

    it "Can discover tabs in one file" do
      DiscoverTabs.file_has_tabs_indenting?(test_data("file_with_tabs.rb")).should== true
    end

    it "Won't discover tabs in one file without tabs" do
      DiscoverTabs.file_has_tabs_indenting?(test_data("file_without_tabs.rb")).should== false
    end

    it "Won't discover any files with tabs in a directory when there are none" do
      DiscoverTabs.files_with_tab_indenting_in_dir(test_data("dir_without_tabbled_files")).should be_empty
    end

    it "Won't discover any files with tabs in a directory when there are none" do
      files_with_tabs = DiscoverTabs.files_with_tab_indenting_in_dir(test_data("dir_with_some_tabbed_files"))
      files_with_tabs[0].should== test_data("dir_with_some_tabbed_files/1.rb")
      files_with_tabs[1].should== test_data("dir_with_some_tabbed_files/8/1.rb")
      files_with_tabs[2].should== test_data("dir_with_some_tabbed_files/dir/4.rb")
      files_with_tabs.size.should== 3
    end

    it "Can deal with the current dir" do
      DiscoverTabs.files_with_tab_indenting_in_dir(".").should_not be_empty
    end

    it "Should swallow ArgumentError expections" do
      DiscoverTabs.stub(:file_has_tabs_indenting?).and_raise(ArgumentError)
      DiscoverTabs.files_with_tab_indenting_in_dir(".").should== []
    end

    it "will only find the files with a certain extension" do
      files_with_tabs = DiscoverTabs.files_with_tab_indenting_in_dir(test_data("dir_with_some_tabbed_files_and_different_extensions"), "*rb")
      files_with_tabs.size.should== 1
      files_with_tabs[0].should== test_data("dir_with_some_tabbed_files_and_different_extensions/tabs.rb")
    end

    it "will discover tabs in a file when a filename it passed (success)" do
      DiscoverTabs.should_receive(:file_has_tabs_indenting?).with(test_data("file_with_tabs.rb")).and_return(true)
      DiscoverTabs.files_with_tab_indenting(test_data("file_with_tabs.rb")).should== [test_data("file_with_tabs.rb")]
    end

    it "will discover tabs in a dir when a directory it passed (failed)" do
      DiscoverTabs.should_receive(:files_with_tab_indenting_in_dir).with(test_data("dir_with_some_tabbed_files")).and_return([])
      DiscoverTabs.files_with_tab_indenting(test_data("dir_with_some_tabbed_files")).should== []
    end

    it "will discover a pattern (based on having an * in the filename) and it passes the pattern (success)" do
      DiscoverTabs.should_receive(:files_with_tab_indenting_in_dir).with(test_data("dir_with_some_tabbed_files"), "*").and_return(["file"])
      DiscoverTabs.files_with_tab_indenting(test_data("dir_with_some_tabbed_files/*")).should== ["file"]
    end
  end

  it "Defaults to the current dir" do
    DiscoverTabs.should_receive(:files_with_tab_indenting).with(".").and_return([])
    DiscoverTabs.cmdline_run([]).should== 1
  end

  it "Should print all the file to stdout" do
    DiscoverTabs.should_receive(:files_with_tab_indenting).with("file").and_return(["file"])
    DiscoverTabs.should_receive(:puts).with("file")
    DiscoverTabs.cmdline_run(["file"]).should== 0
  end

  it "Makes sure the pathname is clean when printing a file" do
    DiscoverTabs.should_receive(:files_with_tab_indenting).with("dir//file").and_return(["dir//file"])
    DiscoverTabs.should_receive(:puts).with("dir/file")
    DiscoverTabs.cmdline_run(["dir//file"]).should== 0
  end

end
