# Acs2aws



## Installation
Login and retrieve AWS STS Token using a any SAML IDP. Inspired by OAuth2WebServerFlow.

 install it yourself as:
```bash
 $ gem install acs2aws
```

## Usage

```bash
Usage:
    acs2aws [OPTIONS] SUBCOMMAND [ARG] ...

Parameters:
    SUBCOMMAND                    subcommand
    [ARG] ...                     subcommand arguments

Subcommands:
    config                        configure an SAML settings
    refresh                       retrieve AWS STS token

Options:
    -v, --version                 print version information
    -h, --help                    print help
```

### Quick Start

```bash
 $ acs2aws config
SAML SP Start Page URL:
https://example.com/auth/aws
Successfully configure.

 $ aws2aws refresh
```

### SAML IdP Example

[saml_idp](https://github.com/saml-idp/saml_idp) is Ruby SAML Identity Provider, best used with Rails.


Add this to your Gemfile:

```
gem 'saml_idp'
```

Add to your `routes.rb` file, for example:

```ruby
get '/auth/aws', to: 'saml#aws'
get '/saml/auth' => 'saml_idp#new'
get '/saml/metadata' => 'saml_idp#show'
post '/saml/auth' => 'saml_idp#create'
match '/saml/logout' => 'saml_idp#logout', via: [:get, :post, :delete]
```

Create a controller that looks like this, customize to your own situation:

```ruby
# frozen_string_literal: true

class Api::SamlIdpController < SamlIdp::IdpController

  def create
    current_user = User.find(session[:current_user_id]) rescue nil
      if current_user.nil?
        redirect_to(auth_path(r: request.fullpath))
      else
        @saml_response = idp_make_saml_response(current_user)
        # noinspection RailsParamDefResolve
        # nonprivileged port is 1025-65535
        #
        # rubocop:disable Sequioacap/SimpleModifierConditional
        @acs_url = "http://localhost:#{params[:cli_port]}/saml_acs" if params[:cli_port].present? && params[:cli_port]&.to_i&.between?(1025, 65535)
        render 'api/saml_idp/saml_post', layout: false
      end
  end

  private

  def idp_make_saml_response(user)
    encode_response user
  end

  def idp_logout
    session.delete(:current_user_id)
  end

end
```

```ruby
# frozen_string_literal: true

class SamlController < ApplicationController

  def aws
    request = OneLogin::RubySaml::Authrequest.new
    redirect_to(request.create(aws_saml_settings, cli_port: params[:cli_port]))
  end

  private

  def current_user
    User.find(session[:current_user_id]) rescue nil
  end

  def aws_saml_settings
    idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
    settings = idp_metadata_parser.parse(SamlIdp.metadata.signed)
    settings.assertion_consumer_service_url = 'https://signin.aws.amazon.com/saml'
    settings.issuer                         = 'https://signin.aws.amazon.com/static/saml-metadata.xml'
    settings.name_identifier_format         = 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic'
    settings
  end

end

```

`/app/views/api/saml_idp/saml_post.html.erb`:
```erb
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
</head>
<body onload="document.forms[0].submit();" style="visibility:hidden;">
<%= form_tag(@acs_url.present? ? @acs_url:saml_acs_url) do %>
  <%= hidden_field_tag("SAMLResponse", @saml_response) %>
  <%= hidden_field_tag("RelayState", params[:RelayState]) %>
  <%= submit_tag "Submit" %>
<% end %>
</body>
</html>
```



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/0xding/acs2aws. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Acs2aws project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/0xding/acs2aws/blob/master/CODE_OF_CONDUCT.md).
