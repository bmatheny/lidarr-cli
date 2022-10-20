# frozen_string_literal: true

require_relative "loggerpatch"
require_relative "option"

module Lidarr
  module Logging
    DEFAULT_LOG_FORMAT = "%Y-%m-%d %H:%M:%S.%L"

    def get options = {}
      class_variable_set(:@@logger, get_logger(options)) unless class_variable_defined?(:@@logger)
      class_variable_get(:@@logger)
    end
    module_function :get

    def get_logger options = {}
      return options[:logger] if options[:logger]
      trace = Lidarr::Option(options[:trace]).get_or_else(false)
      debug = Lidarr::Option(options[:debug]).get_or_else(false)
      progname = Lidarr::Option(options[:progname] || options[:program]).get_or_else("unknown")
      logfile = Lidarr::Option(options[:logfile]).get_or_else($stdout)
      logger = Logger.new(logfile)
      logger.level = if trace
        Logger::TRACE
      elsif debug
        Logger::DEBUG
      else
        Logger::INFO
      end
      logger.progname = File.basename(progname)
      logger.formatter = proc { |severity, datetime, progname, message|
        date_s = datetime.strftime(Lidarr::Logging::DEFAULT_LOG_FORMAT)
        "#{severity} [#{date_s}] #{progname}: #{message}\n"
      }
      logger
    end # end get_logger
    module_function :get_logger
  end # end module Logger

  def logger
    Lidarr::Logging.get
  end
  module_function :logger
end # end module Lidarr
