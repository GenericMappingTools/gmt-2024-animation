#!/usr/bin/env bash
title=IndianaJones_Flight_NY-Venice

cat << 'EOF' > pre.sh
gmt begin
gmt set PROJ_ELLIPSOID Sphere

# Escalas del viaje
cat << 'FILE' > cities.txt
40.711913, -74.007135, New York
47.561598, -52.712229, St Johns (Terranova)
37.741556, -25.696368, Sao Miguel (Azores)
38.775808, -9.135406, Lisboa (Portugal)
45.502971, 12.342151, Venecia (Italia)
FILE
    L=$(gmt mapproject -G+uk cities.txt  --PROJ_ELLIPSOID=Sphere | gmt convert -El -o2)
    dx=$(gmt math -Q ${L} 30 24 MUL DIV =)
    gmt sample1d "cities.txt" -I${dx}k -fg -i1,0 | gmt mapproject -G+uk > "tmp_time.txt"
    gmt events -Rd "tmp_time.txt" -Ar100c > tmp_points.txt
gmt end
EOF

cat << 'EOF' > main.sh
gmt begin
    gmt coast -R-800/800/-450/450+uk -JG${MOVIE_COL0}/${MOVIE_COL1}/24c -Bg0 -Df -G200 -Sdodgerblue2 -N1/0.2,- -Y0p -X0p
    gmt events tmp_time.txt -Ar -T${MOVIE_COL2} -Es -W2p,red
gmt end
EOF

#	Create animation
gmt movie main.sh -Sbpre.sh -N$title -Ttmp_time.txt -Chd -Vi -Ml,png -Fmp4 -Zs