import os, sys
from dotenv import load_dotenv
import codecs
sys.path.append(os.path.dirname(__file__))
import common as common

dataFile = {'name': 'Mysql', 'description': 'Help managing mysql elements'}

pathDokerCompose = 'cd .. && '
pathDokerCompose = ''
menuReturn =  ''
menu_option = [
    {"code": "showenv", "title": "Show Variables", 'description': 'Remove vendor'},
    {"code": "query", "title": "Run querys", 'description': 'run querys'},
    {"code": "entry", "title": "entry conteiner", 'description': 'Remove vendor'},
    {"code": "dump", "title": "Dump", 'description': 'Dump'},
    {"code": "runscripts", "title": "Run scripts", 'description': 'Run Scripts'},
]

def switchOption(code):
    commandDockerCompose = pathDokerCompose + 'docker-compose run --rm db '
    pathEnv = '.docker/db/env'
    if code == 'showenv': 
        print('MYSQL_ROOT_PASSWORD:' + common.fileEnvReading('MYSQL_ROOT_PASSWORD', '.docker/db/env'))
        print('MYSQL_USER:' + common.fileEnvReading('MYSQL_USER', '.docker/db/env'))
        print('MYSQL_PASSWORD:' + common.fileEnvReading('MYSQL_PASSWORD', '.docker/db/env'))
        print('MYSQL_DATABASE:' + common.fileEnvReading('MYSQL_DATABASE', '.docker/db/env'))
        return
    elif code == 'entry': common.cli(commandDockerCompose + 'bash')
    elif code == 'query':
        while True:
            query = input(common.msgColor('ingrese la query: ','WARNING'))
            if not(query == ''): break
            else: continue
        mysqlUser = common.fileEnvReading('MYSQL_USER', '.docker/db/env')
        mysqlPass = common.fileEnvReading('MYSQL_PASSWORD', '.docker/db/env')
        mysqlDataBase = common.fileEnvReading('MYSQL_DATABASE', '.docker/db/env')
        commandx = f'docker-compose exec db mysql -u{mysqlUser} -p{mysqlPass} --database={mysqlDataBase} -e"{query}"'
        print(commandx)
        common.cli(commandx)
        # ToDo: Fix return
        switchOption('query')
    elif code == 'import':return
    elif code == 'dump':
        tables = "docker-compose exec db mysql -uadmin -pabcd1234 --database=wordpress -e\"show full tables where Table_Type = 'BASE TABLE'\" | awk '{print $2}' | grep -v '^Tables'"
        bytelist = common.cliReturn(tables)
        
        #stringlist=[x.decode('utf-8') for x in bytelist]
        print(codecs.decode(bytelist, 'UTF-8'))
        #for f in a:
            #print(f)
            
        





        
    else:
        print('You must select an option')


if __name__ == '__main__':
    showHelper = False
    while True:
        common.menu_print(menu_option, dataFile, showHelper)
        opt=input(common.msgColor('\nEnter your option: ','OKGREEN'))

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

            input(common.msgColor('\nPress enter to return to the menu','OKGREEN'))
            common.cli('clear')
        else:
            input(common.msgColor(f'The option "{opt}" is not in the list. Press enter to continue','DANGER'))
            common.cli('clear')
            continue
