module ProjectReleaser
  module Project
    class Updater
      include Logger::Loggable

      def initialize(git)
        @git = git
      end

      def update
        logger.info 'updating local release and develop branches'
        @git.returning_to_current_branch do |git|
          git.pull [:master, :develop]
        end
      end
    end
  end
end
