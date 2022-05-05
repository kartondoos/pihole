# Linux
This guide is based on Armbian 21.08.1 Buster<br/>
user root<br/>
pw 1234

# setup static ip
nmcli con<br/>
nmcli con mod "Wired connection 1" ipv4.addresses "192.168.1.205/24" <br/>
nmcli con mod "Wired connection 1" ipv4.gateway "192.168.1.1"<br/>
nmcli con mod "Wired connection 1" ipv4.dns "192.168.1.1"<br/>
nmcli con mod "Wired connection 1" ipv4.method "manual"<br/>
reboot to take affect!

# prefrences
prevent root ssh login<br/>
nano /etc/ssh/sshd_config <br/>
change line #PermitRootLogin yes to PermitRootLogin no<br/>
prevent user/or second accont form sudo<br/>
sudo deluser username sudo

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
https://docs.pi-hole.net/guides/dns/unbound/ <br/>
copy the example code at line Configure unbound  
paste the example code in the file  
systemctl restart unbound
login on pihole and go to settings  
uncheck the upstream dns servers that are active  
make a custom upstream dns server  
127.0.0.1#5335  

# install openssl for https on the pi
https://lunarwatcher.github.io/posts/2020/05/14/setting-up-ssl-with-pihole-without-a-fqdn.html
visit this source for the original post! <br/>
Armbian 21.08.1 Focal has a issue for ssl it missing the mod_openssl addon<br/>
its possible the config for ssl goes wrong. you may get a error code :/etc/lighttpd/lighttpd.conf (code=exited status=255)<br/>
if this happands issuse the command pihole -r , remove the external.conf file and optinal rm -rf /etc/sslcerts to restore your pihole<br/>

use the script form lunarwatcher or my simplifyed script 
nano /etc/sslcerts/install-cert.sh paste there the script

edit the file external.conf  
sudo nano /etc/lighttpd/external.conf  
https://discourse.pi-hole.net/t/enabling-https-for-your-pi-hole-web-interface/5771 copy the example code  
edit these 2 lines  
ssl.pemfile = "/etc/letsencrypt/live/pihole.example.com/combined.pem" --> ssl.pemfile = "/etc/sslcerts/combined.pem" <br/>
ssl.ca-file =  "/etc/letsencrypt/live/pihole.example.com/fullchain.pem" --> ssl.ca-file =  "/etc/sslcerts/ca.crt.pem"  
sudo systemctl restart lighttpd.service  


sudo crontab -e  
paste this at the end of the file  
#renew ssl cert  
0 0 1 1 * sudo bash /etc/sslcerts/install-cert.sh >/dev/null 2>&1  
this runs every year at the first of january  


#  want to hoste a other website beside pihole?
cd /var/www/html/
paste here your html pages

or use webservice like apache2
apt install apache2
edit the /etc/apache2/ports.conf and /etc/apache2/sites-enabled/000-default.conf files to listen to diffrent port like 9000 

