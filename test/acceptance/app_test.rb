require_relative '../helper'
require 'capybara'
require 'capybara_minitest_spec'
require 'capybara/poltergeist'
require 'socket'

module FocusedController
  module Test
    def self.port
      @port ||= begin
        server = TCPServer.new('127.0.0.1', 0)
        port   = server.addr[1]
      ensure
        server.close if server
      end
    end
  end
end

Capybara.run_server = false
Capybara.app_host   = "http://127.0.0.1:#{FocusedController::Test.port}"

describe 'acceptance test' do
  def app_root
    TEST_ROOT + '/app'
  end

  def within_test_app
    Bundler.with_clean_env do
      Dir.chdir(app_root) do
        begin
          prev_gemfile, ENV['BUNDLE_GEMFILE'] = ENV['BUNDLE_GEMFILE'], "#{app_root}/Gemfile"
          prev_rubyopt, ENV['RUBYOPT']        = ENV['RUBYOPT'], nil
          ENV['RAILS_VERSION'] = ActionPack::VERSION::STRING
          yield
        ensure
          ENV['BUNDLE_GEMFILE'] = prev_gemfile
          ENV['RUBYOPT']        = prev_rubyopt
        end
      end
    end
  end

  def run_without_bundle_exec(command)
    within_test_app do
      `#{command}`
      $?.must_equal 0
    end
  end

  def run_command(command)
    run_without_bundle_exec "bundle exec #{command}"
  end

  def read_output(stream)
    read = IO.select([stream], [], [stream], 0.1)
    output = ""
    loop { output << stream.read_nonblock(1024) } if read
    output
  rescue Errno::EAGAIN, Errno::EWOULDBLOCK, EOFError
    output
  end

  # This spawns a server process to run the app under test,
  # and then waits for it to successfully come up so we can
  # actually run the test.
  def start_server
    within_test_app do
      command = if Gem::Version.new(Rails::VERSION::STRING) < Gem::Version.new('4.1.0')
                  "bundle exec rails s -p #{FocusedController::Test.port} 2>&1"
                else
                  "./bin/rails s -p #{FocusedController::Test.port} 2>&1"
                end

      IO.popen(command) do |out|
        start   = Time.now
        started = false
        output  = ""
        timeout = 60.0

        while !started && !out.eof? && Time.now - start <= timeout
          output << read_output(out)
          sleep 0.1

          begin
            TCPSocket.new('127.0.0.1', FocusedController::Test.port)
          rescue Errno::ECONNREFUSED
          else
            started = true
          end
        end

        raise "Server failed to start:\n#{output}" unless started

        yield

        Process.kill('QUIT', File.read("tmp/pids/server.pid").to_i)
      end
    end
  end

  before do
    run_without_bundle_exec "bundle check >/dev/null || bundle update >/dev/null"
  end

  let(:s) { Capybara::Session.new(:poltergeist, nil) }

  it 'does basic CRUD actions successfully' do
    start_server do
      s.visit '/posts'

      s.click_link 'New Post'
      s.fill_in 'Title', :with => 'Hello world'
      s.fill_in 'Body',  :with => 'Omg, first post'
      s.click_button 'Create Post'

      s.click_link 'Back'
      s.must_have_content 'Hello world'
      s.must_have_content 'Omg, first post'

      s.click_link 'Show'
      s.must_have_content 'Hello world'
      s.must_have_content 'Omg, first post'

      s.click_link 'Edit'
      s.fill_in 'Title', :with => 'Goodbye world'
      s.fill_in 'Body',  :with => 'Omg, edited'
      s.click_button 'Update Post'
      s.must_have_content 'Goodbye world'
      s.must_have_content 'Omg, edited'

      s.click_link 'Back'
      s.click_link 'Destroy'
      s.wont_have_content 'Goodbye world'
      s.wont_have_content 'Omg, edited'
    end
  end

  it 'runs a functional test' do
    run_command "ruby -Itest test/functional/posts_controller_test.rb"
  end

  it 'runs a unit test' do
    run_command "ruby -Itest test/unit/controllers/posts_controller_test.rb"
  end

  it 'runs a functional spec' do
    run_command "rspec spec/controllers/posts_controller_spec.rb"
  end

  it 'runs a unit spec' do
    run_command "rspec spec/unit/controllers/posts_controller_spec.rb"
  end
end
