# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.1/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.0] 2024-xx-xx

### Added

- Symfony: #35 Add new version of Symfony 7.x

### Fixed

- EFDE: #36 Function info menu not aligned (Debug Mode)
- Symfony: #33 fix application directory permissions application
- MySQL: #3 General fixes for database import and export

## [2.1.0] 2024-03-04

### Added

- MySQL: #3 Add service for MySQL management
- EFDE: #28 Add SHORTCUTS

### Changed

- EFDE: #15
  - Refactoring module loading (Remove ../init)
  - Cleaning the bin/efde
  - Add configuration for default editor
  - Improve mode management (debug and develop)

## [2.0.0] 2024-01-15

### Changed

- EFDE: #15 Migrate from PYTHON to full BASH
  - Refactoring console/{implemention or service}
  - Improve bin/install.sh
  - Fixed main script bin/efde.sh
  - Core refactoring
  - Auto loading module
  - Module structure (common efde docker symfony)
  - Feature management by category or element
  - module.props.element.variable
  - module.tasks.element.method
  - Added debug methods
  - Fixed documentation

## [1.2.0] 2022-01-30

### Added

- EFDE: #14 Installation - Option by script due to lack of git and refactoring of the install.sh scripts
- EFDE: #16 Installation - Migrate docker-compose (v1) to docker compose (v2)
- EFDE: #18 Installation - Validate requirements for docker and docker compose
- Symfony: #6 Being able to indicate the version to use 5.x or 6.x
- Symfony: #13 Install - Establish type of application, microservice or webapp

### Changed

- EFDE: #10 Disable automatic EFDE update - Available by parameter --update
- EFDE: #1 - Partial - Create a file to save configurations

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
