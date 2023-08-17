#!/usr/bin/env bash
#
# Wessel, Esteban, & Delaviel-Anger, 2023

# Delete at the end
#export http_proxy="http://proxy.fcen.uba.ar:8080"

# 1. Calculate map/canvas height
    main_map_region=-130/145/-40/64
    main_map_projection=W7.5       # Mollweide map center at longitude 7.5
    canvas_width=24c
    canvas_height=$(gmt mapproject -R${main_map_region} -J${main_map_projection}/${canvas_width} -Wh)

# 2. File with variables used for the inset map
cat << 'EOF' > in.sh
#	Region, projection, width map and offset in X and Y
    inset_map_region=PTC,ESC,FR,GB,DE+R1/3/1/-3.5
    inset_map_projection=M5.5c                         
    Y=3.168p
    X=8.5c
EOF

# 3. Set up background script
cat << EOF > pre.sh
gmt begin

# 3A. Create files for animation
#	1. Reorder and scale data:
	gmt convert Messi_Goals.txt -i1,2,3,3+s400,0 > data_scale_by_400.txt
    gmt convert Messi_Goals.txt -i1,2,3,3+s80,0  > data_scale_by_80.txt

#   2. Create file with dates versus accumulative sum of goals
    gmt math Messi_Goals.txt -C3 SUM -o0,3 = | gmt sample1d $(gmt info Messi_Goals.txt -T3d) -Fe -fT > dates_vs_goals.txt

# 3B. Make statics background maps
#   1. Plot main map
    gmt basemap -R${main_map_region} -J${main_map_projection}/\${MOVIE_WIDTH} -B+n -Y0 -X0

#	a. Create intesity grid for shadow effect
	gmt grdgradient @earth_relief_05m_p -Nt1.2 -A270 -Gmain_intensity.nc -R${main_map_region}

#	b. Plot satellite image with shadow effect and coastlines
    gmt grdimage  @earth_day_05m -Imain_intensity.nc
    gmt coast -N1/thinnest #-Df

#   c. Create and draw CPT
    gmt makecpt \$(gmt info Messi_Goals.txt -T1+c3) -Chot -I -F+c1 -H > Goals.cpt

    # Plot colorbar near the bottom left of the canvas with a background panel.
    gmt colorbar -CGoals.cpt -DjBL+o0.7c/0.5c+w50% -F+gwhite+p+i+s2p/-2p -L0.1 -S+y"Goals"

#   d. Draw a rectangle showing the area of the inset map
	gmt basemap -R\${inset_map_region} -J\${inset_map_projection} -A | gmt plot -Wthick,white

#	e. Plot inset map with zoom in western Europe
    gmt inset begin -Dx\${X}/\${Y} -F+p+s -R\${inset_map_region} -J\${inset_map_projection}
        gmt grdgradient @earth_relief_01m_p -Nt1.2 -A270 -Ginset_intensity.nc -R\${inset_map_region}
        gmt grdimage  @earth_day -Iinset_intensity.nc
        gmt coast -N1/thinnest -Bf --MAP_FRAME_TYPE=plain --MAP_FRAME_PEN=white #-Df
    gmt inset end

gmt end
EOF

#	----------------------------------------------------------------------------------------------------------
# 	4. Set up main script
cat << EOF > main.sh
gmt begin
	gmt basemap -R${main_map_region} -J${main_map_projection}/\${MOVIE_WIDTH} -B+n -Y0 -X0
	gmt events data_scale_by_500.txt -SE- -CGoals.cpt --TIME_UNIT=d -T\${MOVIE_COL0} -Es+r6+d18 -Ms2.5+c0.5 -Mi5+c0 -Mt+c0 -Wfaint
    gmt basemap -R\${inset_map_region} -J\${inset_map_projection} -B+n -X\${X} -Y\${Y}
	gmt events data_scale_by_80.txt  -SE- -CGoals.cpt --TIME_UNIT=d -T\${MOVIE_COL0} -Es+r6+d18 -Ms2.5+c0.5 -Mi5+c0 -Mt+c0 -Wfaint
gmt end
EOF

#	----------------------------------------------------------------------------------------------------------
# 	5. Run the movie
gmt movie main.sh -Iin.sh -Sbpre.sh -C${canvas_width}cx${canvas_height}cx80 -Tdates_vs_goals.txt -NMovie_Messi -H2 -Ml,png -Vi -Zs -Gblack \
    -Lc0+jTR+o0.3/0.3+gwhite+h2p/-2p+r --FONT_TAG=14p,Courier-Bold,black --FORMAT_CLOCK_MAP=- --FORMAT_DATE_MAP=dd-mm-yyyy   \
	-Lc1+jTL+o0.3/0.3+gwhite+h2p/-2p+r # -Fmp4 -D24

# Place animation
mkdir -p mp4
mv -f Movie_Messi.mp4 mp4
mkdir -p png
mv -f Movie_Messi.png png

rm gmt.history
