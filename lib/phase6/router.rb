require 'byebug'

module Phase6
  class Route
    attr_reader :pattern, :http_method, :controller_class, :action_name

    def initialize(pattern, http_method, controller_class, action_name)
      @action_name = action_name
      @controller_class = controller_class
      @http_method = http_method
      @pattern = pattern
    end

    # checks if pattern matches path and method matches request method
    def matches?(req)
      req.request_method.downcase.to_sym == @http_method &&
        !!@pattern.match(req.path)
    end

    # use pattern to pull out route params (save for later?)
    # instantiate controller and call controller action
    def run(req, res)
      route_params = {}

      regex = @pattern
      route_params_hash = regex.match(req.path)

      unless route_params_hash.nil?
        route_params_hash.names.each do |name|
          route_params[name] = route_params_hash[name]
        end
      end

      c = controller_class.new(req, res, route_params)
      c.invoke_action(action_name)
    end
  end

  class Router
    attr_reader :routes

    def initialize
      @routes = []
    end

    # simply adds a new route to the list of routes
    def add_route(pattern, method, controller_class, action_name)
      @routes << Route.new(pattern, method, controller_class, action_name)
    end

    # evaluate the proc in the context of the instance
    # for syntactic sugar :)
    def draw(&proc)
      self.instance_eval(&proc)
    end

    # make each of these methods that
    # when called add route
    [:get, :post, :put, :delete].each do |http_method|
      define_method("#{http_method}") do |pattern, controller, action_name|
        add_route(pattern, http_method, controller, action_name)
      end
    end

    # should return the route that matches this request
    def match(req)
      routes.each do |route|
        return route if route.matches?(req)
      end
      return nil
    end

    # either throw 404 or call run on a matched route
    def run(req, res)
      matched_route = match(req)
      return res.status = 404 if matched_route.nil?

      matched_route.run(req, res)
    end
  end
end
