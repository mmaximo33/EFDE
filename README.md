# Easy and fast development environment (EFDE)

![efde version](https://img.shields.io/badge/version-v1.1.1-yellow.svg)

## Table of Contents

- [Intro](#intro)
- [About](#about)
- [Installing and Updating](#install--update)
  - [Install](#install)
  - [Update](#update)
- [Usage](#usage)
- [Maintainers](#maintainers)
- [Contributing](#contributing)
- [License](#license)

## Intro

EFDE arises motivated by giving something back to this beautiful community of programmers, computer scientists or curious about technology.

After having gone through some companies, participated in several teams, been a mentor to team members with beginner profiles and even taught this world to family and friends.
I realized that today there are several elements (services, tools, systems, others) that orbit around trying to learn a language, framework or technology.

EFDE aims to standardize, automate and simplify the deployment or preparation of local development environments for different projects. Without losing the flexibility that they can be customized or adjusted according to the need or complexity of the project.

EFDE is not the definitive solution to your problems, sooner or later you will have to understand exactly what is happening behind the things, but you will acquire the answers of what, when, where, for what and why, as you use it.

Who is it for?
It originally arises to help understand and expedite the induction process for those new members of a project or those people who are starting out in the world of programming and are not entirely clear about some knowledge, concepts or bases of services, applications or implementations. .

But it's also thinking of those developers who have a bit more experience and really want to have a little tool to help them do the usual tasks.

Whatever your level, EFDE will be interesting for you!
You are invited to join, use or even contribute to the growth of EFDE to give back to the developer community and open the doors to the new generations.

It is NOT something super innovative, but surely more than one will find it interesting.

## About

EFDE is a project designed to facilitate the management of local development environments, mainly for teams that constantly have new members or beginners who are starting out in this beautiful world of programming.

The objective of the project is to be able to manage implementations with docker such as

### Released ### 
- Symfony

### Coming soon ###
- Magento
- Wordpress
- WooCommerce
- Prestashop
- Django
- Others

## Install & Update

### Requirements
The EFDE installation script. It will check and recommend the installation of the necessary packages for its proper functioning.
Anyway, if you want to know more, you can see the following list with the official documentation

- For download
  - [GIT](https://git-scm.com/book/en/Getting-Started-Installing-Git) or [CURL](https://curl.se/docs/install.html) or [WGET](https://www.gnu.org/software/wget/)
- For run
  - [python3](https://wiki.python.org/moin/BeginnersGuide/Download)
  - [pip](https://packaging.python.org/en/latest/guides/installing-using-linux-tools/?highlight=install%20python3-pip#debian-ubuntu)
- Implement
  - [docker](https://docs.docker.com/engine/install/ubuntu/)
  - [docker-compose](https://docs.docker.com/compose/install/other/)

### Install

To **install** EFDE, you should run the install script. To do that, you may either download and run the script manually, or use the following cURL or Wget command:

```sh
curl -o- https://raw.githubusercontent.com/mmaximo33/efde/main/setup/install.sh | bash

wget -qO- https://raw.githubusercontent.com/mmaximo33/efde/main/setup/install.sh | bash
```

### Update 

You can update in two ways

- Installing it again according to [Install](#install)
- Running efde with the **--update** option

```sh
$ efde --update
```

## Usage

Once installed, you can run EFDE from any directory

```sh
$ efde --help
```

## Captures

![efde + symfony](documentation/images/efde_symfony.png)

## Maintainers

Currently, the sole maintainer is [@mmaximo33](https://github.com/mmaximo33) - more maintainers are quite welcome, and we hope to add folks to the team over time. [Governance](./documentation/GOVERNANCE.md) will be re-evaluated as the project evolves.

## Contributing

There is still a lot to do with this small project if you are invited to join.
Please see [CONTRIBUTING](./documentation/CONTRIBUTING.md) for details.

## License

The MIT License (MIT). Please see [License File](./LICENSE).
