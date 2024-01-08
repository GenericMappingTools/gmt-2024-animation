#!/usr/bin/env bash
#
# Illustration of the time-line of a movie with optional title
# and fade sequence.
#
# Wessel, Esteban, & Delaviel-Anger, 2024

# Determine if we need to specify an output directory or not
if [ "X${1}" = "X" ]; then
	dir=
else
	dir="${1}/"
fi

gmt begin ${dir}Fig_title_fade $1
	gmt set GMT_THEME cookbook
	cat <<- EOF > Custom_annot.txt
	0	afg	0
	1	afg	t@-i@-
	5	afg	t@-o@-
	6	afg	t@-b@-
	7	afg	f@-i@-
	14	afg	f@-o@-
	15	afg	t@-e@-
	EOF
	gmt math -T0/1/25+n 1 PI T MUL COS SUB 2 DIV 100 MUL = Timeline.txt
	gmt math -T1/5/1 100 = >> Timeline.txt
	gmt math -T5/6/25+n 1 PI T 5 SUB MUL COS ADD 2 DIV 100 MUL = >> Timeline.txt
	gmt math -T6/7/25+n 1 PI T 6 SUB MUL COS SUB 2 DIV 100 MUL = >> Timeline.txt
	gmt math -T7/14/1 100 = >> Timeline.txt
	gmt math -T14/15/25+n 1 PI T 14 SUB MUL COS ADD 2 DIV 100 MUL = >> Timeline.txt
	gmt plot -R0/15/0/140 -JX6i/1i -BxcCustom_annot.txt -Byaf+l"fade-level" -W1.5p -BWS Timeline.txt
	gmt plot -Sv24p+bt+et+s -W1.5p,red -N <<- EOF
	0	110	6	110
	6	110	15	110
	EOF
	gmt text -F+f10p+jCB -C1p -Gwhite <<- EOF
	0.5 120 FADE
	6 120 FADE
	14.5 120 FADE
	3 120 TITLE SEQUENCE
	3 50 [OPTIONAL]
	10.5 50 [REQUIRED]
	10.5 120 ANIMATION SEQUENCE
	EOF
	rm -f Custom_annot.txt Timeline.txt
gmt end show
