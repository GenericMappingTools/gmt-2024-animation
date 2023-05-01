#!/usr/bin/env bash

# File with variables used 
cat << 'EOF' > in.sh
	# Dr. Jones stopover cities
	cat <<- 'FILE' > cities.txt
	-74.007	40.712	New York
	-52.712	47.562	St. John's
	-25.696	37.742	São Miguel
	-9.135	38.776	Lisbon
	 12.342	45.503	Venice
	FILE

    animation_duration=30  # in seconds
EOF

cat << 'EOF' > pre.sh
gmt begin
	gmt set PROJ_ELLIPSOID Sphere
	dist_to_Venice=$(gmt mapproject -G+uk cities.txt | gmt convert -El -o2)
    line_increment_per_frame=$(gmt math -Q ${dist_to_Venice} ${animation_duration} ${MOVIE_RATE} MUL DIV =)  # in km
    gmt sample1d cities.txt -T${line_increment_per_frame}k+a > distance_vs_frame.txt -AR+l
    gmt mapproject cities.txt -G+uk > labels.txt
gmt end
EOF

cat << 'EOF' > main.sh
gmt begin
	gmt coast -JM${MOVIE_COL0}/${MOVIE_COL1}/${MOVIE_WIDTH} -Y0 -X0 -R480/270+uk -G200 -Sdodgerblue2 -N1/0.2,- 
   	gmt events distance_vs_frame.txt -W3p,red -T${MOVIE_COL2} -Es -Ar

#   Plot labels
#   gmt events labels.txt -T${MOVIE_COL2} -L500 -Mt100+c100 -F+f18p+jTC -Dj1c -Et+r100+f100+o-250                # Paul's original commando
    gmt events labels.txt -T${MOVIE_COL2} -L500 -Mt100+c100 -F+f18p+jTC -Dj1c -E+r100+f100+o-250 -Gred -Sc0.3c   # Modified to plot also the circles
gmt end
EOF

#	Create animation
gmt movie main.sh -Iin.sh -Sbpre.sh -NIndianaJones_Flight_Complex -Tdistance_vs_frame.txt -Cfhd -Fmp4 -Zs -Vi -D24 -K+p
