#/bin/bash
for a in $(
    for i in $(find /var/log -type f -name btmp*); do
        lastb -f $i
    done | awk '/ssh:/{if(/^[ ]/){print$2}else{print$3}}' | sort | uniq -c | sort -rn | awk '$1>=5{print$2}'
); do
    if ! grep -q "^$a$" blackip.txt; then
        echo "Add:$a"
        echo $a >> blackip.txt
    fi
done
