require 'colorize'

module ProjectReleaser
  module Logger
    class ColoredConsole
      COLORS = {
        :light_blue => "'",
        :green => '`',
        :yellow => '"'
      }

      def info(msg)
        puts colorize(msg)
      end

      def error(msg)
        info "\"Error\": #{msg}"
      end

      private

      def colorize(msg)
        msg = color_all_words(msg, :light_white)
        COLORS.each do |color, char|
          msg = color_char(msg, char, color)
        end
        msg
      end

      def color_all_words(msg, color)
        msg.split.map { |w| w.colorize(color) }.join(' ')  
      end

      def color_char(msg, char, color)
        color_regexp = Regexp.new "#{char}.*?#{char}"
        cleanup_regexp = Regexp.new "#{char}"
        msg.gsub(color_regexp) {|m| m.gsub(cleanup_regexp, '').colorize color}
      end
    end
  end
end
