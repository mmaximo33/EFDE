# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.1/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## [Unreleased] AAAA-MM-DD
### Added
### Changed
### Fixed 
### Removed


## [Unreleased] AAAA-MM-DD
### Added 
- EFDE: #14 Installation - Option by script due to lack of git and refactoring of the install.sh scripts
### Changed
- EFDE: #10 Disable automatic EFDE update - Available by parameter --update
### Fixed 
- EFDE: #11 Installation on clean ubuntu - $HOME/bin
- EFDE: #12 Installation - Missing python dependencies

## [1.1.1] 2022-12-28
### Fixed 
- Symfony: Fix createapp script sequence
- Symfony: #7 Fix permission to folder ./app
- Symfony: #8 Remove environment variable from docker-compose.yml
- Symfony: #9 PMA login as root user

## [1.1.0] 2022-12-26
### Added
- #2 Symfony - Add ability to clone existing project
### Changed
- Installation process refactor
### Fixed 
- Fixed bin/composer actions management
- General fixes in bin/{start environment}
### Removed
- Remove bin/requiriments, not used

## [1.0.0] 2022-12-21

### Added 
- Added environment for symfony and automations
- Preparation of basic documentation (README, LICENSE, CHANGELOG, others)
- Automation of the installation and uninstallation process
- Creation of basic structure
- Start of the project

### Fixed
- General fixes
