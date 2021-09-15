## Git 整个系统

```bash
cd /
cat > .gitignore << EOF
/etc/ld.so.cache
.zsh_history
/proc
/var/lib/docker
EOF

git init
git add -A
git commit -m "first commit"
```
