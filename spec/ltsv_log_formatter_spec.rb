require_relative 'spec_helper'
require 'ltsv_log_formatter'
require 'fileutils'
require 'logger'

describe LtsvLogFormatter do
  let(:logger) do
    Logger.new("#{log_dir}/test.log").tap {|logger|
      logger.formatter = LtsvLogFormatter.new(opts)
    }
  end
  let(:opts)    { {} }
  let(:log_dir) { "#{File.dirname(__FILE__)}/log" }
  let(:now)     { Time.now.iso8601 }

  before do
    FileUtils.mkdir_p log_dir
    Timecop.freeze(Time.now)
  end

  after do
    FileUtils.rm_rf log_dir
    Timecop.return
  end

  def gets
    File.open("#{log_dir}/test.log") do |f|
      f.gets # drop the `# Logfile created on ...` line
      return f.gets
    end
  end

  describe 'options' do
    context '#initialize' do
      it 'with default' do
        formatter = LtsvLogFormatter.new
        expect(formatter.opts[:time_key]).to eql(:time)
        expect(formatter.opts[:level_key]).to eql(:level)
        expect(formatter.opts[:message_key]).to eql(:message)
      end

      it 'with time_key' do
        formatter = LtsvLogFormatter.new("time_key" => "foo")
        expect(formatter.opts[:time_key]).to eql("foo")
      end

      it 'with level_key' do
        formatter = LtsvLogFormatter.new("level_key" => "foo")
        expect(formatter.opts[:level_key]).to eql("foo")
      end

      it 'with message_key' do
        formatter = LtsvLogFormatter.new("message_key" => "foo")
        expect(formatter.opts[:message_key]).to eql("foo")
      end
    end

    context 'with time_key nil' do
      let(:opts) { {time_key: nil} }

      it 'should not output a time field' do
        logger.info("test")
        expect(gets).to eq "level:INFO\tmessage:test\n"
      end
    end

    context 'with level_key nil' do
      let(:opts) { {level_key: nil} }

      it 'should not output a level field' do
        logger.info("test")
        expect(gets).to eq "time:#{now}\tmessage:test\n"
      end
    end

    context 'with message_key nil' do
      let(:opts) { {message_key: nil} }

      it 'should have no effect' do
        logger.info("test")
        expect(gets).to eq "time:#{now}\tlevel:INFO\tmessage:test\n"
      end
    end
  end

  describe 'string param' do
    context 'with default' do
      it do
        logger.info("test")
        expect(gets).to eq "time:#{now}\tlevel:INFO\tmessage:test\n"
      end
    end

    context 'with message_key' do
      let(:opts) { {message_key: "foo"} }

      it do
        logger.info("test")
        expect(gets).to eq "time:#{now}\tlevel:INFO\tfoo:test\n"
      end
    end

    it 'with line feed' do
      logger.info("foo\nbar")
      expect(gets).to eq "time:#{now}\tlevel:INFO\tmessage:foo\\nbar\n"
    end
  end

  describe 'hash param' do
    context 'with default' do
      it do
        logger.info(foo: "bar")
        expect(gets).to eq "time:#{now}\tlevel:INFO\tfoo:bar\n"
      end
    end

    it 'with line feed' do
      logger.info(foo: "foo\nbar")
      expect(gets).to eq "time:#{now}\tlevel:INFO\tfoo:foo\\nbar\n"
    end
  end

  describe 'block param' do
    context 'with string' do
      it do
        logger.info { "test" }
        expect(gets).to eq "time:#{now}\tlevel:INFO\tmessage:test\n"
      end
    end

    context 'with hash' do
      it do
        logger.info { {foo: "bar"} }
        expect(gets).to eq "time:#{now}\tlevel:INFO\tfoo:bar\n"
      end
    end
  end

  describe 'escape LF and TAB' do
    context 'with LF' do
      it do
        logger.info(foo: "bar\nbar")
        expect(gets).to eq "time:#{now}\tlevel:INFO\tfoo:bar\\nbar\n"
      end
    end

    context 'with TAB' do
      it do
        logger.info(foo: "bar\tbar")
        expect(gets).to eq "time:#{now}\tlevel:INFO\tfoo:bar\\tbar\n"
      end
    end
  end
end
