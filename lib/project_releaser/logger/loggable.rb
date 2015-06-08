module ProjectReleaser
  module Logger
    module Loggable
      def logger
        ProjectReleaser.configuration.logger || Console.new
      end
    end
  end
end
