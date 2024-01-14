#
# Makefile for https://github.com/GenericMappingTools/gmt-2024-animation
#
# Wessel, Esteban, & Delaviel-Anger, 2024,
#	The Generic Mapping Tools and Animations for the Masses,
#	Geochem. Geophys. Geosyst.
#

help::
		@grep '^#!' Makefile | cut -c3-
#!-------------------- MAKE HELP FOR ANIMATION PAPER REPO --------------------
#!
#!make <target>, where <target> can be:
#!
#!all           : Just build or update PNG figures and movies for the paper
#!figs          : Just build or update PNG figures
#!movies        : Just build or update MP4 movies
#!clean-figs    : Delete all created PNG products
#!clean-movies  : Delete all created MP4 products
#!spotless      : Delete all created graphic products
#!
#---------------------------------------------------------------------------
# List of scripts creating illustrations and movies (all called Figure)
FIGS=	WED-A_Fig_1.shWED-A_Fig_3.sh WED-A_Fig_5.sh
MOVIES=	WED-A_Fig_2.sh WED-A_Fig_4.sh WED-A_Fig_6.sh
#		Movie_IndianaJones_flight.sh Movie_IndianaJones_flight_complex.sh

figs:
	for script in $(FIGS) ; do\
		bash $$script; \
	done

movies:
	for script in $(MOVIES) ; do\
		bash $$script; \
	done

all:	figs movies

clean-figs:
	rm -f *.png

clean-movies:
	rm -f *.mp4

spotless: clean-figs clean-movies
