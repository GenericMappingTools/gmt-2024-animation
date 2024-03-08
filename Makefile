#
# Makefile for https://github.com/GenericMappingTools/gmt-2024-animation
#
# Wessel, Esteban, & Delaviel-Anger, 2024,
#	The Generic Mapping Tools and Animations for the Masses,
#	Geochem. Geophys. Geosyst.
#
# Note: These commands may NOT work on windows.

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
# List of scripts creating illustrations and movies
FIGS=	WED-A_Fig_1.sh WED-A_Fig_2.sh WED-A_Fig_3.sh WED-A_Fig_4.sh
#MOVIES=	WED-A_Vid_3.sh WED-A_Vid_4.sh WED-A_Vid_5.sh WED-A_Vid_6.sh WED-A_Vid_7.sh
MOVIES=	WED-A_Vid_4.sh WED-A_Vid_5.sh WED-A_Vid_6.sh #WED-A_Vid_7.sh
MOVIES=	WED-A_Vid_4.sh #WED-A_Vid_7.sh


figs:
	for script in $(FIGS) ; do\
		bash $$script; \
	done

movies:
	for script in $(MOVIES) ; do\
		time bash $$script 2> $$script.log ; \
	done

all:	figs movies

clean-figs:
	rm -f *.png

clean-movies:
	rm -f *.mp4

spotless: clean-figs clean-movies

