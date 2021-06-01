#!/bin/bash

# Author	   : Julian Krąbel ( julekkrabel@gmail.com )
# Created On       : 28.04.2020 ( DD.MM.YYYY )
# Last Modified By : Julian Krąbel ( julekkrabel@gmail.com )
# Last Modified On : 28.04.2020 ( DD.MM.YYYY )
# Version          : 1.0
#
# Description      :
# Game "Hangman". Try to guess phrases from different categories.
#
# Free Software

VERSION=1.2
LOCAL=$(cd "$( dirname "$0" )" && pwd)
CHOOSEDLANGUAGE=""
CHOOSEDCATEGORY=""
CURLEVEL=""
POINTS=200

HELP(){
	echo "Check the manual - man hangman.sh"
}

version(){
	echo "Version : $WERSJA"
}

chooseCategory(){

	CHOOSEDLANGUAGE=""
	CHOOSEDCATEGORY=""
	CURLEVEL=""
	CATEGORIES=()
	HARDNESS=()

	LANGUAGE=("Polish" "English")

    while [ -z "$CHOOSEDLANGUAGE" ]; do

        CHOOSEDLANGUAGE=`/usr/bin/zenity --list --title="Hangman" --text="Choose language" --column="Available" "${LANGUAGE[@]}" --height 170 --width 300`

        if [ $? -eq 1 ]
        then
            	exit
        fi
    

    done

cd $CHOOSEDLANGUAGE

    for dir in *; do
        CATEGORIES+=( "${dir##./}" )
    done

    while [ -z "$CHOOSEDCATEGORY" ]; do
    
        CHOOSEDCATEGORY=`/usr/bin/zenity --list --title="Hangman" --text="Choose category" --column="Available" "${CATEGORIES[@]}" --height 400 --width 300`
        
        if [ $? -eq 1 ]
        then
            exit
        fi

    done

	cd $CHOOSEDCATEGORY

        for dir in *; do
               HARDNESS+=( "${dir##./}" )
        done

    while [ -z "$CURLEVEL" ]; do
    
       CURLEVEL=`/usr/bin/zenity --list --title="Hangman" --text="Choose level" --column="Available" "${HARDNESS[@]}" --height 400 --width 300`
        
        if [ $? -eq 1 ]
        then
            exit
        fi

    done

	PATHTOFILE=$LOCAL/$CHOOSEDLANGUAGE/$CHOOSEDCATEGORY/$CURLEVEL

    cd "$LOCAL"

}

addPhrase(){
	`/usr/bin/zenity --question --title "Adding phrases" --text "Click YES to add a new phrase or NO to close the program." --width 300 --height 100 `

   if [ $? -eq 0 ]; then
	chooseCategory

	HASLO=`/usr/bin/zenity --entry --title "Adding phrases" --text "Write a phrase //NO POLISH LETTERS!!!"`


	if [ ! -f "$PATHTOFILE/SLOWNIK.txt" ]; then
	   touch "$PATHTOFILE/SLOWNIK.txt"
	fi

	if [ -n "$PHRASE" ]; then
	   echo ${PHRASE^^} >> "$PATHTOFILE/SLOWNIK.txt"
	fi

	addPhrase
   fi

	exit

}


guessLetter(){
	CHOSENLETTER=`/usr/bin/zenity --list --title="Hangman" --text="Score: $POINTS \n\nCategory: $CHOOSEDCATEGORY\n\nPhrase: \t\t $HIDDEN" --column="Letters" "${LETTERS[@]}" --height 400 --width 300`

   if [ $? -eq 0 ]; then

	FLAG=0
	for i in $(/usr/bin/seq 1 ${#PHRASE})
	do
	   LETTER="${PHRASE:i-1:1}"
	   if [ "$LETTER" == "$CHOSENLETTER" ]; then
		ITER=1
    		for m in $(/usr/bin/seq 1 ${#HIDDEN})
    		do
        	   HIDDENLETTER="\\${HIDDEN:m-1:1}"
        	   if [ $ITER -eq $i ]; then
            		HIDDEN=""${HIDDEN:0:m-1}$CHOSENLETTER${HIDDEN:m}""
            		FLAG=1
        	   fi
        
        	   if [[ "$HIDDENLETTER" =~ ('\*'|'\t'|[A-Z]) ]]; then
            		ITER=$((ITER+1))
        	   fi
    		   HIDDENLETTER=""
    		done
 	  fi
	  LETTER=""
	done

	if [ $FLAG -eq 0  ]; then
	   POINTS=$((POINTS-10))
	fi

   fi

}

guessPhrase(){
	SOLUTION=`/usr/bin/zenity --entry --title="Hangman" --text="Score: $PUNKTY \n\nCategory: $CHOOSEDCATEGORY\n\nPhrase: \t\t $HIDDEN\n\n Write an answer:" --height 400 --width 300`
   if [ $? -eq 0 ]; then
    	if [ "${SOLUTION^^}" == "$PHRASE" ]; then
           POINTS=$((POINTS+50))
           ISCORRECT=1
           /usr/bin/zenity --info --title="Hangman" --text="Congrats! Phrase was: $PHRASE"
        else
           /usr/bin/zenity --warning --title="Hangman" --text="Not this time. You lose 40 points."
           POINTS=$((POINTS-40))
    	fi
   fi
}

play(){

	LETTERS=("A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z")

	/usr/bin/zenity --info --title "Hangman" --text "\t\t\tWelcome to Hangman!! \n\nGuess phrases and score points. At the begining you have 200 points. Guessing letters doesn't increase your score, but if you won't guess one you lose 10 points. You have 5 phrases to guess - each for 50 points. Wrong answer = -40 points. When your score is 0 - you lose." --width 300

	chooseCategory

	PHRASES_COUNT=`/usr/bin/wc -l "$PATHTIFILE/SLOWNIK.txt" | /usr/bin/cut -d " " -f1`
	PHRASESARRAY=()

   for (( n=0; n<5; n++ ))
   do

	PHRASE_NUMBER=$(( ( RANDOM % PHRASES_COUNT ) +1 ))
	   while [[ ${PHRASESARRAY[*]} =~ $PHRASE_NUMBER ]]; do
    	   	PHRASE_NUMBER=$(( ( RANDOM % PHRASES_COUNT ) +1 ))
   done

	PHRASESARRAY+=($PHRASE_NUMBER)

	PHRASE=`/bin/cat "$PATHTOFILE/SLOWNIK.txt" | /usr/bin/head -$PHRASE_NUMBER | /usr/bin/tail -1`
	HIDDEN=""

   for i in $(/usr/bin/seq 1 ${#PHRASE})
   do
	LETTER="${PHRASE:i-1:1}"
	if [ "$LETTER" != " " ]; then
    	   HIDDEN=$HIDDEN"*"
	else
    	   HIDDEN="$HIDDEN\t"
 	fi
	LETTER=""
   done

	ISCORRECT=0

   while [ $ISCORRECT -eq 0 ]; do
	OPTIONS=( "Choose letter" "Guess phrase" )
	CHOOSEOPTION=`/usr/bin/zenity --list --title="Hangman" --text="Score: $POINTS \n\nCategory: $CHOOSEDCATEGORY\n\nPhrase: \t\t $HIDDEN" --column="Options" "${OPTIONS[@]}" --height 400 --width 300`
	if [ $? -eq 1 ]; then
    	   /usr/bin/zenity --question --title="Warning" --text="Are you sure you want to exit?"
    		if [ $? -eq 0 ]; then
        	   exit
    		else
    		   CHOOSEOPTION=`/usr/bin/zenity --list --title="Hangman" --text="Score: $POINTS \n\nCategory: $CHOOSEDCATEGORY\n\nHasło: \t\t $UKRYTE" --column="Phrase" "${OPTIONS[@]}" --height 400 --width 300`
    		fi
	fi

	if [ "$CHOOSEOPTION" == "Choose letter" ]; then
	   guessLetter
	elif [ "$CHOOSEOPTION" == "Guess phrase" ]; then
	   guessPhrase
	fi

	if [ $POINTS -le 0 ]; then
	   /usr/bin/zenity --question --title="Hangman" --text="You've lost all of your point. Would you like to try again?"
    		if [ $? -eq 0 ]; then
        	   POINTS=200
        	   play
    		else
        	   exit
    		fi
	fi

   done
 
   done

	/usr/bin/zenity --question --title="Literaki" --text="Congrats! Score: $PUNKTY Would you like to try again?"

 	if [ $? -eq 0 ]; then
           POINTS=200
           play
    	else
           exit
    	fi

}


while getopts hvap OPT ; do
case $OPT in
h) help;;
v) version;;
a) addPhrase;;
p) play;;
*) echo "Unknown option";;
esac

done
