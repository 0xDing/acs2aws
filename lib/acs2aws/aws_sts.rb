# frozen_string_literal: true

require 'aws-sdk-iam'
require 'base64'
require 'nokogiri'

module Acs2aws
  class AwsSts
    attr_accessor :encode_saml, :saml

    def initialize(encode_saml)
      @encode_saml = encode_saml
      @saml = Nokogiri::XML(Base64.decode64(encode_saml))
      role_entitlement = @saml.xpath('//*[@Name="https://aws.amazon.com/SAML/Attributes/Role"]')
                             .children.children.to_s.split(',')

      # TODO: support customized region.
      client = Aws::STS::Client.new(region: 'ap-southeast-1', credentials: nil)
      resp = client.assume_role_with_saml(
           role_arn: role_entitlement[0],
           principal_arn: role_entitlement[1],
           saml_assertion: @encode_saml,
           # 12 hours
           duration_seconds: 43200
       )
      # puts resp
      system "aws configure --profile default set aws_access_key_id #{resp.credentials.access_key_id}"
      system "aws configure --profile default set aws_secret_access_key #{resp.credentials.secret_access_key}"
      system "aws configure --profile default set aws_session_token #{resp.credentials.session_token}"

      puts "Successfully refresh. Expiration at #{resp.credentials.expiration}".colorize(:green)
    end
  end
end
