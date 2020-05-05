require 'date'

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
	result = calculate_results(points, waypoints, max_distance)

	# TODO? Choice closest point, not the first hit

	log_line "RESULT: You hit: #{result.count} Beskid Bobble(s)"
	result.each do |hit|
		log_line "-> #{hit[:name]}"
		log_line "   First found point: distance: #{hit[:distance]}m, pt_lon: #{hit[:pt_lon]}, pt_lat: #{hit[:pt_lat]}"
		log_line "   Waypoint: wp_lon: #{hit[:longitude]}, wp_lat: #{hit[:latitude]}"
	end
end

def decorate_result(result, header, pilot=nil)
	# Desired result record:
	# - Filename
	# - Date (format: dd.mm.yyyy)
	# - Pilot name
	# - Count of hit waypoints
	# - Hit waypoints (names)
	if pilot
		header[2] = pilot
		log_line 'Pilot name will be: ' + pilot
	end
	if header[2].strip.empty?
		log_error "Warning: Results have empty pilot name. (row header: \"#{header.join(',')}\")"
	end
	begin
		d = Date.strptime(header[1], '%d%m%y')
		header[1] = d.strftime("%d.%m.%Y")
	rescue Exception => e
		log_error "Error: Could not transform this: #{header[1]} to desired date format. Skipped."
	end	   
	header + [result.count] + result.map{|hit_wp| hit_wp[:name]}
end