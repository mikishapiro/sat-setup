#!/bin/bash -x
# Pre-req: Perform subscription-manager register using an account linked to the subs.
subscription-manager repos --disable "*"
subscription-manager repos \
--enable=rhel-9-for-x86_64-baseos-rpms \
--enable=rhel-9-for-x86_64-appstream-rpms \
--enable=satellite-6.16-for-rhel-9-x86_64-rpms \
--enable=satellite-maintenance-6.16-for-rhel-9-x86_64-rpms
dnf -y install expect
dnf -y module enable satellite:el9
dnf -y upgrade
dnf -y install satellite
