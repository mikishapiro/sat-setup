#!/bin/bash -x
# Pre-req: 03-configure-subs.sh successfully ran
# Pre-req: RHEL and Satellite Infrastructure subs in manifest
fnEnableRepo() {
  if [ "x$1" != x ]; then
      # Add other orgs to below list as required
      # for org in MYMAINORG ORG2; do
      for org in MYMAINORG; do
        hammer repository-set enable --organization $org --id $1 --releasever $RELEASE
      done
  fi
}
fnEnableRepoMAIN() {
  if [ "x$1" != x ]; then
    hammer repository-set enable --organization MYMAINORG --id $1 --releasever $RELEASE
  fi
}
hammer repository-set index --organization MYMAINORG > /root/sat-repos.txt

RELEASE=9
echo "Enable sync satellite-capsule-6.16-for-rhel-9-x86_64-rpms"
fnEnableRepoMAIN `grep 'Red Hat Satellite Capsule 6.16 for RHEL 9 x86_64 (RPMs)' /root/sat-repos.txt |awk '{print $1}'`

echo "Enable sync rhel-9-for-x86_64-baseos-rpms"
fnEnableRepo `grep 'Red Hat Enterprise Linux 9 for x86_64 - BaseOS (RPMs)' /root/sat-repos.txt |awk '{print $1}'`

echo "Enable sync rhel-9-for-x86_64-appstream-rpms"
fnEnableRepo `grep 'Red Hat Enterprise Linux 9 for x86_64 - AppStream (RPMs)' /root/sat-repos.txt |awk '{print $1}'`

echo "Enable sync satellite-maintenance-6.16-for-rhel-9-x86_64-rpms"
fnEnableRepo `grep 'Red Hat Satellite Maintenance 6.16 for RHEL 9 x86_64 (RPMs)' /root/sat-repos.txt |awk '{print $1}'`

RELEASE=8
echo "Enable sync rhel-8-for-x86_64-baseos-rpms"
fnEnableRepo `grep 'Red Hat Enterprise Linux 8 for x86_64 - BaseOS (RPMs)' /root/sat-repos.txt |awk '{print $1}'`

echo "Enable sync rhel-8-for-x86_64-appstream-rpms"
fnEnableRepo `grep 'Red Hat Enterprise Linux 8 for x86_64 - AppStream (RPMs)' /root/sat-repos.txt |awk '{print $1}'`

echo "Enable sync satellite-maintenance-6.16-for-rhel-8-x86_64-rpms"
fnEnableRepo `grep 'Red Hat Satellite Maintenance 6.16 for RHEL 8 x86_64 (RPMs)' /root/sat-repos.txt |awk '{print $1}'`

# Kickstart repos
# This is a file repo that contains the entire install media, inclusing OS installer, and a subdirectory with a yum repo
# These are used for provisioning.
RELEASE=9.5
echo "Enable sync rhel-9-for-x86_64-baseos-kickstart"
fnEnableRepo `grep 'Red Hat Enterprise Linux 9 for x86_64 - BaseOS (Kickstart)' /root/sat-repos.txt |awk '{print $1}'`

echo "Enable sync rhel-9-for-x86_64-appstream-kickstart"
fnEnableRepo `grep 'Red Hat Enterprise Linux 9 for x86_64 - AppStream (Kickstart)' /root/sat-repos.txt |awk '{print $1}'`

RELEASE=8.10
echo "Enable sync rhel-8-for-x86_64-baseos-kickstart"
fnEnableRepo `grep 'Red Hat Enterprise Linux 8 for x86_64 - BaseOS (Kickstart)' /root/sat-repos.txt |awk '{print $1}'`

echo "Enable sync rhel-8-for-x86_64-appstream-kickstart"
fnEnableRepo `grep 'Red Hat Enterprise Linux 8 for x86_64 - AppStream (Kickstart)' /root/sat-repos.txt |awk '{print $1}'`
