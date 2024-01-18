# Security Project
## Table of Contents :
-  [Introduction](#introduction) 
-  [OpenLDAP](#openldap) 
-  [Technologies Used](#technologies-used) 
-  [Installation](#installation) 
-  [API](#api) 
-  [Screenshots](#screenshots) 
-  [Conclusion](#conclusion)
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

<img src="/Screenshots/Untitled.png" width="100">

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
