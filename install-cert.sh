# Create a CA
openssl req -newkey rsa:4096 -keyout /etc/sslcerts/ca.pk.pem -x509 -new -nodes -out /etc/sslcerts/ca.cr$-subj "/OU=unknown/O=unknown/L=unknown/ST=unknown/C=unknown" -days 365

# Create a Cert Signing Request
openssl req -new -newkey rsa:4096 -nodes -keyout /etc/sslcerts/pk.pem -out /etc/sslcerts/csr.pem \
-subj "/CN=unknown/OU=unknown/O=unknown/L=unknown/ST=unknown/C=unknown"

# Sign the certificate
openssl x509 -req -in /etc/sslcerts/csr.pem -CA /etc/sslcerts/ca.crt.pem -CAkey \
/etc/sslcerts/ca.pk.pem -CAcreateserial -out /etc/sslcerts/crt.pem -days 365

# See the official post; it requires the private and public key merged into a combined file
cat /etc/sslcerts/pk.pem /etc/sslcerts/crt.pem | tee /etc/sslcerts/combined.pem

#restart httpd
sudo systemctl restart lighttpd.service
