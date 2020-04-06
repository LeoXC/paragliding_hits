# paragliding_hits

This script `hits.rb` analyses .igc track file(s) and calculates through which cylinders pilot have flown.
Cylinders are defined by `waypoints.kml` file and with `max_distance` variable. 

```
The results are saved in .cvs file, where each line have:
  - Filename
  - Date
  - Pilot name
  - Count of hit waypoints
  - Hit waypoints

Define input:
  -f filename (.igc)
  -d directory (with .igc files to read), by default ./tracks/
  -w filename (waypoints XML .kml), by default ./waypoints.kml
  -r max_distance allowed for track point from waypoint to be hit, by default = 120m

Define output:
  -o filename, by default ./results.csv
  -a filename, append to already existing results file, by default ./results.csv

Other:
  -h print help
  -s silent mode on, dont print logs and errors here, but into log files:
		./log.txt
		./errors.txt (if occure)'

Sample ussage:
 ruby hits.rb -f "track_file.igc"
 ruby hits.rb -w ../waypoints.kml -d ../tracks -r 2000
 ruby hits.rb -w ../waypoints.kml -f my_trac_file.igc -o my_results.csv -s
```

Sample look of results.csv:
```2020-03-15-XCM-LD6-011111026906.IGC,150320,,5,Bialskie,Diabli_Kamien,Zapora_Tresna,Jaworzynka,Ruiny_Szalasu_Kamiennego
jakis_kolo_na_Zarze.igc,090320,,3,Bialskie,Jaworzynka,Ruiny_Szalasu_Kamiennego
2019-12-30-XSD-GPB-01_Zar.igc,301219,Marcin Duszynski,0
2020-01-25-XSD-GPB-01_Ochodzita.igc,250120,Leonia Zając,0
2019-12-30-XSD-GPB-01.igc,301219,Marcin Duszynski,0```
