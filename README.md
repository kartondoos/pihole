# Linux
This guide is based on debian

# Install pi-hole 
curl -sSL https://install.pi-hole.net | bash  
up stream dns : cloudflare (we change it later if you choose to run recursive dns)  
webadmin : on  
log querys : on  
mode of logs : show everything  
note down your ip on the screen for the web interface   
pihole -a -p yoursecurepassword  
go to the web server   
ipaddress/admin or use pi.hole/admin  

# install recursive dns on the pi  
sudo apt install unbound  
sudo nano /etc/unbound/unbound.conf.d/pi-hole.conf  
https://docs.pi-hole.net/guides/dns/unbound/ copy the example code at line Configure unbound  
paste the example code in the file  
login on pihole and go to settings  
uncheck the upstream dns servers that are active  
make a custom upstream dns server  
127.0.0.1#5335  

# install openssl for https on the pi
sudo apt install openssl  
#Create a CA
openssl req -newkey rsa:4096 -keyout /etc/sslcerts/ca.pk.pem -x509 -new -nodes -out /etc/sslcerts/ca.crt.pem \
-subj "/OU=unknown/O=unknown/L=unknown/ST=unknown/C=unknown" -days 365

#Create a Cert Signing Request  
openssl req -new -newkey rsa:4096 -nodes -keyout /etc/sslcerts/pk.pem -out /etc/sslcerts/csr.pem \
-subj "/CN=unknown/OU=unknown/O=unknown/L=unknown/ST=unknown/C=unknown"

#Sign the certificate  
openssl x509 -req -in /etc/sslcerts/csr.pem -CA /etc/sslcerts/ca.crt.pem -CAkey \
/etc/sslcerts/ca.pk.pem -CAcreateserial -out /etc/sslcerts/crt.pem -days 365

#merging into a combined file  
cat /etc/sslcerts/pk.pem /etc/sslcerts/crt.pem | tee /etc/sslcerts/combined.pem


edit the file external.conf  
sudo nano /etc/lighttpd/external.conf  
https://discourse.pi-hole.net/t/enabling-https-for-your-pi-hole-web-interface/5771 copy the example code  
edit these 2 lines  
ssl.pemfile = "/etc/letsencrypt/live/pihole.example.com/combined.pem" --> ssl.pemfile = "/etc/sslcerts/combined.pem" 
ssl.ca-file =  "/etc/letsencrypt/live/pihole.example.com/fullchain.pem" --> ssl.ca-file =  "/etc/sslcerts/ca.crt.pem"  
sudo systemctl restart lighttpd.service  

#  to renew this certificate make a script in the folder /etc/sslcerts/
sudo nano /etc/sslcerts/install-cert.sh  
openssl req -newkey rsa:4096 -keyout /etc/sslcerts/ca.pk.pem -x509 -new -nodes -out /etc/sslcerts/ca.crt.pem \
-subj "/OU=unknown/O=unknown/L=unknown/ST=unknown/C=unknown" -days 365 
openssl req -new -newkey rsa:4096 -nodes -keyout /etc/sslcerts/pk.pem -out /etc/sslcerts/csr.pem \
-subj "/CN=unknown/OU=unknown/O=unknown/L=unknown/ST=unknown/C=unknown" 
openssl x509 -req -in /etc/sslcerts/csr.pem -CA /etc/sslcerts/ca.crt.pem -CAkey \
/etc/sslcerts/ca.pk.pem -CAcreateserial -out /etc/sslcerts/crt.pem -days 365
cat /etc/sslcerts/pk.pem /etc/sslcerts/crt.pem | tee /etc/sslcerts/combined.pem
sudo systemctl restart lighttpd.service

sudo crontab -e  
paste this at the end of the file  
#renew ssl cert  
0 0 1 1 * sudo bash /etc/sslcerts/install-cert.sh >/dev/null 2>&1  
this runs every year at the first of january  


#  want to hoste a other website beside pihole?
cd /var/www/html/
paste here your html pages
