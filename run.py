import os
import common

print(os.getcwd())
#common.cli(f'git status')
common.msg('Check Update')
common.cli(f'git checkout master;git reset --hard origin/master')




