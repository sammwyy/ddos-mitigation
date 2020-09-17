# Modules
ignore_ICMP () {
    echo "Installing ICMP Ignore"
    echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
    echo "** Kernel: Setting parameter: icmp_echo_ignore_broadcast -> true"
    echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects
    echo "** Kernel: Setting parameter: accept_redirects -> false"
    iptables -t mangle -A PREROUTING -p icmp -j DROP
    echo "** IPTables: Setting rule: -t mangle -A PREROUTING -p icmp -> DROP"
}

drop_routed_packets () {
    echo "Installing Drop source routed packets"
    echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route
    echo "** Kernel: Setting parameter: accept_source_route -> false"
}

tcp_syn_cookies () {
    echo "Installing TCP Syn cookies"
    sysctl -w net/ipv4/tcp_syncookies=1
    echo "** Kernel: Setting parameter: tcp_syncookies -> true"
}

tcp_syn_backlog () {
    echo "Increasing TCP Syn Backlog"
    echo 2048 > /proc/sys/net/ipv4/tcp_max_syn_backlog
    echo "** Kernel: Setting parameter: tcp_max_syn_backlog -> 2048"
}

tcp_syn_ack () {
    echo "Decreasing TCP Syn-Ack Retries"
    echo 3 > /proc/sys/net/ipv4/tcp_synack_retries
    echo "** Kernel: Setting parameter: tcp_synack_retries -> 3"
}

ip_spoof () {
    echo "Enabling Address Spoofing Protection"
    echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter
    echo "** Kernel: Setting parameter: rp_filter -> true"
}

disable_syn_packet_track () {
    echo "Disabling SYN Packet Track"
    sysctl -w net/netfilter/nf_conntrack_tcp_loose=0
    echo "** Kernel: Setting parameter: nf_conntrack_tcp_loose -> false"
}

drop_invalid_packets () {
    echo "Installing invalid packet drop"
    iptables -A INPUT -m state --state INVALID -j DROP
    echo "** IPTables: Setting rule: -A INPUT -m state INVALID -j DROP"
}

bogus_tcp_flags () {
    echo "Installing Bogus TCP Flags"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
    echo "** IPTables: Setting rule: -t mangle -A PREROUTING --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
    echo "** IPTables: Setting rule: -t mangle -A PREROUTING --tcp-flags FIN,SYN FIN,SYN -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
    echo "** IPTables: Setting rule: -t mangle -A PREROUTING --tcp-flags SYN,RST SYN,RST -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
    echo "** IPTables: Setting rule: -t mangle -A PREROUTING --tcp-flags SYN,FIN SYN,FIN -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
    echo "** IPTables: Setting rule: -t mangle -A PREROUTING --tcp-flags  FIN,RST FIN,RST -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP
    echo "** IPTables: Setting rule: -t mangle -A PREROUTING --tcp-flags FIN,ACK FIN -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP
    echo "** IPTables: Setting rule: -t mangle -A PREROUTING --tcp-flags ACK,URG URG -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP
    echo "** IPTables: Setting rule: -t mangle -A PREROUTING --tcp-flags ACK,FIN FIN -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP
    echo "** IPTables: Setting rule: -t mangle -A PREROUTING --tcp-flags ACK,PSH PSH -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP
    echo "** IPTables: Setting rule: -t mangle -A PREROUTING --tcp-flags ALL ALL -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP
    echo "** IPTables: Setting rule: -t mangle -A PREROUTING --tcp-flags ALL NONE -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
    echo "** IPTables: Setting rule: -t mangle -A PREROUTING --tcp-flags ALL FIN,PSH,URG -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP
    echo "** IPTables: Setting rule: -t mangle -A PREROUTING --tcp-flags ALL SYN,FIN,PSH,URG -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
    echo "** IPTables: Setting rule: -t mangle -A PREROUTING --tcp-flags ALL SYN,RST,ACK,FIN,URG -> DROP"
}

drop_fragment_chains () {
    echo "Installing Chains Fragment drop"
    iptables -t mangle -A PREROUTING -f -j DROP
    echo "** IPTables: Setting rule: -t mangle -A PREROUTING -f -> DROP"
}

tcp_syn_timestamps () {
    echo "Setting TCP Syn Timestamps"
    sysctl -w net/ipv4/tcp_timestamps=1
    echo "** Kernel: Setting parameter: tcp_timestamps -> true"
}

limit_cons_per_ip () {
    echo "Setting connections limit per ip"
    iptables -A INPUT -p tcp -m connlimit --connlimit-above 111 -j REJECT --reject-with tcp-reset
    echo "** IPTables: Setting rule: TCP -m connlimit --connlimit-above 111 -> REJECT WITH TCP RESET"
}

limit_rst_packets () {
    echo "Setting RST packets limit"
    iptables -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT
    echo "** IPTables: Setting rule: -A INPUT -p tcp --tcp-flags RST RST -m limit --limit2/s -> ACCEPT"
    iptables -A INPUT -p tcp --tcp-flags RST RST -j DROP
    echo "** IPTables: Setting rule: -A INPUT -p tcp --tcp-flags RST RST -> DROP"
}

syn_proxy () {
    echo "Installing SYN Proxy"
    iptables -t raw -A PREROUTING -p tcp -m tcp --syn -j CT --notrack
    echo "** IPTables: Setting rule: raw -A PREROUTING -p tcp -m tcp --syn --notrack -> CT"
    iptables -A INPUT -p tcp -m tcp -m conntrack --ctstate INVALID,UNTRACKED -j SYNPROXY --sack-perm --timestamp --wscale 7 --mss 1460
    echo "** IPTables: Setting rule: TCP -m conntrack --ctstate INVALID,UNTRACKET -j SYNPROXY 1460"
    iptables -A INPUT -m state --state INVALID -j DROP
    echo "** IPTables: Setting rule: -A INPUT -m state INVALID -j DROP"
}

prevent_ssh_bf () {
    echo "Installing SSH Bruteforce Detection"
    iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --set
    echo "** IPTables: Setting rule: SSH -m conntrack --ctstate NEW -m recent --set"
    iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP
    echo "** IPTables: Setting rule: SSH --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -> DROP"
}

prevent_port_scanner () {
    echo "Installing Port Scanner Detection"
    iptables -N port-scanning
    echo "** IPTables: Setting rule: -N port-scanning"
    iptables -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN
    echo "** IPTables: Setting rule: TCP SYN,ACK,FIN,RST RST -m limit 1/s --limit-burst 2 -> RETURN"
    iptables -A port-scanning -j DROP
    echo "** IPTables: Setting rule: -A portscanning -> DROP"
}

# Utilities
install_all () {
    ignore_ICMP
    drop_routed_packets
    tcp_syn_cookies
    tcp_syn_backlog
    tcp_syn_ack
    ip_spoof
    disable_syn_packet_track
    drop_invalid_packets
    bogus_tcp_flags
    drop_fragment_chains
    limit_cons_per_ip
    syn_proxy
    prevent_ssh_bf
    prevent_port_scanner
    limit_rst_packets
    tcp_syn_timestamps
}

# MOTD
echo "
    __________                  .__  .__               
    \____    /___________  ____ |  | |__| ____   ____  
      /     // __ \_  __ \/  _ \|  | |  |/    \_/ __ \ 
     /     /\  ___/|  | \(  <_> )  |_|  |   |  \  ___/ 
    /_______ \___  >__|   \____/|____/__|___|  /\___  >
            \/   \/                          \/     \/ 

    ❄ Zeroline v1.0 by sammwy"

echo "
    ╔═════════════════════════════════════════════╗
    ║                                             ║
    ║  1.  Ignore ICMP Packets                    ║
    ║  2.  Drop source routed Packets             ║
    ║  3.  Enable TCP Syn Cookies                 ║
    ║  4.  Enable TCP Timestamps                  ║
    ║  5.  Increase TCP SYN Backlog               ║
    ║  6.  Decrease TCP SYN-ACK Retries           ║
    ║  7.  Enable IP Spoof protection             ║
    ║  8.  Disable SYN Packet track               ║
    ║  9.  Drop invalid packets                   ║
    ║  10. Insert bogus TCP Flags FIN,SYN,RST,ACK ║
    ║  11. Drop Fragments in all Chains           ║
    ║  12. Limit connections per IP               ║
    ║  13. Limit RST Packets                      ║
    ║  14. Use SYN-PROXY                          ║
    ║  15. Prevent SSH Bruteforce                 ║
    ║  16. Prevent Port Scanner                   ║
    ║                                             ║
    ║  99.  Install all scripts                   ║
    ║                                             ║
    ╚═════════════════════════════════════════════╝
"

read -p " Select an option: " option

case $option in
    1) ignore_ICMP;;
    2) drop_routed_packets;;
    3) tcp_syn_cookies;;
    4) tcp_syn_timestamps;;
    5) tcp_syn_backlog;;
    6) tcp_syn_ack;;
    7) ip_spoof;;
    8) disable_syn_packet_track;;
    9) drop_invalid_packets;;
    10) bogus_tcp_flags;;
    11) drop_fragment_chains;;
    12) limit_cons_per_ip;;
    13) limit_rst_packets;;
    14) syn_proxy;;
    15) prevent_ssh_bf;;
    16) prevent_port_scanner;;
    99) install_all;;
    *) echo Option not found;;
esac

echo "Finished! 

    Thanks you for use Zeroline by Sammwy
    Consider donating at: https://paypal.me/sammwy
    Github: https://github.com/sammwyy
"