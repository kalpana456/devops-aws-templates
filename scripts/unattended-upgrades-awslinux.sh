#!/bin/sh
#drop this shell script into /etc/cron.daily/yumupdate

YUM=/usr/bin/yum

# -y == assume yes
# -d == debug verbosity
# -e == error-reporting level
# -R == wait 0~n min before running the command (randomise)

# clear all packages, dependency headers, metadata and metadata cache
${YUM} -y -d 0 -e 0 clean all

# update the yum package itself
${YUM} -y -d 0 -e 0 update yum

# update everything
${YUM} -y -R 10 -e 0 -d 0 update
