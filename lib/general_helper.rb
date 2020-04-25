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
	log_line "DONE!"
	# Is silence_mode: Save logs and errors to file
	# TBD
end

def default_params()
	Hash[
	  igc_file: nil,
	  igc_dir: 'tracks',
	  wp_file: 'waypoints.kml',
	  max_distance: 420,
	  results_file: 'results.csv',
	  results_append_file: nil,
	  pilot: nil,
	  squash: false 
	]
end

def read_input_params(argv, params)
	until argv.empty?
		arg = argv[0]
		if ['-f','-d','-w','-r','-p','-o','-a'].include?(arg)
			exit_script("Error: Missing value for switch '#{arg}'") if !argv[1] || argv[1] =~ /^-.$/ 
			value = (argv[1]).strip
		end

		if arg == '-f'
			exit_script("Error: '#{value}' is not .igc file") unless value =~ %r(.igc$)i
			params[:igc_file] = value
   	elsif arg == '-d'
   		params[:igc_dir] = value
   	elsif arg == '-w'
   		params[:wp_file] = value
   	elsif arg == '-r'
   		params[:max_distance] = (value).to_f
   		log_line "Chosen max distance: #{params[:max_distance]}"
   	elsif arg == '-p'
   		params[:pilot] = value
		elsif arg == '-o'
   		params[:results_file] = value
   	elsif arg == '-a'
   		params[:results_append_file] = value
   	elsif arg == '-m'
   		params[:squash] = true
   		argv.shift
   		next
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

def save_in_file(filename, results, append=false)
	begin
		log_line "----- Saving results in: '#{filename}'"
		if File.file?(filename) && !append
			log_line "File '#{filename}' already exists, it will be replaced."
		end

		f = File.open(filename, "w")
		results.each do |result|
			csv_line = result.join(',')
			f.puts csv_line
		end
	rescue => e
		log_error "Error: File write problem (filename: #{filename}; #{e.message})"
	ensure
  	f.close if f
	end
end

def read_results_from_file(filename)
	begin
		previous_results = []
		if File.file?(filename)
			log_line "----- Reading previous results from: '#{filename}'"
			
			File.readlines(filename).each do |line|
				previous_results << line.strip.split(',')
			end
		end
		previous_results
	rescue => e
		log_error "Error: #{e.message}"
	end
end

def sqauash_results results
	# Note: Merge lines of same pilot.
	# Separate .igc files and dates with `;`
	# Skip lines with same filename.
	# If no pilot name provided, merge to one line.
	log_line "Current results count: #{results.count}"
	all_results = []
	results.each do |result|
		file_s = result[0].strip.downcase
		pilot = result[2].strip.downcase

		if pilot.empty?
			log_error "Warning: Empty pilot name. (row header: \"#{result[0..3].join(',')}\")"
			(action, poor_result) = check_if_any_better_by_file(all_results, result)
			if action == 'swap'
				all_results.delete(poor_result)
				all_results << result
			elsif action == 'add'
				all_results << result
			end
			next
		else
			(action, saved_result) = check_if_any_better_by_pilot(all_results, result)
			if action == 'add'
				all_results << result
				next
			elsif action == 'swap'
				all_results.delete(saved_result)
				all_results << result
				next
			elsif action == 'merge'
				all_results.delete(saved_result)

				all_hits = (saved_result[4..] + result[4..]).uniq

				all_results << [
					saved_result[0] + ';' + result[0],	# list files
					saved_result[1] + ';' + result[1],	# list dates
					saved_result[2],										# pilot name
					all_hits.count,											# hits count
					all_hits														# unique hits
				].flatten
			end
		end
	end
	log_line "After squash results count: #{all_results.count}"
	all_results
rescue => e
	log_error "Error: #{e.message}"
end

def check_if_any_better_by_file(base_results, result)
	# return: [action, poor_result]
	# worse/better means have more files incuded in result
	file_s = result[0].strip.downcase

	base_results.each do |saved|
		saved_file_s = saved[0].strip.downcase
		if file_s == saved_file_s						# if equal => skip
			return ['skip', nil]
		elsif saved_file_s.include?(file_s)	# if saved is better => skip
			return ['skip', result]
		elsif file_s.include?(saved_file_s)	# if saved is worse => swap
			return ['swap', saved]
		end
	end

	return ['add', nil]							# if not found (by file) => add
end

def check_if_any_better_by_pilot(all_results, result)
	# return: [action, poor_result]
	# worse/better means have more files included in result
	pilot = result[2].strip.downcase

	all_results.select do |saved|
		saved_pilot = saved[2].strip.downcase
		if pilot == saved_pilot
			# puts "Found row with same pilot, comparing by files now ..."
			(action, poor_result_by_file) = check_if_any_better_by_file([saved], result)
			if action == 'swap'
				#puts "Saved row is worse, need to swap."
				return ['swap', saved]
			elsif action == 'add'	# merge
				# puts "Saved row is different (new). Need to merge."
				return ['merge', saved]
			elsif action == 'skip'
				# puts "Saved row is better, skip this one."
				return ['skip', saved]
			end
		end
	end

	#puts "No row with such pilot yet, adding."
	return ['add', result]
end
