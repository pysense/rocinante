## Git 整个系统

```bash
cd /
cat > .gitignore << EOF
/proc
/dev
/sys
/run
/var
/data/mariadb
.bash_history
.viminfo
EOF

git init
git add -A
git commit -m "first commit"
```
