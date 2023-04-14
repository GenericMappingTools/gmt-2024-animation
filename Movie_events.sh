#!/usr/bin/env bash
#
# Movie_events.sh
#
# Wessel, Esteban, & Delaviel-Anger, 2023
#
# Create a short MP4 showing the life of two simple events.
# Both events starts at 0 and ends at 1, but we add rise
# and fade and coda to one of them (red) and let the other
# be plain default (green) and only visible from 0-1.

echo 20 6 0 1 Red Label  > red.txt
echo  0 6 0 1 Green Label > green.txt
cat <<- EOF > labels.txt
-0.125 2 RISE
0.125 2 PLATEAU
0.375 2 DECAY
1.125 2 FADE
1.375 2 CODA
EOF
# Create an approximate default scaling step function we can interpolate in events
cat <<- EOF > normal.txt
-0.5	0
-0.001	0
0	1
0.999	1
1	0
1.5	0
EOF
# Create the exact default scaling step function
cat <<- EOF > stepfunction.txt
-0.5	0
0	0
0	1
1	1
1	0
1.5	0
EOF
cat <<- EOF > pre.sh
gmt begin
	# Build the more complicated size vs time curve based on knowledge of what events does internally
	echo "-0.5 0" > size_vs_time.txt
	# Rise (t = -0.25 to 0 symbol size goes from 0 to 2x)
	gmt math -T-0.25/0/0.01 T 0.25 ADD 0.25 DIV 2 POW 2 MUL = >> size_vs_time.txt
	# plateau (t = 0 to 0.25 symbol size stays at 2x)
	#gmt math -T0/0.25/0.01 2 = >> size_vs_time.txt
	# Decay (t = 0.25 to 0.5 symbol size decays from 2x to 1x)
	gmt math -T0.25/0.5/0.01 1 T 0.25 SUB 0.25 DIV 2 POW SUB 1 ADD = >> size_vs_time.txt
	# active (t = 0.5 to 1 symbol size stays at 1x)
	gmt math -T0.6/1/0.1 1 = >> size_vs_time.txt
	# Fade (t = 1 to 1.25 symbol size linearly drops to 0.25 during fading)
	gmt math -T1.1/1.25/0.05 1 T 1 SUB 0.25 DIV SUB 0.75 MUL 0.25 ADD = >> size_vs_time.txt
	# Code (t = 1.25 to 1.5 symbol size stays at 0.25 during code)
	gmt math -T1.3/1.5/0.1 0.25 = >> size_vs_time.txt
	# Lay down the two curves and labels as background plot. Movie starts each frame with this plot
	gmt plot -R-0.5/1.5/-0.1/2.1 -JX13.2c/2c -X4.4c -Y2.25c stepfunction.txt -W5p,green@50
	gmt plot size_vs_time.txt -W1p,red -BW -Bafg0.25+l"Size scale"
	gmt text -F+f8p+jBC -Dj6p -N labels.txt
gmt end
EOF
cat << 'EOF' > main.sh
gmt begin
	# Animate the red circle via the -E settings to ensure changes beyond the step function
	gmt events red.txt -T${MOVIE_COL0} -R-20/40/1/9 -JX20c/10c -B -Es+r0.25+p0.25+d0.25+f0.25 \
		-Et+o0.25 -Sc2c -Gred -W1p -Ms2+c0.25 -Mi1+c-0.5 -Mt100+c50 -F+f18p+jBC -Dj3c -L -X1c -Y1c
	# Plot the green circle at constant size and only visible during its duration
	gmt events green.txt -T${MOVIE_COL0} -Sc2c -Ggreen -W1p -F+f18p+jBC -Dj3c -L -E
	# Plot red circle moving along the red size curve as function of time
	gmt sample1d size_vs_time.txt -T${MOVIE_COL0}, -Fl | gmt plot -Sc4p -Gred -W0.25p -R-0.5/1.5/-0.1/2.1 \
	-JX13.2c/2c -N -X3.4c -Y1.25c
	# Plot smaller green circle moving along the default green curve as function of time
	gmt sample1d normal.txt -T${MOVIE_COL0}, -Fl | gmt plot -Sc2p -Ggreen -W0.25p -N
gmt end
EOF
# Run the movie and add frame counter and horizontal time-progress bar
gmt movie -C22cx12cx100 main.sh -Sbpre.sh -NMovie_events -T-0.5/1.5/0.01 -D24 -Fmp4 -Lc0 -Lf+jTR \
-Pf+jBC+o0/1.5c+ac -M150,png -Zs
# Delete temporary files
rm -f green.txt red.txt normal.txt labels.txt stepfunction.txt
mkdir -p mp4
mv -f Movie_events.mp4 mp4
mv -f Movie_events.png png
open mp4/Movie_events.mp4
