module OnsOnRails
  module RSpec
    module SilenceHelper
      def silence_logger(logger, temporary_level = ::Logger::UNKNOWN)
        old_logger_level = logger.level
        logger.level = temporary_level

        yield
      ensure
        logger.level = old_logger_level
      end
    end
  end
end
