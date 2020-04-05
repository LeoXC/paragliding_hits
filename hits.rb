require "./lib/read_igc.rb"
require "./lib/read_waypoints.rb"
require "./lib/calculate_results.rb"
require "./lib/general_helper.rb"
require "./lib/read_helper.rb"

HELP = '
SCRIPT DESCRIPTION:
This script `hits.rb` analyses .igc track file(s), 
and calculates through which cylinders pilot have flown.
Cylinders are defined by waypoints.kml file and with max_distance variable. 
The results are saved in .cvs file, where each line have:
  - Filename
  - Date
  - Pilot name
  - Hit waypoints

Define input:
	-f filename (.igc)
	-d directory (with .igc files to read), by default ./tracks/
	-w filename (waypoints XML .kml), by default ./waypoints.kml
	-r max_distance allowed for track point from waypoint to be hit,
	   by default = 120m
Define output:
	-o filename, by default ./results.csv
	-a filename, append to already existing results file, by default ./results.csv
Other:
	-h print help
	-s silent mode on, dont print logs and errors here, but into log files:
		./log.txt
		./errors.txt (if occure)'.freeze

begin
  params = default_params()
  params = read_input_params(ARGV, params)

  waypoints = read_waypoints_with_info(params[:wp_file])

	igc_files = igc_files_to_read(params[:igc_file], params[:igc_dir])
	
	results = []
	igc_files.each do |igc_file|
		(header, points) = read_points_with_info(igc_file)
		result = calculate_results_with_info(points, waypoints, params[:max_distance])
		result = decorate_result(result, header)
		results << result
	end

	# Save results
	unless results.empty?
		if params[:results_append_file]
			append_to_file(params[:results_append_file], results)
		else
			save_in_file(params[:results_file], results)
		end
	end

	end_program
	# TODO: end_program => save logs and errors to file
end

