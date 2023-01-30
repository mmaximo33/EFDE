import os, sys, subprocess, webbrowser, codecs
import common, environment, composer, domain, mysql, symfony

dataFile = {'name': 'efde', 'description': 'Easy and Fast Developer Enviroment'}

runPath = os.getcwd()
runPathFolder = os.path.split(os.getcwd())
efdePath = f"{os.path.dirname(os.path.dirname(os.path.abspath(__file__)))}"


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

def check_config_efde_env():
    return common.efde_file_env_exists()

def check_environment():
    global menu_current
    app = common.efde_file_env_read('app_type')

    if app == 'symfony':
        menu_option_implement.insert(1, menu_option_environment['symfony'])
        menu_current = menu_option_implement
    else:
        menu_current = menu_option_implement
    
    return menu_current

def switch_option(code):
    if code == 'moreInfo':
        more_info()
    elif code == 'symfony':
        symfony.install_symfony()
    else: 
        print(common.msgColor('Coming soon...','DANGER'))

def more_info():
    url = "https://github.com/mmaximo33/efde"
    if sys.platform == 'darwin':    # in case of OS X
        subprocess.Popen(['open', url])
    else:
        webbrowser.open_new_tab(url)


if __name__ == '__main__':
    menu_current = menu_option_start # default menu

    efdeConfigExists = check_config_efde_env()
    if efdeConfigExists:
        menu_current = check_environment() # environment menu
        

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
                switch_option(code)
                input(common.msgColor('\nPress enter to return to the menu','SUCCESS'))
                common.cli("clear")
        else:
            input(common.msgColor(f'The option "{opt}" is not in the list. Press enter to continue','DANGER'))
            common.cli('clear')
            continue
