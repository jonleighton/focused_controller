require 'helper'
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
  def run_without_bundle_exec(command)
    Dir.chdir(TEST_ROOT + '/app') do
      Bundler.with_clean_env do
        `#{command}`
        $?.must_equal 0
      end
    end
  end

  def run_command(command)
    run_without_bundle_exec "bundle exec #{command}"
  end

  # This spawns a server process to run the app under test,
  # and then waits for it to successfully come up so we can
  # actually run the test.
  def start_server
    output = IO.pipe
    @pid = Kernel.spawn(
      { 'BUNDLE_GEMFILE' => TEST_ROOT + '/app/Gemfile' },
      "bundle exec rails s -p #{FocusedController::Test.port}",
      :chdir => TEST_ROOT + '/app',
      :out => output[1], :err => output[1]
    )

    start   = Time.now
    started = false

    while !started && Time.now - start <= 15.0
      begin
        sleep 0.1
        TCPSocket.new('127.0.0.1', FocusedController::Test.port)
      rescue Errno::ECONNREFUSED
      else
        started = true
      end
    end

    unless started
      puts "Server failed to start"
      puts "Output:"
      puts

      loop do
        begin
          print output[0].read_nonblock(1024)
        rescue Errno::EWOULDBLOCK, Errno::EAGAIN
          puts
          break
        end
      end

      raise
    end

    yield

    Process.kill('TERM', @pid)
  end

  before do
    run_without_bundle_exec "bundle --quiet"
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
