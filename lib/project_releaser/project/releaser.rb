module ProjectReleaser
  module Project
    class Releaser
      include Logger::Loggable

      def initialize(git)
        @git = git
      end

      def release(version)
        @git.returning_to_current_branch do |git|
          @git = git
          update_local_branches
          merge_branches if branches.size > 1
          push_release version
        end
      end

      private

      def update_local_branches
        logger.info 'updating local branches'
        @git.pull branches
      end

      def merge_branches
        logger.info "merging 'develop' into 'master'"
        @git.merge :master, :develop
        logger.info "merging back 'master' into 'develop'"
        @git.merge :develop, :master
      end

      def push_release(version)
        logger.info "pushing new release `#{version}` to 'master'"
        @git.push :master, version
      end

      def branches
        @branches ||= begin
          branches = [:master]
          branches += [:develop] if @git.has_branch? :develop
          branches
        end
      end
    end
  end
end
