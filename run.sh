#!/bin/bash
#/opt/otrs/bin/otrs.SetPassword.pl --agent root@localhost root &
#wait
#/opt/otrs/bin/otrs.RebuildConfig.pl &
#wait
#/opt/otrs/bin/Cron.sh start otrs &
#wait
#curl -o /tmp/Znuny4OTRS-Repo.opm http://portal.znuny.com/api/addon_repos/public/1420
#/opt/otrs/bin/otrs.PackageManager.pl -a install -p /tmp/Znuny4OTRS-Repo.opm &
#wait
#service httpd start
#wait
#service crond start
#exec /usr/sbin/sshd -D
