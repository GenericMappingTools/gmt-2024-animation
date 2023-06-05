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

#   2. Create file with accumulative sum for the the TL label
   #gmt math Messi_Goals.txt -C3 SUM -o0,3 = label.txt

#	2. Crear lista de fechas para la animacion: Inicio/Fin/Intervalo. o: meses. y: años
	#gmt math -o0 -T2004-01-01T/2023-07-01T/1d T = times.txt
  	#gmt math -o0 -T2018-01-01T/2023-07-01T/7d T = times.txt

#   2. Interpolate data every 3d
    #gmt sample1d Messi_Goals.txt -fT t7-01T/7d T = times.txt
    gmt sample1d Messi_Goals.txt -fT --TIME_UNIT=d -I3 -Fe -o0,4 > times.txt

    gmt basemap -R\${REGION} -J\${PROJ}/\${MOVIE_WIDTH} -B+n -Y\${Y} -X0

##	a. Crear grilla para sombreado a partir del DEM
#	gmt grdgradient @earth_relief_05m -Nt1.2 -A270 -Gtmp_intens.nc

##	b. Graficar imagen satelital 
#	gmt grdimage  @earth_day_05m -Itmp_intens.nc
    gmt grdimage  @earth_day_15m

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
	-Lc0+jTR+o0.3/0.3+gwhite+h+r --FONT_TAG=14p,Helvetica,black --FORMAT_CLOCK_MAP=- --FORMAT_DATE_MAP=dd-mm-yyyy       \
	#-Lc1+jTL+o0.3/0.3+gwhite+h+r

# Place animation
mkdir -p mp4
mv -f Movie_IndianaJones_flight_complex.mp4 mp4
mkdir -p png
mv -f Movie_IndianaJones_flight_complex.png png

