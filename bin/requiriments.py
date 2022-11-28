import os, sys, subprocess
from . import common

dataFile = {'name': 'Requiriments', 'description': 'Configure local domain'}

pathDokerCompose = 'cd .. && '
pathDokerCompose = ''
menuReturn =  ''
menu_option = [
    {"code": "configure",  "title": "Configure", 'description': 'configure bin/.env, /etc/hosts, symfony'},
    {"code": "check",  "title": "Checks", 'description': 'Verifica, bin/.env, /etc/hosts, symfony'}
]

varEnv = 'DOMAIN_LCL'

def switchOption(code):
    if code == 'check':
        return
    elif code == 'configure':
        return
    else:
        print('You must select an option')

def configureCheck():
    
if __name__ == '__main__':
    showHelper = False
    while True:
        common.menu_print(menu_option, dataFile, showHelper)
        opt=input(common.msgColor('\nEnter your option: ','OKGREEN'))

        if opt == 'q': exit()
        elif opt == 'r': 
            common.cli("clear")
            exit()
        elif opt == 'h':
            showHelper = not(showHelper)
            common.cli("clear")
        elif opt.isnumeric() and (int(opt) in range(0,len(menu_option))):
            code = menu_option[int(opt)]['code']
            switchOption(code)

            input(common.msgColor('\nPress enter to return to the menu','OKGREEN'))
            common.cli("clear")
        else:
            input(common.msgColor(f'The option "{opt}" is not in the list. Press enter to continue','DANGER'))
            common.cli('clear')
            continue
