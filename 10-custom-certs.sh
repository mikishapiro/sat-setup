#!/bin/bash -x

# Pre-reqs: 02-install.sh Completed
mkdir /root/satellite_cert
CERT_KEY=/root/satellite_cert/satellite_cert_key.pem
CERT_CSR=/root/satellite_cert/satellite_cert_csr.pem
OPENSSL_CNF=/root/satellite_cert/openssl.cnf
openssl genrsa -out $CERT_KEY 4096

cat << EOF > $OPENSSL_CNF
[ req ]
req_extensions = v3_req
distinguished_name = req_distinguished_name
prompt = no

[ req_distinguished_name ]
commonName = `hostname -f`

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth, clientAuth, codeSigning, emailProtection
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = `hostname -f`
EOF
openssl req -new -key $CERT_KEY -config $OPENSSL_CNF -out $CERT_CSR

echo "Please sign CSR found in $CERT_CSR"
