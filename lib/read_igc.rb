# This is .igc file read function, based on documentation:
# http://vali.fai-civl.org/documents/IGC-Spec_v1.00.pdf

# Usage:
# (header, points, errors) = read_points('track.igc')

IGC_LINES = [
	"A - FVU identification number",
	"H - File header",
	"I - Fix extension",
	"J - Extension",
	"C - Task",
	"L - Log Book",
	"B - Fix",
	"D - Differential GPS",
	"E - Event",
	"K - Extension data",
	"F - Constellation",
	"G - Security",
]

def read_points filename
	points = []
	errors = []
	header = [File.basename(filename)] 
	# Header: 
	# - Filename
	# - Date
	# - Pilot name
	begin
		f = File.open(filename)
		f.each do |line|
			comment = IGC_LINES.find{ |e| e[0] == line[0]}
			if comment
				#puts comment
			else
				errors << "Error: Unknown line type: #{line}"
			end

			if line =~ /^A/
			elsif line =~ /^H/
				if line =~ /^H.DTE/
					# Date
					# H D D M M Y Y A A A CR LF
					# HFDTE301219
					# HFDTEDATE:150320,01
					if line.index(':')
						header[1] = line[line.index(':')+1,6]
					else
						header[1] = line[5,6]
					end
				elsif line =~ /^H.PLT/
					# Pilot
					# HFPLTPILOTINCHARGE:Marcin Duszynski
					# HFPLTPILOT:
					header[2] = (line[(line.index(':')+1)..line.length]).strip
				elsif line =~ /^H.GTY/
					# Glider Type
				elsif line =~ /^H.GID/
					# Glider ID
				end
				#?: HFTZNTIMEZONE:1
			elsif line =~ /^I/
				# I023638FXA3940SIU
				# FXA = Fix Accuracy
				# SIU?
				# I033638FXA3942VAR4347ACZ
				# FXA, VAR, ACZ
			elsif line =~ /^J/
			elsif line =~ /^C/
			elsif line =~ /^L/
				# LMMMGPSPERIOD5000MSEC
				# GPS Period 5000 msec
			elsif line =~ /^B/
				# B1454304932731N01857245EA008250086500504
				# Time            6 bytes           HHMMSS           Valid characters 0-9
				# Latitude        8 bytes           DDMMMMMN         Valid characters N, S, 0-9
				# Longitude       9 bytes           DDDMMMMME        Valid characters E,W, 0-9
				# Fix valid       1 byte            V                A: valid, V:nav warning
				# Press Alt.      5 bytes           PPPPP            Valid characters -, 0-9
				#
				# Note: This is a fixed size record, the size of which is defined in the I Record. 
				# The mandatory data is: UTC, latitude, longitude, fix validity and pressure altitude. 
				# It is recommended to include GPS altitude and fix accuracy if they are available.
				#
				# Important! I don't check S,N,E,W !!! it will work only for Poland! ;)
				latitude_str = line[7,7]
				longitude_str = line[15,8]
				(latitude_dd, longitude_dd) = encode_dms_to_dd(latitude_str, longitude_str)

				points << Hash[
					time: line[1,6],
					# latitude_str: line[7,8],	# N
					latitude: latitude_dd,
					# longitude_str: line[15,9],# E
					longitude: longitude_dd,
					valid: line[24], 					# A=ok
					pressure_alt: line[25,5],
					gps_alt: ((line.size >= 30) ? line[30,5] : nil),
					extensions: ((line.size >= 35) ? line[35,line.size-37] : nil)	# fixed altitude? Engine RPM
				]
				if line[24] == 'V'
					errors << "Error: Got V:nav warning in B-line"
				end
				if points.last[:latitude] == 0
					errors << "Error: Error converting latitude: #{points.last[:latitude_str]}"
				end
				if points.last[:longitude] == 0
					errors << "Error: Error converting latitude: #{points.last[:longitude_str]}"
				end
			elsif line =~ /^D/
			elsif line =~ /^E/
			elsif line =~ /^K/
			elsif line =~ /^F/
			elsif line =~ /^G/
				# `curl` to FAI or leave it to XCPortal
			end
		end
	rescue Errno::ENOENT
		errors << "Error: File not found: #{filename}"
	ensure
  	f.close if f
	end
	[header, points, errors]
end

def encode_dms_to_dd latitude_str, longitude_str
	# Degrees, minutes, and seconds (DMS): 41°24'12.2"N 2°10'26.5"E.
	# Decimal degrees (DD): 41.40338, 2.17403
	# decimal_degrees = degrees + minutes / 60 + seconds / 3600

	# Latitude_str: 4932731N
	degrees = latitude_str[0,2].to_f
	minutes = latitude_str[2,2].to_f
	seconds = (latitude_str[4,2] + '.' + latitude_str[6,1]).to_f
	latitude_dd = (degrees + (minutes/60) + (seconds/3600)).round(8)
	
	# Latitude_str: 01913428E
	degrees = longitude_str[0,3].to_f
	minutes = longitude_str[3,2].to_f
	seconds = (longitude_str[5,2] + '.' + longitude_str[7,1]).to_f
	longitude_dd = (degrees + (minutes/60) + (seconds/3600)).round(8)
	
	[latitude_dd, longitude_dd]
rescue => e
	log_error "Error in encode_dms_to_dd(): #{e.inspect}"
	[0,0]
end