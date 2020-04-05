# paragliding_hits
This script that analyses .igc track file(s) and calculates through which cylinders pilot have flown.
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
		./errors.txt (if occure)'
