#!/bin/bash

# First argument: Client identifier

cat /etc/openvpn/client-configs/base.conf \
    <(echo -e '<ca>') \
    /etc/openvpn/pki/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    /etc/openvpn/pki/issued/${1}.crt \
    <(echo -e '</cert>\n<key>') \
    /etc/openvpn/pki/private/${1}.key \
    <(echo -e '</key>\n<tls-auth>') \
    /etc/openvpn/ta.key \
    <(echo -e '</tls-auth>') \
    > /etc/openvpn/client-configs/${1}.ovpn