# frozen_string_literal: true

require "logger"

class Logger
  module Severity
    TRACE = -1
  end

  def less_verbose
    if level < Logger::Severity::UNKNOWN
      @level += 1
    end
  end

  def more_verbose
    if level > Logger::Severity::TRACE
      @level -= 1
    end
  end

  def trace?
    level <= Logger::Severity::TRACE
  end

  def trace!
    @level = Logger::Severity::TRACE
  end

  def trace(progname = nil, &block)
    add(TRACE, nil, progname, &block)
  end

  private

  def format_severity severity
    if severity == TRACE
      "TRACE"
    else
      SEV_LABEL[severity] || "ANY"
    end
  end
end
