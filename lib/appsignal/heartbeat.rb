module Appsignal
  class Heartbeat
    class << self
      def start
        Appsignal.logger.debug("Starting heartbeat thread")
        Thread.new do
          begin
            loop do
              Appsignal.monitor_transaction(
                'perform_job.heartbeat',
                class: 'Appsignal',
                method: 'heartbeat',
                queue_start: Time.now
              ) do
                sleep(1)
              end
              Appsignal.logger.debug("Heartbeat")
              sleep(wait_time)
            end
          rescue => ex
            Appsignal.logger.error("Error in heartbeat thread: #{ex}")
          end
        end
      end

      def wait_time
        4 * 60 * 60
      end
    end
  end
end
