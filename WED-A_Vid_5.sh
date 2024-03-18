#!/usr/bin/env bash
#
# Video 5 in this paper: WED-A_Vid_5.sh
# https://github.com/GenericMappingTools/gmt-2024-animation
#
# Wessel, Esteban & Delaviel-Anger, 2024,
# The Generic Mapping Tools and Animations for the Masses,
# Geochem. Geophys. Geosyst.
#
# Purpose: Create an animation showcasing Lionel Messi's goals over time, 
# around the world and with detail in western Europe.
# The movie took almost 26 minutes to render on an 8-core Intel® Core™ i7-7700 CPU @ 3.60GHz.
#--------------------------------------------------------------------------------
NAME=WED-A_Vid_5

# 0. Get data to the main directory
cp data/Messi_Goals.txt .

# 1. Calculate map/canvas height
	main_map_region=-130/145/-40/64		# West/East/South/North boundaries
	main_map_projection=W7.5			# Mollweide map center at longitude 7.5 ºE
	canvas_width=24c
	canvas_height=$(gmt mapproject -R${main_map_region} -J${main_map_projection}/${canvas_width} -Wh)

# 2. File with variables used for the inset map
cat << EOF > in.sh
#	Region, projection, width map and offset in X/Y direction 
	inset_map_region=PTC,ESC,GB,DE+R1/3/1/-3.5
	inset_map_projection=M5.5c		# Mercator map of 5.5 cm width
	Y=0.2c							# Shift plot in Y-direction
	X=8.5c							# Shift plot in X-direction
EOF

# 3. Set up background script
cat << EOF > pre.sh
gmt begin
	gmt set GMT_DATA_SERVER oceania GMT_DATA_UPDATE_INTERVAL 1d

# 3A. Create files for animation
#	1. Reorder and scale data
	gmt convert Messi_Goals.txt -i1,2,3,3+s400,0 > data_scale_by_400.txt
	gmt convert Messi_Goals.txt -i1,2,3,3+s80,0  > data_scale_by_80.txt

# 	2. Create file with dates every 3 days versus cumulative sum of goals
	gmt math Messi_Goals.txt -C3 SUM -o0,3 = | gmt sample1d $(gmt info Messi_Goals.txt -T3d) -Fe -fT > dates_vs_goals.txt

# 3B. Make static background maps
#	1. Plot main map
#	a. Create intensity grid for shadow effect
	gmt grdgradient @earth_relief_05m_p -Nt1.2 -A270 -Gmain_intensity.nc -R${main_map_region}

#	b. Plot satellite image with shadow effect and coastlines
	gmt grdimage @earth_day_05m -Imain_intensity.nc -R${main_map_region} -J${main_map_projection}/\${MOVIE_WIDTH} -Y0 -X0
	gmt coast -N1/thinnest

#	c. Create and draw CPT
	gmt makecpt \$(gmt info Messi_Goals.txt -T1+c3) -Chot -I -F+c1 -H > Goals.cpt
	# Plot colorbar near the bottom left of the canvas with a background panel.
	gmt colorbar -CGoals.cpt -DjBL+o0.7c/0.5c+w50% -F+gwhite+p+i+s2p/-2p -L0.1 -S+y"Goals"

#	d. Draw a rectangle showing the area of the inset map
	gmt basemap -R\${inset_map_region} -J\${inset_map_projection} -A | gmt plot -Wthick,white

#	e. Plot inset map with zoom in western Europe
	gmt inset begin -Dx\${X}/\${Y} -F+p+s -R\${inset_map_region} -J\${inset_map_projection}
		gmt grdgradient @earth_relief_01m_p -Nt1.2 -A270 -Ginset_intensity.nc -R\${inset_map_region}
		gmt grdimage @earth_day -Iinset_intensity.nc
		gmt coast -N1/thinnest -Bf --MAP_FRAME_TYPE=plain --MAP_FRAME_PEN=white
	gmt inset end

gmt end
EOF

# 4. Set up main script
cat << EOF > main.sh
# Set the region, projection and offset (in X and Y) with basemap and them plot the events. 
gmt begin
	gmt set TIME_UNIT=d
	gmt basemap -R${main_map_region} -J${main_map_projection}/\${MOVIE_WIDTH} -B+n -Y0 -X0
	gmt events data_scale_by_400.txt -SE- -CGoals.cpt -T\${MOVIE_COL0} -Es+r6+d18 -Ms2.5+c0.5 -Mi5+c0 -Mt+c0 -Wfaint
	gmt basemap -R\${inset_map_region} -J\${inset_map_projection} -B+n -X\${X} -Y\${Y}
	gmt events data_scale_by_80.txt  -SE- -CGoals.cpt -T\${MOVIE_COL0} -Es+r6+d18 -Ms2.5+c0.5 -Mi5+c0 -Mt+c0 -Wfaint
gmt end
EOF

# 5. Run the movie
gmt movie main.sh -Iin.sh -Sbpre.sh -C${canvas_width}cx${canvas_height}cx80 -Tdates_vs_goals.txt -N${NAME} -H2 -Ml,png -Vi -Zs -Gblack -K+fo+p \
	-Lc0+jTR+o0.3/0.3+gwhite+h2p/-2p+r --FONT_TAG=14p --FORMAT_CLOCK_MAP=- --FORMAT_DATE_MAP=dd-mm-yyyy \
	-Lc1+jTL+o0.3/0.3+gwhite+h2p/-2p+r -Fmp4

# 6. Delete temporary files
rm gmt.history Messi_Goals.txt