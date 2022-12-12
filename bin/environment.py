import os, sys
sys.path.append(os.path.dirname(__file__))
import common as common

dataFile = {'name': 'Environment', 'description': 'Help managing project containers'}

PathDockerCompose = 'cd .. && '
PathDockerCompose = ''
#menuReturn =  ''
menu_option = [
    {"code": "build",   "title": "Build", 'description': 'Build containers'},
    {"code": "start",   "title": "Start", 'description': 'start containers'},
    {"code": "restart", "title": "Restart", 'description': 'Restar containers'},
    {"code": "stop",    "title": "Stop", 'description': 'Stop containers'},
    {"code": "up",      "title": "Up", 'description': 'Up containers'},
    {"code": "logs",    "title": "Logs", 'description': 'Monitor and search for values in the container logs'},
    {"code": "entry",   "title": "Entry container", 'description': 'Enter the indicated container'},
    {"code": "command", "title": "Run command", 'description': 'Run command in container. Example: bash, cp, rm'},
    {"code": "apache",  "title": "Stop Apache", 'description': 'Shutdown local apache service'},
    {"code": "stopAll", "title": "Stop all containers", 'description': 'Shutdown all containers on my computer'},
    {'code': 'down',    'title': "Down", 'description': 'Shutdown and destroy container and network'},

]

def switchOption(code):
    if code in ['build', 'start', 'restart', 'stop','up','logs', 'entry','command', 'down']: 
        managementContainer(code)
    elif code == 'apache': common.cli('sudo service apache2 stop')
    elif code == 'stopAll': 
        shutdown = common.checkYesNo(common.msgColor('Are you sure you want to shutdown all docker containers?','DANGER'))
        if shutdown: common.cli('docker container stop $(docker ps -aq)')
    else:
        print('You must select an option')

def managementContainer(action, command = ''):
    commandDockerCompose = PathDockerCompose + "docker-compose"
    common.cli(commandDockerCompose + " ps")
    
    # Check containers
    if action in ['entry', 'command'] : 
        while True:
            container = input(common.msgColor('Enter container name: ','WARNING'))
            if not(container == ''): break
            else: continue
    else: container = input(common.msgColor('Container name or enter for all: ','WARNING'))

    # Actions run
    if action == 'up': command = '-d'
    elif action == 'logs': 
        action = 'logs -f'
        values = ''
        while True:
            search = input(common.msgColor('Enter value to search or Enter for all: ','WARNING'))
            if search == '': break
            else:
                if not(values == ''):
                    values = values + '|' + search
                else:
                    values = search
                continue

        if not(values ==''): command = command + ' | egrep --color=always "' + values + '"'
    elif action == 'entry':
        action = modeInstance()
        command = 'bash'
    elif action == 'command':
        action = modeInstance()
        command = input(common.msgColor('What command do you want to run?: ','WARNING'))
    elif action == 'down': 
        confirm = common.checkYesNo(common.msgColor('Are you sure you want to remove all containers?','DANGER'),'n')
        if confirm == False: return
        # ToDo: A definir esta secuencia
        #withPrune = common.checkYesNo('Desea eliminar los volumenes','n')
        #if withPrune:
        #   common.cli('docker volume prune $(docker volume ls | egrep directory')        
        #   common.cli('docker image rmi $(' + commandDockerCompose + ' images -q')        

    # Execute action
    common.cli(
        commandDockerCompose + ' ' + action + ' ' + container + ' ' + command,
        True
    )

def modeInstance():
    mode = common.checkYesNo(common.msgColor('You want to open a new instance? (RUN/EXEC) =','WARNING'))
    if mode: return 'run --rm' 
    else: return 'exec'

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
