module HashExtensions
  def assert_required_keys(*args)
    missing_args = args.reject{|arg| self.key?(arg) }
    raise ArgumentError.new("Missing keys: #{missing_args.join(', ')}") if missing_args.any?
    self
  end

  def stringify_values!
    each_pair {|k,v| self[k] = v.to_s }
    self
  end


  ## Returns selected keys, named or renamed as specified
  # myproduct = {:name => "something", :price => "20"}
  # liability = myproduct.tap(&{:cost => :price}.to_transformer)
  # liability[:cost] == 20
  ## Note: Tap only works where source is a hash object, so use as otherwise
  # (because tap always returns the object you are tapping)
  # myproduct = ::OpenStruct.new({:name => "something", :price => "20"})
  # liability.as!({:cost => :price})
  # liability[:cost] == 20
  #
  # Transforming values:
  # Pass a hash as the value with the key being the source key/method
  # myproduct = ::OpenStruct.new({:name => "something", :price => "20"})
  # my_sale_product = myproduct.as!({:sale_price => {:price => ->(val){ val / 2 } } })
  # my_sale_product[:sale_price] == 10

  def to_transformer
    ->(hash_or_object) {
      new_hash = {}

      if hash_or_object.is_a?(::Hash)
        self.each_pair do |k,v|
          if v.is_a?(Hash)
            new_hash[k] = v.values.first.call(hash_or_object[v.keys.first])
          elsif v.is_a?(Proc)
            new_hash[k] = v.call(hash_or_object[k])
          else
            new_hash[k] = hash_or_object[v]
          end
        end

        hash_or_object.keys.map{ |k| hash_or_object.delete(k) }
        hash_or_object.merge!(new_hash)
      else
        self.each_pair do |k,v|
          if v.is_a?(Hash)
            new_hash[k] = v.values.first.call(hash_or_object.__send__(v.keys.first))
          elsif v.is_a?(Proc)
            new_hash[k] = v.call(hash_or_object.__send__(k))
          else
            new_hash[k] = hash_or_object.__send__(v)
          end
        end
      end

      return new_hash
    }
  end
end

class Hash
  include HashExtensions
end
