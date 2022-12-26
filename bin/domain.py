import subprocess
import common

dataFile = {'name': 'Domains LCL', 'description': 'Configure local domain'}

menu_option = [
    {"code": "configure",  "title": "Configure", 'description': 'configure bin/.env, /etc/hosts, symfony'},
    {"code": "check",  "title": "Checks", 'description': 'Verifica, bin/.env, /etc/hosts, symfony'},
    {"code": "inDocker",  "title": "Docker", 'description': 'En docker'},
    {"code": "inSymfony", "title": "Symfony", 'description': 'En symfony'}
]

varEnv = 'DOMAIN_LCL'

def switchOption(code):
    if code == 'check':
        configureLocalCheck()
    elif code == 'inDocker':
        configureLocalDomain()
    elif code == 'inSymfony':
        print('insymfony')
    else:
        print('You must select an option')

def configureLocalCheck():
    #check .env
    msgInEnv = ''
    fileExists = common.fileEnvExists(False)
    if not fileExists: msgInEnv = common.msgColor(f'\n    This project does not have the file {common.filePathEnv()}','OKCYAN')

    inEnvExists = common.fileEnvReading(varEnv)
    checkInEnvExists = not inEnvExists == None and not inEnvExists ==''
    if not checkInEnvExists : msgInEnv = common.msgColor(f'\n    The variable was not configured {common.filePathEnv()}:{varEnv}','OKCYAN')
    if msgInEnv == '': msgInEnv = common.msgColor(f'\n    The project domain is {inEnvExists}','SUCCESS')

    # check /etc/hosts
    try:
        # https://stackoverflow.com/a/33054552/20367738
        inEtcHosts = subprocess.check_output(f'cat /etc/hosts | egrep "{inEnvExists}"', shell=True).decode()
        inEtcHostsCheckComment = ''
        if '#' in inEtcHosts: inEtcHostsCheckComment = common.msgColor('\n    But it is commented','DANGER')
        msgInEtcHost = common.msgColor(f'\n    The domain is registered in /etc/host.','SUCCESS') + inEtcHostsCheckComment + f'\n    {inEtcHosts}'

    except subprocess.CalledProcessError as e:
        msgInEtcHost = common.msgColor('Local domain not configured in /etc/host','DANGER')
        pass
    

    print(
        common.msgColor('# Env: ','OKCYAN') + msgInEnv + 
        common.msgColor('\n# /etc/host:','OKCYAN') + msgInEtcHost
    )
    # ToDo: get configured domain in symfony
    #symfony env domain    
    

def configureLocalDomain():
    fileExists = common.fileEnvExists()
    
    if not fileExists:
        confirm = common.checkYesNo(common.msgColor('You want to create the configuration file?','WARNING'),'y')
        if confirm == False : return 
        common.fileEnvCreateFile()
    inEnvExists = common.fileEnvReading(varEnv)
    if not inEnvExists == None : 
        print(f'It is configured as {inEnvExists}')
        return

    while True:
        domainName = input(f'Enter the domain name, without the extension. Example: mydomain\nName: ')
        if domainName == '': continue

        domain = f'{domainName.lower()}.lcl'
        setDomain = f'127.0.0.1 {domain}'
        common.fileEnvWrite('DOMAIN_LCL',setDomain)
        common.cli(f'echo "\n# {domainName.upper()}\n127.0.0.1 {setDomain}" | sudo tee -a /etc/hosts',True)
        break
    


if __name__ == '__main__':
    print(
        common.msgColor(
            f"-------------------------------\nIn construction\n-------------------------------",
            'INFO_CYAN'
        )
    )
    input(common.msgColor('\nPress enter to return to the menu','SUCCESS'))
    common.cli('clear')

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
