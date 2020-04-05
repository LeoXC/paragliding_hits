
def read_waypoints_with_info(wp_file)
	log_line "Reading waypoints file: #{wp_file}"
	
	(waypoints, errors) = read_waypoints(wp_file)
	
	errors.each{|e| log_error(e)} unless errors.empty?
	exit_script("Error: No waypoints to measure distance from.") if waypoints.count==0
	log_line "Nr of waypoints: #{waypoints.count}"

	waypoints
end

def read_points_with_info(igc_file)
	log_line "----- Reading .igc file: #{igc_file}"
	
	(header, points, errors) = read_points(igc_file)

	errors.each{|e| log_error(e)} unless errors.empty?
	log_line "Nr of points: #{points.count}"

	[header, points]
end

def calculate_results_with_info(points, waypoints, max_distance)
	log_line "Calulating hits for max distance: #{max_distance}"
	
	result = calculate_results(points, waypoints, max_distance)

	# TODO? Choice closest point, not the first hit

	log_line "RESULT: You hit: #{result.count} Beskid Bobble(s)"
	result.each do |hit|
		log_line "-> #{hit[:name]}" #, distance: #{hit[:distance]}m"
	end
end

def decorate_result(result, header)
	# Desired result record:
	# - Filename
	# - Date
  # - Pilot name
  # - Count of hit waypoints
  # - Hit waypoints (names)
	header + [result.count] + result.map{|hit_wp| hit_wp[:name]}
end