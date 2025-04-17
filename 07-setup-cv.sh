#!/bin/bash -x
# Pre-req: Completed 06-setup-lce.sh

# MYMAINORG-only content: 
org=MYMAINORG
cv=cv_capsule
hammer content-view create --organization $org --name $cv
repo_id=`hammer repository list --organization $org |grep "Red Hat Satellite Maintenance 6.16 for RHEL 9 x86_64 RPMs"       |awk '{print $1}'`
hammer content-view add-repository --organization $org --name cv_capsule --repository-id $repo_id
repo_id=`hammer repository list --organization $org |grep "Red Hat Enterprise Linux 9 for x86_64 - BaseOS RPMs 9"           |awk '{print $1}'`
hammer content-view add-repository --organization $org --name cv_capsule --repository-id $repo_id
repo_id=`hammer repository list --organization $org |grep "Red Hat Enterprise Linux 9 for x86_64 - AppStream RPMs 9"        |awk '{print $1}'`
hammer content-view add-repository --organization $org --name cv_capsule --repository-id $repo_id
repo_id=`hammer repository list --organization $org |grep "Red Hat Satellite Capsule 6.16 for RHEL 9 x86_64 RPMs"           |awk '{print $1}'`
hammer content-view add-repository --organization $org --name cv_capsule --repository-id $repo_id
hammer content-view publish --organization $org --name
cv_id=`hammer content-view version list|grep -w $cv|awk '/Library/{print $1}'`
for lce in lce_stage lce_nonprod lce_prod; do
  hammer content-view version promote --organization $org --id $cv_id --to-lifecycle-environment $lce
done

# All-orgs content:
for org in MYMAINORG ORG2; do
  # Create a RHEL9 CV:
  hammer content-view create --organization $org --name cv_rhel9
  # Add repos:
  repo_id=`hammer repository list --organization $org |grep "Red Hat Satellite Maintenance 6.16 for RHEL 9 x86_64 RPMs"       |awk '{print $1}'`
  hammer content-view add-repository --organization $org --name cv_rhel9 --repository-id $repo_id
  repo_id=`hammer repository list --organization $org |grep "Red Hat Enterprise Linux 9 for x86_64 - BaseOS RPMs 9"           |awk '{print $1}'`
  hammer content-view add-repository --organization $org --name cv_rhel9 --repository-id $repo_id
  repo_id=`hammer repository list --organization $org |grep "Red Hat Enterprise Linux 9 for x86_64 - AppStream RPMs 9"        |awk '{print $1}'`
  hammer content-view add-repository --organization $org --name cv_rhel9 --repository-id $repo_id
  repo_id=`hammer repository list --organization $org |grep "Red Hat Enterprise Linux 9 for x86_64 - BaseOS Kickstart 9.5"    |awk '{print $1}'`
  hammer content-view add-repository --organization $org --name cv_rhel9 --repository-id $repo_id
  repo_id=`hammer repository list --organization $org |grep "Red Hat Enterprise Linux 9 for x86_64 - AppStream Kickstart 9.5" |awk '{print $1}'`
  hammer content-view add-repository --organization $org --name cv_rhel9 --repository-id $repo_id

  # Add Filter 1: All GA stuff
  hammer content-view filter create --organization $org --content-view cv_rhel9 --inclusion true --name cvf_rpm_not_in_errata --type rpm --original-packages true
  # Add Filter 2: Everything in the security stream up to the nominated date
  hammer content-view filter create --organization $org --content-view cv_rhel9 --inclusion true --name cvf_errata_security --type erratum_date
  hammer content-view filter rule create --organization $org --content-view cv_rhel9 --content-view-filter cvf_errata_security --date-type issued --end-date 2025-04-01 --types security
  # Add Filter 3: Everything in the bugfix and enhancement stream up to the nominated date
  hammer content-view filter create --organization $org --content-view cv_rhel9 --inclusion true --name cvf_errata_bugfix_enhancement --type erratum_date
  hammer content-view filter rule create --organization $org --content-view cv_rhel9 --content-view-filter cvf_errata_bugfix_enhancement --date-type issued --end-date 2025-04-01 --types bugfix,enhancement
  # rhel9 CV is ready for publication.

  # Create a RHEL8 CV:
  hammer content-view create --organization $org --name cv_rhel8
  # Add repos:
  repo_id=`hammer repository list --organization $org |grep "Red Hat Satellite Maintenance 6.16 for RHEL 8 x86_64 RPMs"        |awk '{print $1}'`
  hammer content-view add-repository --organization $org --name cv_rhel8 --repository-id $repo_id
  repo_id=`hammer repository list --organization $org |grep "Red Hat Enterprise Linux 8 for x86_64 - BaseOS RPMs 8"            |awk '{print $1}'`
  hammer content-view add-repository --organization $org --name cv_rhel8 --repository-id $repo_id
  repo_id=`hammer repository list --organization $org |grep "Red Hat Enterprise Linux 8 for x86_64 - AppStream RPMs 8"         |awk '{print $1}'`
  hammer content-view add-repository --organization $org --name cv_rhel8 --repository-id $repo_id
  repo_id=`hammer repository list --organization $org |grep "Red Hat Enterprise Linux 8 for x86_64 - BaseOS Kickstart 8.10"    |awk '{print $1}'`
  hammer content-view add-repository --organization $org --name cv_rhel8 --repository-id $repo_id
  repo_id=`hammer repository list --organization $org |grep "Red Hat Enterprise Linux 8 for x86_64 - AppStream Kickstart 8.10" |awk '{print $1}'`
  hammer content-view add-repository --organization $org --name cv_rhel8 --repository-id $repo_id

  # Add Filter 1: All GA stuff
  hammer content-view filter create --organization $org --content-view cv_rhel8 --inclusion true --name cvf_rpm_not_in_errata --type rpm --original-packages true
  # Add Filter 2: Everything in the security stream up to the nominated date
  hammer content-view filter create --organization $org --content-view cv_rhel8 --inclusion true --name cvf_errata_security --type erratum_date
  hammer content-view filter rule create --organization $org --content-view cv_rhel8 --content-view-filter cvf_errata_security --date-type issued --end-date 2025-04-01 --types security
  # Add Filter 3: Everything in the bugfix and enhancement stream up to the nominated date
  hammer content-view filter create --organization $org --content-view cv_rhel8 --inclusion true --name cvf_errata_bugfix_enhancement --type erratum_date
  hammer content-view filter rule create --organization $org --content-view cv_rhel8 --content-view-filter cvf_errata_bugfix_enhancement --date-type issued --end-date 2025-04-01 --types security

  for cv in cv_rhel8 cv_rhel9; do
    hammer content-view publish --organization $org --name $cv
    cv_id=`hammer content-view version list --organization $org|grep -w $cv|awk '/Library/{print $1}'`
    for lce in lce_stage lce_nonprod lce_prod; do
      hammer content-view version promote --organization $org --id $cv_id --to-lifecycle-environment $lce
    done
  done
done
