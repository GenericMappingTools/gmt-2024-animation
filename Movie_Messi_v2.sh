#!/usr/bin/env bash
#
# Wessel, Esteban, & Delaviel-Anger, 2023

#export http_proxy="http://proxy.fcen.uba.ar:8080"

# File with variables used 
cat << 'EOF' > in.sh
#	Proyeccion del mapa y ancho del mapa
	REGION=-130/145/-40/64
    REGION2=-10/25/35/50
    REGION2=-11/18/35/54
    #REGION2=ESC # España
    #REGION2=ESC,PTC,FR,GB,DE+R0/5/0/0
    REGION2=ESC+R1
    #REGION=$(gmt info Messi_Goals.txt -i1,2 -I10)
	PROJ=W7.5
    PROJ2=M8c
    Y=0c
    Y2=0c

EOF

cat << EOF > pre.sh
gmt begin
#	1. Reordenar datos y agrandar
	gmt convert Messi_Goals.txt -i1,2,3,3+s400,0 > temp_q.txt
    gmt convert Messi_Goals.txt -i1,2,3,3+s80,0 > temp_q2.txt

#   2. Create file with dates and accumulative sum for the labels
    gmt math Messi_Goals.txt -C3 SUM -o0,3 = | gmt sample1d $(gmt info Messi_Goals.txt -T3d) -Fe -fT > times.txt

    gmt basemap -R\${REGION} -J\${PROJ}/\${MOVIE_WIDTH} -B+n -Y\${Y} -X0

##	a. Crear grilla para sombreado a partir del DEM
    #gmt grdcut @earth_relief
#	gmt grdgradient @earth_relief_05m -Nt1.2 -A270 -Gtmp_intens.nc

##	b. Graficar imagen satelital 
#	gmt grdimage  @earth_day_05m -Itmp_intens.nc
    gmt grdimage  @earth_day_20m
	gmt coast -Df -N1/thinnest

##	c. Graficar zoom Europa W
    gmt grdimage  @earth_day_03m -R\${REGION2} -J\${PROJ2} -X9c -Y\${Y2} -Bf
    gmt coast -Df -N1/thinnest

    gmt makecpt -Chot -T1/7/1 -I -H > temp_q.cpt
    gmt makecpt -Crainbow -T1/7/1 -I -H > temp_q2.cpt

gmt end
EOF

#	----------------------------------------------------------------------------------------------------------
# 	2. Set up main script
cat << EOF > main.sh
gmt begin
	gmt basemap -R\${REGION} -J\${PROJ}/\${MOVIE_WIDTH} -B+n -Y\${Y} -X0
	gmt events temp_q.txt -SE- -Ctemp_q.cpt --TIME_UNIT=d -T\${MOVIE_COL0} -Es+r6+d18 -Ms2.5+c0.5 -Mi5+c0 -Mt+c0 -Wfaint
    gmt basemap -R\${REGION2} -J\${PROJ2} -B+n -X9c -Y\${Y2}
	#gmt events temp_q2.txt -SE- -Ctemp_q.cpt --TIME_UNIT=d -T\${MOVIE_COL0} -Es+r6+d18 -Ms2.5+c0.5 -Mi5+c0 -Mt+c0 -Wfaint
gmt end
EOF

#	----------------------------------------------------------------------------------------------------------
# 	3. Run the movie
	gmt movie main.sh -Iin.sh -Sbpre.sh -C24cx10.475cx80 -Ttimes.txt -NMovie_Messi_v2 -W -H2 -D24 -Ml,png -Vi -Zs -Fmp4 -Gred -K+po \
	-Lc0+jTR+o0.3/0.3+gwhite+h+r --FONT_TAG=14p,Helvetica,black --FORMAT_CLOCK_MAP=- --FORMAT_DATE_MAP=dd-mm-yyyy       \
	-Lc1+jTL+o0.3/0.3+gwhite+h+r # -Pf+ac0 #+jRM+w5.9c+o2.7/0.8c+P3,white+p1,red+a1+f11p,2,white

# Place animation
mkdir -p mp4
mv -f Movie_Messi_v2.mp4 mp4
mkdir -p png
mv -f Movie_Messi_v2.png png

