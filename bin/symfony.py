import common, environment, composer

dataFile = {'name': '+Symfony', 'description': 'Help managing Symfony elements'}

pathDokerCompose = ''
menu_option = [
    {"code": "createapp",   "title": "Create New App", 'description': 'Create a new symfony application'},
    {"code": "clone",   "title": "Clone My App", 'description': 'Clone from a git MyApp'},
    {"code": "console",   "title": "Console", 'description': 'Work with the symfony console'},
    {"code": "actionFixpermissions",   "title": "Fix permissions", 'description': 'Fix Permissions'},
]

def switchOption(code):
    if code in ['createapp','clone','console','fixpermissions']: 
        runCommandsOptions(code)
    else:
        print('You must select an option')

def runCommandsOptions(action, command = ''):
    if action == 'createapp': actionCreateApp()
    elif action == 'clone': actionCloneApp()
    elif action == 'console': actionConsole()
    elif action == 'fixpermissions': actionFixPermissions()

def actionCreateApp(): 
    createAppFolder()
    if common.isEmptyDirectory('./app', True):
        startDocker()
        runCommand('composer create-project symfony/website-skeleton .')


def actionCloneApp(): 
    createAppFolder()
    if common.isEmptyDirectory('./app', True):
        repository = input(common.msgColor('Enter the url of your repository: ','WARNING'))
        common.cli(f'git clone {repository} ./app')
        startDocker()
        composer.managementContainer('install')

def actionConsole():
    values = ''
    command = 'bin/console'
    questionCommand = input(common.msgColor('Enter the command or press enter for more info: ','WARNING'))
    if questionCommand == '': 
        while True:
            search = input(common.msgColor('Enter what you are looking for or press enter for the full list: ','WARNING'))
            if search == '': 
                break
            else:
                if not values == '':
                    values = values + '|' + search
                else:
                    values = search
                continue
        
        if not values =='' :
            questionCommand = 'list | egrep --color=always "' + values + '"'
        else:
            questionCommand = 'list'

    command = command + ' ' + questionCommand
    runCommand(command)

def actionFixPermissions(): 
    #ToDo: Review oficial documentation
    common.cli('sudo chown -R $USER:$USER ./app')

def runCommand(command):
    common.cli("docker-compose run --rm app " + command, True)

def createAppFolder():
    if not common.existsPath('./app',True):
        common.cli(f'mkdir ./app',True)
        actionFixPermissions()

def startDocker():
    environment.switchOption('apache')
    environment.switchOption('up')

if __name__ == '__main__':

    showHelper = False
    while True:
        common.menu_print(menu_option, dataFile, showHelper)
        opt=input(common.msgColor('\nEnter your option: ','SUCCESS'))

        if opt == 'q': exit()
        elif opt == 'r': 
            common.cli('clear') 
            exit()
        elif opt == 'h': 
            showHelper = not(showHelper)
            common.cli('clear')
        elif opt.isnumeric() and (int(opt) in range(0,len(menu_option))):
            code = menu_option[int(opt)]['code']
            switchOption(code)

            input(common.msgColor('\nPress enter to return to the menu','SUCCESS'))
            common.cli('clear')
        else:
            input(common.msgColor(f'The option "{opt}" is not in the list. Press enter to continue','DANGER'))
            common.cli('clear')
            continue
