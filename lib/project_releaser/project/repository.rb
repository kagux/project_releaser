module ProjectReleaser
  module Project
    class Repository
      class RepositoryHasNoBranches < RuntimeError; end;
      class RepositoryNotFound < RuntimeError; end;
      class MissingBranch < RuntimeError; end;

      VERSION_PARTS = %I(major minor patch)
      DEFAULT_VERSION = [1, 0, 0]

      def initialize(repo_path)
        @git = open_repository(repo_path)
      end

      def current_version
        Hash[VERSION_PARTS.zip versions.last]
      end

      def pull(branches)
        branches.each do |branch|
          checkout branch
          @git.remotes.each do |remote|
            @git.fetch remote.name #otherwise it wouldnt get new tags...
            @git.pull remote.name, branch
          end
        end
      end

      def merge(target_branch, source_branch)
        checkout target_branch
        begin
          @git.merge source_branch
        rescue
          Kernel.system 'git mergetool'
          @git.commit 'resolved merge conflict'
        end
      end

      def push(branch, version_name)
        checkout branch
        @git.add_tag version_name
        @git.remotes.each do |r|
          @git.push r.name, branch
          @git.push r.name, version_name 
        end
      end

      def remotes
        Hash[@git.remotes.map{ |r| [r.name, r.url] }]
      end

      def current_branch
        raise RepositoryHasNoBranches unless @git.branches.count > 0

        @git.branches.find { |b| b.current }.name
      end

      def checkout(branch)
        @git.checkout branch 
      rescue Git::GitExecuteError
        raise MissingBranch, "Branch '#{branch}' is missing"
      end

      def fetch_tags
        @git.remotes.each { |r| @git.fetch(r.name, :tags => true) }
      end

      def has_branch?(branch_name)
        @git.branches.map(&:name).include? branch_name.to_s
      end

      def returning_to_current_branch(&block)
        branch = current_branch
        yield self
        checkout branch
      end

      private 

      def versions
        tags = @git.tags
        return [DEFAULT_VERSION] if tags.empty?
        valid_tags = tags
                    .map(&:name)
                    .select{ |n| n.start_with? 'v' }

        return [DEFAULT_VERSION] if valid_tags.empty?
        valid_tags
          .map{ |n| n.sub('v', '').split('.').map(&:to_i) }
          .map{ |a| a.fill(0, a.size..2) }
          .sort
      end

      def open_repository(repo_path)
        ::Git.open repo_path
      rescue ArgumentError
        raise RepositoryNotFound
      end
    end
  end
end
