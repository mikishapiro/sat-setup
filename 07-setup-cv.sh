#!/bin/bash -x
# Pre-req: Completed 06-setup-lce.sh

# MYMAINORG-only content: 
org=MYMAINORG
hammer content-view create --organization $org --name cv_capsule
hammer content-view add-repository --organization $org --name cv_capsule --repository "Red Hat Enterprise Linux 9 for x86_64 - BaseOS RPMs 9"
hammer content-view add-repository --organization $org --name cv_capsule --repository "Red Hat Enterprise Linux 9 for x86_64 - AppStream RPMs 9"
hammer content-view add-repository --organization $org --name cv_capsule --repository "Red Hat Satellite Capsule 6.16 for RHEL 9 x86_64 RPMs"
hammer content-view add-repository --organization $org --name cv_capsule --repository "Red Hat Satellite Maintenance 6.16 for RHEL 9 x86_64 RPMs"
for cv in cv_capsule; do
  hammer content-view publish --organization $org --name $cv
  cv_id=`hammer content-view version list|grep -w $cv |sort|tail -1|awk '{print $1}'`
  for lce in lce_stage lce_nonprod lce_prod; do
    hammer content-view version promote --organization $org --id $cv_id --to-lifecycle-environment $lce
  done
done

# All-orgs content:
# for org in MYMAINORG ORG2; do
for org in MYMAINORG; do
  hammer content-view create --organization $org --name cv_rhel9
  hammer content-view add-repository --organization $org --name cv_rhel9 --repository "Red Hat Enterprise Linux 9 for x86_64 - BaseOS RPMs 9"
  hammer content-view add-repository --organization $org --name cv_rhel9 --repository "Red Hat Enterprise Linux 9 for x86_64 - AppStream RPMs 9"
  hammer content-view add-repository --organization $org --name cv_rhel9 --repository "Red Hat Enterprise Linux 9 for x86_64 - BaseOS Kickstart 9.5"
  hammer content-view add-repository --organization $org --name cv_rhel9 --repository "Red Hat Enterprise Linux 9 for x86_64 - AppStream Kickstart 9.5"
  hammer content-view filter create --organization $org --content-view cv_rhel9 --inclusion true --name cvf_rpm_not_in_errata --type rpm --original-packages true
  hammer content-view filter create --organization $org --content-view cv_rhel9 --inclusion true --name cvf_errata_security --type erratum_date
  hammer content-view filter rule create --organization $org --content-view cv_rhel9 --content-view-filter cvf_errata_security --date-type issued --end-date 2025-04-01 --types security

  hammer content-view create --organization $org --name cv_rhel8
  hammer content-view add-repository --organization $org --name cv_rhel8 --repository "Red Hat Enterprise Linux 8 for x86_64 - BaseOS RPMs 8"
  hammer content-view add-repository --organization $org --name cv_rhel8 --repository "Red Hat Enterprise Linux 8 for x86_64 - AppStream RPMs 8"
  hammer content-view add-repository --organization $org --name cv_rhel9 --repository "Red Hat Enterprise Linux 9 for x86_64 - BaseOS Kickstart 8.10"
  hammer content-view add-repository --organization $org --name cv_rhel9 --repository "Red Hat Enterprise Linux 9 for x86_64 - AppStream Kickstart 8.10"
  hammer content-view filter create --organization $org --content-view cv_rhel8 --inclusion true --name cvf_rpm_not_in_errata --type rpm --original-packages true
  hammer content-view filter create --organization $org --content-view cv_rhel8 --inclusion true --name cvf_errata_security --type erratum_date
  hammer content-view filter rule create --organization $org --content-view cv_rhel8 --content-view-filter cvf_errata_security --date-type issued --end-date 2025-04-01 --types security

  hammer content-view filter create --organization $org --content-view cv_rhel9 --inclusion true --name cvf_errata_bugfix_enhancement --type erratum_date
  hammer content-view filter rule create --organization $org --content-view cv_rhel9 --content-view-filter cvf_errata_bugfix_enhancement --date-type issued --end-date 2025-04-01 --types bugfix,enhancement

  for cv in cv_rhel8 cv_rhel9 cv_capsule; do
    hammer content-view publish --organization $org --name $cv
    cv_id=`hammer content-view version list|grep -w $cv |sort|tail -1|awk '{print $1}'`
    for lce in lce_stage lce_nonprod lce_prod; do
      hammer content-view version promote --organization $org --id $cv_id --to-lifecycle-environment $lce
    done
  done
done
