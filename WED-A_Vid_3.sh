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
# The movie took 152 seconds to render on an 8-core Intel® Core™ i7-7700 CPU @ 3.60GHz.
#--------------------------------------------------------------------------------
FIG=WED-A_Vid_3

# File with variables used 
cat << 'EOF' > in.sh
	# Dr. Jones stopover cities
	cat <<- 'FILE' > cities.txt
	-74.007	40.712	New York
	-52.712	47.562	St. John's (Newfoundland)
	-25.696	37.742	São Miguel (Azores)
	-9.135	38.776	Lisbon
	 12.342	45.503	Venice
	FILE
EOF

cat << 'EOF' > pre.sh
gmt begin
    gmt sample1d cities.txt -T10k+a > distance_vs_frame.txt
gmt end
EOF

cat << 'EOF' > main.sh
gmt begin
	gmt coast -JM${MOVIE_COL0}/${MOVIE_COL1}/${MOVIE_WIDTH} -R480/270+uk -G200 -Sdodgerblue2 \
		-N1/0.2,- -Y0 -X0
	gmt events distance_vs_frame.txt -W3p,red -T${MOVIE_COL2} -Es -Ar
gmt end
EOF
#	Create animation
gmt movie main.sh -Iin.sh -Sbpre.sh -N${FIG} -Tdistance_vs_frame.txt -Cfhd -Fmp4 -Zs -Vi
