# frozen_string_literal: true

require 'clamp'
require 'colorize'
require 'uri'

module Acs2aws
  module Cli
    class ConfigCommand < Clamp::Command
      option %w(-v --version), :flag, 'print version information' do
        puts "acs2aws: version #{Acs2aws::VERSION}\n\n"
        exit(0)
      end

      def execute
        puts 'SAML SP Start Page URL:'.colorize(:red)
        sp_url = STDIN.gets.chomp
        until URI.parse(sp_url).is_a?(URI::HTTP)
          puts 'Error: '.colorize(:red) + 'URL must be a valid uri with a scheme matching the http https pattern. Please enter again.'
          sp_url = STDIN.gets.chomp
        end
        File.open(Acs2aws::CONFIG_PATH, 'w') { |f| f.write sp_url }
        puts 'Successfully configure.'.colorize(:green)
      end
    end
  end
end
