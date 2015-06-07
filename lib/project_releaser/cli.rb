require 'commander'

module ProjectReleaser
  class CLI
    include Commander::Methods
    include Logger::Loggable

    def run
      program :name, 'Project Releaser'
      program :version, ProjectReleaser::VERSION
      program :description, 'Painlessly release your SemVer project'
      program :help_formatter, :compact
      default_command :help

      always_trace!

      build_version_cmd
      build_name_cmd
      build_update_cmd
      build_release_cmd

      run!
    rescue ProjectReleaser::Project::Repository::RepositoryHasNoBranches
      logger.error "It appears your project '#{project.name}' has no branches, you need at least 2"
    rescue ProjectReleaser::Project::Repository::RepositoryNotFound
      logger.error 'Working directory does not have git repository'
    rescue ProjectReleaser::Project::Repository::MissingBranch
      logger.error 'Project repository does not have expected branch'
    end

    private

    def build_version_cmd
      command :version do |c|
        c.syntax = 'project version'
        c.description = 'Current version of the project'
        action c do 
          logger.info "Current version of '#{project.name}' is #{project.current_version}"
        end
      end
    end

    def build_name_cmd
      command :name do |c|
        c.syntax = 'project name'
        c.description = 'Infer project name from git remotes'
        action c do 
          logger.info "You are working on project '#{project.name}'"
        end
      end
    end

    def build_update_cmd
      command :update do |c|
        c.syntax = 'project update'
        c.description = 'Updates release and develop branches from all remotes'
        action c do 
          ProjectReleaser::Project.update
        end
      end
    end

    def build_release_cmd
      command :release do |c|
        c.syntax = 'project release'
        c.description = 'Merges develop into release and pushes it with new version tag'
        action c do |args, options|
          ProjectReleaser::Project.release args.first
        end
      end
    end

    def project
      ProjectReleaser::Project
    end

    def action(cmd, &block)
      proc = lambda do |args, options|
        block.call args, options
        logger.info '`Done!`'
      end
      cmd.action(&proc)
    end
  end
end
