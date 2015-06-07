module ProjectReleaser
  module Logger
    class Console
      def info(msg)
        puts msg
      end

      alias_method :error, :info

    end
  end
end
