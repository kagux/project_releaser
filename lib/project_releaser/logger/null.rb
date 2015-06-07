module ProjectReleaser
  module Logger
    class Null
      def info(msg)
        # no op
      end

      alias_method :error, :info
    end
  end
end

