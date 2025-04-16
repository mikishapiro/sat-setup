#!/bin/bash -x
# Pre-req: Completed 05-configure-syncplan.sh

# Set up once-off initial sync:
# for org in MYMAINORG ORG2; do
for org in MYMAINORG; do
  prev_env=Library
  for env in lce_{stage,nonprod,prod}; do
    hammer lifecycle-environment create --name $env --organization $org --prior $prev_env
    prev_env=$env
  done
done
