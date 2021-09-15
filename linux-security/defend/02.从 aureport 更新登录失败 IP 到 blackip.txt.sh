#/bin/bash
for a in $(
    aureport -l --failed | awk '{print$5}' | sort | uniq -c | sort -rn |
        awk '$1>=5{print$2}' # 打印失败次数大等于 5 的 IP
); do
    if ! grep -q "^$a$" blackip.txt; then
        echo "Add IP to blackip.txt: $a"
        echo $a >> blackip.txt
    fi
done
