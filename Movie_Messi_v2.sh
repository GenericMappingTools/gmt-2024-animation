#!/usr/bin/env bash
#
# Wessel, Esteban, & Delaviel-Anger, 2023

export http_proxy="http://proxy.fcen.uba.ar:8080"

# Calculate map/canvas height
    REGION=-130/145/-40/64
    PROJ=W7.5
    W=24
    H=$(gmt mapproject -R$REGION -J$PROJ/$W -Wh)

# File with variables used 
cat << 'EOF' > in.sh
#	Proyeccion del mapa y ancho del mapa
    REGION2=PTC,ESC,FR,GB,DE+R1/3/1/-3.5
    PROJ2=M5.5c
    Y=3.168p
    X=8.5c
EOF

cat << EOF > pre.sh
gmt begin
#	1. Reordenar datos y agrandar
	gmt convert Messi_Goals.txt -i1,2,3,3+s400,0 > temp_q.txt
    gmt convert Messi_Goals.txt -i1,2,3,3+s80,0 > temp_q2.txt

#   2. Create file with dates and accumulative sum for the labels
    gmt math Messi_Goals.txt -C3 SUM -o0,3 = | gmt sample1d $(gmt info Messi_Goals.txt -T3d) -Fe -fT > times.txt

#   3. Create main map
    gmt basemap -R${REGION} -J${PROJ}/\${MOVIE_WIDTH} -B+n -Y0 -X0

##	a. Crear grilla para sombreado a partir del DEM
	#gmt grdgradient @earth_relief_05m -Nt1.2 -A270 -Gtmp_intens.nc

##	b. Graficar imagen satelital 
	#gmt grdimage  @earth_day_05m -Itmp_intens.nc
    gmt grdimage  @earth_day
	gmt coast -Df -N1/thinnest
    
    gmt makecpt -Chot -T1/7/1 -I -H > temp_q.cpt
    gmt colorbar -Ctemp_q.cpt -DjMR+o1c/0 -F+gwhite+p+i+s

	gmt basemap -R\${REGION2} -J\${PROJ2} -A | gmt plot -Wthick,white 


##	c. Graficar zoom Europa W
    gmt basemap -R\${REGION2} -J\${PROJ2} -X\${X} -Y\${Y} -Bf --MAP_FRAME_TYPE=plain --MAP_FRAME_PEN=white
    #gmt grdgradient @earth_relief_05m -Nt1.2 -A270 -Gtmp_intens2.nc
    #gmt grdimage  @earth_day -Itmp_intens.nc
    gmt grdimage  @earth_day
    gmt coast -Df -N1/thinnest

gmt end
EOF

#	----------------------------------------------------------------------------------------------------------
# 	2. Set up main script
cat << EOF > main.sh
gmt begin
	gmt basemap -R${REGION} -J${PROJ}/\${MOVIE_WIDTH} -B+n -Y0 -X0
	gmt events temp_q.txt -SE- -Ctemp_q.cpt --TIME_UNIT=d -T\${MOVIE_COL0} -Es+r6+d18 -Ms2.5+c0.5 -Mi5+c0 -Mt+c0 -Wfaint
    gmt basemap -R\${REGION2} -J\${PROJ2} -B+n -X\${X} -Y\${Y}
	gmt events temp_q2.txt -SE- -Ctemp_q.cpt --TIME_UNIT=d -T\${MOVIE_COL0} -Es+r6+d18 -Ms2.5+c0.5 -Mi5+c0 -Mt+c0 -Wfaint
gmt end
EOF

#	----------------------------------------------------------------------------------------------------------
# 	3. Run the movie
	gmt movie main.sh -Iin.sh -Sbpre.sh -C${W}cx${H}cx80 -Ttimes.txt -NMovie_Messi_v2 -H2 -D24 -Ml,png -Vi -Zs -Gblack  \
    -Lc0+jTR+o0.3/0.3+gwhite+h+r --FONT_TAG=14p,Helvetica,black --FORMAT_CLOCK_MAP=- --FORMAT_DATE_MAP=dd-mm-yyyy       \
	-Lc1+jTL+o0.3/0.3+gwhite+h+r #-Fmp4

# Place animation
mkdir -p mp4
mv -f Movie_Messi_v2.mp4 mp4
mkdir -p png
mv -f Movie_Messi_v2.png png

rm gmt.history