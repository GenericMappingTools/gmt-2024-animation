#!/usr/bin/env bash

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
	gmt coast -JM${MOVIE_COL0}/${MOVIE_COL1}/${MOVIE_WIDTH} -Y0 -X0 -R480/270+uk -G200 -Sdodgerblue2 -N1/0.2,- 
	gmt events distance_vs_frame.txt -W3p,red -T${MOVIE_COL2} -Es
gmt end
EOF

#	Create animation
gmt movie main.sh -Iin.sh -Sbpre.sh -NIndianaJones_Flight -Tdistance_vs_frame.txt -Cfhd -Fmp4 -Zs -Vi
