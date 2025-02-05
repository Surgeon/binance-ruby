module Binance
  module Api
    module Features
      class Account
        class << self
          def balance!(recvWindow: nil, api_key: nil, api_secret_key: nil)
            timestamp = Configuration.timestamp
            params = { recvWindow: recvWindow, timestamp: timestamp }
            Request.send!(api_key_type: :read_info, path: "/fapi/v2/balance",
                          params: params.delete_if { |key, value| value.nil? },
                          security_type: :features, api_key: api_key, api_secret_key: api_secret_key)
          end

          def position_risk!(symbol: nil, recvWindow: nil, api_key: nil, api_secret_key: nil)
            timestamp = Configuration.timestamp
            params = { symbol: symbol, recvWindow: recvWindow, timestamp: timestamp }
            Request.send!(api_key_type: :read_info, path: "/fapi/v2/positionRisk",
                          params: params.delete_if { |key, value| value.nil? },
                          security_type: :features, api_key: api_key, api_secret_key: api_secret_key)
          end

          def start_user_stream!(api_key: nil, api_secret_key: nil)
            timestamp = Configuration.timestamp
            params = { timestamp: timestamp }
            Request.send!(api_key_type: :read_info, method: :post, path: "/fapi/v1/listenKey",
                          params: params.delete_if { |key, value| value.nil? },
                          security_type: :features, api_key: api_key, api_secret_key: api_secret_key)
          end

          def keepalive_user_stream!(api_key: nil, api_secret_key: nil)
            timestamp = Configuration.timestamp
            params = { timestamp: timestamp }
            Request.send!(api_key_type: :read_info, method: :put, path: "/fapi/v1/listenKey",
                          params: params.delete_if { |key, value| value.nil? },
                          security_type: :features, api_key: api_key, api_secret_key: api_secret_key)
          end

          private

          def ensure_required_create_keys!(params:)
            keys = required_create_keys.dup
            missing_keys = keys.select { |key| params[key].nil? }
            raise Error.new(message: "required keys are missing: #{missing_keys.join(", ")}") unless missing_keys.empty?
          end

          def required_create_keys
            [].freeze
          end
        end
      end
    end
  end
end
