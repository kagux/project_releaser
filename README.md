# Project Releaser

CLI command to make releases of your semantic versioned project a breeze.
It merges your development branch into release and tags with next `major`, `minor` or `patch` version.

Currently branches are not configurable:
* development is `staging`
* release is `master`

## Installation

Add this line to your application's Gemfile:

    gem 'project_releaser'

And then execute:

    $ bundle install

## Usage
  ```
  project [command]

      --help      Print help
  ```

Available commands:

  * `version`   Current production version of the project
  * `name`      Project name
  * `update`    Updates master and staging branches from all reomtes
  * `release`   Merges staging into master and pushes master with new version


### Release Command

By default it releases next `patch` version of the project. To set specific version use (`major`, `minor` or `patch`) argument
```
project release major
```
You can also release an exact version 
```
project release 7.10.5
```
## TODO

* Configurable branches
* Improve logs
