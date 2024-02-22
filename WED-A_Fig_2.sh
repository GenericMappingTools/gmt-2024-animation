#!/usr/bin/env bash
#
# Figure 2 in this paper: WED-A_Fig_2.sh
# https://github.com/GenericMappingTools/gmt-2024-animation
#
# Wessel, Esteban & Delaviel-Anger, 2024,
#	The Generic Mapping Tools and Animations for the Masses,
#	Geochem. Geophys. Geosyst.
#
# Purpose: Show plot of the six movie progress indicators available.
#--------------------------------------------------------------------------------
FIG=WED-A_Fig_2

# Make dummy map script for the static "movie"
cat << EOF > main.sh
gmt begin
	gmt set GMT_THEME cookbook
	gmt basemap -R0/10/0/5 -JX20c/8.5c -Bafg -BWSrt+glightgray
gmt end show
EOF

gmt movie main.sh -CHD -T50 -M10,png -N${FIG} -Pa+jTL -Pb+jTC+ap -Pc+ap -Pd+jLM+ap -Pe+ap+jRM -Pf+ap -W/tmp/junk -Zs \
	-Ls"a)"+jTL+o1.7c/0.5c -Ls"b)"+jTC+o-1.1c/0.5c -Ls"c)"+jTR+o1.7c/0.5c -Ls"d)"+jML+o0.7c/0  -Ls"e)"+jMR+o0.6c/0 -Ls"f)"+jBC+o-8c/0.5c
