# paragliding_hits

This script `hits.rb` analyses .igc track file(s) and calculates through which cylinders pilot have flown.
Cylinders are defined by `waypoints.kml` file and with `max_distance` variable. 

```
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
  -r max_distance allowed for track point from waypoint to be hit, by default = 120m
  -p pilot_name, to be pritned in results instead of the one in .igc file(s)

Define output:
  -o filename, by default ./results.csv
  -a filename, append to already existing results file (by pilot)

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

Sample results:

1. Sample look of results.csv:
(5 tracks, 4 pilots, 2 tracks without pilot name in .igc)
```2020-03-15-XCM-LD6-011111026906.IGC,150320,,5,Bialskie,Diabli_Kamien,Zapora_Tresna,Jaworzynka,Ruiny_Szalasu_Kamiennego
jakis_kolo_na_Zarze.igc,090320,,3,Bialskie,Jaworzynka,Ruiny_Szalasu_Kamiennego
2019-12-30-XSD-GPB-01.igc;2019-12-30-XSD-GPB-01_Zar.igc,301219;301219,Marcin Duszynski,0
2020-01-25-XSD-GPB-01_Ochodzita.igc,250120,Leonia Zając,0
```

2. Sample look of results.csv:
(squashed 12 tracks, 2 pilots)
```
2020-01-23-XSD-GPB-01.igc;2020-01-25-XSD-GPB-01.igc;2020-03-17-XSD-GPB-03.igc;2020-03-18-XSD-GPB-01.igc;2020-03-10-XSD-GPB-01.igc;2020-03-05-XSD-GPB-01.igc;2020-03-17-XSD-GPB-02.igc;2020-03-10-XSD-GPB-02.igc;2020-03-17-XSD-GPB-01.igc;2020-01-16-XSD-GPB-02.igc;2020-02-15-XSD-GPB-01.igc,230120;250120;170320;180320;100320;050320;170320;100320;170320;160120;150220,Leonia Zając,6,Bieguny,Plyn_Dezynfekcji,Rybny_Potok,Zimna_Dziura,Matyska,Rysianka
2019-12-30-XSD-GPB-01.igc,301219,Marcin Duszynski,0
```

3. Sample look of appended results.csv:
(append tracks from Sample1 to results.csv from Sample2)
```
2020-03-15-XCM-LD6-011111026906.IGC,150320,,2,Jaworzynka,Ruiny_Szalasu_Kamiennego
jakis_kolo_na_Zarze.igc,090320,,1,Ruiny_Szalasu_Kamiennego
2019-12-30-XSD-GPB-01.igc;2019-12-30-XSD-GPB-01_Zar.igc,301219;301219,Marcin Duszynski,0
2020-01-23-XSD-GPB-01.igc;2020-01-25-XSD-GPB-01.igc;2020-03-17-XSD-GPB-03.igc;2020-03-18-XSD-GPB-01.igc;2020-03-10-XSD-GPB-01.igc;2020-03-05-XSD-GPB-01.igc;2020-03-17-XSD-GPB-02.igc;2020-03-10-XSD-GPB-02.igc;2020-03-17-XSD-GPB-01.igc;2020-01-16-XSD-GPB-02.igc;2020-02-15-XSD-GPB-01.igc;2020-01-25-XSD-GPB-01_Ochodzita.igc,230120;250120;170320;180320;100320;050320;170320;100320;170320;160120;150220;250120,Leonia Zając,6,Bieguny,Plyn_Dezynfekcji,Rybny_Potok,Zimna_Dziura,Matyska,Rysianka
```