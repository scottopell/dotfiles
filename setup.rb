#!/usr/bin/env ruby

require "thor"

class Dot < Thor
  package_name "dot_setup"
  # map "-i" => :install

  no_commands do
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

  desc "install", "Install dotfiles for the current user"
  def install
    home = "#{ENV["HOME"]}"
    Dir.chdir(home) do
      files = get_valid_files
      files.each do |f|
        file_name = File.basename f
        target = ".#{file_name}"
        if File.exists? target
          puts "~#{target} already exists, skipping"
          puts "~#{target} is%s a symlink" % [File.symlink?(target)? "": " NOT"]
        else
          puts "Creating symlink for #{file_name}"
          `ln -s #{f} .#{file_name}`
        end
      end
    end
  end

  desc "clean", "Cleans (removes) symlinks to dotfiles"
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

end

Dot.start
