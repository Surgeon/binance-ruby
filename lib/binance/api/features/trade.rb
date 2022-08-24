module Binance
  module Api
    module Features
      class Trade
        class << self
          def mark_price!(symbol: nil, recvWindow: nil, api_key: nil, api_secret_key: nil)
            timestamp = Configuration.timestamp
            params = { symbol: symbol, recvWindow: recvWindow, timestamp: timestamp }
            ensure_required_create_keys!(params: params)
            Request.send!(api_key_type: :read_info, path: "/fapi/v1/premiumIndex",
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
            [:symbol].freeze
          end
        end
      end
    end
  end
end
