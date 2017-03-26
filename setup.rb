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
      opts.banner = "Usage: setup.rb [--install|--clean|--zsh|--vim|--brew|--force]"

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

      opts.on("-b", "--brew",
              "Installs brew and bundles default apps") do |brew|
        options.brew = brew;
      end

      opts.on("-z", "--zsh",
              "installs zsh framework") do |zsh|
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
    `curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim`
    puts "Installing plugins in the background, could take a few minutes"
    `vim +PlugInstall +qall`
  end

  def zsh
    # TODO probably should re-implement this in ruby.
    # and also make it smarter, right now it seems to just prepend its
    # own stuff to whatever you already have.
    # So if you run this after linking in dotfiles, then you should
    # probably delete one of the zim loading snippets
    #
    `git clone --recursive https://github.com/Eriner/zim.git \
               ${ZDOTDIR:-${HOME}}/.zim;\
    setopt EXTENDED_GLOB\
    for template_file ( ${ZDOTDIR:-${HOME}}/.zim/templates/* ); do\
      user_file="${ZDOTDIR:-${HOME}}/.${template_file:t}"\
      touch ${user_file}\
      ( print -rn "$(<${template_file})$(<${user_file})" >! ${user_file} ) 2>/dev/null\
    done`
  end

  def brew_and_bundle
    brew
    bundle
  end

  def brew
    `ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`
  end

  def bundle
    # TODO figure out if this extra tap is necessary.
    #  I thought I read somewhere bundle is builtin to brew now
    `brew 'tap homebrew/bundle'`
    `brew bundle --file=$HOME/dotfiles/Brewfile`
  end

  private

  def get_valid_files
    home = "#{ENV["HOME"]}"
    # ensure we're in the proper directory
    Dir.chdir("#{home}/dotfiles") do 
      path = Dir.pwd
      files = Dir.entries(path)
      ignored_file_extensions = [ "md", "rb", "swp" ]
      ignored_entries = [ ".", "..", ".git", ".DS_Store", "Brewfile" ]
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
elsif options.brew
  dot.brew_and_bundle
elsif options.zsh
  dot.zsh
end
