#!/usr/bin/env bash
#
# Video 3 in this paper: WED-A_Vid_3.sh
# https://github.com/GenericMappingTools/gmt-2024-animation
#
# Wessel, Esteban & Delaviel-Anger, 2024,
# The Generic Mapping Tools and Animations for the Masses,
# Geochem. Geophys. Geosyst.
#
# Purpose: Simple movie with Indiana Jones flight.
# The movie took 2.2 minutes to render on an 8-core Intel® Core™ i7-7700 CPU @ 3.60GHz.
#--------------------------------------------------------------------------------
NAME=WED-A_Vid_3

# 1. Set up background script to create data files needed in the loop
cat << 'EOF' > pre.sh
# Dr. Jones stopover cities
cat <<- 'FILE' > cities.txt
-74.007	40.712	New York
-52.712	47.562	St. John's (Newfoundland)
-25.696	37.742	São Miguel (Azores)
-9.135	38.776	Lisbon
 12.342	45.503	Venice
FILE

# Interpolate between cities every 10 km
gmt begin
	gmt sample1d cities.txt -T10k+a > distance_vs_frame.txt
gmt end
EOF

# 2. Set up main script
cat << 'EOF' > main.sh
gmt begin
	# Lay down land/ocean background map for the frame
	gmt coast -JM${MOVIE_COL0}/${MOVIE_COL1}/${MOVIE_WIDTH} -R480/270+uk -G200 -Sdodgerblue2 \
		-N1/0.2,- -Y0 -X0
	
	# Draw the flight path from start to now
	gmt events distance_vs_frame.txt -W3p,red -T${MOVIE_COL2} -Es -Ar
gmt end
EOF

# 3. Run the movie
gmt movie main.sh -Sbpre.sh -N${NAME} -Tdistance_vs_frame.txt -Cfhd -Fmp4 -Zs -Ml,png -Vi