import os
import subprocess
import webbrowser
import sys
import codecs
#import bin.common as common, bin.environment as environment, bin.composer as composer, bin.domain  as domain, bin.mysql as mysql 
from bin import common, environment, composer, domain, mysql

dataFile = {'name': 'efde', 'description': 'Easy and Fast Developer Enviroment'}

menu_option_start = [
    {"code": "moreInfo",  "title": "More Info", 'description': 'More Info'},
    {"code": "symfony",  "title": "Install Symfony", 'description': 'More Info'},
    {"code": "wordpress",  "title": "Install wordpress", 'description': 'More Info'},
    {"code": "magento",  "title": "Install Magento", 'description': 'More Info'},
    {"code": "prestashop",  "title": "Install prestashop", 'description': 'More Info'},


]

menu_option_implement = [
        {"code": 'environment',  "title": environment.dataFile['name'], 'description': environment.dataFile['description']},
    {"code": 'composer',  "title": composer.dataFile['name'], 'description': composer.dataFile['description']},
    {"code": 'domain',  "title": domain.dataFile['name'], 'description': domain.dataFile['description']},
    {"code": 'mysql',  "title": mysql.dataFile['name'], 'description': mysql.dataFile['description']},
]

def checkEfdeEnv():
    """ TESTEO HELP """
    #check si tengo un .efde
    return common.fileEnvExists(True)
    #print(f'checkdirectorio')

def checkUpdate():
    response = codecs.decode(common.cliReturn('cd ~/.efde;git pull'),'UTF-8')
    if not response == 'Already up to date.\n':
        print("ACTUALIZAR REPO")

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

#def checkUpdate():
#    print(common.msgColor('Check Update','INFO_CYAN'))
#    common.cli(f'git checkout master;git reset --hard origin/master;git pull origin master')

def moreInfo():
    url = 'https://gitlab.com/dockerizations/efde'
    if sys.platform == 'darwin':    # in case of OS X
        subprocess.Popen(['open', url])
    else:
        webbrowser.open_new_tab(url)


if __name__ == '__main__':
    projectPath = os.getcwd()
    print(os.getcwd())
    currentPath = os.path.split(os.getcwd())
    projectPath = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
#   help(checkEfdeEnv)
    if checkEfdeEnv():
        menu_show = menu_option_implement
    else:
        menu_show = menu_option_start

    showHelper = False
    while True:
        common.menu_print(menu_show, dataFile, showHelper)
        opt=input(common.msgColor('\nEnter your option: ','SUCCESS'))

        if opt == 'q': exit()
        elif opt == 'r': 
            common.cli("clear")
            exit()
        elif opt == 'h':
            showHelper = not(showHelper)
            common.cli("clear")
        elif opt.isnumeric() and (int(opt) in range(0,len(menu_show))):
            code = menu_show[int(opt)]['code']
            if checkEfdeEnv():
                print(common.msgColor('\nYou moved to','OKGREEN'))
                common.cli(f'python3 {projectPath}/.efde/bin/{code}.py')
            else: 
                switchOption(code)
                input(common.msgColor('\nPress enter to return to the menu','OKGREEN'))
                common.cli("clear")
        else:
            input(common.msgColor(f'The option "{opt}" is not in the list. Press enter to continue','DANGER'))
            common.cli('clear')
            continue
