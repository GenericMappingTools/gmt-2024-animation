# WIP. This commands will be add to the other script at the end.

# Create movie
#ffmpeg -loglevel warning -f image2 -framerate 24 -y -i "/home/federico/Github/Esteban82/gmt-2023-animation/Federico/1b_Jones_Flight_Complex/IndianaJones_Flight_Complex_WIP/IndianaJones_Flight_Complex_WIP_%03d.png" -vcodec libx264  -pix_fmt yuv420p IndianaJones_Flight_Complex_WIP.mp4

infile=RaidersMarch.mp3
outfile=trim.mp3
begin=0.478 # seconds
begin=0.5 # seconds
#duration=30 # seconds
#ffprobe -i IndianaJones_Flight_Complex_WIP.mp4 -show_entries format=duration -v quiet -of csv="p=0"
duration=$(ffprobe -i IndianaJones_Flight_Complex_WIP.mp4 -show_entries format=duration -v quiet -of csv="p=0")
echo $duration
video=IndianaJones_Flight_Complex_WIP
#video=WIP3

ffmpeg -loglevel warning -ss $begin -y -i $infile -t $duration $outfile
ffmpeg -loglevel warning -i ${video}.mp4 -y -i $outfile ${video}_final.mp4

rm $outfile