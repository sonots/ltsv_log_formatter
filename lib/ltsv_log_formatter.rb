require 'time'

class LtsvLogFormatter
  # for tests
  attr_reader :opts

  # @param [Hash] opts
  # @option opts [String] time_key (default: time)
  # @option opts [String] level_key (default: level)
  # @option opts [String] message_key (default: message)
  def initialize(opts={})
    @opts = opts.map {|k, v| [k.to_sym, v] }.to_h # symbolize_keys
    @opts[:time_key]      = :time    unless @opts.has_key?(:time_key)
    @opts[:level_key]     = :level   unless @opts.has_key?(:level_key)
    @opts[:message_key] ||= :message
  end

  def call(severity, time, progname, msg)
    "#{format_time(time)}#{format_severity(severity)}#{format_message(msg)}\n"
  end

  private
  def format_time(time)
    "#{@opts[:time_key]}:#{time.iso8601}\t" if @opts[:time_key]
  end

  def format_severity(severity)
    "#{@opts[:level_key]}:#{severity}\t" if @opts[:level_key]
  end

  LF = "\n".freeze
  TAB = "\t".freeze
  ESCAPED_LF = "\\n".freeze
  ESCAPED_TAB = "\\t".freeze
  ESCAPE_TARGET = /[#{LF}#{TAB}]/

  def format_message(msg)
    unless msg.is_a?(Hash)
      msg = { @opts[:message_key] => msg }
    end
    msg.map {|k, v| "#{k}:#{v.to_s.gsub(ESCAPE_TARGET, LF => ESCAPED_LF, TAB => ESCAPED_TAB)}" }.join(TAB)
  end
end
