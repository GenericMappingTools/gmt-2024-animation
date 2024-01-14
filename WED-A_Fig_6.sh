#!/usr/bin/env bash
#
# Figure 6 (a movie) in this paper: WED-A_Fig_6.sh
# https://github.com/GenericMappingTools/gmt-2024-animation
#
# Wessel, Esteban, & Delaviel-Anger, 2024,
# The Generic Mapping Tools and Animations for the Masses,
# Geochem. Geophys. Geosyst.
#
# Purpose: Simple movie of spinning Moon.
#--------------------------------------------------------------------------------
FIG=WED-A_Fig_6

cat <<- 'EOF' > main.sh
gmt begin
  gmt grdimage @moon_relief_06m_p.grd -Rg -JG-${MOVIE_FRAME}/30/20c -Bg -X0 -Y0
gmt end show
EOF
gmt movie main.sh -C20cx20cx30 -T359 -Fmp4 -Mf,png -N${FIG} -Zs
