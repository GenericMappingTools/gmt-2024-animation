# Data period
date_start="2010-01-01"
date_stop="2022-06-30"

date_start_interest="2012-01-01"
#date_stop_interest="2019-11-01"  # Date used for the article
date_stop_interest="2022-01-01"

# 1. Generate the list of dates
gmt math -T${date_start_interest}T/${date_stop_interest}T/1d -o0 T = timetable.txt

# 2. Count the total number of days between the dates
number_days=$(gmt math -Q ${date_stop_interest}T ${date_start_interest}T SUB 1 ADD --TIME_UNIT=d =)

# 3. Generate the list of azimuth (used for Earth rotation) from 0 to 360
gmt math -T0/360/${number_days}+n T -o0 = azimuth.txt

# 4. Generate the index table for reading for time-series
row_start=$(gmt math -Q ${date_start_interest}T ${date_start}T SUB --TIME_UNIT=d =)
row_stop=$(gmt math -Q ${row_start} ${number_days} ADD 1 SUB =)
seq ${row_start} ${row_stop} > index_graphs.txt

# 5. Concatenate files
paste -d" " timetable.txt azimuth.txt index_graphs.txt > movie_frames.txt

# Countries of Interest
coi_1='france'
coi_1_iso='FR'
coi_1_clr='royalblue'

coi_2='argentina'
coi_2_iso='AR'
coi_2_clr='firebrick'

# # # # # # # # # # # # # # #
# # 	Paper params		#
# # # # # # # # # # # # # # #

# Figure parts dimensions
PLT_globe_size=12																					# Earth plot size in cm
PLT_graph_height=3																					# Graph height in cm
PLT_graph_width=$(gmt math -Q ${PLT_graph_height} 16 MUL 9 DIV FLOOR =)								# Graph width
PLT_inset_size=$(gmt math -Q ${PLT_graph_height} 3 DIV =)											# Inset size
colrbar_margin=0.5																					# Colorbar margin

gmt set MAP_GRID_PEN_SECONDARY faint,lightgray 														# Embellishment for time-series graph
gmt set FORMAT_DATE_OUT="dd o yyyy"
gmt set FORMAT_CLOCK_OUT="-"

# # # # # # # # # # # # # # #
# # 	Right panel params	#
# # # # # # # # # # # # # # #

# Get the y-axis range by comparing the maximum value of filtered data (to be plot, last column) 
# (cumulated daily-mean precipitation within region normalized by region area)
# + 10% and 30% addition for graph y-range and unit annotation above 

coi1_range_max=$(gmt info ../roi_results/${coi_1}_filtered.txt -C -o3)
coi2_range_max=$(gmt info ../roi_results/${coi_2}_filtered.txt -C -o3)

subplt_region_max=$(gmt math -Q ${coi1_range_max} ${coi2_range_max} MAX =)
subplt_region_max_10=$(gmt math -Q ${subplt_region_max} 1.1 MUL =)
subplt_region_max_30=$(gmt math -Q ${subplt_region_max} 1.3 MUL =)

# Some shift for INSET "legend-icon"
gapx=$(gmt math -Q ${PLT_inset_size} 3 DIV =)
gap1=$(gmt math -Q ${PLT_inset_size} 1.1 MUL =)
gap2=$(gmt math -Q ${PLT_inset_size} ${gap1} 1.3 MUL ADD =)

# Annotation string for graph y-axis arrow
annot_inset="<mm.day@+-1@+>/km@+2@+"
