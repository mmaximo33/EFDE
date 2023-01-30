import codecs
from dotenv import load_dotenv

import common

dataFile = {'name': 'Mysql', 'description': 'Help managing mysql elements'}

menuReturn =  ''
menu_option = [
    {"code": "showenv", "title": "Show Variables", 'description': 'Remove vendor'},
    {"code": "query", "title": "Run querys", 'description': 'run querys'},
    {"code": "entry", "title": "entry conteiner", 'description': 'Remove vendor'},
    {"code": "dump", "title": "Dump", 'description': 'Dump'},
    {"code": "runscripts", "title": "Run scripts", 'description': 'Run Scripts'},
]

def switch_option(code):
    commandDockerCompose = common.command_docker_compose()
    if code == 'showenv': 
        print('MYSQL_ROOT_PASSWORD:' + common.file_env_read('MYSQL_ROOT_PASSWORD'))
        print('MYSQL_USER:' + common.file_env_read('MYSQL_USER'))
        print('MYSQL_PASSWORD:' + common.file_env_read('MYSQL_PASSWORD'))
        print('MYSQL_DATABASE:' + common.file_env_read('MYSQL_DATABASE'))
        return
    elif code == 'entry': common.cli(commandDockerCompose + 'run --rm db bash')
    elif code == 'query':
        while True:
            query = input(common.msgColor('ingrese la query: ','WARNING'))
            if not(query == ''): break
            else: continue
        mysqlUser = common.file_env_read('MYSQL_USER')
        mysqlPass = common.file_env_read('MYSQL_PASSWORD')
        mysqlDataBase = common.file_env_read('MYSQL_DATABASE')
        commandx = f'{commandDockerCompose} exec db mysql -u{mysqlUser} -p{mysqlPass} --database={mysqlDataBase} -e"{query}"'
        print(commandx)
        common.cli(commandx)
        # ToDo: Fix return
        switch_option('query')
    elif code == 'import':return
    elif code == 'dump':
        tables = commandDockerCompose + " exec db mysql -uadmin -pabcd1234 --database=wordpress -e\"show full tables where Table_Type = 'BASE TABLE'\" | awk '{print $2}' | grep -v '^Tables'"
        bytelist = common.cliReturn(tables)
        
        #stringlist=[x.decode('utf-8') for x in bytelist]
        print(codecs.decode(bytelist, 'UTF-8'))
        #for f in a:
            #print(f)
    else:
        print('You must select an option')


if __name__ == '__main__':
    print(
        common.msgColor(
            f"-------------------------------\nIn construction\n-------------------------------",
            'WARNING'
        )
    )
    input(common.msgColor('\nPress enter to return to the menu','SUCCESS'))
    common.cli('clear')
    exit()
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
            switch_option(code)

            input(common.msgColor('\nPress enter to return to the menu','SUCCESS'))
            common.cli('clear')
        else:
            input(common.msgColor(f'The option "{opt}" is not in the list. Press enter to continue','DANGER'))
            common.cli('clear')
            continue
