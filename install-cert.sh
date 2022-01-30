#user specified!
host=pihole.lan
certValidityDays=365
OU=Unknown
O=Unknown
L=Unknown
ST=Unknown
C=Unknown #dont use unknown a error will follow!

# Create a CA
openssl req -newkey rsa:4096 -keyout /etc/sslcerts/ca.pk.pem -x509 -new -nodes -out \
/etc/sslcerts/ca.crt.pem -subj "/OU=${OU}/O=${O}/L=${L}/ST=${ST}/C=${C}" -days "${certValidityDays}"

# Create a Cert Signing Request
openssl req -new -newkey rsa:4096 -nodes -keyout /etc/sslcerts/pk.pem \
-out /etc/sslcerts/csr.pem -subj "/CN=${host}/OU=${OU}/O=${O}/L=${L}/ST=${ST}/C=${C}"

# Sign the certificate
openssl x509 -req -in /etc/sslcerts/csr.pem -CA /etc/sslcerts/ca.crt.pem \
-CAkey /etc/sslcerts/ca.pk.pem -CAcreateserial -out /etc/sslcerts/crt.pem -days "${certValidityDays}"

# See the official post; it requires the private and public key merged into a combined file
cat /etc/sslcerts/pk.pem /etc/sslcerts/crt.pem | tee /etc/sslcerts/combined.pem

#source code : https://lunarwatcher.github.io/posts/2020/05/14/setting-up-ssl-with-pihole-without-a-fqdn.html
