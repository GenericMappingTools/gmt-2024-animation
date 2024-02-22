#!/usr/bin/env bash
#
# Figure 1 in this paper: WED-A_Fig_1.sh
# https://github.com/GenericMappingTools/gmt-2024-animation
#
# Wessel, Esteban & Delaviel-Anger, 2024,
#	The Generic Mapping Tools and Animations for the Masses,
#	Geochem. Geophys. Geosyst.
#
# Purpose: Plot of the general movie dimensions and label placements in a canvas.
#--------------------------------------------------------------------------------
FIG=WED-A_Fig_1

gmt begin ${FIG} png
	gmt set GMT_THEME cookbook
	gmt basemap -R0/24/0/13.5 -Jx1c -B0
	gmt plot -W0.5p,- <<- EOF
	>
	2.5	0
	2.5	13.5
	>
	0	2.5
	24	2.5
	EOF
	gmt plot -Glightgray -W1p <<- EOF
	2.5	2.5
	23	2.5
	23	12
	2.5	12
	EOF
	gmt plot -Sv24p+b+e+h0.5+s -Gblack -W2p <<- EOF
	0	2.8	2.5	2.8
	6	0	6	2.5
	0	10	24	10
	5	0	5	13.5
	EOF
	gmt text -F+f16p,Helvetica-Bold+a+j -Gwhite -W0.5p <<- EOF
	12	10	0	CM	MOVIE_WIDTH
	5	6.75	90	CM	MOVIE_HEIGHT
	2.8	3	0	LM	-X@%2%off@%%
	6	2.8		0	CB	-Y@%2%off@%%
	EOF
	cat <<- EOF > Position.txt
	1.15	0.75	BL
	13.0	0.75	BC
	22.85	0.75	BR
	1.15	7.50	ML
	13.0	7.50	MC
	22.85	7.50	MR
	1.15	12.80	TL
	13.0	12.80	TC
	22.85	12.80	TR
	EOF
	while read x y txt; do
		echo 0 0 ${txt} | gmt text -D${x}/${y} -F+f12p,Courier-Bold+jCM -C0.5c/0.2c -W0.5p,dashed -Gwhite
	done < Position.txt
	rm -f Position.txt
gmt end show
