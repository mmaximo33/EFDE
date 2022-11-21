# PROJECT: Easy and fast development environment (EFDE)
## Abouts
EFDE is a project designed to facilitate the management of local development environments, mainly for teams that constantly have new members or beginners who are starting out in this beautiful world of programming.

The objective of the project is to be able to manage implementations with docker such as
  - Symphony
  - Magento
  - Wordpress
  - WooCommerce 
  - Prestashop
  - Django
  - Others

### Install & Update Script
To **install** or **update** EFDE, you should run the install script. To do that, you may either download and run the script manually, or use the following cURL or Wget command:
```sh
curl -o- https://gitlab.com/dockerizations/efde/-/raw/main/install.sh | bash
```
```sh
wget -qO- https://gitlab.com/dockerizations/efde/-/raw/main/install.sh | bash
```

### Usage
Once installed, you can run EFDE from any directory

```sh
$ efde
```

