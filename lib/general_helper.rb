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

def exit_script error=nil, help=false
	puts error if error
	puts HELP if help
	exit
end

def end_program
	# Is silence_mode: Save logs and errors to file
	# TBD
end

def default_params()
	Hash[
	  igc_file: nil,
	  igc_dir: 'tracks',
	  wp_file: 'waypoints.kml',
	  max_distance: 120,
	  results_file: 'results.csv',
	  results_append_file: nil
	]
end

def read_input_params(argv, params)
	until argv.empty?
		arg = argv[0]
		if arg == '-f'
			exit_script("Error: '#{argv[1]}' is not .igc file") unless argv[1] =~ %r(.igc$)i
			params[:igc_file] = argv[1]
   	elsif arg == '-d'
   		params[:igc_dir] = argv[1]
   	elsif arg == '-w'
   		params[:wp_file] = argv[1]
   	elsif arg == '-r'
   		params[:max_distance] = (argv[1]).to_f
		elsif arg == '-o'
   		params[:results_file] = argv[1]
   	elsif arg == '-a'
   		params[:results_append_file] = argv[1]
   	elsif arg == '-s'
   		@silent_mode = true
   		argv.shift
   		next
   	elsif arg == '-h'
   		exit_script(error=nil, help=true)
   		break
   	else 
   		exit_script("Error: Unknown argument: #{arg}", help=true)
		end
   	argv.shift(2)
	end
	params
end

def igc_files_to_read(igc_file, igc_dir)
	igc_files = []
	if igc_file
		exit_script("Error: Unexisting .igc file: #{igc_file}") unless File.file?(igc_file)
		igc_files << igc_file
	elsif igc_dir
		igc_dir_path = Dir.pwd + '/' + igc_dir
		exit_script("Error: Unexisting .igc directory: #{igc_dir_path}") unless File.exist?(igc_dir_path)
		log_line "Collecting .igc files from dir: #{igc_dir_path}"
		igc_files = Dir[igc_dir_path + '/*.igc']
		log_line "Nr of .igc files: #{igc_files.count}"
	end
	igc_files
end

def save_in_file(filename, results)
	begin
		log_line "Saving results in: '#{filename}'"
		if File.file?(filename)
			log_line "File '#{filename}' already exists, it will be replaced."
		end
		f = File.open(filename, "w")

		results.each do |result|
			cvs_line = result.map{ |v| v }.join(',')
			f.puts cvs_line
		end
	rescue => e
		errors << "Error: File write problem (filename: #{filename}; #{e.message}"
	ensure
  	f.close if f
	end
end

def append_to_file(filename, results)
	# TBD
end

