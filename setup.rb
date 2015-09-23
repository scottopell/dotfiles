#!/usr/bin/env ruby
require 'optparse'
require 'ostruct'

class DotParse

  def self.parse args
    options = OpenStruct.new
    options.library = []
    options.inplace = false
    options.encoding = "utf8"
    options.transfer_type = :auto
    options.verbose = false

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: setup.rb [--install|--clean|--zsh|--vim|--force]"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-i", "--install",
              "creates symlinks in the home directory") do |i|
        options.install = i
      end

      opts.on("-c", "--clean",
              "cleans up any symlinks from the home folder") do |c|
        options.clean = c
      end

      opts.on("-f", "--force",
              "overwrites all files with symlinks. Dangerous.") do |force|
        options.force = force
      end

      opts.on("-z", "--zsh",
              "installs oh my zsh") do |zsh|
        options.zsh = zsh
      end

      opts.on("-v", "--vim",
              "sets up the custom vim environment") do |vim|
        options.vim = vim
      end

      opts.separator ""
      opts.separator "Common options:"

      # No argument, shows at tail.  This will print an options summary.
      # Try it and see!
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end

    opt_parser.parse!(args)
    options
  end
end

class Dot
  def install force=false
    home = "#{ENV["HOME"]}"
    Dir.chdir(home) do
      files = get_valid_files
      files.each do |f|
        file_name = File.basename f
        target = ".#{file_name}"
        if File.exists?(target) && force == false
          puts "~#{target} already exists, skipping"
          puts "~#{target} is%s a symlink" % [File.symlink?(target)? "": " NOT"]
        else
          puts "Creating symlink for #{file_name}"
          `ln -s -f #{f} .#{file_name}`
        end
      end
    end
  end

  def clean
    home = "#{ENV["HOME"]}"
    Dir.chdir(home) do 
      files = get_valid_files
      files.each do |f|
        file_name = File.basename f
        target = ".#{file_name}"
        if File.symlink? target
          `rm #{target}`
          puts "Deleting symlink for #{target}"
        else 
          puts "#{file_name} isn't a symlink, ignoring"
        end
      end
    end
  end

  def vim
    `git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim`
    puts "Installing plugins in the background, could take a few minutes"
    `vim +PluginInstall +qall`
  end

  def zsh
    `curl -L http://install.ohmyz.sh | sh`
  end

  private

  def get_valid_files
    home = "#{ENV["HOME"]}"
    # ensure we're in the proper directory
    Dir.chdir("#{home}/dotfiles") do 
      path = Dir.pwd
      files = Dir.entries(path)
      ignored_file_extensions = [ "md", "rb", "swp" ]
      ignored_entries = [ ".", "..", ".git" ]
      files.delete_if do |f|
        # select files that match, then check for elements
        file_ignore = ignored_entries.detect { |fi| f == fi }
        extension_ignore = ignored_file_extensions.detect do |fe| 
          pat = /(.*)\.#{fe}/
          f.match(pat)
        end
        extension_ignore || file_ignore
      end
      # full path
      files.map! do |f|
        "#{path}/#{f}"
      end
      files
    end
  end
end

options = DotParse.parse(ARGV)
dot = Dot.new

if options.install
  dot.install
elsif options.force
  dot.install true
elsif options.clean
  dot.clean
elsif options.vim
  dot.vim
elsif options.zsh
  dot.zsh
end