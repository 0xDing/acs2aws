# frozen_string_literal: true

require 'clamp'
require 'launchy'
require 'acs2aws/acs_server'


module Acs2aws
  module Cli
    class RefreshCommand < Clamp::Command
      def execute
        srv = Acs2aws::AcsServer.new
        Launchy.open("http://localhost:#{Acs2aws::SERVER_PORT}/")
        srv.instance.run!
      end
    end
  end
end