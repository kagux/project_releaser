module ProjectReleaser
  module Project
    extend Logger::Loggable
    extend self

    def release(version_type)
      version = next_version version_type
      logger.info "releasing project '#{name}' `#{current_version}` -> `#{version}`"
      releaser = Releaser.new git
      releaser.release version
    end

    def update
      updater = Updater.new git
      updater.update
    end

    def name
      info.name
    end

    def current_version
      info.current_version
    end

    def next_version(version_type)
      info.next_version version_type
    end

    private

    def info
      Info.new(git)
    end

    def git
      @git ||= Repository.new Dir.pwd
    end
  end
end
