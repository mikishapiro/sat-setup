#!/bin/bash -x
# Pre-req: 02-install.sh successfully ran
# Pre-req: the manifest for the primary org of the satellite is present and available on the disk
hammer subscription upload --organization "MYMAINORG" --file /root/11111111-1111-1111-1111-111111111111_MYMAINORG.zip

# hammer organization create --name ORG2
# hammer subscription upload --organization "ORG2" --file /root/11111111-1111-1111-1111-111111111111_ORG2.zip

# Proxy settings:
PROXY_IP=10.0.0.1
PROXY=http://$PROXY_IP:443
# Configure a content proxy object:
hammer http-proxy delete --name proxy_$PROXY_IP
hammer http-proxy create --name proxy_$PROXY_IP --url $PROXY --organization-title MYMAINORG 
# hammer http-proxy create --name proxy_$PROXY_IP --url $PROXY --organization-titles MYMAINORG,ORG2
# Select this http_proxy object as the default proxy:
hammer settings set --name content_default_http_proxy --value proxy_$PROXY_IP
# Set the global proxy setting:
hammer settings set --name http_proxy --value $PROXY

# Set the default download policy to immediate:
hammer settings set --name default_redhat_download_policy --value immediate
hammer settings set --name default_proxy_download_policy --value immediate
hammer settings set --name default_download_policy --value immediate

for org in MYMAINORG; do
  hammer subscription refresh-manifest --organization "$org"
done
