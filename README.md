dotfiles
========

Nothing exciting or groundbreaking, just my dotfiles.

I try to avoid using other's existing dotfiles, so these are pretty much written from scratch with only the things that I care about.


Added a setup script, requires the gem "thor".

You can do `chmod +x setup.rb` then you can use it without typing ruby in front.
Sometimes its the little things.


```bash
    dot_setup commands:
    setup.rb clean           # Cleans (removes) symlinks to dotfiles
    setup.rb help [COMMAND]  # Describe available commands or one specific command
    setup.rb install         # Install dotfiles for the current user
```
