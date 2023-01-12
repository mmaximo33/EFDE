import os, sys, subprocess, webbrowser, codecs
import common, environment, composer, domain, mysql, symfony

dataFile = {'name': 'efde', 'description': 'Easy and Fast Developer Enviroment'}

runPath = os.getcwd()
runPathFolder = os.path.split(os.getcwd())
efdePath = f"{os.path.dirname(os.path.dirname(os.path.abspath(__file__)))}"
efdeConfigEnvironment = "app_type"


menu_option_start = [
    {"code": "moreInfo",  "title": "More Info", 'description': 'More Info'},
    {"code": "symfony",  "title": "Install Symfony", 'description': 'More Info'},
    {"code": "magento",  "title": "Coming soon - Install Magento", 'description': 'Coming soon'},
    {"code": "wordpress",  "title": "Coming soon - Install Wordpress", 'description': 'Coming soon'},
    {"code": "wocommerce",  "title": "Coming soon - Install WooCommerce", 'description': 'Coming soon'},
    {"code": "prestashop",  "title": "Coming soon - Install Prestashop", 'description': 'Coming soon'},
    {"code": "drupal",  "title": "Coming soon - Install Drupal", 'description': 'Coming soon'},
    {"code": "react",  "title": "Coming soon - Install React", 'description': 'Coming soon'},
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
        print(common.msgColor('Coming soon...','DANGER'))

def moreInfo():
    url = "https://github.com/mmaximo33/efde"
    if sys.platform == 'darwin':    # in case of OS X
        subprocess.Popen(['open', url])
    else:
        webbrowser.open_new_tab(url)


if __name__ == '__main__':
    menu_current = menu_option_start # default menu

    efdeConfigExists = checkConfigEfdeEnv()
    if efdeConfigExists:
        menu_current = checkEnvironment() # environment menu
        

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
                print(common.msgColor('\nYou moved to','SUCCESS'))
                common.cli("clear")
                common.cli(f'python3 {efdePath}/bin/{code}.py')
            else: 
                switchOption(code)
                input(common.msgColor('\nPress enter to return to the menu','SUCCESS'))
                common.cli("clear")
        else:
            input(common.msgColor(f'The option "{opt}" is not in the list. Press enter to continue','DANGER'))
            common.cli('clear')
            continue
