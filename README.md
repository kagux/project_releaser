# Project Releaser

CLI command to make releases of your semantic versioned project a breeze.

Running `project release` in the root of your project:
* updates and `release` and `development` (if present) branches from all remotes
* merges `development` branch with `release` (again, if `development` is present)
* tags project with next `patch` version (which is the default one, `major` and `minor` are also available)
* pushes both branches and tags to all remotes

Please, refer to [Usage](#usage) section for more commands and examples.

Currently branches are not configurable:
* development is `develop`
* release is `master`

## Installation

Add this line to your application's Gemfile:

    gem 'project_releaser'

And then execute:

    $ bundle install

## <a name="usage"></a>Usage
  ```
  project [command]

      --help      Print help
  ```

Available commands:

  * `version`   Current production version of the project
  * `name`      Project name
  * `update`    Updates master and develop branches from all reomtes
  * `release`   Merges develop into master and pushes master with new version


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
* Notifications on release (i.e. to Slack)
* Improve logs
