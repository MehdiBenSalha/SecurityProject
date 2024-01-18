# Security Project
## Table of Contents :
-  [Introduction](#introduction) 
-  [OpenLDAP](#openldap) 
-  [Apache](#apache) 
-  [OpenVPN](#openvpn) 
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
