#!/bin/bash -x
# Pre-req: 08-setup-activationkeys.sh Completed
# Pre-req: 09-capsule-certs.sh Completed
# Pre-req: expect rpm installed
# Pre-req: Local .pwd file contains desired password to be passed as default root. Replace with keystore as required.
orgs="MYMAINORG,ORG2"
for os in rhel9 rhel8; do
  hammer hostgroup create --organizations $orgs --name hg_$os

  # Apply relevant hostgroup changes at this level:
  # Partition table:
  hammer hostgroup update --organizations $orgs --title hg_$os --partition-table 'Kickstart default'
  # Set default root (disable to-console output):
  set +x
  expect -c "spawn hammer hostgroup update --organizations $orgs --title hg_$os --ask-root-password true; expect "group:" ; send \"$(<.pwd)\r\"; expect eof"
  set -x
  # Set the content view to that of this major OS: (note each org has its own content-view-id for similarly named content views)
  # Required for Provisioning:
  # To make the Install Media configurable at this tier, both a content source and lifecycle environment with access to that media need to be set up.
  # We will set those up to the satellite server and Library respectively so that the OS field can be set.
  # Those two settings are not meant to reach clients. They will be overridden by lower-tier inheriting hostgroups.
  hammer hostgroup update --organizations $orgs --title hg_$os --content-source `hostname -f`
  hammer hostgroup update --organizations $orgs --title hg_$os --architecture x86_64
  case $os in
   rhel8)       hammer hostgroup update --organizations $orgs --title hg_$os --operatingsystem "RedHat 8.10";;
   rhel9)       hammer hostgroup update --organizations $orgs --title hg_$os --operatingsystem "RHEL 9.5";;
   *)           ;;
  esac
  # CV and LCEs have different IDs in each org. We set them to the ID of the primary tenant (MYMAINORG) at the top tier, and override with tenant-specific in the third tier.
  hammer hostgroup update --organization MYMAINORG --title hg_$os --content-view cv_$os
  hammer hostgroup update --organization MYMAINORG --title hg_$os --lifecycle-environment Library

  # Proceed to nested location tier:
  for loc in lab:o2lj-satt2-cap01.iplab.au.singtelgroup.net; do
    area=`echo $loc|cut -d: -f1`
    capsule=`echo $loc|cut -d: -f2`
    hammer hostgroup create --organizations $orgs --name $area --parent-title hg_$os

    # Apply relevant hostgroup changes at this level
    hammer hostgroup update --organizations $orgs --title hg_$os/$area --content-source $capsule

    # Proceed to nested org tier to specify the org's individual content view:
    for org in MYMAINORG ORG2; do
      hammer hostgroup create --organization $org --name $org --parent-title hg_$os/$area
      hammer hostgroup update --organization $org --title hg_$os/$area/$org --content-view cv_$os
      # Proceed to nested environment tier:
      for env in stage nonprod prod; do
        hammer hostgroup create --organization $org --name $env --parent-title hg_$os/$area/$org
        hammer hostgroup update --organization $org --title hg_$os/$area/$org/$env --lifecycle-environment lce_$env
        hammer hostgroup set-parameter --hostgroup-title hg_$os/$area/$org/$env --name kt_activation_keys --value ak_${os}_${env}
      done
    done
  done
done
