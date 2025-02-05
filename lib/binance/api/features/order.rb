module Binance
  module Api
    module Features
      class Order
        class << self
          def create!(newClientOrderId: nil, newOrderResponseType: nil, closePosition: nil, reduceOnly: nil,
                      price: nil, quantity: nil, recvWindow: nil, stopPrice: nil, symbol: nil,
                      callbackRate: nil, activationPrice: nil, workingType: nil,
                      side: nil, type: nil, timeInForce: nil, test: false, api_key: nil, api_secret_key: nil)
            timestamp = Configuration.timestamp
            params = {
              newClientOrderId: newClientOrderId, reduceOnly: reduceOnly,
              newOrderRespType: newOrderResponseType, price: price, quantity: quantity, closePosition: closePosition,
              recvWindow: recvWindow, stopPrice: stopPrice, symbol: symbol, side: side,
              callbackRate: callbackRate, activationPrice: activationPrice, workingType: workingType,
              type: type, timeInForce: timeInForce, timestamp: timestamp,
            }.delete_if { |key, value| value.nil? }
            ensure_required_create_keys!(params: params)
            path = "/fapi/v1/order#{"/test" if test}"
            Request.send!(api_key_type: :trading, method: :post, path: path,
                          params: params, security_type: :features, tld: Configuration.tld, api_key: api_key,
                          api_secret_key: api_secret_key)
          end

          def cancel!(orderId: nil, originalClientOrderId: nil, recvWindow: nil, symbol: nil,
                      api_key: nil, api_secret_key: nil)
            raise Error.new(message: "symbol is required") if symbol.nil?
            raise Error.new(message: "either orderid or originalclientorderid " \
                          "is required") if orderId.nil? && originalClientOrderId.nil?
            timestamp = Configuration.timestamp
            params = { orderId: orderId, origClientOrderId: originalClientOrderId,
                       recvWindow: recvWindow,
                       symbol: symbol, timestamp: timestamp }.delete_if { |key, value| value.nil? }
            Request.send!(api_key_type: :trading, method: :delete, path: "/fapi/v1/order",
                          params: params, security_type: :features, tld: Configuration.tld, api_key: api_key,
                          api_secret_key: api_secret_key)
          end

          # Be careful when accessing without a symbol!
          def cancel_all_open!(recvWindow: 5000, symbol: nil, api_key: nil, api_secret_key: nil)
            timestamp = Configuration.timestamp
            params = { recvWindow: recvWindow, symbol: symbol, timestamp: timestamp }
            Request.send!(api_key_type: :trading, method: :delete, path: "/fapi/v1/allOpenOrders",
                          params: params, security_type: :features, tld: Configuration.tld, api_key: api_key,
                          api_secret_key: api_secret_key)
          end

          def status!(orderId: nil, originalClientOrderId: nil, recvWindow: nil, symbol: nil,
                      api_key: nil, api_secret_key: nil)
            raise Error.new(message: "symbol is required") if symbol.nil?
            raise Error.new(message: "either orderid or originalclientorderid " \
                          "is required") if orderId.nil? && originalClientOrderId.nil?
            timestamp = Configuration.timestamp
            params = {
              orderId: orderId, origClientOrderId: originalClientOrderId, recvWindow: recvWindow,
              symbol: symbol, timestamp: timestamp,
            }.delete_if { |key, value| value.nil? }
            Request.send!(api_key_type: :trading, path: "/fapi/v1/order",
                          params: params, security_type: :features, tld: Configuration.tld, api_key: api_key,
                          api_secret_key: api_secret_key)
          end

          def all!(limit: 500, orderId: nil, recvWindow: 5000, symbol: nil, api_key: nil, api_secret_key: nil)
            raise Error.new(message: "max limit is 500") unless limit <= 500
            raise Error.new(message: "symbol is required") if symbol.nil?
            timestamp = Configuration.timestamp
            params = { limit: limit, orderId: orderId, recvWindow: recvWindow, symbol: symbol, timestamp: timestamp }
            Request.send!(api_key_type: :read_info, path: "/fapi/v1/allOrders",
                          params: params.delete_if { |key, value| value.nil? },
                          security_type: :features, tld: Configuration.tld, api_key: api_key,
                          api_secret_key: api_secret_key)
          end

          # Be careful when accessing without a symbol!
          def all_open!(recvWindow: 5000, symbol: nil, api_key: nil, api_secret_key: nil)
            timestamp = Configuration.timestamp
            params = { recvWindow: recvWindow, symbol: symbol, timestamp: timestamp }
            Request.send!(api_key_type: :read_info, path: "/fapi/v1/openOrders",
                          params: params, security_type: :features, tld: Configuration.tld, api_key: api_key,
                          api_secret_key: api_secret_key)
          end

          private

          def additional_required_create_keys(type:)
            case type
            when :limit
              [:price, :timeInForce].freeze
            when :stop_loss, :take_profit
              [:stopPrice].freeze
            when :stop_loss_limit, :take_profit_limit
              [:price, :stopPrice, :timeInForce].freeze
            when :limit_maker
              [:price].freeze
            else
              [].freeze
            end
          end

          def ensure_required_create_keys!(params:)
            keys = required_create_keys.dup.concat(additional_required_create_keys(type: params[:type]))
            missing_keys = keys.select { |key| params[key].nil? }
            raise Error.new(message: "required keys are missing: #{missing_keys.join(", ")}") unless missing_keys.empty?
          end

          def required_create_keys
            [:symbol, :side, :type, :timestamp].freeze
          end
        end
      end
    end
  end
end
