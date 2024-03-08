#!/usr/bin/env bash
inicio=$(date +%s)
#
# Video 6 in this paper: WED-A_Vid_6.sh
# https://github.com/GenericMappingTools/gmt-2024-animation
#
# Wessel, Esteban & Delaviel-Anger, 2024,
#	The Generic Mapping Tools and Animations for the Masses,
#	Geochem. Geophys. Geosyst.
#
# Purpose: Show movie of Emperor 3-D density model sliced N-S.
# The movie took 5.6 minutes to render on an 8-core Intel® Core™ i7-7700 CPU @ 3.60GHz.
#--------------------------------------------------------------------------------
FIG=WED-A_Vid_6
#
# High-resolution movie of the 3-D density structure of the Emperors
# HD if -C1920x700x116+c and UHD if -C3840x1400x232+c.

cat << EOF > pre.sh
# Prepare data and CPT for movie
gmt begin
	# Select the range of along-strike y-profiles in 2 km increments
	gmt math -T-150/150/2 -o1 -I T = pos3D.txt
	gmt makecpt -Croma -T2150/3050 -I --COLOR_BACKGROUND=black -H > rho3D.cpt
	#unzip data/Emperor_oblique_prisms.txt.zip
	#cp -f data/*.nc .
	# Lay down average density grid in the horizontal plane
	gmt set FONT_TAG 20p,Helvetica,black
	gmt grdimage Emperor_oblique_ave_dens.nc -R100/2220/-280/200 -Jx0.007c -Jz0.0006c -Baf -Bzaf -BWStrZ -p165/30 -Q -Crho3D.cpt -X1c -Y0.2c
	gmt colorbar -Crho3D.cpt -DJCB+w5c+o-5.75c/-0.5c -Bxaf -By+l"kg/m@+3@+" --FONT_ANNOT_PRIMARY=7p --MAP_FRAME_PEN=0.5p
gmt end
EOF
cat << 'EOF' > main.sh
gmt begin
	# Select the prisms along the current line
	gmt select Emperor_oblique_prisms.txt -Z${MOVIE_COL0}/$((${MOVIE_COL0} + 2))+c1 > slice.txt -o0:2,3+o2650,4 -bo3h,2f
	# Use the following command if you want instead to truncate the prisms below the current line (it needs a lot of memory).
	#gmt select Emperor_oblique_prisms.txt -Z${MOVIE_COL0}/600+c1 > slice.txt -o0:2,3+o2650,4 -bo3h,2f

	# Plot the prisms
	gmt plot3d slice.txt -R100/2220/-280/200/0/6000 -Jx0.007c -Jz0.0006c -p165/30 -So1q+b -Crho3D.cpt -X1c -Y0.2c -bi3h,2f

	# Draw the kink line
	printf "100 ${MOVIE_COL0} 0\n2220 ${MOVIE_COL0} 0\n" | gmt plot3d -W0.25p -p

	# Get topography along the profile
	gmt grdtrack -GEmperor_oblique_load_mask.nc -E100/${MOVIE_COL0}/2220/${MOVIE_COL0} -s > topography_profile.txt

	# Plot topographic outline
	gmt plot3d topography_profile.txt -W0.25p -p -gD0.3c -Vq
gmt end
EOF

# Run the movie
# Use with GMT 6 (dev version)
#gmt movie -Tpos3D.txt main.sh -Sbpre.sh -C1920x700x116+c -D12 -N${FIG} -Ls"The Emperor Seamounts 3-D Density Model"+jTC -Pc+ac0 -M50,png -H2 -Fmp4 -Vi -Zs
# With GMT 6.5
#gmt movie -Tpos3D.txt main.sh -Sbpre.sh -C19.20x7x100 -D12 -N${FIG} -Ls"The Emperor Seamounts 3-D Density Model"+jTC -Pc+ac0 -M50,png -H2 -Fmp4 -Vi -Zs 

# WIP
gmt movie -Tpos3D.txt main.sh -Sbpre.sh -C16.55cx6.03cx116 -D12 -N${FIG} -Ls"The Emperor Seamounts 3-D Density Model"+jTC -Pc+ac0 -M50,png -Fmp4 -H2 -Vi -Zs 

fin=$(date +%s)
tiempo_total=$((fin - inicio))
echo "El script tardó $tiempo_total segundos en ejecutarse."