# DDoS Mitigation

## Files
**Zeroline** This script automatically and safely installs all the iptables rules and kernel modifications that are in this repository instantly.  
[Download v1.0](https://github.com/sammwyy/ddos-mitigation/blob/master/scripts/zeroline.sh)

## Disclaimer
Some rules may interfere with the functioning of the tools and tips in this repository. Make sure you have an emergency method to disable the Firewall or revert the changes made with this repository in case you lose access to the server.  

## Index
- [Kernel](#kernel-modifications)
  - [Drop ICMP Echo Requests](#Drop-ICMP-ECHO-Requests)
  - [Dont accept ICMP Redirect](#Dont-accept-ICMP-Redirect)
  - [Drop source routed packets](#Drop-source-routed-packets)
  - [Enable SYN-Cookie (for prevent SYN Flood)](#Enable-SYN-Cookie-for-prevent-SYN-Flood)
  - [Increase TCP SYN backlog (for prevent TCP Starvation)](#Increase-TCP-SYN-backlog)
  - [Decrease TCP SYN-ACK retries (for prevent TCP Starvation)](#Decrease-TCP-SYN-ACK-retries)
  - [Enable Address Spoofing Protection](#Enable-Address-Spoofing-Protection)
  - [Disable SYN Packet tracking]("Disable-SYN-Packet-tracking)
- [IPTables](#iptables)
  - [Drop Invalid Packets](#drop-invalid-packets)
  - [Block packets with bogus TCP flags](#block-packets-with-bogus-tcp-flags)
  - [Drop ICMP](#drop-icmp)
  - [Drop Fragments in all Chains](#Drop-Fragments-in-all-Chains)
  - [Limit connections per IP](#Limit-connections-per-IP)
  - [Limit RST Packets](#Limit-RST-packets)
  - [Use of SYN-PROXY](#use-of-syn-proxy)
  - [Prevent SSH Bruteforce](#Prevent-SSH-Bruteforce)
  - [Prevent Port Scanner](#prevent-port-scanner)
 
  
## Kernel Modifications
#### Drop ICMP ECHO-Requests
To prevent smurf attack.
```
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
```

#### Dont accept ICMP Redirect
To prevent smurf attack.
```
echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects
```

#### Drop source routed packets
```
echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route
```

#### Enable SYN-Cookie for prevent SYN Flood
To prevent SYN Flood and TCP Starvation.
```
sysctl -w net/ipv4/tcp_syncookies=1
sysctl -w net/ipv4/tcp_timestamps=1
```

#### Increase TCP SYN backlog
To prevent TCP Starvation.
```
echo 2048 > /proc/sys/net/ipv4/tcp_max_syn_backlog
```

#### Decrease TCP SYN-ACK retries
To prevent TCP Starvation.
```
echo 3 > /proc/sys/net/ipv4/tcp_synack_retries
```

#### Enable Address Spoofing Protection
To prevent IP Spoof.
```
echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter
```

#### Disable SYN Packet tracking
To prevent the system from using resources tracking SYN Packets.
```
sysctl -w net/netfilter/nf_conntrack_tcp_loose=0
```

## IPTables
#### Drop Invalid Packets
Drop invalid packets with invalid or unknown status.
```
iptables -A INPUT -m state --state INVALID -j DROP
```

#### Block packets with bogus TCP flags
```
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
```

#### Drop ICMP
To prevent Smurf Attack.
```
iptables -t mangle -A PREROUTING -p icmp -j DROP
```

#### Drop Fragments in all Chains
```
iptables -t mangle -A PREROUTING -f -j DROP
```

#### Limit connections per IP
```
iptables -A INPUT -p tcp -m connlimit --connlimit-above 111 -j REJECT --reject-with tcp-reset
```

#### Limit RST Packets
```
iptables -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT
iptables -A INPUT -p tcp --tcp-flags RST RST -j DROP
```

#### Use of SYN-PROXY
```
iptables -t raw -A PREROUTING -p tcp -m tcp --syn -j CT --notrack
iptables -A INPUT -p tcp -m tcp -m conntrack --ctstate INVALID,UNTRACKED -j SYNPROXY --sack-perm --timestamp --wscale 7 --mss 1460
iptables -A INPUT -m state --state INVALID -j DROP
```

#### Prevent SSH Bruteforce
```
iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --set
iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP
```

#### Prevent Port Scanner
```
iptables -N port-scanning
iptables -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN
iptables -A port-scanning -j DROP
```

## Sources
- [hackplayers.com](https://www.hackplayers.com/2016/04/proteccion-ddos-mediante-iptables.html)
- [stackexchange.com](https://security.stackexchange.com/questions/4603/tips-for-a-secure-iptables-config-to-defend-from-attacks-client-side)
