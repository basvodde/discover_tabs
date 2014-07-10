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

  context "tab replacement" do

    it "will return the same line if there is no tab on the line" do
      DiscoverTabs.replace_tabs_with_spaces_on_line("string", 4).should== "string"
    end

    it "will convert one tab at the beginning to spaces" do
      DiscoverTabs.replace_tabs_with_spaces_on_line("\tstring", 2).should== "  string"
    end

    it "will convert multiple tabs at the beginning to spaces" do
      DiscoverTabs.replace_tabs_with_spaces_on_line("\t\t\tstring", 3).should== "         string"
    end

    it "will not convert tabs that are not at the beginning" do
      DiscoverTabs.replace_tabs_with_spaces_on_line(" \tstri\tng\t", 3).should== " \tstri\tng\t"
    end

    it "will replace all tabs in a multi-line file" do
      DiscoverTabs.replace_tabs_with_spaces("\t\thello\nworld\n\t", 2).should== "    hello\nworld\n  "
    end

    it "will read and re-write the files which it replaces spaces" do
      File.should_receive(:read).with("file").and_return("content")
      DiscoverTabs.should_receive(:replace_tabs_with_spaces).with("content", 3).and_return("new_content")
      File.should_receive(:write).with("file", "new_content")
      DiscoverTabs.replace_tabs_in_files(["file"], 3)
    end
  end

  context "Parsing parameters" do
    it "Can print out an error on error" do
      DiscoverTabs.should_receive(:puts).with("invalid option: --wrong_parameter")
      DiscoverTabs.should_receive(:exit).with(1)
      DiscoverTabs.parse_argv(["--wrong_parameter"])
    end

    it "Should receive the help text on -h" do
      DiscoverTabs.should_receive(:puts).with("usage: discover_tabs [options] [filename|directory]\n    -r N                             Replace tabs intending with N spaces\n    -h, --help\
                       Show this message\n")
      DiscoverTabs.should_receive(:exit).with(0)
      DiscoverTabs.parse_argv(["-h"])
    end

    it "Should parse the -r4 and pass it back properly" do
      DiscoverTabs.parse_argv(["-r4", "file"])[:replace_tabs].should == 4
    end

    it "Should parse the filename|directory" do
      DiscoverTabs.parse_argv(["file"])[:files].should == ["file"]
    end

    it "Should default the filename|directory to current dir" do
      DiscoverTabs.parse_argv([])[:files].should == ["."]
    end
  end

  context "Command line main entry point" do
    it "Should print all the file to stdout" do
      DiscoverTabs.should_receive(:files_with_tab_indenting).with("file").and_return(["file"])
      DiscoverTabs.should_receive(:files_with_tab_indenting).with("file2").and_return([])
      DiscoverTabs.should_receive(:puts).with("file")
      DiscoverTabs.cmdline_run(["file", "file2"]).should== 0
    end

    it "Makes sure the pathname is clean when printing a file" do
      DiscoverTabs.should_receive(:files_with_tab_indenting).and_return(["file"])
      DiscoverTabs.should_receive(:puts)
      DiscoverTabs.should_receive(:replace_tabs_in_files).with(["file"], 4)
      DiscoverTabs.cmdline_run(["-r4", "file"]).should== 0
    end
  end
end
