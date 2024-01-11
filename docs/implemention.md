# EFDE | Easy and fast development environment

## Index
- [EFDE CONFIG](#efde-config)
  - [Global](#global-config)
  - [For project](#project-config)
- [Basic Use](#basic-use)

## Efde config
Distributing configurations for local deployments between different team members is easy with **EFDE**

### Global config
The global **EFDE** configurations can be found in
```sh
cat ~/.efde/bin/config.env 
```

### Project config
Configurations for implementations installed with **EFDE** are located in

```sh
cd  <project>     # Project folder

cat .efde/.env    # Variable file  
ls -la .env       # Symbolic link for docker recipe
```

## Basic Use 
Below we show you some of the characteristics that all implementations have. 
This may vary depending on the framework, language or technology, adjusting to the needs of each type of project.


![efde symfony use](./media/efde_symfony_use.gif)
