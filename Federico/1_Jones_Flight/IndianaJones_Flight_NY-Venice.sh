#!/usr/bin/env bash
title=IndianaJones_Flight_NY-Venice

cat << 'EOF' > pre.sh
gmt begin
	gmt set PROJ_ELLIPSOID Sphere

	# Dr. Jones stopover cities
	cat <<- 'FILE' > cities.txt
	-74.007	40.712	New York
	-52.712	47.562	St Johns (Terranova)
	-25.696	37.742	Sao Miguel (Azores)
	-9.135	38.776	Lisboa (Portugal)
	 12.342	45.503	Venecia (Italia)
	FILE
    dist_to_Venice=$(gmt mapproject -G+uk cities.txt | gmt convert -El -o2)
    line_increment=$(gmt math -Q ${dist_to_Venice} 30 ${MOVIE_RATE} MUL DIV =)
    gmt sample1d cities.txt -T${line_increment}k+a > tmp_time.txt
gmt end
EOF

cat << 'EOF' > main.sh
gmt begin
	gmt coast -R-800/800/-450/450+uk -JG${MOVIE_COL0}/${MOVIE_COL1}/24c -Bg0 -Df -G200 -Sdodgerblue2 -N1/0.2,- -Y0p -X0p
	gmt events tmp_time.txt -Ar -T${MOVIE_COL2} -Es -W2p,red
gmt end
EOF

#	Create animation
gmt movie main.sh -Sbpre.sh -N$title -Ttmp_time.txt -Chd -Vi -Ml,png -Fmp4 -Zs
