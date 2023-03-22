#
# Makefile for
#
# Wessel, P., Esteban, F. and A-D, G., 2023
#   The Generic Mapping Tools and Animations for the Masses,
#	<journal TBD>
#

help::
		@grep '^#!' Makefile | cut -c3-
#!-------------------- MAKE HELP FOR PAPER --------------------
#!
#!
#!make <target>, where <target> can be:
#!
#!pdf           : Just build or update PDF figures for the paper
#!png           : Just build or update PNG figures for the paper
#!mp4           : Just build or update MP4 animations for the paper
#!clean         : Clean up and remove created Latex files of all types, except figs and calc
#!spotless      : As clean, but also delete all created PDF, JPG and PNG figures
#!
#---------------------------------------------------------------------------
# List of scripts creating illustrations
FIG=	Fig_events_curves.sh	Fig_movie_progress.sh	Fig_title_fade.sh

# List of scripts creating animations
MOVIE=	Movie_events.sh

#--------------------------------------
PDFtmp= $(FIG:.sh=.pdf)
PDF= $(addprefix pdf/, $(PDFtmp))
PNGtmp= $(FIG:.sh=.png)
PNG= $(addprefix png/, $(PNGtmp))
MP4tmp= $(MOVIE:.sh=.mp4)
MP4= $(addprefix mp4/, $(MP4tmp))

png:	$(PNG)

pdf:	$(PDF)

mp4:	$(MP4)
		mkdir -p mp4

mp4/%.mp4: %.sh
	bash $*.sh mp4; rm -f gmt.conf gmt.history

png/%.png: %.sh
	bash $*.sh png; rm -f gmt.conf gmt.history

pdf/%.pdf: %.sh
	bash $*.sh pdf; rm -f gmt.conf gmt.history

clean:
	rm -f *.ps

spotless:	clean
	rm -rf png pdf mp4
