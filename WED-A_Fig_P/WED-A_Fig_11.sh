#!/usr/bin/env bash
#
# Figure P (a movie) in this paper: WED-A_Fig_11.sh
# https://github.com/GenericMappingTools/gmt-2024-animation
#
# Wessel, Esteban, & Delaviel-Anger, 2024,
# The Generic Mapping Tools and Animations for the Masses,
# Geochem. Geophys. Geosyst.
#
# Purpose: Movie of a decade of precipitation around the world
#--------------------------------------------------------------------------------
FIG="WED-A_Fig_11" 

# The following lines of code aggregate several components :
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

	# Data period
	date_start="2010-01-01"
	date_stop="2022-06-30"

	date_start_interest="2012-01-01"
	date_stop_interest="2022-01-01"
	
	# 1. Generate the list of dates
	gmt math -T${date_start_interest}T/${date_stop_interest}T/1d -o0 T = timetable.txt

	# 2. Count the total number of days between the dates
	number_days=$(gmt math -Q ${date_stop_interest}T ${date_start_interest}T SUB 1 ADD --TIME_UNIT=d =)

	# 3. Generate the list of azimuth (used for Earth rotation) from 0 to 360
	gmt math -T0/360/${number_days}+n T -o0 = azimuth.txt

	# 4. Generate the index table for reading for time-series
	row_start=$(gmt math -Q ${date_start_interest}T ${date_start}T SUB --TIME_UNIT=d =)
	row_stop=$(gmt math -Q ${row_start} ${number_days} ADD 1 SUB =)
	seq ${row_start} ${row_stop} > index_graphs.txt

	# 5. Concatenate files
	paste -d" " timetable.txt azimuth.txt index_graphs.txt > movie_frames.txt
	
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
	colrbar_margin=0.5																					# Colorbar margin

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
		gmt set MAP_FRAME_TYPE graph

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
	bg_color=$(tail -3 ../precip.cpt | head -1 | awk '{print $2}')
	gmt begin
		gmt set GMT_DATA_UPDATE_INTERVAL 1d GMT_DATA_SERVER oceania

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
		
		gmt grdgradient @earth_relief_06m -Gearth_gradient.nc -A-45 -Nt1+a0
		gmt grdsample $data -I06m -Gtmp_grid.nc
		gmt grdimage tmp_grid.nc -Cprecip.cpt -Bafg -Iearth_gradient.nc -X0.4c -Y0.15c -Rg -JG${MOVIE_COL1}/15/${PLT_globe_size}c
		gmt coast -Dl -A5000 -Wthinner -Gantiquewhite -S${bg_color} -t65
		gmt coast -Dl -A5000 -E${coi_1_iso}+g${coi_1_clr} -t45
		gmt coast -Dl -A5000 -E${coi_2_iso}+g${coi_2_clr} -t45

		# # # # # # # # # # # # # # #
		# # 	Graph subplots		#
		# # # # # # # # # # # # # # #
		# #		* time-series		#
		# # # # # # # # # # # # # # #	
		
		gmt subplot begin 3x1 -Fs${PLT_graph_width}c/${PLT_graph_height}c -M0.75c	\
			-X$(gmt math -Q ${PLT_globe_size} ${colrbar_margin} ADD 4 ADD =)c \
			-Y1.5c -R${date_start}T/${date_stop}T/0/${subplt_region_max_10} -JX${PLT_graph_width}cT/${PLT_graph_height}c \
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
gmt movie main.sh -Iinclude.sh -Sbpre.sh -Tmovie_frames.txt -N${FIG} -Ml,png \
	-Pb+jTR+w0.75c -Lc+o4c/0c --FORMAT_DATE_MAP="dd o yyyy" --FORMAT_CLOCK_MAP=- \
	-D21 -Zs -V -C1080p -Fmp4 
	#-C2160p