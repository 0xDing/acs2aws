# frozen_string_literal: true

require 'acs2aws/version'
require 'acs2aws/cli/config'
require 'acs2aws/cli/refresh'
require 'clamp'
require 'colorize'

module Acs2aws
  CONFIG_PATH = ENV['HOME']+'/.acs2awc.conf'
  SERVER_PORT = 10389
  class MainCommand < Clamp::Command
    option %w(-v --version), :flag, 'print version information' do
      puts "acs2aws: #{Acs2aws::VERSION.colorize(:light_blue)}\n\n"
      exit(0)
    end

    subcommand 'config', 'configure an SAML settings', Cli::ConfigCommand
    subcommand 'refresh', 'retrieve AWS STS token', Cli::RefreshCommand
  end

  MainCommand.run
end
