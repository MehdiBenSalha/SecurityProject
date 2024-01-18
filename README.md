# Security Project
## Table of Contents :
-  [Introduction](#introduction) 
-  [OpenLDAP](#openldap) 
-  [Apache](#apache) 
-  [OpenVPN](#openvpn) 
-  [DNS](#dns) 
## Introduction
This project focuses on configuring and validating network services, emphasizing authentication with OpenLDAP, SSH, Apache, and OpenVPN. Divided into three parts, it covers OpenLDAP setup, SSH and Apache integration, OpenVPN configuration, DNS management, and Kerberos authentication. The repository serves as a guide for implementing secure network services, providing comprehensive documentation for replication and understanding of network security practices.
## OpenLDAP

We need to check the IP address of our machine using the command.
```sh
ifconfig
```

Then we need to configure the hostname and the FQDN (Fully Qualified Domain Name) of the machine.
```sh
hostnamectl set-hostname server
```
We edit the host file :
```sh
sudo vim /etc/hosts
```
By adding this line :
```sh
127.0.1.1 server.insat.tn server
```
We obtain : 

<img src="/Screenshots/Untitled.png" width="250">

Install the OpenLDAP package.
```sh
sudo apt install slapd ldap-utils
```
Start the OpenLDAP service.
```sh
sudo service slapd start
```
Install the Apache web server.
```sh
sudo apt install apache2 php php-cgi libapache2-mod-php php-mbstring php-common
php-pear -y
```
Install LDAP Account Manager (LAM).
```sh
sudo apt -y install ldap-account-manager
```
Activate the PHP-CGI PHP extension.
```sh
sudo a2enconf php*-cgi
```
Configure LDAP Account Manager.
```sh
On accéde à 192.168.56.102/lam
```
Afterward, create users and groups, and assign each user to a group, we obtain the following tree : 

<img src="/Screenshots/Untitled 2.png" width="250">

<img src="/Screenshots/Untitled 3.png" width="250">

<img src="/Screenshots/Untitled 4.png" width="250">

<img src="/Screenshots/Untitled 5.png" width="400">

<img src="/Screenshots/Untitled 6.png" width="300">

<img src="/Screenshots/Untitled 7.png" width="600">

We create the groups : 

<img src="/Screenshots/Untitled 12.png" width="600">

We affect the users to the previously created groups :

<img src="/Screenshots/Untitled 15.png" width="600">

<img src="/Screenshots/Untitled 16.png" width="600">

We obtain this tree : 

<img src="/Screenshots/Untitled 92.png" width="250">

To test LDAP Directory, execute the following command :
```sh
ldapsearch -x -LLL -H ldap:/// -b dc=insat,dc=tn '(uid=user1)'
```
Then we add the certificates : 

<img src="/Screenshots/Untitled 18.png" width="600">

<img src="/Screenshots/Untitled 19.png" width="600">

<img src="/Screenshots/Untitled 20.png" width="600">
	
## Apache
We start by downloading the needed packages : 
```sh
sudo apt-get install apache2-utils
sudo apt-get install libapache2-mod-ldap-userdir
```
Create an index.html page in the folder you want to protect (in our case, it will be "/var/www/html/protected") :

Configure the file /etc/apache2/sites-available/000-default.conf.

```sh
<Directory "/var/www/html/protected">
	AuthType Basic
	AuthName "Restricted Access"
	AuthBasicProvider ldap
	AuthLDAPURL "ldap://localhost/dc=insat,dc=tn?uid?sub?(objectClass=*)"
	AuthLDAPGroupAttribute memberUid
	AuthLDAPGroupAttributeIsDN off
	AuthLDAPBindDN "cn=admin,dc=insat,dc=tn"
	AuthLDAPBindPassword "kali"
	Require ldap-filter &(objectClass=posixAccount)(memberof=CN=group1,OU=group,dc=insat,dc=tn)
	Require ldap-group CN=group1,OU=group,dc=insat,dc=tn
</Directory>
```
With this configuration, if you try to access server.insat.tn/protected, you will be prompted to enter a login and password that are registered in the LDAP server. Additionally, only users from group1 have access to this page.

### DEMO Apache with LDAP 
We try to login with "user2" who's part of the groupe 2 => ACESS DENIED

Then we login with "user1" who's part of the groupe 1 => ACESS ALLOWED

<img src="/Screenshots/APACHE-WITH-LDAP.gif">

## OpenVPN
For the installation and configuration of the OpenVPN server, we used an installation script. 

To download it :

```sh
wget https://git.io/vpn -O openvpn-install.sh && bash openvpn-install.sh
sudo chmod +x openvpn-install.sh
```

Run it with `sudo bash openvpn-install.sh` and configure some server parameters.

<img src="/Screenshots/Untitled 39.png" width="600">

A `server.conf` file will be created in `/etc/openvpn/server` with all the necessary certificates.

<img src="/Screenshots/Untitled 40.png" width="600">

Add these two lines to `server.conf` :
```sh
plugin /usr/lib/openvpn/openvpn-auth-ldap.so /etc/openvpn/auth/auth-ldap.conf
verify client-cert optional
```
Another file, `user1.ovpn` (the client configuration file), will be created in `/root`. 

Add "auth-user-pass" to this file and remove the key and cert sections.

To enable LDAP authentication, install the `openvpn-auth-ldap` package.
```sh
sudo apt install openvpn-auth-ldap
```
The module will be installed in "/usr/lib/openvpn/openvpn-auth-ldap.so". 

Create the configuration file "/etc/openvpn/auth/auth-ldap.conf".
```sh
<LDAP>
	# LDAP server URL
	URL ldap://192.168.56.102
	# Bind DN (If your LDAP server doesn't support anonymous binds)
	BindDN cn=admin,dc=insat,dc=tn
	# Bind Password
	Password kali
	# Network timeout (in seconds)
	Timeout 15
	# Enable Start TLS
	TLSEnable no
</LDAP>
<Authorization>
	# Base DN
	BaseDN ou=user,dc=insat,dc=tn
	# User Search Filter
	SearchFilter "(&(uid=%u)(objectClass=posixAccount))"
	# Require Group Membership
	RequireGroup true
	<Group>
		# Default is true. Match full user DN if true, uid only if false.
		RFC2307bis false
		BaseDN ou=group,dc=insat,dc=tn
		SearchFilter "(|(cn=group1))"
		MemberAttribute memberUid
		# Add group members to a PF table (disabled)
		#PFTable ips_vpn_eng
	</Group>
</Authorization>
```

Restart the OpenVPN service :
```sh
systemctl restart openvpn-server@server
```
Add port 389 (LDAP port) to the firewall of the LDAP server : 
```sh
sudo ufw allow 389
```
Start the OpenVPN server : 
```sh
cd /etc/openvpn/server
sudo openvpn --config server.conf
```
On the client machine, perform the same steps with the "user1.ovpn" file :
```sh
cd /root
sudo openvpn --config user1.conf
```
You will be prompted to enter a login and password stored in the LDAP server. 
> Warning : Only users from group1 can connect to the server.
### DEMO Login OpenVPN with LDAP user
<img src="/Screenshots/OPENVPN-LOGIN.gif">

## DNS
We start by installing “bind9”
```sh
sudo apt install bind9
```
We add the DNS server ip
```sh
sudo nano /etc/resolv.conf
```
<img src="/Screenshots/Untitled 48.png" width="400">

We define our forwarders in `the named.conf.options` file :
```sh
cd /etc/bind
sudo nano named.conf.options
```
<img src="/Screenshots/Untitled 50.png" width="400">

We create a forward zone by defining it in the named.conf.local file, named `insat.tn` which points to `db.insat.tn`.

<img src="/Screenshots/Untitled 51.png" width="400">

We create the `db.insat.tn` file :
```sh
cd /etc/bind
mkdir /zones
sudo nano db.insat.tn
```
The we define our DNS records for OpenLDAP, Apache and OpenVPN :

<img src="/Screenshots/Untitled 56.png" width="400">

### Validation and Testing 
Launch the DNS server :
```sh
sudo /usr/sbin/named -g -c /etc/bind/named.conf -u bind
```
We add the DNS server ip in the client distant machine : 
```sh
sudo nano /etc/resolv.conf
```
<img src="/Screenshots/Untitled 60.png" width="400">

Finally we test the different defined services :
```sh
nslookup ldap.insat.tn
nslookup openvpn.insat.tn
nslookup apache.insat.tn
```
<img src="/Screenshots/Untitled 61.png" width="400">




