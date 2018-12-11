# frozen_string_literal: true
# https://github.com/matti/sinatra-silent

module Sinatra
  module Silent
    class SilentLogger
      # rubocop:disable Style/MethodMissingSuper
      # rubocop:disable Style/MissingRespondToMissing
      def method_missing(m, *args, &block); end
    end

    module ClassMethods
      def set(option, value = (not_set = true), ignore_setter = false, &block)
        return if option == {}

        case option
        when :silent_all
          set :silent_sinatra, true
          set :silent_webrick, true
          set :silent_access_log, true
        when :silent_access_log
          new_server_settings = if value == true
                                  existing_server_settings.merge(AccessLog: [])
                                else
                                  existing_server_settings.tap { |hash| hash.delete(:AccessLog) }
                                end

          super :server_settings, new_server_settings
        when :silent_sinatra
          case value
          when true
            self.define_singleton_method :suppress_messages? do
              return true
            end
          when false
            self.define_singleton_method :suppress_messages? do
              handler_name =~ /cgi/i || quiet
            end
          end
        when :silent_webrick
          new_server_settings = if value == true
                                  existing_server_settings.merge(Logger: SilentLogger.new)
                                else
                                  existing_server_settings.tap { |hash| hash.delete(:Logger) }
                                end

          super :server_settings, new_server_settings
        else
          super option, value, ignore_setter, &block
        end
      end

      private

      def existing_server_settings
        return {} unless self.settings.respond_to? :server_settings
        self.settings.server_settings
      end
    end

    def self.prepended(base)
      class << base
        prepend ClassMethods
      end
    end
  end
end

Sinatra::Base.prepend Sinatra::Silent
