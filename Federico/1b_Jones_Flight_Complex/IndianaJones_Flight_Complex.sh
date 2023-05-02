#!/usr/bin/env bash
title=IndianaJones_Flight_Complex_WIP

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

# 1. Make a title slide explaining things
cat << 'EOF' > title.sh
gmt begin
	echo "12 11.5 Dr. Jones flight to Venice on his Last Crusade" | gmt text -R0/24/0/13.5 -Jx1c -F+f26p,Helvetica-Bold+jCB -X0 -Y0
	gmt text -M -F+f14p <<- END
	> 12 6.5 16p 20c j
	We will simulate the flight path from New York to Venice trough three stopovers.
	We first do some maths to have a fix duration of the movie. 
    Then, we interpolate between the cities along a rhumb line.
	We also make a separate file for the label.
	Finally we make a Mercator map a map centered on the changing longitude and latitude.
    We draw the path with a red lines. The name of the cities will appear along with a circle showing its location.
	END
gmt end #show
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
#gmt movie main.sh -Iin.sh -Sbpre.sh -NIndianaJones_Flight_Complex -Tdistance_vs_frame.txt -Cfhd -Fmp4 -Zs -Vi -D60 -K+p
gmt movie main.sh -Iin.sh -Sbpre.sh -N${title} -Tdistance_vs_frame.txt -Etitle.sh+d6s+fo1s+gwhite -C480p -Fmp4 -Vi -D24 -K+gblack+p -Zs

#	Add audio track
    #ffmpeg -loglevel warning -ss 14 -i RaidersMarch.mp3 cut.mp3
#    ffmpeg -loglevel warning -i $title.mp4 -y -i trim.mp3 ${title}_final.mp4

