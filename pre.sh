# # # # # # # # # # # # # # #
# # 	Local function		#
# # # # # # # # # # # # # # #

gmt_subplt_inset () {
# Used to avoid inset commands repetition for the subplot graphs (right side)
environment=$1
region=$2
color=$3

gmt inset begin ${environment} -N -R${region}
gmt coast -E${region}+g${color}
echo "${region}" | gmt text -F+f10p,Courier-Bold,black+cRM+jBL -N
gmt inset end
}

# # # # # # # # # # # # # # #
# #    Static environment   #
# # # # # # # # # # # # # # #

gmt begin

# # # # # # # # # # # # # # #
# # 	Globe [left panel]	#
# # # # # # # # # # # # # # #
# # 	* colour-palettes	#
# #		* colourbar params	#
# # # # # # # # # # # # # # #	

# Colour palettes
gmt makecpt -Crain -T0/50 -H -D		> precip.cpt	# foreground (data)

# Create intesity grid from relief grid
gmt set GMT_DATA_UPDATE_INTERVAL 1d GMT_DATA_SERVER oceania
gmt grdgradient @earth_relief_06m -Gearth_gradient.nc -A-45 -Nt1+a0

# Initialize Globe position
gmt basemap -Rg -JG0/15/${PLT_globe_size}c -B -X0.4c -Y0.15c
gmt colorbar -DJMR+ef+o${colrbar_margin}c/0c -Bxaf+l"Daily-mean precipitation" -By+l"<mm.day@+-1@+>" -Cprecip.cpt --MAP_ANNOT_OFFSET=7p

# # # # # # # # # # # # # # #
# # Graphs subplots [right]	#
# # # # # # # # # # # # # # #
# # 	* x/y-ranges		#
# #		* inset positions	#
# # 	* annotations		#
# # # # # # # # # # # # # # #	
gmt set MAP_FRAME_TYPE graph

# Actual subplot (3 rows)
#	total size (figure) imposed `-Fs`
#	increase vertical margins `-M`
#	impose shift from left panel `-X` and `-Y`
#	set x/y axis `-R`
#	set projection (cartesian) `-JX`
#	graph embellishments (annotation, ticks and gridlines) `-B`
gmt subplot begin 3x1 \
-Fs${PLT_graph_width}c/${PLT_graph_height}c	\
-M0.75c	\
-X$(gmt math -Q ${PLT_globe_size} ${colrbar_margin} ADD 4 ADD =)c \
-Y1.5c \
-R${date_start}T/${date_stop}T/0/${subplt_region_max_10} \
-JX${PLT_graph_width}cT/${PLT_graph_height}c \
-B+n

gmt subplot set 0
# Manually place the globe "annotation" arrow
echo 2007-06-01T 0.00015 180 0.5 | gmt plot -Sv0.3c+e+h0+a45+gblack+pthick -N
# Use `legend` module to annotate the left panel
gmt legend -DjBL+w5c/1.5c+o-1c/0c+l1.2 -F+p1p,darkgray+gwhitesmoke+r+s3p/-2p,lightskyblue4 --FONT_ANNOT_PRIMARY=8p,Helvetica,dimgray << END
H 8p,Helvetica Daily-mean precipitation
G 0.005c 
T 1\260x1\260 gridded data in mm.day@+-1@+
T derived from satellite measurements.
END

gmt subplot set 1
# Manually place the graph "annotation" arrow
echo 2020-01-01T 0 -90 0.5 | gmt plot -Sv0.3c+e+h0+a45+gblack+pthick -N
# Use `legend` module to annotate the right panel
gmt legend -DjBL+w5c/2.5c+o1.5c/0c -F+p1p,darkgray+gwhitesmoke+r+s3p/-2p,lightskyblue4 --FONT_ANNOT_PRIMARY=8p,Helvetica,dimgray << END
H 8p,Helvetica Daily-mean precipitation 
H 8p,Helvetica summed over a given territory:
G 0.05c
T The time-series are normalized by their respective area (km@+2@+)
T and a 3 months low-pass (boxcar) filter is applied
T to highlight the seasonal cycles.
END

gmt subplot set 2
# Initialize graph with basemap (change subplot previously defined -R ), 
#	add secondary frame (`-Bs` without annot, ticks 1y, gridlines 3 months)
gmt basemap -BWS -Bxa3Yg1Y -Byafg	
# x[T]: annotation(3 years), ticks(none), gridlines(1 year)
# y[precip]: auto (annot, ticks, grids)-Bsxf1yg3o

#	add small text "units" above y-axis
echo ${date_start}T ${subplt_region_max_30} $annot_inset | gmt text -F+f8p,Times-Italic,black -N

# Inset generated with local function
gmt_subplt_inset "-DJTR+o${gapx}c/-${gap1}c -JM${PLT_inset_size}c+du" ${coi_1_iso} ${coi_1_clr}
gmt_subplt_inset "-DJTR+o${gapx}c/-${gap2}c -JM${PLT_inset_size}c+du" ${coi_2_iso} ${coi_2_clr}
gmt subplot end
gmt end
