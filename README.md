# kazoo-configs
Kazoo Configuration Files for Software We Use

## Quick & dirty install

1. Fetch this whole repo or fork it
    * `git clone git@github.com:2600hz/kazoo-configs.git ~/.kazoo-configs.git`
1. Symlink this folder to `/etc/kazoo`
    * `sudo ln -s ~/.kazoo-configs.git /etc/kazoo`
1. Get `rsyslog` to log stuff to `/var/log/2600hz/kazoo.log` with
    * `cd /etc/rsyslog.d && sudo ln -s ~/.kazoo-configs.git/system/rsyslog.d/90-2600hzPlatform.conf .`
