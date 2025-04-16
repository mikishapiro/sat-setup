#!/bin/bash -x
# Pre-req: a file called .pwd that has the password that will be set to the Satellite local administrator account
# Pre-req: successfully run 01-repos.sh
# Pre-req: pass in the password to apply via a local .pwd file
satellite-installer --scenario satellite \
--foreman-initial-organization "NE" \
--foreman-initial-location "All Locations" \
--foreman-initial-admin-username administrator \
--foreman-initial-admin-password "$(<.pwd)"

systemctl enable firewalld
firewall-cmd --zone=public --add-port=443/tcp --permanent
firewall-cmd --reload

echo "Logs can be found in /var/log/foreman-installer/satellite.log"
