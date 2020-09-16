# DDoS Mitigation

## Index
- [IPTables](#iptables)
  - [Drop Invalid Packets](#drop-invalid-packets)
  - [Drop TCP packets that are new and are not SYN](#drop-tcp-packets-that-are-new-and-are-not-sync)
  - [Block packets with bogus TCP flags](#block-packets-with-bogus-tcp-flags)
  - [Drop ICMP](#drop-icmp)
  - [Drop Fragments in all Chains](#Drop-Fragments-in-all-Chains)
  - [Limit connections per IP](#Limit-connections-per-IP)
  - [Limit RST Packets](#Limit-RST-packets)
  - [Limit new TCP Connections per seconds per IP](#Limit-new-TCP-Connections-per-seconds-per-IP)
  - [Use of SYN-PROXY](#use-of-syn-proxy)
  - [Prevent SSH Bruteforce](#Prevent-SSH-Bruteforce)
  - [Prevent Port Scanner](#prevent-port-scanner)
  
### Drop Invalid Packets
```
iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP
```

### Drop TCP packets that are new and are not SYN
```
iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
```

### Block packets with bogus TCP flags
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

### Drop ICMP
```
iptables -t mangle -A PREROUTING -p icmp -j DROP
```

### Drop Fragments in all Chains
```
iptables -t mangle -A PREROUTING -f -j DROP
```

### Limit connections per IP
```
iptables -A INPUT -p tcp -m connlimit --connlimit-above 111 -j REJECT --reject-with tcp-reset
```

### Limit RST Packets
```
iptables -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT
iptables -A INPUT -p tcp --tcp-flags RST RST -j DROP
```

### Limit new TCP Connections per seconds per IP
```
iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 60/s --limit-burst 20 -j ACCEPT
iptables -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP
```

### Use of SYN-PROXY
```
iptables -t raw -A PREROUTING -p tcp -m tcp --syn -j CT --notrack
iptables -A INPUT -p tcp -m tcp -m conntrack --ctstate INVALID,UNTRACKED -j SYNPROXY --sack-perm --timestamp --wscale 7 --mss 1460
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
```

### Prevent SSH Bruteforce
```
iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --set
iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP
```

### Prevent Port Scanner
```
iptables -N port-scanning
iptables -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN
iptables -A port-scanning -j DROP
```
