# frozen_string_literal: true

require 'sinatra/base'
require 'acs2aws/aws_sts'
require 'uri'

module Acs2aws
  class AcsServer
    attr_accessor :instance

    def initialize
      sp_url = File.read(Acs2aws::CONFIG_PATH) rescue nil
      valid_sp_url = URI.parse(sp_url).is_a?(URI::HTTP) rescue false
      raise StandardError.new('Error: '.colorize(:red) + 'Config not found or invalid. Please re-configure.') unless valid_sp_url
      @instance = Sinatra.new do
        set :port, Acs2aws::SERVER_PORT
        set :title, 'acs2aws'
        get '/' do
          redirect "#{sp_url}?cli_port=#{Acs2aws::SERVER_PORT}"
        end

        post '/saml_acs' do
          Acs2aws::AwsSts.new(params['SAMLResponse'])
          body 'Successfully. <script>window.opener = self;window.close();</script>'
          Thread.new do
            sleep 1
            Process.kill 'INT', Process.pid
          end
          halt 200
        end
      end
    end

  end
end
