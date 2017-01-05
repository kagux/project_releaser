module ProjectReleaser
  module Project
    class Info
      def initialize(git)
        @git = git
      end

      def name
        url = @git.remotes.values.last
        return 'unknown' if url.nil?

        repo_name_start = url.index('/') + 1
        url[repo_name_start..-1].sub(/\.git$/, '')
      end

      def current_version
        @git.fetch_tags
        format @git.current_version
      end

      def next_version(version_type = :patch)
        version_type = (version_type || :patch).to_sym
        return exact_version(version_type) unless valid_version_part? version_type

        new_version = @git.current_version
        new_version[version_type] += 1
        new_version = reset_lesser_versions new_version, version_type
        format new_version
      end

      private

      def exact_version(version)
        raise ArgumentError unless version =~ /\Av{0,1}\d+\.\d+\.\d+\Z/
        version.to_s.prepend('v').sub('vv', 'v')
      end

      def valid_version_part?(version)
        Project::Repository::VERSION_PARTS.include? version
      end

      def format(version)
        'v' << version.values.join('.')
      end

      def reset_lesser_versions(full_version, cutoff_version)
        keys = full_version.keys
        index = keys.index cutoff_version
        Hash[full_version.map { |k, v| keys.index(k) <= index ? [k, v] : [k, 0] }]
      end
    end
  end
end
