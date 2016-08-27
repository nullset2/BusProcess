require_relative '../config/api_config'
require_relative 'api_client'
require 'pry'

class BusSimulator

	def initialize
		@api_client = ApiClient.new
		@sleep_time = 10
		@route_id = 1
	end

	def run
		data = []
		drivers = @api_client.get_drivers
		drivers.each do |driver|
			route_id = driver["driver_route"]["route_id"]
			polyline = @api_client.get_route_polyline(route_id)
			data << {index: 0, driver: driver, polyline: polyline}
		end

		loop do
			data.each do |x|
				index = x[:index]
				index = 0 if index >= x[:polyline].count
				driver = x[:driver]
				polyline = x[:polyline]
				current_location = polyline[index]
				@api_client.authenticate(driver["email"], "testingpassword")
				@api_client.update_user_location(current_location[0], current_location[1])
				index += 1
			end
			sleep @sleep_time
		end



		routes_with_drivers = @api_client.get_routes_with_drivers
		processing_routes = []

		routes_with_drivers.each do |id|
			polyline = @api_client.get_route_polyline(id)
			processing_routes << {id: id, index: 0, polyline: polyline}
		end

		loop do
			processing_routes.each do |route|
				index = route[:index]
				index = 0 if index >= route[:polyline].count
				current_location = route[:polyline][index]
				@api_client.update_user_location(current_location[0], current_location[1])
				route[:index] += 1
			end
			sleep @sleep_time
		end unless routes_with_drivers.nil? || routes_with_drivers.empty?
	end

end