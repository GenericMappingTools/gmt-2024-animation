# Get background color
bg_color=$(tail -3 ../precip.cpt | head -1 | awk '{print $2}')
gmt begin

# File name to be processed
filename=$(gmt math -Q ${MOVIE_COL0} -fT --FORMAT_DATE_OUT=yyyymmdd --FORMAT_CLOCK_OUT=- =)
data="grids/${filename}.grd"

# Resample input grid to match the intesity grid
gmt grdsample $data -I06m -Gintensity_grid.nc

# Plot input grid with shadow effect
gmt grdimage intensity_grid.nc -Cprecip.cpt -Bafg -Iearth_gradient.nc -X0.4c -Y0.15c -Rg \
-JG${MOVIE_COL1}/15/${PLT_globe_size}c

# Plot coastlines and paint dry/wet areas with transparency
gmt coast -Dl -A5000 -Wthinner -Gantiquewhite -S${bg_color} -t65

# Plot both countries with transparency
gmt coast -E${coi_1_iso}+g${coi_1_clr} -E${coi_2_iso}+g${coi_2_clr} -t45

# Graph time-series
gmt subplot begin 3x1 -Fs${PLT_graph_width}c/${PLT_graph_height}c -M0.75c	\
-X$(gmt math -Q ${PLT_globe_size} ${colrbar_margin} ADD 4 ADD =)c \
-Y1.5c -R${date_start}T/${date_stop}T/0/${subplt_region_max_10} \
-JX${PLT_graph_width}cT/${PLT_graph_height}c \
-B+n

# Continuous line and moving dot
gmt subplot set 2
gmt plot ../roi_results/${coi_1}_filtered.txt -Wthick,${coi_1_clr} -t20 -q0:${MOVIE_COL2}
gmt plot ../roi_results/${coi_1}_filtered.txt -Sc0.2c -G${coi_1_clr} -Wthick,black -qi${MOVIE_COL2}
gmt plot ../roi_results/${coi_2}_filtered.txt -Wthick,${coi_2_clr} -t20 -q0:${MOVIE_COL2}
gmt plot ../roi_results/${coi_2}_filtered.txt -Sc0.2c -G${coi_2_clr} -Wthick,black -qi${MOVIE_COL2}
gmt subplot end
gmt end
