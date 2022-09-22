#!/bin/bash
#Name:      series.sh
#Version:   2.00
#Author:    Mario Rybar
#Created:   16.04.2018
#Updated:   11.02.2022
#===================================================================
# Enable debug
#set -x

  # VARIABLES
  cd -- "$(dirname "$0")"
  WDIR=`pwd`
  WORKLOG="${WDIR}/WORKS.log"
  LOG="${WDIR}/logs/$(date +"%d%m%Y")_TV_series.log"
  #GENERAL="${WDIR}/general.txt"
  TODAY="Today.s\sTV\sEpisodes\:"
  TOMORROW="Tomorrow.s\sTV\sEpisodes\:"
  YESSTERDAY="Yesterday.s\sTV\sEpisodes\:"

  # Importing preferences
  #cd /home/majlo/Documents/Script/series/
  . ./preferences.sh


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# Disabled for now
# Run only once
createGENERAL() {
  if [[ `cat ${GENERAL} | wc -l` -lt 42 ]]; then
    echo "---------------------------------" > ${GENERAL}
    for i in "${MYFIELD[@]}"
      do
        echo -e "$i" >> ${GENERAL}
        echo -e "\n---------------------------------" >> ${GENERAL}
    done
  fi
}

SORT_UNIQ() {
  for i in "${MYFIELD[@]}"
    do
      UNIQ=$(cat ${GENERAL} | awk "/$i/,/^$/" | head -n-1 | tail -n+2 | sed -e 's/ //g' | sort -r | uniq | sed -e 's/$/\\n/g' | tr -d '\n ')
      cat ${GENERAL} | sed -e ':a;N;$!ba' -e "s#$i.*---------------------------------#$i\n${UNIQ}\n---------------------------------#" > 1.txt
      mv 1.txt ${GENERAL}
    done
}

#-------------------------------------------------------------------------------
# Cleaning
cleaning() {
  rm -rf ${WORKLOG}
  rm -rf 1
}

# Get releasess
get_that_series() {
  # Get page #1
  curl https://next-episode.net/recent/ > ${WORKLOG}
  echo "----------------------------------------------------------------------------------------------" > ${LOG}
  echo -e "- TV SERIES log $(date +%d-"%m-%Y") > ${LOG}" >> ${LOG}
  echo -e "----------------------------------------------------------------------------------------------" >> ${LOG}
}

# Main function
getEpisodes() {
  echo "=============================" >> ${LOG}
  echo "  ${1}" | sed -e "s/\./\'/g" -e 's/\\s/ /g' -e 's/\\//g' >> ${LOG}
  echo "———————————————————————————" >> ${LOG}
  for i in "${MYFIELD[@]}"
    do
      cat ${WORKLOG} | grep -a -A 2 "${1}" | grep -Po "(?<=$i\<\/a\>\<\/h3\>\&nbsp\;\-\&nbsp\;)\d{1,2}x\d{1,2}(?=\s\-\s\<span)" &>1
      if [[ "$?" == 0 ]]; then
        # Add TV show name
        #echo "$i" >> ${LOG}

        EPISODE=$(cat ${WORKLOG} | grep -a -A 2 "${1}" | grep -Po "(?<=$i\<\/a\>\<\/h3\>\&nbsp\;\-\&nbsp\;)\d{1,2}x\d{1,2}(?=\s\-\s\<span)")

        #echo "${EPISODE}" >> ${LOG}
        # Get season number
        SEASON=$(echo "${EPISODE}" | cut -d'x' -f1)
        # if season number less than 10
        if (( $SEASON < 10 )); then
          EPISODE=$(echo "S0${EPISODE}");
        else
          EPISODE=$(echo "S${EPISODE}");
        fi
        EPISODE=$(echo "${EPISODE}" | sed -e 's/x/E/g')
        # generate TV Show + S00E00
        echo "$i ${EPISODE}" >> ${LOG}

        echo -e "" >> ${LOG}


        #UNIQ=$(cat ${GENERAL} | awk "/$i/,/^$/" | head -n-1 | tail -n+2 | sed -e 's/ //g'  | sort -r | uniq | sed -e 's/$/\\n/g' | tr -d '\n ')
        #cat ${GENERAL} | awk "/$i/,/^$/" | head -n-1 | tail -n+2 | sed -e 's/ //g' | grep "${EPISODE}" &>1
        #if [[ "$?" != 0 ]]; then
        #  sed -i "/^$i/a \ ${EPISODE}" ${GENERAL}
        #fi
      fi
    done
}

#read log
read_log() {
  cat ${LOG}
}

#-------------------------------------------------------------------------------
# CALL FUNCTIONS
#createGENERAL
#SORT_UNIQ
get_that_series
getEpisodes "${YESSTERDAY}"
getEpisodes "${TODAY}"
getEpisodes "${TOMORROW}"
read_log
cleaning
echo "$WDIR"
