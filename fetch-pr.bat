@echo off
git fetch origin
git checkout master
git reset --hard origin/master
git pull origin master
powershell.exe -Command "git branch | ?{-not ($_ -eq \"* master\")} | %%{git branch -D $_.trim()}"
FOR %%a IN (%*) DO (
git merge origin/pr/%%a
)