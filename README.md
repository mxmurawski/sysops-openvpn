This repository is an instruction how to install and configure OpenVPN server on Ubuntu.

Required software: openvpn, easy-rsa

Let's switch working directory to /etc/openvpn and iterpersonate as root user.

Create easy-rsa directory and change its permissions by executing below command:
```
mkdir /etc/openvpn/easy-rsa && chmod 700 /etc/openvpn/easy-rsa
```
Link easy-rsa files containing certificate authority management scripts to /etc/openvpn/easy-rsa by executing below command:
```
ln -s /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/
```
Create /etc/openvpn/easy-rsa/vars file by executing below command:
```
cat /path/to/repo/vars > /etc/openvpn/easy-rsa/vars
```
Initialize PKI and build certificate authority by executing below command:
```
/etc/openvpn/easy-rsa/easyrsa init-pki && /etc/openvpn/easy-rsa/easyrsa build-ca
```
Now provide CA password and confirm it in the next step. At the end You will be prompted to enter Common Name for the CA that is being built. Executing above commands will result in creation of pki directory in /etc/openvpn.

Generate Diffie-Hellman parameters file by executing below command:
```
openssl dhparam -out /etc/openvpn/dh2048.pem 2048
```
Create certificate request for server by executing below command:
```
/etc/openvpn/easy-rsa/easyrsa gen-req server nopass
```
You will be prompted to provide Common Name for server's certificate. You can leave default value which is server.

Sign server's certificate request by executing below command:
```
/etc/openvpn/easy-rsa/easyrsa sign-req server server
```
You will be prompted to confirm by typing "yes". Next You have to provide CA password.

Generate tls-crypt pre-shared key:
```
openvpn --genkey secret /etc/openvpn/ta.key
```
Create certificate request for client by executing below command:
```
/etc/openvpn/easy-rsa/easyrsa gen-req client1 nopass
```
You will be prompted to provide Common Name for client's certificate. You can leave default value which is client1.

Sign client's certificate request by executing below command:
```
/etc/openvpn/easy-rsa/easyrsa sign-req client client1
```
You will be prompted to confirm by typing "yes". Next You have to provide CA password.

Copy /path/to/repo/server.conf file to /etc/openvpn by executing below command:
```
cp /path/to/repo/server.conf /etc/openvpn/
```
Adjust this file to your own needs:
```
server 10.8.0.0 255.255.255.0 - this line defines tunnel network in which clients and server will reside.
```
```
push "route 192.168.0.0 255.255.255.0" - this line defines network to which You may want to provide routing to VPN server's clients.
```
```
push "redirect-gateway def1 bypass-dhcp" - this line changes clients' default gateway to VPN server's IP address. This is useful if You want VPN server's users to forward whole network traffic through your VPN server.
```
```
push "dhcp-option DNS 8.8.8.8" - this line changes clients' DNS server address. This is useful if You want to provide to VPN server's users access to Your internal DNS server if You have one.
```
```
duplicate-cn - this line allows users to creatate multiple connections to VPN server using the same ovpn file.
```
Now uncomment below line in /etc/sysctl.conf:
```
net.ipv4.ip_forward=1
```
At the beginning of /etc/ufw/before.rules append below block:
```
# START OPENVPN RULES
# NAT table rules
*nat
:POSTROUTING ACCEPT [0:0]
# Allow traffic from OpenVPN client to eth0 (change to the interface you discovered!)
-A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
COMMIT
# END OPENVPN RULES
```
You have to check if the network address agrees with the one provided in /etc/openvpn/server.conf and interface name agrees with the one You use for the remote users' connections.

Now edit file /etc/default/ufw by replacing:
```
DEFAULT_FORWARD_POLICY="DROP"
```
To:
```
DEFAULT_FORWARD_POLICY="ACCEPT"
```
Let's prepare for enabling system's firewall. First avoid locking-out by allowing traffic on port 22 by executing below command:
```
ufw allow 22
```
Then allow traffic on port 1194 by executing below commands:
```
ufw allow 1194
```
Finally enable firewall by executing bellow command:
```
ufw enable
```
Confirm enabling by pressing "y".
The last step to enable and start VPN server server is to execute below command:
```
systemctl enable openvpn@server.service && systemctl start openvpn@server.service
```
Now your VPN server is running. Let's prepare for creating users' configuration .ovpn files automatically. To do this, create /etc/openvpn/client-configs directory, assign proper file permissions and copy /path/to/repo/make_config.sh file by executing bellow command:
```
mkdir /etc/openvpn/client-configs ; chmod 700 /etc/openvpn/client-configs ; cp /path/to/repo/make_config.sh /etc/openvpn/client-configs ; chmod +x /etc/openvpn/client-configs/make_config.sh
```
Execute script with the name of client certificate's name which is client1 by executing below command:
```
/etc/openvpn/client-configs/make_config.sh client1
```
Copy /etc/openvpn/client-configs/client1.ovpn file to a client machine, import it to OpenVPN Connect and enjoy Your VPN connection :-)