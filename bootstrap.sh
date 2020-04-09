#!/bin/bash

# this script assumes we are running on an a machine called "Control"

rm -f /srv/salt
ln -s /srv/iris-experiment-system/salt /srv/salt

apt install -y salt-master salt-minion
systemctl enable salt-master
systemctl restart salt-master

# HTCondor pool password
mkdir -p /srv/salt/local-conf
uuidgen >/srv/salt/local-conf/htcondor--pool_password

echo 'master: Control' >/etc/salt/minion.d/50-main.conf
perl -p -i -e 's;#default_include.*;default_include: minion.d/*.conf;' /etc/salt/minion
salt-call --state-verbose=false state.highstate
salt-key -y -a Control
salt-call --state-verbose=false state.highstate
systemctl enable salt-minion
systemctl restart salt-minion

# configure the salt master

for MINION in `cat /etc/hosts | egrep 'Compute|Submit' | sed 's/.*\t//' | sort`; do
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $MINION \
	"apt install -y salt-minion ; echo 'master: Control' >/etc/salt/minion.d/50-main.conf ; perl -p -i -e 's;#default_include.*;default_include: minion.d/*.conf;' /etc/salt/minion ; salt-call --state-verbose=false state.highstate"
    salt-key -y -a $MINION
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $MINION \
	"salt-call --state-verbose=false state.highstate ; systemctl enable salt-minion ; systemctl restart salt-minion"
done


