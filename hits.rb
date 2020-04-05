require "./lib/read_igc.rb"
require "./lib/read_waypoints.rb"
require "./lib/calculate_results.rb"

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

@silent_mode = false
@logs = []
@all_errors = []

def log_line line
	if @silent_mode
		@logs << line
	else
		puts line
	end
end

def log_error line
	if @silent_mode
		@all_errors << line
	else
		puts line
	end
end

def exit_script error=nil
	puts error if error
	puts HELP
	exit
end

begin
  igc_file = nil
  igc_dir = 'tracks'
  wp_file = 'waypoints.kml'
  max_distance = 120
  results_file = 'results.csv'
  results_append_file = nil

	until ARGV.empty?
		arg = ARGV[0]
		if arg == '-f'
			igc_file = ARGV[1]
			exit_script("Error: '#{igc_file}' is not .igc file") unless igc_file =~ %r(.igc$)i
   	elsif arg == '-d'
   		igc_dir = ARGV[1]
   	elsif arg == '-w'
   		wp_file = ARGV[1]
   	elsif arg == '-r'
   		max_distance = (ARGV[1]).to_f
		elsif arg == '-o'
   		results_file = ARGV[1]
   	elsif arg == '-a'
   		results_append_file = ARGV[1]
   	elsif arg == '-s'
   		@silent_mode = true
   	elsif arg == '-h'
   		exit_script
   	else 
   		exit_script("Error: Unknown argument: #{arg}")
		end
   	ARGV.shift(2)
	end

	log_line "Reading waypoints file: #{wp_file}"
	(waypoints, errors) = read_waypoints(wp_file)
	unless errors.empty?
		log_error "-> Errors when reading waypoints file:"
		errors.each{|e| log_error(e)}
	end
	log_line "Nr of waypoints: #{waypoints.count}"

	# Files to read:
	igc_files = []
	if igc_file
		igc_files << igc_file
	elsif igc_dir
		igc_dir_path = Dir.pwd + '/' + igc_dir
		log_line "Collecting .igc files from dir: #{igc_dir_path}"
		igc_files = Dir[igc_dir_path + '/*.igc']
		log_line "Nr of .igc files: #{igc_files.count}"
	end
	
	igc_files.each do |igc_file|
		log_line "----- Reading .igc file: #{igc_file}"
		(points, errors) = read_points(igc_file)
		unless errors.empty?
			log_error "-> Errors when reading .igc file:"
			errors.each{|e| log_error(e)}
		end
		log_line "Nr of points: #{points.count}"
	
		log_line "Calulating hits for max distance: #{max_distance}"
		result = calculate_results(points, waypoints, max_distance)

		# TODO? Choose closest points

		# Print result
		log_line "You hit: #{result.count} Beskid Bobble(s)"
		result.each do |hit|
			log_line "-> #{hit[:name]}" #, distance: #{hit[:distance]}m"
		end
	end
# rescue => e
# 	puts "Error: #{e.message}"
end

