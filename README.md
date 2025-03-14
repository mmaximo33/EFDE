# EFDE | Easy and Fast Development Environment [![follow](https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/@Efde.official)

![efde type](https://img.shields.io/badge/project-Open_Source-green.svg) ![efde version](https://img.shields.io/badge/license-MIT-blue.svg)

![efde version](https://img.shields.io/badge/status-Active-green.svg)
![efde_lastcommin](https://img.shields.io/github/last-commit/mmaximo33/efde.svg)
![efde_release](https://img.shields.io/github/release/mmaximo33/efde.svg)
![efde_since release](https://img.shields.io/github/commits-since/mmaximo33/efde/2.2.0.svg)
![efde_since release](https://img.shields.io/github/commits-since/mmaximo33/efde/1.2.0.svg)

![issue-open](https://img.shields.io/github/issues/mmaximo33/efde.svg)
![issue-close](https://img.shields.io/github/issues-closed/mmaximo33/efde.svg)
![pull-open](https://img.shields.io/github/issues-pr/mmaximo33/efde.svg)
![pull-close](https://img.shields.io/github/issues-pr-closed/mmaximo33/efde.svg)

![efde translations](https://img.shields.io/badge/language-grey.svg) ![en_US](https://img.shields.io/badge/en.US-blue.svg) ![es_ES](https://img.shields.io/badge/es.ES-blue.svg) ![pt_PT](https://img.shields.io/badge/pt.PT-blue.svg)

### If you like the project, give us a little star ⭐.
#### It really helps us a lot. Thank you! 💪
## Index

- [Intro](#intro)
- [Installing, Manager Versions, Updating & Uninstall](#install--update)
- [Usage](#usage)
- [Mission](#mission)
- [Documentation](#documentation)
  - [Doc for Developer (Collaborators)](docs/developer.md) 🔥
  - [Code of conduct](#code-of-conduct) | [Maintainers](#maintainers) | [Contributing](#contributing) | [License](#license)

## Intro

EFDE is a project designed to facilitate the management of local development environments, mainly for teams that constantly have new members or beginners who are starting out in this beautiful world of programming.

The objective of the project is to be able to manage implementations with docker such as

### Released

[![Docker](https://img.shields.io/badge/Docker-2CA5E0?style=for-the-badge&logo=docker&logoColor=white)](#)

[![Install PHP](https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white)](https://www.php.net/)
[![Install Laravel](https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white)](console/implemention/laravel/docs/README.md)
[![Install Symfony](https://img.shields.io/badge/Symfony-000?logo=symfony&logoColor=fff&style=for-the-badge)](console/implemention/symfony/docs/README.md)
[![Install Wordpress](https://img.shields.io/badge/Wordpress-21759B?style=for-the-badge&logo=wordpress&logoColor=white)](console/implemention/wordpress/docs/README.md)

### Coming soon

[![Install Portainer.io](https://img.shields.io/badge/Portainer.io-105f8f?style=for-the-badge&logo=portainer&logoColor=white)](docs/developer.md)

[![Install PHP](https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white)](https://www.php.net/)
[![Install Magento](https://img.shields.io/badge/Magento-f06835?style=for-the-badge&logo=magento&logoColor=white)](docs/developer.md)
[![Prestashop](https://img.shields.io/badge/prestashop-%23DF0067.svg?&style=for-the-badge&logo=prestashop&logoColor=white)](docs/developer.md)

[![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)](docs/developer.md)
[![Install React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)](docs/developer.md)
[![Install Angular](https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white)](docs/developer.md)
[![Install Vue.js](https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vue.js&logoColor=4FC08D)](docs/developer.md)

[![Install Python](https://img.shields.io/badge/Python-FFD43B?style=for-the-badge&logo=python&logoColor=blue)](docs/developer.md)
[![Install Django](https://img.shields.io/badge/django-113527?style=for-the-badge&logo=django&logoColor=white)](docs/developer.md)

## Install & Update

### Requirements

The **EFDE** installation script. It will check and recommend the installation of the necessary packages for its proper functioning.
Anyway, if you want to know more, you can see the following list with the official documentation

#### Compatibility

![Debian](https://img.shields.io/badge/Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)

#### For download

[![CURL](https://img.shields.io/badge/CURL-212121?style=for-the-badge&logo=CURL&logoColor=white)](https://curl.se/docs/install.html)
[![WGET](https://img.shields.io/badge/wget-212121?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/wget/)

#### Implement (If you do not have it installed, EFDE manages the installation on Linux)

[![Git](https://img.shields.io/badge/GIT-E44C30?style=for-the-badge&logo=git&logoColor=white)](https://git-scm.com/book/en/Getting-Started-Installing-Git)
[![Docker](https://img.shields.io/badge/Docker-2CA5E0?style=for-the-badge&logo=docker&logoColor=white)](https://docs.docker.com/engine/install/ubuntu/)
[![Docker Compose](https://img.shields.io/badge/Docker_Compose-2CA5E0?style=for-the-badge&logo=docker&logoColor=white)](https://docs.docker.com/compose/install/other/)

<details>
<summary>See installation of required tools</summary>

![efde_process_install.png](./docs/media/efde_process_install.png)

</details>

### Install
#### Manual 
For manual installation you must
<details>
<summary>Distro debian/ubuntu</summary>

```sh
mkdir -p ~/.efde
cd $_
git clone https://github.com/mmaximo33/EFDE.git .

ln -sfT $PWD/bin/efde.sh ~/bin/efde

# In case you want to test a branch
# git switch <branch>
```
</details>

<details>
<summary>In Windows</summary>

```sh
Coming soon
```

</details>

<details>
<summary>In MacOS</summary>

```sh
Coming soon
```

</details>

#### For script 

Run the following command (**CURL** or **WGET**) to install **EFDE** on your computer

```sh
curl -o- https://raw.githubusercontent.com/mmaximo33/efde/main/bin/install.sh | bash
```

```sh
wget -qO- https://raw.githubusercontent.com/mmaximo33/efde/main/bin/install.sh | bash
```

![Efde process install](./docs/media/efde_process_install.gif)

### Manager Version, Update & Uninstall
![efde process versiosn update uninstall](./docs/media/efde_process_version_update_uninstall.gif)

## Usage

### New project

- Once **EFDE** is installed
- Go to the directory where you create your projects (example: `~/Domains`)
- Run `efde`  in your command console

### Created project with EFDE

- In case you are in a project created with **EFDE**. Example: `~/Domains/demo`
- The menu for that implementation will be displayed (Symfony, Laravel, Magento, Wordpress, WooComerce, Prestashop, React, Angular, Vue, Others)

![efde symfony install](./console/implemention/symfony/docs/media/install.gif)

### Use in project 

![efde symfony use](./console/implemention/symfony/docs/media/use.gif)

### Shortcuts

Since version 2.1.0, shortcuts are available. You can see the list by running `efde efde:shortcuts`

![efde shortcuts](./docs/media/efde_shortcut.gif)

#### Projects shortcuts
Since version 2.2.1, CUSTOM shortcuts are available per project. You can see the list by running `efde custom`

<details>
<summary>Custom Shortcuts</summary>

![efde_shortcuts_custom.png](./docs/media/efde_shortcuts_custom.png)

</details>

## Mission

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

## Contributing

There is still a lot to do with this small project if you are invited to join.
Please see [CONTRIBUTING](./CONTRIBUTING.md) for details.

## Sponsor
If you like this project and want to give some recognition, it is now possible to **become a [Github sponsor](https://www.github.com/sponsors/mmaximo33)** and support this project by sponsoring **[mmaximo33](https://www.github.com/sponsors/mmaximo33)** maintainer on Github. Even if it's a small contribution, you participate in the effort of making **open source projects maintained for anyone**, and developers to be rewarded for their work/time.

## Contribute
If you want to report a bug or request a new feature/improvement, please **read the project [contributors guidelines](./CONTRIBUTING.md) before**.

Thanks for taking time to contribute. 🎉 👍

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%">
        <a href="https://www.linkedin.com/in/marucci-maximo/">
          <img src="https://avatars.githubusercontent.com/u/12983255?v=4?s=100" width="100px;" alt="Marucci Maximo"/><br/>
          <sub><b>mmaximo33</b></sub><br/>
          <sub><b>Marucci Maximo</b></sub>
        </a><br/>
        <a href="#ideas-mmaximo33" title="Ideas, Planning, & Feedback">🤔</a> 
        <a href="https://github.com/mmaximo33/EFDE/commits?author=mmaximo33" title="Code">💻</a> 
        <a href="https://github.com/mmaximo33/EFDE/issues?q=author%3Ammaximo33+label%3A%2203+Type%3A+Documentation+%3Abooks%3A%22" title="Documentation">📖</a> 
        <a href="https://github.com/mmaximo33/EFDE/issues?q=author%3Ammaximo33+label%3A%2203+Type%3A+Discussion+%3Aspeaker%3A%22" title="Answering Questions">💬</a> 
        <a href="https://github.com/mmaximo33/EFDE/issues?q=author%3Ammaximo33+label%3A%2203+Type%3A+Bug+%3Abug%3A%22" title="Bug reports">🐛</a> 
        <a href="https://github.com/mmaximo33/EFDE/commits?author=mmaximo33" title="Tests">⚠️</a> 
        <a href="https://github.com/mmaximo33/EFDE/pulls?q=is%3Apr+reviewed-by%mmaximo33" title="Reviewed Pull Requests">👀</a>
      </td>
      <td align="center" valign="top" width="14.28%">
        <a href="https://www.linkedin.com/in/marucci-maximo/">
          <img src="./docs/media/joinus.png" width="100px;" alt="Join Us"/><br/>
          <sub><b></b></sub><br/>
          <sub><b>Join us</b></sub>
        </a><br/>
        <a href="#ideas-joinus" title="Ideas, Planning, & Feedback">🤔</a> 
        <a href="#code-joinus" title="Code">💻</a> 
        <a href="#docs-joinus" title="Documentation">📖</a> 
        <a href="#questions-joinus" title="Answering Questions">💬</a> 
        <a href="#bugs-joinus" title="Bug reports">🐛</a> 
        <a href="#qa-joinus" title="Tests">⚠️</a> 
        <a href="#pr-joinus" title="Reviewed Pull Requests">👀</a>
      </td>
    </tr>

[//]: # (      6 per row )
[//]: # (      <td align="center" valign="top" width="14.28%">)
[//]: # (      </td>)
[//]: # (      <td align="center" valign="top" width="14.28%">)
[//]: # (      </td>)
[//]: # (      <td align="center" valign="top" width="14.28%">)
[//]: # (      </td>)
[//]: # (      <td align="center" valign="top" width="14.28%">)
[//]: # (      </td>)

  </table>
<tbody>

### Collaborate with us

<a href="https://jb.gg/OpenSourceSupport" target="_blank">
  <img src="https://resources.jetbrains.com/storage/products/company/brand/logos/jb_beam.png" height="125" alt="Logotipo de JetBrains (principal) logo.">
</a>

## Documentation
### Code of conduct

The collaborators of this project strongly believe in a respectful community.
For this reason we operate under the following [CODE OF CONDUCT](./CODE_OF_CONDUCT.md)

### Maintainers

Currently, the sole maintainer is **[@mmaximo33](https://github.com/mmaximo33)** - more maintainers are quite welcome, and we hope to add folks to the team over time.
[GOVERNANCE](./GOVERNANCE.md) will be re-evaluated as the project evolves.

### License

The MIT License (MIT). Please see [LICENSE](./LICENSE.md).
