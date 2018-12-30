#
###
#### Default proper configuration
###
#


## Reset tables configurations
#
echo "📦  Reset tables configurations"

# Flush all rules
echo "   -- Flush iptable rules"
iptables -F
iptables -F -t nat
iptables -F -t mangle
iptables -F -t raw
# Erase all non-default chains
echo "   -- Erase all non-default chains"
iptables -X
iptables -X -t nat
iptables -X -t mangle
iptables -X -t raw


## Trafic configurations
#
echo "⚙️  Trafic configurations"
# Block all traffic by default
echo "   -- Block all traffic by default"
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
echo "   -- Allow all and everything on localhost"
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
# Allow established connections TCP
echo "   -- Allow established connections TCP"
iptables -A INPUT -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
# Allow established connections UDP
echo "   -- Allow established connections UDP"
iptables -A INPUT -p udp -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p udp -m state --state ESTABLISHED,RELATED -j ACCEPT
# Allow pings
echo "   -- Allow output pings"
iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 8 -j ACCEPT
# Allow SSH connection on 69 port
echo "   -- Allow SSH connection on 69 port"
iptables -A INPUT -p tcp --dport 69 -j ACCEPT
# Allow HTTP
echo "   -- Allow HTTP"
iptables -t filter -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
# Allow HTTPS
echo "   -- Allow HTTPS"
iptables -t filter -A OUTPUT -p tcp --dport 443 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 443 -j ACCEPT


## Mail configurations
#
echo "✉️  Mail configurations"
# Allow SMTP
echo "   -- Allow SMTP"
iptables -t filter -A INPUT -p tcp --dport 25 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 25 -j ACCEPT
# Allow POP3
echo "   -- Allow POP3"
iptables -t filter -A INPUT -p tcp --dport 110 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 110 -j ACCEPT
# Allow IMAP
echo "   -- Allow IMAP"
iptables -t filter -A INPUT -p tcp --dport 143 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 143 -j ACCEPT
# Allow POP3S
echo "   -- Allow POP3S"
iptables -t filter -A INPUT -p tcp --dport 995 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 995 -j ACCEPT


## DDoS protections
#
echo "🛡  DDoS protetion"

# Synflood protection
echo "   -- Synflood protection"
/sbin/iptables -A INPUT -p tcp --syn -m limit --limit 2/s --limit-burst 30 -j ACCEPT
# Pingflood protection
echo "   -- Pingflood protection"
/sbin/iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT
# Port scanning protection
echo "   -- Port scanning protection"
/sbin/iptables -A INPUT -p tcp --tcp-flags ALL NONE -m limit --limit 1/h -j ACCEPT
/sbin/iptables -A INPUT -p tcp --tcp-flags ALL ALL -m limit --limit 1/h -j ACCEPT


## Save the tables configuration
#
iptables-save > /etc/iptables/rules.v4
