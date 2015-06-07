require 'git'
require 'project_releaser'

ProjectReleaser.configure do |config|
  config.logger = ProjectReleaser::Logger::Null.new
end
