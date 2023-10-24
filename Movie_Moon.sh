cat <<- 'EOF' > main.sh
gmt begin
  gmt grdimage @moon_relief_06m -Rg -JG-${MOVIE_FRAME}/30/20c -Bg -X0 -Y0
gmt end show
EOF
gmt movie main.sh -C20cx20cx30 -T359 -Fmp4 -Mf,png -NMovie_Moon -Z
