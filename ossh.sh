#!/bin/bash
source $(dirname $0)/general.sh

log "Updating repository index..."
sudo apt-get -qq update

log "Install OSSH dependencies..."
sudo apt-get -qq -y install gcc
sudo apt-get -qq -y install build-essential
sudo apt-get -qq -y install zlib1g-dev
sudo apt-get -qq -y install libssl-dev

log "Download and compile OSSH..."
wget -c -O ofcssh.tar.gz https://github.com/brl/obfuscated-openssh/tarball/master
tar zxvf ofcssh.tar.gz
cd brl-obfuscated-openssh-ca93a2c
./configure
make
sudo make install

log "Configuring OSSH..."
mv /usr/local/sbin/sshd /usr/sbin/sshd_ofc
cp /etc/ssh/sshd_config /etc/ssh/sshd_ofc_config
sed -i "s/Port /#Port /g" /etc/ssh/sshd_ofc_config
sed -i "s/UsePAM /#UsePAM /g" /etc/ssh/sshd_ofc_config
echo "ObfuscatedPort 2222" >> /etc/ssh/sshd_ofc_config

tries=5
while [ $tries -ge 5 ]
    log "Configuring OSSH private keys (passphrase)..."
    echo -n "Please enter a strong password: "
    read -n $PASS1
    echo "Repeat: "
    read -n $PASS2
    if [$PASS1 -eq $PASS2] then
        echo "ObfuscateKeyword $PASSWORD" >> /etc/ssh/sshd_ofc_config
        break
    else
        echo "Passwords do not match. $tries tries left"
        let tries -= 1
    fi
done

log "Securing SSH and OSSH..."
chmod 700 ~/.ssh
log "Adding public keys to OSSH and SSH"
for f in ./keys/*
do
	log "Appending key file $f to authorized hists..."
	cat $f >> ~/.ssh/authorized_keys
done

log "Disable password logins for SSH and OSSH..."
sudo sed -i -e 's/#PasswordAuthentication*/PasswordAuthentication no/g' /etc/ssh/sshd_config 
sudo sed -i -e 's/#PasswordAuthentication*/PasswordAuthentication no/g' /etc/ssh/sshd_ofc_config

log "Disabling DSA and ECDSA algorithms for OSSH..."
sed -i -e "s/HostKey \/etc\/ssh\/ssh_host_dsa_key/#HostKey \/etc\/ssh\/ssh_host_dsa_key/g" /etc/ssh/sshd_ofc_config
sed -i -e "s/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/#HostKey \/etc\/ssh\/ssh_host_ecdsa_key/g" /etc/ssh/sshd_ofc_config

log "Reloading SSH and OSSH services..."
sudo service sshd reload
sudo /usr/sbin/sshd_ofc -f /etc/ssh/sshd_ofc_config

log "Make OSSH start automattically..."
sudo echo "/usr/sbin/sshd_ofc -f /etc/ssh/sshd_ofc_config" > /etc/init.d/ssh_ofc
sudo chmod +x /etc/init.d/ssh_ofc
sudo ln -s -f /etc/init.d/ssh_ofc /etc/rcS.d/S42ssh_ofc