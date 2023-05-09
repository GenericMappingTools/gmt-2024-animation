#!/usr/bin/env bash
#
# IndianaJones_Flight_Complex.sh
#
# Wessel, Esteban, & Delaviel-Anger, 2023
#
# Create a more complex Indiana Jones flight animation where
# we make some further changes to the initial animation:
# 1. Add a title sequences to explain what the movie illustrates.
# 2. Plot a city circle and label when plan is within 250 km of city
# 3. Add the Raiders of the Lost Arc soundtrack

title=IndianaJones_Flight_Complex

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
     
    animation_duration=27 # in seconds
EOF

# 1. Make a title slide explaining things
cat << 'EOF' > title.sh
gmt begin
	echo "12 11.5 Dr. Jones' flight to Venice on his Last Crusade" | gmt text -R0/24/0/13.5 -Jx1c -F+f26p,Helvetica-Bold+jCB -X0 -Y0
	gmt text -M -F+f14p <<- END
	> 12 6.5 16p 20c j
	We will simulate the flight path from New York to Venice trough three stopovers.
	First, we do some calculations to set a fixed duration of the movie. 
    Then, we interpolate between the cities along a rhumb line.
	We also make a separate file for the labels.
	Finally, we make a Mercator map centered on the changing longitude and latitude.
    We draw the path with a red line. The name of the cities will appear along with a circle showing its location.
	END
	# Place the GMT logo and Indiana Jones movie logo along the bottom
    gmt image indiana-jones-logo.png -DjBR+jBR+w9c+o2/1c
	gmt logo -DjBL+w6c+o2c/1c
gmt end
EOF
cat << 'EOF' > pre.sh
gmt begin
	#gmt set PROJ_ELLIPSOID Sphere
	# Get length of travel and compute line increment in km per frame
	dist_to_Venice=$(gmt mapproject -G+uk cities.txt | gmt convert -El -o2)
    line_increment_per_frame=$(gmt math -Q ${dist_to_Venice} -1 ${animation_duration} ${MOVIE_RATE} MUL ADD DIV =) # in km
    # Resample path between cities using rhumbline interpolation
    gmt sample1d cities.txt -T${line_increment_per_frame}k+a > distance_vs_frame.txt -AR+l
    # Compute distance to each city to know when to place labels
    gmt mapproject cities.txt -G+uk > labels.txt
gmt end
EOF

cat << 'EOF' > main.sh
gmt begin
	# Lay down land/ocean background map for the frame
	gmt coast -JM${MOVIE_COL0}/${MOVIE_COL1}/${MOVIE_WIDTH} -Y0 -X0 -R480/270+uk -G200 -Sdodgerblue2 -N1/0.2,- 
	# Draw the flight path from start to now
   	gmt events distance_vs_frame.txt -W3p,red -T${MOVIE_COL2} -Es -Ar
	# Plot labels that appear/disappear when plan reaches the cities
    gmt events labels.txt -T${MOVIE_COL2} -L500 -Mt100+c100 -F+f18p+jTC -Dj1c -E+r100+f100+o-250 -Gred -Sc0.3c   # Modified to plot also the circles
gmt end
EOF

#	Create animation
gmt movie main.sh -Iin.sh -Sbpre.sh -Ntmp_${title} -Tdistance_vs_frame.txt -Etitle.sh+d6s+fo1s -Cfhd -Fmp4 -Vi -D60 -K+p -Zs

#	Add audio track
# Get length of the animation    
duration=$(ffprobe -i tmp_${title}.mp4 -show_entries format=duration -v quiet -of csv="p=0")

# Trim soundtrack from the 0.5 seconds time point
ffmpeg -loglevel warning -ss 0.5 -y -i RaidersMarch.mp3 -t $duration tmp_trim.mp3

# Add soundtrack to the animation
ffmpeg -loglevel warning -i tmp_${title}.mp4 -y -i tmp_trim.mp3 ${title}.mp4

rm tmp_*
