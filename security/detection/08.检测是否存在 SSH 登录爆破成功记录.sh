#/bin/bash
# by 1057

failed_ip=$(mktemp)
success_ip=$(mktemp)
swap=$(mktemp)

# 统计失败 IP
if command -v aureport > /dev/null; then
    aureport -l --failed | awk '/ssh/{print$5}' | sort | uniq >> $swap
fi

for i in $(find /var/log -type f -name btmp*); do
    lastb -f $i
done | awk '/ssh:/{if(/^[ ]/){print$2}else{print$3}}' | sort | uniq >> $swap

sort $swap | uniq > $failed_ip

# 统计成功 IP
> $swap
if command -v aureport > /dev/null; then
    aureport -l --success | awk '/ssh/{print$5}' | sort | uniq >> $swap
fi

for i in $(find /var/log -type f -name wtmp*); do
    last -f $i
done | awk '/pts/{if(/^[ ]/){print$2}else{print$3}}' | sort | uniq >> $swap

sort $swap | uniq > $success_ip

# 检查即失败又成功的 IP
for i in $(cat $success_ip); do
    echo "Checking suspicious IP: $i"
    if grep -q "^$i$" $failed_ip; then
        echo "Logs from aureport for IP: $i"
        echo "============================================"
        echo "# date time auid host term exe success event"
        echo "============================================"
        if command -v aureport > /dev/null; then
            aureport -l | grep --color "\b$i\b"
        fi
        echo "Logs from last[b] for IP: $i"
        for j in $(find /var/log -type f -name [bw]tmp*); do
            last -f $j
        done | grep --color "\b$i\b"
        echo "Logs from journalctl for IP: $i"
        if command -v journalctl > /dev/null; then
            journalctl | awk '/sshd.*(Accepted|Failed)/' | grep --color "\b$i\b"
        fi
        echo "Logs from $(ls /var/log/secure /var/log/auth.log 2> /dev/null) for IP: $i"
        awk '/sshd.*(Accepted|Failed)/' $(ls /var/log/secure /var/log/auth.log 2> /dev/null) | grep --color "\b$i\b"
    fi
done

/bin/rm $failed_ip $success_ip $swap
