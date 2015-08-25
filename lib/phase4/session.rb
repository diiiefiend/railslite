require 'json'
require 'webrick'
require 'byebug'

module Phase4
  class Session
    # find the cookie for this app
    # deserialize the cookie into a hash
    def initialize(req)
      @req = req
      cookie = req.cookies.find { |cookie| cookie.name == '_rails_lite_app' }
      if cookie.nil?
        @cookie = {}
      else
        @cookie = JSON.parse(cookie.value)
      end
    end

    def [](key)
      @cookie[key]
    end

    def []=(key, val)
      @cookie[key] = val
    end

    # serialize the hash into json and save in a cookie
    # add to the responses cookies
    def store_session(res)
      cookie = WEBrick::Cookie.new("_rails_lite_app", @cookie.to_json)
      res.cookies << cookie
    end
  end
end
