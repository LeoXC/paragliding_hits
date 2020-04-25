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
The results are saved in .csv file, where each line have:
  - Filename
  - Date
  - Pilot name
  - Count of hit waypoints
  - Hit waypoints

Define input:
	-f filename (.igc)
	-d directory (with .igc files to read), by default ./tracks/
	-w filename (waypoints XML .kml), by default ./waypoints.kml
	-r max_distance allowed for track point from waypoint to be hit, by default = 420m
	-p pilot_name, to be pritned in results instead of the one in .igc file(s)
Define output:
	-o filename, by default ./results.csv
	-a filename, append to already existing results file (by pilot)
Other:
	-h print help
	-s silent mode on, dont print logs and errors here, but into log files:
		./log.txt
		./errors.txt (if occure)
	-m merge (squash) similar results into one line (by pilot) in resutls file, by default it is off
Sample ussage:
 ruby hits.rb -f "track_file.igc"
 ruby hits.rb -w ../waypoints.kml -d ../tracks -r 2000
 ruby hits.rb -w ../waypoints.kml -f my_trac_file.igc -o my_results.csv -s'.freeze

begin
  params = default_params()
  params = read_input_params(ARGV, params)

  waypoints = read_waypoints_with_info(params[:wp_file])

	igc_files = igc_files_to_read(params[:igc_file], params[:igc_dir])
	
	results = []
	igc_files.each do |igc_file|
		(header, points) = read_points_with_info(igc_file)
		result = calculate_results_with_info(points, waypoints, params[:max_distance])
		result = decorate_result(result, header, params[:pilot])
		results << result
	end

	# Save results
	unless results.empty?
		if params[:results_append_file]
			previous_results = read_results_from_file(params[:results_append_file])
			results = previous_results.concat(results)
		end

		results = sqauash_results(results) if params[:squash]
		
		# TODO: Currently append is: read + clear + write,
		# due to squash functionality. Migth be needing rewrite, 
		# if operation takes to long in biger amount of data
		if params[:results_append_file]
			save_in_file(params[:results_append_file], results, append: true)
		else
			save_in_file(params[:results_file], results)
		end
	end

	end_program
end

