require "rexml/document"
include REXML

# Usage:
# [waypoints, errors] = read_waypoints('waypoints.kml')

def read_waypoints filename
	waypoints = []
	errors = []
	begin
		xmlfile = File.open(filename)
		xmldoc = Document.new(xmlfile)
		waypoints = XPath.match(xmldoc, "//Placemark").map do |wp|
			# "19.1963047,49.7170397,0"
			coord_str = wp.elements[3].elements[1].text.strip
			coord_hash = coord_str.split(',')
			Hash[
				name: wp.elements[1].text,
				#coordinates: coord_hash,
				latitude: coord_hash[1].to_f,
				longitude: coord_hash[0].to_f
			]
		end
	rescue Errno::ENOENT
		errors << "Error: File not found: #{filename}"
	ensure
  	xmlfile.close if xmlfile
	end
	[waypoints, errors]
end