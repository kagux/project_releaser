require 'git'
require 'ostruct'
require 'project_releaser/version'
require 'project_releaser/logger/loggable'
require 'project_releaser/logger/console'
require 'project_releaser/logger/colored_console'
require 'project_releaser/logger/null'
require 'project_releaser/project/repository'
require 'project_releaser/project/releaser'
require 'project_releaser/project/updater'
require 'project_releaser/project/info'
require 'project_releaser/project'
require 'project_releaser/cli'

module ProjectReleaser
  extend self

  def configure(&block)
    configuration.tap(&block)
  end

  def configuration
    @configuration ||= OpenStruct.new 
  end
end 
