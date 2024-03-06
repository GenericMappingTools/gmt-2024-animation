#!/usr/bin/env bash
inicio=$(date +%s)
#
# Video 2 in this paper: WED-A_Vid_2.sh
# https://github.com/GenericMappingTools/gmt-2024-animation
#
# Wessel, Esteban & Delaviel-Anger, 2024,
# The Generic Mapping Tools and Animations for the Masses,
# Geochem. Geophys. Geosyst.
#
# Purpose: Simple movie of spinning Moon.
# The movie took 236 seconds to render on an 8-core Intel® Core™ i7-7700 CPU @ 3.60GHz.
#--------------------------------------------------------------------------------
FIG=WED-A_Vid_2

cat <<- 'EOF' > main.sh
gmt begin
	export http_proxy="http://proxy.fcen.uba.ar:8080"
	gmt set GMT_DATA_UPDATE_INTERVAL 7d 
	gmt set GMT_DATA_SERVER oceania
	gmt grdimage @moon_relief_06m_p.grd -Rg -JG-${MOVIE_FRAME}/30/${MOVIE_WIDTH} -Bg -X0 -Y0
gmt end show
EOF
gmt movie main.sh -C20cx20cx30 -T359 -Fmp4 -Mf,png -N${FIG} -Zs -Vi
fin=$(date +%s)
tiempo_total=$((fin - inicio))
echo "El script tardó $tiempo_total segundos en ejecutarse."