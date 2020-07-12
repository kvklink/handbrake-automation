# handbrake-automation ⚙️
Tired of manually running [handbrake](https://handbrake.fr/)? Well I sure am!

This project consists of two scripts that will handle converting media files from pretty much any common format into .mp4 files

## :mag: Dependencies
* Python 3
* [tendo](https://pypi.org/project/tendo/)

## :sa: Usage
There are two files:
* `move_mp4.sh`
* `convert.sh`

Let's assume we have two servers available: one that is power efficient but excruciatingly slow (server A), and one that is very fast, but it's power bill will burn a hole in your wallet (server B).

Server A could schedule a cron job that executes `move_mp4.sh` every so often. This file will look for any media files, and move them from a source directory into a target directory if they are already .mp4 files. When any other media formats are encountered, a Wake-on-LAN packet is sent to server B.

Server B would then run `convert.sh` on startup*, which will also look in a source directory for media files.

After `convert.sh` is finished, it will issue a shutdown command after waiting for two minutes. Feel free to remove the last two lines if this doesn't suit your needs. 

*"But what if I only use one server?"* I hear you ask. Well in that case, just use `convert.sh` and disregard the other script. (And probably remove the aforementioned shutdown...)

###### *\*This could be achieved eg. by using `@reboot` in a crontab*

## :dart: Setup
To use these scripts yourself, be sure to edit the following environment variables:
* `HANDBRAKE_MOVIES_SOURCE_DIR` - Source location of your movies
* `HANDBRAKE_MOVIES_TARGET_DIR` - Destination of converted movies
* `HANDBRAKE_SERIES_SOURCE_DIR` - Source location of TV shows
* `HANDBRAKE_SERIES_TARGET_DIR` - Destination of converted TV shows

On the machine that will be running `move_mp4.sh` be sure to also edit the following:

* `HANDBRAKE_WAKEUP_MAC` - The MAC address that should receive a WoL packet if needed

For both scripts, there is also an optional variable, which is used to add a custom suffix to all handled files. This could be used in combination with other scripts or programs that (for example) check if a files ends in `.CONVERTED.mp4`

Log files are stored in `/var/log/debug.log` for `move_mp4.sh` and `/var/log/convert/debug.log` for `convert.sh`, be sure to create these files in advance, and set up the proper file permissions.

**Last but not least**: don't forget to make all scripts executable (`chmod +x`)

## :beginner: FAQ
* *Help, it's not working* :frowning:
  * Feel free to open an issue and I'll see what I can do!
* *I'm missing feature X* :angry:
  * Again, please open an issue, but no guarantees, as I have other things to do as well :wink:
* *I'd like to contribute!* :smile:
  * That's awesome! I'd love to look at any pull requests
* *This project's name is silly* :confused:
  * I know, I know. I couldn't really think of anything creative... :sweat_smile:
