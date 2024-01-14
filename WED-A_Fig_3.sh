#!/usr/bin/env bash
#
# Figure 3 in this paper: WED-A_Fig_3.sh
# https://github.com/GenericMappingTools/gmt-2024-animation
#
# Wessel, Esteban, & Delaviel-Anger, 2024,
#	The Generic Mapping Tools and Animations for the Masses,
#	Geochem. Geophys. Geosyst.
#
# Purpose: Show plot of the six movie progress indicators available.
#--------------------------------------------------------------------------------
FIG=WED-A_Fig_3

gmt begin ${FIG} png
	gmt set GMT_THEME cookbook
	gmt set FONT_LABEL 12p
	gmt subplot begin 5x1 -Fs15c/4c -A
	# SIZE
	cat <<- EOF > Custom_annoLine.txt
	-0.5	afg	t@-r@-
	0	afg	t@-b@-
	0.6	afg	t@-p@-
	1.5	afg	t@-d@-
	3	afg	t@-e@-
	3.5	afg	t@-f@-
	EOF
	# Rise (t = -0.5 to 0 symbol size goes from 0 to 5x)
	gmt math -T-0.5/0/0.02 T 0.5 ADD 2 MUL 2 POW 5 MUL = Line.txt
	# plateau (t = 0 to 0.5 symbol size stays at 5x)
	gmt math -T0/0.6/0.1 5 = >> Line.txt
	# Decay (t = 0.5 to 1.5 symbol size decays from 5x to 1x)
	gmt math -T0.6/1.5/0.02 0.9 T 0.6 SUB SUB 0.9 DIV 2 POW 4 MUL 1 ADD = >> Line.txt
	# active (t = 1.5 to 3 symbol size stays at 1x)
	gmt math -T1.5/3/0.1 1 = >> Line.txt
	# Fade (t = 3 to 3.5 symbol size linearly drops to 0.3 during fading)
	gmt math -T3/3.5/0.1 T 3 SUB 1.4 MUL NEG 1 ADD = >> Line.txt
	# Code (t = 3.5 5 symbol size stays at 0.3 during code)
	gmt math -T3.5/5/0.1 0.3 = >> Line.txt
	gmt basemap -R-1/5/-1/6.5 -BWStr -BxcCustom_annoLine.txt -Byag10+l"Symbol magnification" -c
	gmt plot -W3p,green <<- EOF -lDefault
	-1	0
	0	0
	0	1
	3	1
	3	0
	5	0
	EOF
	gmt plot -W0.25p,- <<- EOF
	-1	1
	6	1
	EOF
	gmt plot -W2p Line.txt -lAnnounce
	gmt plot -Sv12p+bt+et+s -W1.5p,red <<- EOF
	-0.5	5.5	1.5	5.5
	EOF
	gmt plot -Sv12p+bt+et+s -W1.5p,blue <<- EOF
	0	6	3	6
	EOF
	gmt plot -St12p -Gblue <<- EOF
	0	-0.9
	3	-0.9
	EOF
	gmt text -F+f9p -Gwhite <<- EOF
	-0.25 -0.4 RISE
	0.3 -0.4 PLATEAU
	1 -0.4 DECAY
	2.25 -0.4 NORMAL
	3.25 -0.4 FADE
	4.25 -0.4 CODA
	0.5 5.5 ANNOUNCE
	1.5 6 DURATION OF EVENT
	EOF
	# INTENSITY
	# Rise (t = -0.5 to 0 intensity goes from 0 to 4)
	gmt math -T-0.5/0/0.02 T 0.5 ADD 2 MUL 2 POW 4 MUL = Line.txt
	# plateau (t = 0 to 0.6 intensity stays at 4)
	gmt math -T0/0.6/0.1 4 = >> Line.txt
	# Decay (t = 0.6 to 1.5 intensity decays from 4 to 0)
	gmt math -T0.6/1.5/0.02 0.9 T 0.6 SUB SUB 0.9 DIV 2 POW 4 MUL = >> Line.txt
	# active (t = 1.5 to 3 intensity stays at 0)
	gmt math -T1.5/3/0.1 0 = >> Line.txt
	# Fade (t = 3 to 3.5 intensity linearly drops to -0.75 during fading)
	gmt math -T3/3.5/0.1 T 3 SUB 1.5 MUL NEG = >> Line.txt
	# Code (t = 3.5 5 intensity stays at -0.75 during coda)
	gmt math -T3.5/5/0.1 -0.75 = >> Line.txt
	gmt basemap -R-1/5/-1/6.5 -BWStr -BxcCustom_annoLine.txt -Bya+l"Color intensity" -c
	gmt plot -W3p,green <<- EOF
	-1	0
	5	0
	EOF
	gmt plot -W0.25p,- <<- EOF
	-1	0
	6	0
	EOF
	gmt plot -W2p Line.txt
	gmt plot -Sv12p+bt+et+s -W1.5p,red <<- EOF
	-0.5	5.5	1.5	5.5
	EOF
	gmt plot -Sv12p+bt+et+s -W1.5p,blue <<- EOF
	0	6	3	6
	EOF
	gmt plot -St12p -Gblue <<- EOF
	0	-0.9
	3	-0.9
	EOF
	gmt text -F+f9p -Gwhite <<- EOF
	-0.25 -0.4 RISE
	0.3 -0.4 PLATEAU
	1 -0.4 DECAY
	2.25 -0.4 NORMAL
	3.25 +0.4 FADE
	4.25 -0.4 CODA
	0.5 5.5 ANNOUNCE
	1.5 6 DURATION OF EVENT
	EOF
	# COLOR ADJUSTMENT
	# Rise (t = -0.5 to 0 symbol dz goes from 0 to 1)
	gmt math -T-0.5/0/0.02 T 0.5 ADD 2 MUL 2 POW = Line.txt
	# plateau (t = 0 to 0.5 symbol dz stays at 1)
	gmt math -T0/0.6/0.1 1 = >> Line.txt
	# Decay (t = 0.5 to 1.5 symbol dz decays from 1 to 0)
	gmt math -T0.6/1.5/0.02 0.9 T 0.6 SUB SUB 0.9 DIV 2 POW = >> Line.txt
	# active (t = 1.5 to 3 symbol dz stays at 0)
	gmt math -T1.5/3/0.1 0 = >> Line.txt
	# Fade (t = 3 to 3.5 symbol dz linearly drops to -0.2 during fading)
	gmt math -T3/3.5/0.1 T 3 SUB 0.4 MUL NEG = >> Line.txt
	# Coda (t = 3.5 5 symbol dz stays at -0.2 during code)
	gmt math -T3.5/5/0.1 -0.2 = >> Line.txt
	gmt basemap -R-1/5/-0.30/1.30 -BWStr -BxcCustom_annoLine.txt -Bya+l"Symbol @~D@~z" -c
	gmt plot -W3p,green <<- EOF
	-1	0
	5	0
	EOF
	gmt plot -W0.25p,- <<- EOF
	-1	0
	6	0
	EOF
	gmt plot -W2p Line.txt
	gmt plot -Sv12p+bt+et+s -W1.5p,red <<- EOF
	-0.5	1.10	1.5	1.10
	EOF
	gmt plot -Sv12p+bt+et+s -W1.5p,blue <<- EOF
	0	1.20	3	1.20
	EOF
	gmt plot -St12p -Gblue <<- EOF
	0	-0.18
	3	-0.18
	EOF
	gmt text -F+f9p -Gwhite <<- EOF
	-0.25 -0.07 RISE
	0.3 -0.07 PLATEAU
	1 -0.07 DECAY
	2.25 -0.07 NORMAL
	3.25 -0.07 FADE
	4.25 -0.07 CODA
	0.5 1.10 ANNOUNCE
	1.5 1.20 DURATION OF EVENT
	EOF
	# TRANSPARENY
	# Rise (t = -0.5 to 0 transparency goes from 100 to 0)
	gmt math -T-0.5/0/0.02 1 T 0.5 ADD 2 MUL SUB 2 POW 100 MUL = Line.txt
	# plateau, decay, normal (t = 0 to 3 transparency stays at 0)
	gmt math -T0/3/0.1 0 = >> Line.txt
	# Fade (t = 3 to 3.5 transparency linearly increases to 75 during fading)
	gmt math -T3/3.5/0.1 T 3 SUB 2 MUL 75 MUL = >> Line.txt
	# Code (t = 3.5 5 transparency stays at 75 during coda)
	gmt math -T3.5/5/0.1 75 = >> Line.txt
	gmt basemap -R-1/5/-20/130 -BWStr -BxcCustom_annoLine.txt -Bya+l"Symbol transparency" -c
	gmt plot -W3p,green <<- EOF
	-1	100
	0	100
	0	0
	3	0
	3	100
	5	100
	EOF
	gmt plot -W0.25p,- <<- EOF
	-1	0
	6	0
	EOF
	gmt plot -W2p Line.txt
	gmt plot -Sv12p+bt+et+s -W1.5p,red <<- EOF
	-0.5	110	1.5	110
	EOF
	gmt plot -Sv12p+bt+et+s -W1.5p,blue <<- EOF
	0	120	3	120
	EOF
	gmt plot -St12p -Gblue <<- EOF
	0	-18
	3	-18
	EOF
	gmt text -F+f9p -Gwhite <<- EOF
	-0.25 -7 RISE
	0.3 -7 PLATEAU
	1 -7 DECAY
	2.25 -7 NORMAL
	3.25 -7 FADE
	4.25 -7 CODA
	0.5 110 ANNOUNCE
	1.5 120 DURATION OF EVENT
	EOF
	# LABELS
	# Rise (t = -0.5 to 0 transparency goes from 100 to 0)
	gmt math -T-0.5/0/0.02 1 T 0.5 ADD 2 MUL SUB 2 POW 100 MUL = Line.txt
	# normal (t = 0 to 3 transparency stays at 0)
	gmt math -T0/3/0.1 0 = >> Line.txt
	# Fade (t = 3 to 3.5 transparency linearly increases to 100 during fading)
	gmt math -T3/3.5/0.1 T 3 SUB 2 MUL 100 MUL = >> Line.txt
	# Code (t = 3.5 5 transparency stays at 100 during coda)
	gmt math -T3.5/5/0.1 100 = >> Line.txt
	gmt basemap -R-1/5/-20/130 -BWStr -BxcCustom_annoLine.txt -Bya+l"Label transparency" -c
	gmt plot -W3p,green <<- EOF
	-1	100
	0	100
	0	0
	3	0
	3	100
	5	100
	EOF
	gmt plot -W0.25p,- <<- EOF
	-1	0
	6	0
	EOF
	gmt plot -W2p Line.txt
	gmt plot -Sv12p+bt+et+s -W1.5p,blue <<- EOF
	0	110	3	110
	EOF
	gmt plot -St12p -Gblue <<- EOF
	0	-18
	3	-18
	EOF
	gmt text -F+f9p -Gwhite <<- EOF
	-0.25 -7 RISE
	1.5 -7 NORMAL
	3.25 -7 FADE
	4.25 -7 CODA
	1.5 120 FULL VISIBILITY OF LABEL
	EOF
	gmt subplot end 
	rm -f Custom_annoLine.txt Line.txt
gmt end show
