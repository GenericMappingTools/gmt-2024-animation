#!/usr/bin/env bash
#
# Makes a plot of the six movie progress indicators available
#
# Wessel, Esteban, & Delaviel-Anger, 2023
#
# Make dummy map script for static "movie"
cat << EOF > map.sh
gmt begin
	gmt set GMT_THEME cookbook
	gmt basemap -R0/10/0/5 -JX7.6i/3.4i -Bafg -BWSrt+glightgray
gmt end
EOF
if [ "X{$1}" = "X" ]; then
	fmt=png
else
	fmt=$1
fi
gmt movie map.sh -CHD -T50 -M10,${fmt} -NFig_movie_progress -Pa+jTL -Pb+jTC+ap -Pc+ap -Pd+jLM+ap -Pe+ap+jRM -Pf+ap -W/tmp/junk -Zs \
	-Ls"a)"+jTL+o1.7c/0.5c -Ls"b)"+jTC+o-1.1c/0.5c -Ls"c)"+jTR+o1.7c/0.5c -Ls"d)"+jML+o0.7c/0  -Ls"e)"+jMR+o0.6c/0 -Ls"f)"+jBC+o-8c/0.5c
mv -f Fig_movie_progress.${fmt} ${fmt}
open ${fmt}/Fig_movie_progress.${fmt}
