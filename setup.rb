#!/usr/bin/env ruby
require 'optparse'
require 'ostruct'
require 'fileutils'

module Tty extend self
  def blue; bold 34; end
  def green; bold 32; end
  def white; bold 39; end
  def red; underline 31; end
  def reset; escape 0; end
  def bold n; escape "1;#{n}" end
  def underline n; escape "4;#{n}" end
  def escape n; "\033[#{n}m" if STDOUT.tty? end
end

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
    puts "Installing zim"

    puts "Cloning zim into home"
    `git clone --recursive https://github.com/Eriner/zim.git \
               ${ZDOTDIR:-${HOME}}/.zim;`
    puts "\n"

    Dir.chdir(File.join(ENV["HOME"], '.zim', 'templates')) do
      path = Dir.pwd
      template_file_names = Dir.entries(path)
      template_file_names.each do |template_name|
        next if ['.', '..'].include? template_name

        destination_path = File.join(ENV["HOME"], ".#{template_name}")
        template_path = File.join(path, template_name)
        if !File.exist?(destination_path)
          puts "Copying template file #{Tty.green}'#{template_name}'#{Tty.reset} to #{Tty.green} #{destination_path} #{Tty.reset}"
          FileUtils.cp(template_path, destination_path)
        else
          template_lines = File.readlines(template_path)
          destination_contents = File.readlines(destination_path).join('\n')

          percent_included = check_inclusion(destination_contents,
                                             template_lines)

          if (template_lines.join('\n') == destination_contents)
            puts "Your version of file #{Tty.blue} #{template_name} #{Tty.reset} is identical to the template (#{template_path}), not modifying #{destination_path}."
          elsif (percent_included < 0.85)
            puts "#{Tty.red}[ACTION REQUIRED]#{Tty.reset} Your version of file #{Tty.blue} #{template_name} #{Tty.reset} doesn't seem to include the template version, manually copy the template (#{template_path}) into your version (#{destination_path})."
            puts "example command to prepend the template into your copy:"
            puts "\tcat #{template_path} #{destination_path} > tmp && mv tmp #{destination_path}"
          else
            puts "Your version of file #{Tty.blue} #{template_name} #{Tty.reset} seems to already contain the template (#{template_path}), not modifying #{destination_path}."
          end
        end
        puts "\n"
      end
    end

    puts "#{Tty.red}[ACTION REQUIRED]#{Tty.reset} As first time setup, open a new terminal and run:"
    puts "\tsource ${ZDOTDIR:-${HOME}}/.zlogin"
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
      ignored_entries = [ ".", "..", ".git", ".DS_Store", "Brewfile", "iterm2_config" ]
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

  def check_inclusion string_blob, lines
    lines_included = 0
    lines.each do |line|
      if (string_blob.include? line)
        lines_included += 1
      end
    end
    return lines_included.to_f / lines.length
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
