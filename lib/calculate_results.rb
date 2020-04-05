RAD_PER_DEG = Math::PI / 180
RM = 6371000 # Earth radius in meters

def distance(lat1, lon1, lat2, lon2)
  lat1_rad, lat2_rad = lat1 * RAD_PER_DEG, lat2 * RAD_PER_DEG
  lon1_rad, lon2_rad = lon1 * RAD_PER_DEG, lon2 * RAD_PER_DEG

  a = Math.sin((lat2_rad - lat1_rad) / 2) ** 2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin((lon2_rad - lon1_rad) / 2) ** 2
  c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1 - a))

  RM * c # Delta in meters
end

def calculate_results points, waypoints, max_distance=120
	# Choose all points that hit any of the cylinders (waypoint + max_distance)
	# Default: max_distance = 120 #m
	result = []
	waypoints.each do |wp|
		points.each do |pt|
			ds = distance(wp[:latitude], wp[:longitude], pt[:latitude], pt[:longitude])
			if ds <= max_distance
				#puts "Hit: #{ds.round(0)}"
				unless result.include?(wp)
					#puts "First added hit: #{ds.round(0)}"
					# I dont add it, as it is not the closest one, just first found.
					# wp[:distance] = ds.round(0)
					result << wp
				end
			end
		end
	end
	result
end