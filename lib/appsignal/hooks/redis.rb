module Appsignal
  class Hooks
    # @api private
    class RedisHook < Appsignal::Hooks::Hook
      register :redis

      def dependencies_present?
        defined?(::Redis) &&
          Appsignal.config &&
          Appsignal.config[:instrument_redis]
      end

      def install
        ::Redis::Client.class_eval do
          alias process_without_appsignal process

          def process(commands, &block)
            sanitized_commands = commands.map do |command, *args|
              "#{command}#{args.map { |_| ' ?'}.join}"
            end.join("\n")

            Appsignal.instrument "query.redis" do
              process_without_appsignal(commands, &block)
            end
          end
        end
      end
    end
  end
end
