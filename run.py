import os
import subprocess
import webbrowser
import sys
import common as common

dataFile = {'name': 'efde', 'description': 'Easy and Fast Developer Enviroment'}

menu_option = [
    {"code": "moreInfo",  "title": "More Info", 'description': 'More Info'}
]

def switchOption(code):
    if code == 'moreInfo':
        moreInfo()
    elif code == 'symfony':
        print('SYMFONY')     
    elif code == 'wordpress':
        print('WORDPRESS')
    else: 
        print('no disponible')

def prepareEnvironment(type):

    # Preguntar nombre del directorio
    # Descargar la dockerizacion
    # Descargar el bin/ del proyecto/branch
    print('prepare')

def checkUpdate():
    print(common.msgColor('Check Update','INFO_CYAN'))
    common.cli(f'git checkout master;git reset --hard origin/master;git pull origin master')

def moreInfo():
    url = 'https://gitlab.com/dockerizations/efde'
    if sys.platform == 'darwin':    # in case of OS X
        subprocess.Popen(['open', url])
    else:
        webbrowser.open_new_tab(url)


if __name__ == '__main__':
    #checkUpdate()
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
