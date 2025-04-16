#!/bin/bash -x
# Pre-req: 04-enable-redhatrepos.sh

# Set up once-off initial sync:
hammer sync-plan delete --name sp_hourly --organization MYMAINORG
hammer sync-plan create --name sp_hourly --organization MYMAINORG --enabled yes --interval hourly --sync-date "`date -d '3 minutes' +'%Y/%m/%d %H:%M:%S'`"
hammer product set-sync-plan --organization MYMAINORG --sync-plan sp_hourly --name "Red Hat Enterprise Linux for x86_64"
hammer product set-sync-plan --organization MYMAINORG --sync-plan sp_hourly --name "Red Hat Satellite Capsule"
# Sync Verification
echo "Sync verification started at `date`"
TIMEOUT=`date -d "12 hours" +%s`
while [ "x${CHK1}${CHK2}${CHK3}${CHK4}${CHK5}${CHK6}${CHK7}${KS1}${KS2}${KS3}${KS4}" != x11111111111 ]; do
  # Exit if timeout exceeded:
  [ `date +%s` -gt $TIMEOUT ] && echo "Timeout Exceeded" && exit

  # Check if each of the repositories has been synced:
  CHK1=`hammer repository info --organization MYMAINORG --product "Red Hat Enterprise Linux for x86_64" --name "Red Hat Enterprise Linux 9 for x86_64 - BaseOS RPMs 9" --fields Sync/status|grep -c Success`

  CHK2=`hammer repository info --organization MYMAINORG --product "Red Hat Enterprise Linux for x86_64"  --name "Red Hat Enterprise Linux 9 for x86_64 - AppStream RPMs 9" --fields Sync/status|grep -c Success`

  CHK3=`hammer repository info --organization MYMAINORG --product "Red Hat Enterprise Linux for x86_64"  --name "Red Hat Satellite Maintenance 6.16 for RHEL 9 x86_64 RPMs" --fields Sync/status|grep -c Success`

  CHK4=`hammer repository info --organization MYMAINORG --product "Red Hat Satellite Capsule"  --name "Red Hat Satellite Capsule 6.16 for RHEL 9 x86_64 RPMs" --fields Sync/status|grep -c Success`

  CHK5=`hammer repository info --organization MYMAINORG --product "Red Hat Enterprise Linux for x86_64" --name "Red Hat Enterprise Linux 8 for x86_64 - BaseOS RPMs 8" --fields Sync/status|grep -c Success`

  CHK6=`hammer repository info --organization MYMAINORG --product "Red Hat Enterprise Linux for x86_64"  --name "Red Hat Enterprise Linux 8 for x86_64 - AppStream RPMs 8" --fields Sync/status|grep -c Success`

  CHK7=`hammer repository info --organization MYMAINORG --product "Red Hat Enterprise Linux for x86_64"  --name "Red Hat Satellite Maintenance 6.16 for RHEL 8 x86_64 RPMs" --fields Sync/status|grep -c Success`

  KS1=`hammer repository info --organization MYMAINORG --product "Red Hat Enterprise Linux for x86_64"  --name "Red Hat Enterprise Linux 9 for x86_64 - BaseOS Kickstart 9.5" --fields Sync/status|grep -c Success`
  KS2=`hammer repository info --organization MYMAINORG --product "Red Hat Enterprise Linux for x86_64"  --name "Red Hat Enterprise Linux 9 for x86_64 - AppStream Kickstart 9.5" --fields Sync/status|grep -c Success`
  KS3=`hammer repository info --organization MYMAINORG --product "Red Hat Enterprise Linux for x86_64"  --name "Red Hat Enterprise Linux 8 for x86_64 - BaseOS Kickstart 8.10" --fields Sync/status|grep -c Success`
  KS4=`hammer repository info --organization MYMAINORG --product "Red Hat Enterprise Linux for x86_64"  --name "Red Hat Enterprise Linux 8 for x86_64 - AppStream Kickstart 8.10" --fields Sync/status|grep -c Success`
  # Sleep for 60 seconds:
  sleep 1
done

hammer sync-plan delete --name sp_hourly --organization MYMAINORG
echo "Sync verification successfully completed at `date`"

# Set up permanent daily sync schedule:
hammer sync-plan delete --name sp_daily --organization MYMAINORG
hammer sync-plan create --name sp_daily --organization MYMAINORG --name sp_daily --enabled yes --interval daily --sync-date "`date +'%Y/%m/%d 03:00:00'`"
hammer product set-sync-plan --organization MYMAINORG --sync-plan sp_daily --name "Red Hat Enterprise Linux for x86_64"
hammer product set-sync-plan --organization MYMAINORG --sync-plan sp_daily --name "Red Hat Satellite Capsule"
