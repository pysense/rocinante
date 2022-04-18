#/bin/bash
# by 1057

failed_ip=$(mktemp)
success_ip=$(mktemp)
swap=$(mktemp)

# 统计失败 IP
> $swap
echo "> 从 lastb 获取登录失败 IP"
for i in $(find /var/log -type f -name btmp*); do
    lastb -f $i
done | awk '/ssh:/{if(/^[ ]/){print$2}else{print$3}}' | sort | uniq >> $swap

echo "> 从 aureport 获取登录失败 IP"
if command -v aureport > /dev/null; then
    aureport -l --failed | awk '/ssh/{print$5}' | sort | uniq >> $swap
fi

echo "> 从 journalctl 获取登录失败 IP"
if command -v journalctl > /dev/null; then
    journalctl | awk '/sshd.*Failed/{print$(NF-3)}' | grep -Eo "([0-9]+\.){3}[0-9]+" | sort | uniq >> $swap
fi

echo "> 从 /var/log 获取登录失败 IP"
cat $(ls /var/log/secure /var/log/auth.log 2> /dev/null) | awk '/sshd.*Failed/{print$(NF-3)}' | grep -Eo "([0-9]+\.){3}[0-9]+" | sort | uniq >> $swap

# 失败 IP 去重
sort $swap | uniq > $failed_ip

# 统计成功 IP
> $swap
echo "> 从 last 获取登录成功 IP"
for i in $(find /var/log -type f -name wtmp*); do
    last -f $i
done | awk '/pts/{if(/^[ ]/){print$2}else{print$3}}' | sort | uniq >> $swap

echo "> 从 aureport 获取登录成功 IP"
if command -v aureport > /dev/null; then
    aureport -l --success | awk '/ssh/{print$5}' | sort | uniq >> $swap
fi

echo "> 从 journalctl 获取登录成功 IP"
if command -v journalctl > /dev/null; then
    journalctl | awk '/sshd.*Accepted/{print$(NF-5)}' | grep -Eo "([0-9]+\.){3}[0-9]+" | sort | uniq >> $swap
fi

echo "> 从 /var/log 获取登录成功 IP"
cat $(ls /var/log/secure /var/log/auth.log 2> /dev/null) | awk '/sshd.*Accepted/{print$(NF-5)}' | grep -Eo "([0-9]+\.){3}[0-9]+" | sort | uniq >> $swap

# 成功 IP 去重
sort $swap | uniq > $success_ip

# 检查即失败又成功的 IP
for i in $(cat $success_ip); do
    echo "检查登录成功 IP 是否存在失败记录: $i"
    if grep -q "^$i$" $failed_ip; then
        echo ">>> 01. Logs from last[b] for IP: $i"
        for j in $(find /var/log -type f -name [bw]tmp*); do
            last -f $j
        done | grep --color "\b$i\b"
        echo ">>> 02. Logs from aureport for IP: $i"
        echo "============================================"
        echo "# date time auid host term exe success event"
        echo "============================================"
        if command -v aureport > /dev/null; then
            aureport -l | grep --color "\b$i\b"
        fi
        echo ">>> 03. Logs from journalctl for IP: $i"
        if command -v journalctl > /dev/null; then
            journalctl | awk '/sshd.*(Accepted|Failed)/' | grep --color "\b$i\b"
        fi
        echo ">>> 04. Logs from $(ls /var/log/secure /var/log/auth.log 2> /dev/null) for IP: $i"
        awk '/sshd.*(Accepted|Failed)/' $(ls /var/log/secure /var/log/auth.log 2> /dev/null) | grep --color "\b$i\b"
    fi
done

/bin/rm $failed_ip $success_ip $swap
