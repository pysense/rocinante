#/bin/bash

for a in $(
    cat $(ls /var/log/secure /var/log/auth.log 2> /dev/null) | awk '/sshd.*Failed/{print$(NF-3)}' | grep -Eo "([0-9]+\.){3}[0-9]+" |
        sort | uniq -c | sort -rn | awk '$1>=5{print$2}' # 打印失败次数大等于 5 的 IP
); do
    if ! grep -q "^$a$" blackip.txt; then
        echo "Add IP to blackip.txt: $a"
        echo $a >> blackip.txt
    fi
done
