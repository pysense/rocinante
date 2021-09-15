#!/bin/bash
if [[ ! -f /etc/hosts.deny.vbak ]]; then
    cp /etc/hosts.deny{,.vbak}
fi
for i in $(cat blackip.txt); do
    if ! grep -q "^sshd:$i$" /etc/hosts.deny; then
        echo "Add:$i"
        echo "sshd:$i" >> /etc/hosts.deny
    fi
done
if ! read -t 30 -p "请在 30秒内按下 Enter 键以确认当前配置未导致 SSH 连接丢失，否则配置将回退。"; then
    mv -f /etc/hosts.deny.vbak /etc/hosts.deny
fi
