import os
import subprocess
import webbrowser
import sys
import codecs
#import bin.common as common, bin.environment as environment, bin.composer as composer, bin.domain  as domain, bin.mysql as mysql 
from bin import common, environment, composer, domain, mysql, symfony

dataFile = {'name': 'efde', 'description': 'Easy and Fast Developer Enviroment'}

runPath = os.getcwd()
runPathFolder = os.path.split(os.getcwd())
efdePath = f"{os.path.dirname(os.path.dirname(os.path.abspath(__file__)))}/.efde"
efdeConfigEnvironment = "app_type"


menu_option_start = [
    {"code": "moreInfo",  "title": "More Info", 'description': 'More Info'},
    {"code": "symfony",  "title": "Install Symfony", 'description': 'More Info'},
    {"code": "magento",  "title": "Coming soon - Install Magento", 'description': 'Coming soon'},
    {"code": "wordpress",  "title": "Coming soon - Install wordpress", 'description': 'Coming soon'},
    {"code": "prestashop",  "title": "Coming soon - Install prestashop", 'description': 'Coming soon'},
]

menu_option_implement = [
    {"code": 'environment',  "title": environment.dataFile['name'], 'description': environment.dataFile['description']},
    {"code": 'composer',  "title": composer.dataFile['name'], 'description': composer.dataFile['description']},
    {"code": 'domain',  "title": domain.dataFile['name'], 'description': domain.dataFile['description']},
    {"code": 'mysql',  "title": mysql.dataFile['name'], 'description': mysql.dataFile['description']},
]

menu_option_environment = {
    "symfony": {"code": 'symfony',  "title": symfony.dataFile['name'], 'description': symfony.dataFile['description']},
}

menu_current = []

def checkConfigEfdeEnv():
    """ TESTEO HELP """

    return common.fileEnvExists(True)

def checkEnvironment():
    global menu_current
    app = common.fileEnvReading(f'{efdeConfigEnvironment}')
    if app == 'symfony':
        menu_option_implement.insert(1,menu_option_environment['symfony'])
        menu_current = menu_option_implement
    else:
        menu_current = menu_option_implement
    
    return menu_current


def checkUpdate():
    response = codecs.decode(common.cliReturn('cd ~/.efde;git pull'),'UTF-8')
    if not response == 'Already up to date.\n':
        print("ACTUALIZAR REPO")

def setNameProject():
    while True:
        projectName = input(f'Enter the project name [my-project]\nProject Name: ')
        if projectName == '': continue
        return projectName

def installSymfony():
    projectName = setNameProject()
    projectPath = f"{runPath}/{projectName}"
    common.cli(f'mkdir {projectPath} ',True)
    common.cli(f'cp -rT {efdePath}/environments/symfony/ {projectPath}/',True)
    common.cli(f'echo "app_type=symfony" > {projectPath}/{common.configEnv["fileEnv"]}',True)
    common.cli(f'cd {projectPath};efde')
    exit()

def switchOption(code):
    if code == 'moreInfo':
        moreInfo()
    elif code == 'symfony':
        installSymfony()
    else: 
        print('Coming soon')

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
#    help(checkEfdeEnv)
    efdeConfigExists = checkConfigEfdeEnv()
    if efdeConfigExists:
        menu_current = checkEnvironment()
    else:
        menu_current = menu_option_start

    showHelper = False
    while True:
        common.menu_print(menu_current, dataFile, showHelper)
        opt=input(common.msgColor('\nEnter your option: ','SUCCESS'))

        if opt == 'q': exit()
        elif opt == 'r': 
            common.cli("clear")
            exit()
        elif opt == 'h':
            showHelper = not(showHelper)
            common.cli("clear")
        elif opt.isnumeric() and (int(opt) in range(0,len(menu_current))):
            code = menu_current[int(opt)]['code']
            if efdeConfigExists:
                print(common.msgColor('\nYou moved to','OKGREEN'))
                common.cli("clear")
                common.cli(f'python3 {efdePath}/bin/{code}.py')
            else: 
                switchOption(code)
                input(common.msgColor('\nPress enter to return to the menu','OKGREEN'))
                common.cli("clear")

        else:
            input(common.msgColor(f'The option "{opt}" is not in the list. Press enter to continue','DANGER'))
            common.cli('clear')
            continue
