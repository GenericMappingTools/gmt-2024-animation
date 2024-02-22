#!/usr/bin/bash
#
# Figure S (a movie) in this paper: WED-A_Fig_S.sh
# https://github.com/GenericMappingTools/gmt-2024-animation
#
# Wessel, Esteban, & Delaviel-Anger, 2024,
# The Generic Mapping Tools and Animations for the Masses,
# Geochem. Geophys. Geosyst.
#
# Purpose: Movie of seismicity near La Soufrière volcano (La Guadeloupe, Lesser Antilles)
#--------------------------------------------------------------------------------

# Hypocenters data
DATA_file="DATA/2014-2019_catalog.csv"

# # Topography data
res_topo="01s"
gmt grdmath -RGP @earth_synbath_${res_topo}_g 0 GT 0 NAN @earth_synbath_${res_topo}_g MUL = topo_island.nc

# Area of Interest
SOUFRIERE_LON=-61.663406
SOUFRIERE_LAT=16.043829
SOUFRIERE=${SOUFRIERE_LON}/${SOUFRIERE_LAT}

max_dist_volc=12
west_lim=$(gmt math -Q ${SOUFRIERE_LON} ${max_dist_volc} ${SOUFRIERE_LAT} COSD MUL KM2DEG SUB =)
east_lim=$(gmt math -Q ${SOUFRIERE_LON} ${max_dist_volc} ${SOUFRIERE_LAT} COSD MUL KM2DEG ADD =)
south_lim=$(gmt math -Q ${SOUFRIERE_LAT} ${max_dist_volc} KM2DEG SUB  =)
north_lim=$(gmt math -Q ${SOUFRIERE_LAT} ${max_dist_volc} KM2DEG ADD  =)

DOMAIN_region=$(gmt mapproject -RGP,MQ+r1 -WR)
DOMAIN_volc="-R${west_lim}/${east_lim}/${south_lim}/${north_lim}"

# Figure's dimension
width_volc=$(gmt math -Q 9 2 SQRT MUL =) # diagonal from 9cm edge
posx_volc=2
posy_volc=2

width_region=5
posx_region=$(gmt math -Q ${width_volc} ${posx_volc} ADD 9 ADD =)
posy_region=3.5

width_profile=${width_region}
posx_profile=${posx_region} # $(gmt math -Q ${posx_region} 1.5 SUB =)
posy_profile=$(gmt math -Q ${posy_region} $(gmt mapproject ${DOMAIN_region} -JM${width_region} -Wh) ADD 2 ADD =)

# 3D view
azimuth=135
elevation=20
PERSPECTIVE="${azimuth}/${elevation}+w${SOUFRIERE}"

max_depth_data=$(gmt math -C3 -o3 ${DATA_file} -1 MUL LOWER -Sf =)
max_depth_3d=$(gmt math -Q $max_depth_data 1000 MUL =)
# max_depth_coupe=-137000 #gmt histogram $DATA_file -i3 -Glightblue -W -T1 -Baf -png test
max_alt=$(gmt grdinfo topo_island.nc -Mf | grep "v_max" | awk '{print $5}')

# Topo/bathy profiles
cat <<- EOF > track.txt
-61.6525093993956 16.02593225832284
-61.67133858104974 16.0570823829057
EOF
gmt grdtrack ${DOMAIN_region} track.txt -G@earth_synbath_${res_topo}_g -C200k/0.1/0.25+v -Sm+sstack.txt -Vq > table.txt
gmt math stack.txt 0 LE 0 NAN stack.txt MUL = sea_area.txt

# # # # # # # # # 
gmt begin test png
	gmt makecpt -Coleron -T0/${max_alt} -H > relief.cpt
	arrow_lon=$(gmt math -Q ${azimuth} -1 MUL =)

	# 3D view : hypocenters
	gmt plot3d ${DOMAIN_volc}/${max_depth_3d}/0 -JM${width_volc} -JZ12c  \
		${DATA_file} -i2,1,3+d-0.001 -Se${azimuth}/0.5/$(gmt math -Q 0.5 ${elevation} SIND MUL =) -Gred \
		-BwsneZ3+b+zlightbrown -Bz50000+l"depth (m)" \
		-Xa${posx_volc} -Ya${posy_volc} \
		-p${PERSPECTIVE}

	# 3D view : surface
	gmt coast ${DOMAIN_volc} -JM${width_volc} \
	-Wthick,black -Df -Slightblue -t75 \
	-Xa${posx_volc} -Ya$(gmt math -Q ${posy_volc} 12 ${elevation} COSD MUL ADD =) \
	-p

	gmt grdview ${DOMAIN_volc}/0/${max_alt} -JZ1c \
		topo_island.nc -Crelief.cpt -Qc -I+d \
		-Bafg \
		-Xa${posx_volc} -Ya$(gmt math -Q ${posy_volc} 12 ${elevation} COSD MUL ADD =) \
		-p -t50

# # # 
# # # 
# # # 
# 	# Minimap : coast
# 	gmt coast ${DOMAIN_region} -JM${width_region}c -W -Slightblue -Glightbrown \
# 		-TdjBL+f1+l \
# 		-Ba0.5f0.5g0.5 \
# 		-Xa${posx_region} -Ya${posy_region} \
# 		--FORMAT_GEO_MAP="ddd.xxx" --FONT_ANNOT_PRIMARY=4p

# 	gmt basemap -Bwesn -p90 \
# 		-LjBR+w$(gmt math -Q 1 DEG2KM RINT -Vq =)k+o-0.15c/$(gmt math -Q -${width_region} 0.3 ADD =)c+u+c+f \
# 		-Xa${posx_region} -Ya${posy_region} \
# 		--FONT_ANNOT_PRIMARY=4p --MAP_SCALE_HEIGHT=3p 

# 	# Minimap : hypocenters (within radius)
# 	gmt select ${DATA_file} -i2,1 -fg -C${SOUFRIERE}+d50k > subset.txt
# 	gmt plot ${DATA_file} -i2,1 -Sc0.1c -Glightgray  -Xa${posx_region} -Ya${posy_region} -t80
# 	gmt plot subset.txt -Sc0.1c -Gblack -Xa${posx_region} -Ya${posy_region} -t50

# 	# Minimap : swath
# 	gmt plot table.txt -Wfaint,black -Xa${posx_region} -Ya${posy_region}

# 	# # Minimap : dome
# 	# echo ${SOUFRIERE_LON} ${SOUFRIERE_LAT} | gmt plot -Sx0.25c -Wred -Xa${posx_region} -Ya${posy_region} # Marker of La Soufriere Volcano
	
# 	# Minimap : rotating arrow
# 	gmt plot -Rg -JG180/90/3c -SV0.4c+ea+h0+a60+gred -Wfatter,red \
# 	-Xa$(gmt math -Q ${posx_region} 0.66 SUB =) -Ya$(gmt math -Q ${posy_region} 3.75 ADD =) <<- EOF
# 	${arrow_lon} 5 0 0.75c
# 	EOF
# 	# gmt basemap -Bafg -Xa$(gmt math -Q ${posx_region} 0.66 SUB =) -Ya$(gmt math -Q ${posy_region} 3.75 ADD =) # Frame for "polar" projection

# # # # 
# # # # 
# # # # 
# 	# Profile : hypocenters
# 	gmt plot subset.txt  -R-40/100/-10000/3000 -JX${width_profile}/${width_region} \
# 		-Xa${posx_profile} -Ya${posy_profile}

# 	# Profile : sea_area
# 	gmt plot sea_area.txt -Glightblue -Sb1q+b0 -Xa${posx_profile} -Ya${posy_profile}
# 	gmt plot -W -Xa${posx_profile} -Ya${posy_profile} <<- EOF
# 	-40 0
# 	100 0
# 	EOF

# 	# Profile : topo thickness
# 	gmt plot -Wthick stack.txt -i0,1,5,6 -L+b -Glightgray -Xa${posx_profile} -Ya${posy_profile}
# 	echo "WSW" | gmt text -F+cTL+fHelvetica-Bold -DJ0.1 -Xa${posx_profile} -Ya${posy_profile}
# 	echo "ENE" | gmt text -F+cTR+fHelvetica-Bold -DJ0.1 -Xa${posx_profile} -Ya${posy_profile}

# 	gmt basemap  -Bxafg1000+l"Distance from dome (km)" -Byaf+l"Depth (m)" -BWSne -Xa${posx_profile} -Ya${posy_profile}

gmt end show
