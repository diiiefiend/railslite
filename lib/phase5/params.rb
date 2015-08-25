require 'uri'
require 'byebug'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:

    def initialize(req, route_params = {})
      @params = {}
      @params.merge!(route_params)
      # debugger if !route_params.empty?
      parse_www_encoded_form(req.query_string)
      parse_www_encoded_form(req.body)
    end

    def [](key)
      if @params.member?(key)
        @params[key]
      else
        key.is_a?(String) ? @params[key.to_sym] : @params[key.to_s]
      end
    end

    # this will be useful if we want to `puts params` in the server log
    def to_s
      @params.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      if !www_encoded_form.nil?
        URI.decode_www_form(www_encoded_form).each do |k, v|
          all_keys = parse_key(k)
          @params.deep_merge!(generate_hash(all_keys, v))
        end
      end
    end

    def generate_hash(key, value)
      hash = {}
      if key.length == 1
        hash[key[0]] = value
        return hash
      end
      hash[key[0]] = generate_hash(key.drop(1), value)
      return hash
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end
  end
end
