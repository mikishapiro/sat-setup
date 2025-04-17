#!/bin/bash -x
# Pre-req: Completed 07-setup-cv.sh

# Create a key for the capsule:
hammer activation-key create --organization MYMAINORG --auto-attach false --name ak_capsule --lifecycle-environment lce_prod --content-view cv_capsule
# Make the capsule key enable the capsule dnf repositories when it is used:
hammer activation-key content-override --organization MYMAINORG --name ak_capsule --content-label satellite-capsule-6.16-for-rhel-9-x86_64-rpms --override-name enabled --value 1
hammer activation-key content-override --organization MYMAINORG --name ak_capsule --content-label satellite-maintenance-6.16-for-rhel-9-x86_64-rpms --override-name enabled --value 1

# Create a key for the RHEL SOE (all orgs):
for org in MYMAINORG ORG2; do
  for os in rhel8 rhel9; do
    # repeat for rhel8 and rhel9
    for lce in stage nonprod prod; do
      hammer activation-key create --organization $org --auto-attach false --name ak_${os}_${lce} --lifecycle-environment lce_$lce --content-view cv_$os
    done
  done
done

