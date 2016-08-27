require 'rest-client'
require 'json'

require_relative '../config/api_config'
require_relative '../config/api_routes'

class ApiClient
	def initialize
		@server = ApiConfig::SERVER_URL
		@sign_in = form_route ApiRoutes::SIGN_IN
		@get_routes = form_route ApiRoutes::GET_ROUTES
		@get_drivers = form_route ApiRoutes::GET_DRIVERS
		@put_user_location = form_route ApiRoutes::PUT_USER_LOCATION
		@headers = {
			:content_type => :json,
			:accept => :json
		}

		@email = ApiConfig::EMAIL
		@password = ApiConfig::PASSWORD
		@authentication_resp = authenticate(@email, @password)
		#@user = create_reponse(@authentication_resp.body)
	end

	def form_route(route)
		"#{@server}#{route}"
	end

	def create_reponse(response)
		JSON.parse response
	end

	def post(route)
		RestClient.post(route, nil, @headers)
	end

	def put(route, body)
		RestClient.put(route, body, @headers)
	end

	def get(route)
		create_reponse(RestClient.get("#{route}", @headers))
	end

	def authenticate(email, password)
		@authentication_resp = post("#{@sign_in}?email=#{email}&password=#{password}")
		@headers[:access_token] = @authentication_resp.headers[:access_token]
		@headers[:client] = @authentication_resp.headers[:client]
		@headers[:uid] = @authentication_resp.headers[:uid]
	end

	def get_route_polyline(route_id)
		route_body = get "#{@get_routes}/#{route_id}"
		route_body["decrypted_points"]
	end

	def get_drivers
		drivers = get "#{@get_drivers}?search_distance=100"
	end

	def get_routes_with_drivers
		get_drivers.collect {|x| x["driver_route"]["route_id"]}
	end

	def update_user_location(latitude, longitude)
		put "#{@put_user_location}", {latitude: latitude, longitude: longitude}
		puts [latitude, longitude].to_s
	end

end