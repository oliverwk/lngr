echo "# nkd lngr" >> README.md
git add .
git commit -m "First commit"
git branch -M nkd
git remote add origin https://github.com/oliverwk/lngr.git
git push -u origin nkd
