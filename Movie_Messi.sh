#!/usr/bin/env bash
#
# Wessel, Esteban, & Delaviel-Anger, 2023

# File with variables used 
cat << 'EOF' > in.sh
#	Proyeccion del mapa y ancho del mapa
	REGION=-135/160/-56/64
    REGION=-135/150/-44/64
	PROJ=W8.68
    Y=2.73c
EOF

cat << EOF > pre.sh
gmt begin
#	1. Reordenar datos y agrandar
	gmt convert Messi_Goals.txt -i1,2,3,3+s500,0 > temp_q.txt

#   2. Create file with dates and accumulative sum for the labels
    gmt math Messi_Goals.txt -C3 SUM -o0,3 = | gmt sample1d $(gmt info Messi_Goals.txt -T3d) -Fe -fT > times.txt

#   3. Create static map
    gmt basemap -R\${REGION} -J\${PROJ}/\${MOVIE_WIDTH} -B+n -Y\${Y} -X0

#	gmt grdgradient @earth_relief_05m -Nt1.2 -A270 -Gtmp_intens.nc
#	gmt grdimage  @earth_day_05m -Itmp_intens.nc
    gmt grdimage  @earth_day_15m  # Lower resolution image to use while testing the script. Must be deleted for final version.

	gmt coast -Df -N1/thinnest
    gmt makecpt -Chot -T1/7/1 -I -H > temp_q.cpt
gmt end
EOF

#	----------------------------------------------------------------------------------------------------------
# 	2. Set up main script
cat << EOF > main.sh
gmt begin
	gmt basemap -R\${REGION} -J\${PROJ}/\${MOVIE_WIDTH} -B+n -Y\${Y} -X0
	gmt events temp_q.txt -SE- -Ctemp_q.cpt --TIME_UNIT=d -T\${MOVIE_COL0} -Es+r6+d18 -Ms2.5+c0.5 -Mi5+c0 -Mt+c0 -Wfaint
gmt end
EOF

#	----------------------------------------------------------------------------------------------------------
# 	3. Run the movie
	gmt movie main.sh -Iin.sh -Sbpre.sh -Cfhd -Ttimes.txt -NMovie_Messi -H2 -D24 -Ml,png -Vi -Zs -Gred -Fmp4 \
	-Lc0+jTR+o0.3/0.3+gwhite+h+r --FONT_TAG=14p,Helvetica,black --FORMAT_CLOCK_MAP=- --FORMAT_DATE_MAP=dd-mm-yyyy \
	-Lc1+jTL+o0.3/0.3+gwhite+h+r

# Place animation
mkdir -p mp4
mv -f Movie_Messi.mp4 mp4
mkdir -p png
mv -f Movie_Messi.png png

