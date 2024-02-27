export http_proxy="http://proxy.fcen.uba.ar:8080"

#!/usr/bin/env bash
#
# Figure P (a movie) in this paper: WED-A_Fig_P.sh
# https://github.com/GenericMappingTools/gmt-2024-animation
#
# Wessel, Esteban, & Delaviel-Anger, 2024,
# The Generic Mapping Tools and Animations for the Masses,
# Geochem. Geophys. Geosyst.
#
# Purpose: Movie of a decade of precipitation around the world
#--------------------------------------------------------------------------------

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# #																								# #
# #											MOVIE												# #
# # 										time												# #
# #																								# #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# The following lines of code aggregate several components :
#	* On the go :
#		A simple routine to declare the working directory
#
#	* INCLUDE.SH :
#		Generated file that retains all the constants the movie needs. It is overly dense to
#		highlight some of the many customization GMT offers
#
#	* PRE.SH :
#		Generated file that initiates the figure. The "static background" for each plot is here.
#		Also, a subroutine (gmt_subplt_inset) is embedded to avoid excessive repetitions.
#		(You might note that there's not "post.sh"... simply because I haven't any relevant 
#		"static foreground" to add.)
#
#	* MAIN.SH :
#		Generated file that updates the figure. The "dynamic" part for each plot is here.
#
#	* On the go :
#		
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
FIG="WED-A_Fig_P" 

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # 									include.sh												  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# In this part, we declare all fixed variables for the general framework of the movie.
#	STEP BY STEP :
#		(1) The period of interest within the total available dataset
#		(2) Generate a timetable (first column with absolute time)
#		(3) Generate angle perspective (second column)
#		(4) Generate an index for frame counting (third column, equivalent to julian time)
#		(5) Merge all columns into a single file "movie_frame".
#		(6) Declare a region of interest for the time-series
#		(7) Declare the paper/plots sizes and the text format for "time"
#		(8) Declare the axis parameters for the time-series
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
cat <<- 'EOF' > include.sh

								# # # # # # # # # # # # # # #
								# # 	 Frame lists		#
								# # # # # # # # # # # # # # #
	# Data period
	date_start="2010-01-01"
	date_stop="2022-06-30"

	date_start_interest="2012-01-01"
	date_stop_interest="2021-12-31"

	# Generate the list of dates (corresponding to files)
	gmt math -T${date_start_interest}T/${date_stop_interest}T/1 --TIME_UNIT=d -o0 T = timetable.txt

	# Generate the list of azimuth (used for Earth rotation)
	gmt math -T0/360/$(gmt math -Q 360 $(wc -l timetable.txt | awk '{print $1}') DIV =) T -o0 = azimuth.txt
#	gmt math -T0/360/$(gmt math -Q 360 $(wc -l < timetable.txt ) DIV =) T -o0 = azimuth.txt
#	gmt math -T0/360/$(wc -l < timetable.txt )+n T -o0 = azimuth.txt
	
	# Generate the index table for reading for time-series
	row_start=$(gmt math -Q ${date_start_interest}T ${date_start}T SUB --TIME_UNIT=d =)
	row_stop=$(gmt math -Q ${date_stop_interest}T ${date_start_interest}T SUB ${row_start} ADD 1 ADD --TIME_UNIT=d =)
	gmt math -T${row_start}/${row_stop}/1 T -o0 = index_graphs.txt
	
	# Insure that the two files got the same length and concatenate them
	echo "$(gmt math -Q ${date_stop_interest}T 1 ADD --TIME_UNIT=d -fT -o0 =)" >> timetable.txt
	paste -d" " timetable.txt azimuth.txt index_graphs.txt > movie_frames.txt

	# # Make Slow-Mo
	# awk 'BEGIN { X=1; Y=10; N=7 } { if (NR >= X && NR <= Y) { for (i=1; i<=N; i++) { print } } else { print } }' movie_frames.txt > movie_frames_sl.txt
	# awk 'BEGIN { X=1654; Y=1664; N=7 } { if (NR >= X && NR <= Y) { for (i=1; i<=N; i++) { print } } else { print } }' movie_frames_sl.txt > movie_frames_sm.txt
	
	# Countries of Interest
	coi_1='france'
	coi_1_iso='FR'
	coi_1_clr='royalblue'

	coi_2='argentina'
	coi_2_iso='AR'
	coi_2_clr='firebrick'
	
								# # # # # # # # # # # # # # #
								# # 	Paper params		#
								# # # # # # # # # # # # # # #

	# Figure parts dimensions
	PLT_globe_size=12																					# Earth plot size in cm
	PLT_graph_height=3																					# Graph height in cm
	PLT_graph_width=$(gmt math -Q ${PLT_graph_height} 16 MUL 9 DIV FLOOR =)								# Graph width
	PLT_inset_size=$(gmt math -Q ${PLT_graph_height} 3 DIV =)											# Inset size

	#rm -f ./gmt.conf																					# Make sure we're clear with GMT parameters
	#rm -f ${work_dir}/gmt.conf																			# (should be the same: sanity check)
	gmt set MAP_GRID_PEN_SECONDARY faint,lightgray 														# Embellishment for time-series graph
	gmt set FORMAT_DATE_OUT="dd o yyyy"
	gmt set FORMAT_CLOCK_OUT="-"

								# # # # # # # # # # # # # # #
								# # 	Right panel params	#
								# # # # # # # # # # # # # # #


	# Get the y-axis range by comparing the maximum value of filtered data (to be plot, last column) 
	# (cumulated daily-mean precipitation within region normalized by region area)
	# + 10% and 30% addition for graph y-range and unit annotation above 

	coi1_range_max=$(gmt info ../data/roi_results/france_filtered.txt -C -o3)
	coi2_range_max=$(gmt info ../data/roi_results/argentina_filtered.txt -C -o3)

	subplt_region_max=$(gmt math -Q ${coi1_range_max} ${coi2_range_max} MAX =)
		subplt_region_max_10=$(gmt math -Q ${subplt_region_max} 1.1 MUL =)
		subplt_region_max_30=$(gmt math -Q ${subplt_region_max} 1.3 MUL =)

	# Some shift for INSET "legend-icon"
	gapx=$(gmt math -Q ${PLT_inset_size} 3 DIV =)
	gap1=$(gmt math -Q ${PLT_inset_size} 1.1 MUL =)
	gap2=$(gmt math -Q ${PLT_inset_size} ${gap1} 1.3 MUL ADD =)

	# Annotation string for graph y-axis arrow
	# (would be more elegant with LaTeX)
	annot_inset="<mm.day@+-1@+>/km@+2@+"

EOF

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # 									pre.sh													  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# In this part, we generate a file "pre-flight" which defines some "fixed" part of the movie.
#	STEP BY STEP : 
#		(0) A subroutine for country-shape logo in the time-series (inset)
#		(1) Left panel : rotating Earth
#			(a) define the colormaps for precipitation and topography
#			(b) plot the frame and the colorbar
#		(2) Right panel : expoit the subplot module to place legend and time-series
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
cat <<- 'EOF' > pre.sh
								# # # # # # # # # # # # # # #
								# # 	Local function		#
								# # # # # # # # # # # # # # #


	gmt_subplt_inset () {
		# Used to avoid inset commands repetition for the subplot graphs (right side)
		environment=$1
		region=$2
		color=$3

		gmt inset begin ${environment} -N -R${region}
			gmt coast -E${region}+g${color}
			echo "${region}" | gmt text -F+f10p,Courier-Bold,black+cRM+jBL -N
		gmt inset end
	}


								# # # # # # # # # # # # # # #
								# #    Static environment   #
								# # # # # # # # # # # # # # #


	gmt begin
		
		# # # # # # # # # # # # # # #
		# # 	Globe [left panel]	#
		# # # # # # # # # # # # # # #
		# # 	* colour-palettes	#
		# #		* colourbar params	#
		# # # # # # # # # # # # # # #	
		
		# Colour palettes
		gmt makecpt -Crain -T0/50 -H -D		> precip.cpt	# foreground (data)
		gmt makecpt -Cgray -T0/5000 -H -I	> relief.cpt	# background (topo)
		
		colrbar_margin=0.5

		# Initialize Globe position
		gmt basemap -Rg -JG0/15/${PLT_globe_size}c -B -X0.4c -Y0.15c
		gmt colorbar -DJMR+ef+o${colrbar_margin}c/0c -Bxaf+l"Daily-mean precipitation" -By+l"<mm.day@+-1@+>" -Cprecip.cpt --MAP_ANNOT_OFFSET=7p

		# # # # # # # # # # # # # # #
		# # Graphs subplots [right]	#
		# # # # # # # # # # # # # # #
		# # 	* x/y-ranges		#
		# #		* inset positions	#
		# # 	* annotations		#
		# # # # # # # # # # # # # # #	
		gmt set MAP_FRAME_TYPE graph		# hard code the map style in gmt.conf to avoid repetition (--PAR=...)

		# Actual subplot (3 rows)
		#	total size (figure) imposed `-Fs`
		#	increase vertical margins `-M`
		#	impose shift from left panel `-X` and `-Y`
		#	set x/y axis `-R`
		#	set projection (cartesian) `-JX`
		#	graph embellishments (annotation, ticks and gridlines) `-B`
		gmt subplot begin 3x1 \
			-Fs${PLT_graph_width}c/${PLT_graph_height}c	\
			-M0.75c	\
			-X$(gmt math -Q ${PLT_globe_size} ${colrbar_margin} ADD 4 ADD =)c \
			-Y1.5c \
			-R${date_start}T/${date_stop}T/0/${subplt_region_max_10} \
			-JX${PLT_graph_width}cT/${PLT_graph_height}c \
			-B+n

			gmt subplot set 0

				# Manually place the globe "annotation" arrow
				echo 2007-06-01T 0.00015 180 0.5 | gmt plot -Sv0.3c+e+h0+a45+gblack+pthick -N

				# Use `legend` module to annotate the left panel
				gmt legend -DjBL+w5c/1.5c+o-1c/0c+l1.2 -F+p1p,darkgray+gwhitesmoke+r+s3p/-2p,lightskyblue4 --FONT_ANNOT_PRIMARY=8p,Helvetica,dimgray << END
	H 8p,Helvetica Daily-mean precipitation
	G 0.005c 
	T 1\260x1\260 gridded data in mm.day@+-1@+
	T derived from satellite measurements.
	END

			gmt subplot set 1

				# Manually place the graph "annotation" arrow
				echo 2020-01-01T 0 -90 0.5 | gmt plot -Sv0.3c+e+h0+a45+gblack+pthick -N

				# Use `legend` module to annotate the right panel
				gmt legend -DjBL+w5c/2.5c+o1.5c/0c -F+p1p,darkgray+gwhitesmoke+r+s3p/-2p,lightskyblue4 --FONT_ANNOT_PRIMARY=8p,Helvetica,dimgray << END
	H 8p,Helvetica Daily-mean precipitation 
	H 8p,Helvetica summed over a given territory:
	G 0.05c
	T The time-series are normalized by their respective area (km@+2@+)
	T and a 3 months low-pass (boxcar) filter is applied
	T to highlight the seasonal cycles.
	END

			gmt subplot set 2

				# Initialize graph with basemap (change subplot previously defined -R ), 
				#	add secondary frame (`-Bs` without annot, ticks 1y, gridlines 3 months)
				gmt basemap -BWS -Bxa3Yg1Y -Byafg	
								# x[T]: annotation(3 years), ticks(none), gridlines(1 year)
								# y[precip]: auto (annot, ticks, grids)-Bsxf1yg3o

				#	add small text "units" above y-axis
				echo ${date_start}T ${subplt_region_max_30} $annot_inset | gmt text -F+f8p,Times-Italic,black -N
		
				# Inset generated with local function
				gmt_subplt_inset "-DJTR+o${gapx}c/-${gap1}c -JM${PLT_inset_size}c+du" ${coi_1_iso} ${coi_1_clr}
				gmt_subplt_inset "-DJTR+o${gapx}c/-${gap2}c -JM${PLT_inset_size}c+du" ${coi_2_iso} ${coi_2_clr}

		gmt subplot end

	gmt end
EOF

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # 									main.sh													  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # The actual moving parts.
# # It reads through the file assigned with `movie -T<file>` to change :
# # 	* The globe perspective (`-JG`), ie rotation
# #		* Read daily data one after the other
# #		* Make the time-series progress with time
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
cat <<- 'EOF' > main.sh

	gmt set GMT_DATA_SERVER oceania
	colrbar_margin=$(echo "${PLT_globe_size}/15;"|bc)
	bg_color=$(tail -3 ../precip.cpt | head -1 | awk '{print $2}')

	gmt begin

		filename=$(gmt math -Q ${MOVIE_COL0} -fT --FORMAT_DATE_OUT=yyyymmdd --FORMAT_CLOCK_OUT=- =)
		data="data/grids/${filename}.grd"			# File name to be processed
		
		# # # # # # # # # # # # # # #
		# # 		Globe			#
		# # # # # # # # # # # # # # #
		# # 	* data				#
		# # 	* topography		# NB : topo + coastline should be in post-flight script. 
		# #		* coastlines		#		However, the rotation imposes to plot them here
		# #		* coi				#		(projection history not retained elsewhere)
		# # # # # # # # # # # # # # #
		
		gmt grdimage -Rg -JG${MOVIE_COL1}/15/${PLT_globe_size}c -Bafg $data -Cprecip.cpt  \
			-X0.4c -Y0.15c

		gmt set GMT_DATA_UPDATE_INTERVAL 1d
		gmt set GMT_DATA_SERVER oceania
		gmt grdimage @earth_relief_30m -Crelief.cpt -I+d -t50
		#gmt coast -Dl -A5000 -Wthinner -Gantiquewhite -S${bg_color} -t65
		gmt coast -Dl -A5000 -Wthinner -Gantiquewhite -S238/237/243 -t65
		gmt coast -Dl -A5000 -E${coi_1_iso}+g${coi_1_clr} -t45
		gmt coast -Dl -A5000 -E${coi_2_iso}+g${coi_2_clr} -t45

		# # # # # # # # # # # # # # #
		# # 	Graph subplots		#
		# # # # # # # # # # # # # # #
		# #		* time-series		#
		# # # # # # # # # # # # # # #	
		
		# Nota : `-X` needs to be 0.5c greater than in `pre.sh`
		gmt subplot begin 3x1 \
			-Fs${PLT_graph_width}c/${PLT_graph_height}c	\
			-M0.75c	\
			-X$(gmt math -Q ${PLT_globe_size} ${colrbar_margin} ADD 4.5 ADD =)c	\
			-Y1.5c \
			-R${date_start}T/${date_stop}T/0/${subplt_region_max_10} \
			-JX${PLT_graph_width}cT/${PLT_graph_height}c \
			-B+n

			gmt subplot set 2

				# Continuous line and moving dot
				gmt plot ../data/roi_results/${coi_1}_filtered.txt -Wthick,${coi_1_clr} -t20 -q0:${MOVIE_COL2}
				gmt plot ../data/roi_results/${coi_1}_filtered.txt -Sc0.2c -G${coi_1_clr} -Wthick,black -qi${MOVIE_COL2}

				gmt plot ../data/roi_results/${coi_2}_filtered.txt -Wthick,${coi_2_clr} -t20 -q0:${MOVIE_COL2}
				gmt plot ../data/roi_results/${coi_2}_filtered.txt -Sc0.2c -G${coi_2_clr} -Wthick,black -qi${MOVIE_COL2}

		gmt subplot end

	gmt end
EOF

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# #											GMT MOVIE											  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Finally, the command to rule them all.
#	-I for the parameters shared accross the animation
#	-Sb for the static set-up
#	-T for the parameters that control the animation
#	-N & -M for filename and poster image respectively
#	-P for the progress circle and -L for the timestamp labelling
#	-C for the canvas size, -D for the frame rate and -F for the file format
gmt movie main.sh -Iinclude.sh -Sbpre.sh -Tmovie_frames.txt -N${FIG} -Mf,png \
	-Pb+jTR+w0.75c -Lc --FORMAT_DATE_MAP="dd o yyyy" --FORMAT_CLOCK_MAP=- \
	-C2160p -D21 -Zs -V #-Fmp4 
	#-C2160p \
	

# # Clean after yourself
# mkdir ${work_dir}/RESULTS/${FIG}
# mv ${work_dir}/*mp4 ${work_dir}/RESULTS/${FIG}
# rm -rf ${work_dir}/*