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
 ruby hits.rb -w ../waypoints.kml -f my_trac_file.igc -o my_results.csv -s
```

## Samples:

1. Sample look of resutls.csv:
(12 tracks, 2 pilots, no squash/merge)

`ruby hits.rb -d "../tracks" -w ../waypoints.kml -r 1000 -o ./results.csv`
```
2020-01-23-XSD-GPB-01.igc,23.01.2020,Leonia Zając,0
2020-01-25-XSD-GPB-01.igc,25.01.2020,Leonia Zając,0
2020-03-17-XSD-GPB-03.igc,17.03.2020,Leonia Zając,1,Bieguny
2020-03-18-XSD-GPB-01.igc,18.03.2020,Leonia Zając,1,Plyn_Dezynfekcji
2020-03-10-XSD-GPB-01.igc,10.03.2020,Leonia Zając,1,Rybny_Potok
2020-03-05-XSD-GPB-01.igc,05.03.2020,Leonia Zając,1,Zimna_Dziura
2020-03-17-XSD-GPB-02.igc,17.03.2020,Leonia Zając,0
2020-03-10-XSD-GPB-02.igc,10.03.2020,Leonia Zając,0
2020-03-17-XSD-GPB-01.igc,17.03.2020,Leonia Zając,0
2020-01-16-XSD-GPB-02.igc,16.01.2020,Leonia Zając,1,Matyska
2020-02-15-XSD-GPB-01.igc,15.02.2020,Leonia Zając,1,Rysianka
2019-12-30-XSD-GPB-01.igc,30.12.2019,Marcin Duszynski,0
```

2. Sample look of results.csv:
(12 tracks, 2 pilots, squashed)

`ruby hits.rb -d "../tracks" -w ../waypoints.kml -r 1000 -o ./results.csv -m`
```
2020-01-23-XSD-GPB-01.igc;2020-01-25-XSD-GPB-01.igc;2020-03-17-XSD-GPB-03.igc;2020-03-18-XSD-GPB-01.igc;2020-03-10-XSD-GPB-01.igc;2020-03-05-XSD-GPB-01.igc;2020-03-17-XSD-GPB-02.igc;2020-03-10-XSD-GPB-02.igc;2020-03-17-XSD-GPB-01.igc;2020-01-16-XSD-GPB-02.igc;2020-02-15-XSD-GPB-01.igc,23.01.2020;25.01.2020;17.03.2020;18.03.2020;10.03.2020;05.03.2020;17.03.2020;10.03.2020;17.03.2020;16.01.2020;15.02.2020,Leonia Zając,6,Bieguny,Plyn_Dezynfekcji,Rybny_Potok,Zimna_Dziura,Matyska,Rysianka
2019-12-30-XSD-GPB-01.igc,30.12.2019,Marcin Duszynski,0
```

3. Sample look of results.csv:
(1 track, empty pilot's name)

`ruby hits.rb -f ../tracks/2020-03-15-XCM-LD6-011111026906.IGC -w ../waypoints.kml -r 1000 -o ./results.csv`
```
2020-03-15-XCM-LD6-011111026906.IGC,15.03.2020,,2,Jaworzynka,Ruiny_Szalasu_Kamiennego
```

## Used ruby version:
``` ruby -v
ruby 2.6.3p62 (2019-04-16 revision 67580) [universal.x86_64-darwin19]
```

## Create .exe file:
- use OCRA: https://github.com/larsch/ocra
- works only on Windows
- install ocra, by i.e. 

`gem install ocra`

- goto your script directory and run: 

`ocra hits.rb --console`

- additional params: 

`--console` - it will be console script
`--no-dep-run` - don't run script.rb to check for dependencies.
`--no-autoload` - don't load/include script.rb's autoloads.
`--no-autodll` - disable detection of runtime DLL dependencies.
`--icon=c:\path-to\icon.ico` - use this icon for .exe ;)

Other docs about OCRA: 
https://ourcodeworld.com/articles/read/270/how-to-create-an-executable-exe-from-a-ruby-script-in-windows-using-ocra
