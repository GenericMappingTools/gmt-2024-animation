#!/usr/bin/env bash
title=IndianaJones_Flight_Simple

# File with variables used 
cat << 'EOF' > in.sh
	# Dr. Jones stopover cities
	cat <<- 'FILE' > cities.txt
	-74.007	40.712	New York
	-52.712	47.562	St Johns (Newfoundlad)
	-25.696	37.742	São Miguel (Azores)
	-9.135	38.776	Lisbon
	 12.342	45.503	Venice
	FILE
EOF

cat << 'EOF' > pre.sh
gmt begin
	gmt set PROJ_ELLIPSOID Sphere
    gmt sample1d cities.txt -T10k+a > distance_vs_frame.txt
gmt end
EOF

cat << 'EOF' > main.sh
gmt begin
	gmt coast -R480/270+uk -JG${MOVIE_COL0}/${MOVIE_COL1}/${MOVIE_WIDTH} -Df -G200 -Sdodgerblue2 -N1/0.2,- -Y0 -X0
	gmt events distance_vs_frame.txt -Ar -T${MOVIE_COL2} -Es -W3p,red
gmt end
EOF

#	Create animation
gmt movie main.sh -Iin.sh -Sbpre.sh -N${title} -Tdistance_vs_frame.txt -CHD -Vi -H4 -Ml,png -Fmp4 -Zs