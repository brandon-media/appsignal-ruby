require 'fileutils'

module Appsignal
  class Heartbeat
    CONTROL_FILE_PATH = File.join(Dir.pwd, 'tmp', 'last_heartbeat')

    class << self
      def start
        Appsignal.logger.debug("Starting heartbeat thread")
        Thread.new do
          begin
            loop do
              do_heartbeat
              sleep(wait_time)
            end
          rescue => ex
            Appsignal.logger.error("Error in heartbeat thread: #{ex}")
          end
        end
      end

      def do_heartbeat
        if right_time?
          Appsignal.monitor_transaction(
            'perform_job.heartbeat',
            class: 'Appsignal',
            method: 'heartbeat',
            queue_start: Time.now
          ) do
            sleep(1)
          end
          Appsignal.logger.debug("Heartbeat")
          FileUtils.touch(CONTROL_FILE_PATH)
        end
      end

      def wait_time
        4 * 60 * 60
      end

      def right_time?
        last_heartbeat_at = File.mtime(CONTROL_FILE_PATH) rescue nil
        return true unless last_heartbeat_at

        Time.now - last_heartbeat_at >= wait_time
      end
    end
  end
end
