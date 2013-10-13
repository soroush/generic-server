#!/bin/bash
source $(dirname $0)/general.sh

log "Updating repository index..."
sudo apt-get -qq update

log "Installing UFW firewall wrapper..."
sudo apt-get -qq -y install ufw

log "Openning SSH port..."
sudo ufw allow ssh
log "Openning DNS port..."
sudo ufw allow domain
log "Openning HTTP port..."
sudo ufw allow www
log "Openning SMTP port..."
sudo ufw allow smtp
#sudo ufw allow pop2
#sudo ufw allow pop3
log "Openning POP3 SSL/TLS port"
sudo ufw allow pop3s
#sudo ufw allow imap2
#sudo ufw allow imap3
log "Openning IMAP SSL/TLS port"
sudo ufw allow imaps
log "Openning MySQL port"
sudo ufw allow mysql
log "Open SAMBA ports"
sudo ufw allow netbios-ns
sudo ufw allow netbios-dgm
sudo ufw allow netbios-ssn
sudo ufw default deny
sudo ufw enable