#!/bin/bash
#Name:      series.sh
#Version:   1.00
#Author:    Mario Rybar
#Created:   16.04.2018
#>Silicon Valley</a></h3>&nbsp;-&nbsp;5x04 - <span
#>The Simpsons</a></h3>&nbsp;-&nbsp;29x16 -

  #VARIABLES
  WORKLOG="/home/majlo/Documents/Script/series/logs/WORKS.log"
  LOG="/home/majlo/Documents/Script/series/logs/TV_series_$(date +"%m%d%Y").log"
  GENERAL="/home/majlo/Documents/Script/series/general.txt"


  #Importing preferences
  cd /home/majlo/Documents/Script/series/
  . ./preferences.sh

#Run only once
createGENERAL() {
  #if [[ `cat ${GENERAL} | wc -l` -lt 42 ]]; then
    echo "---------------------------------" > ${GENERAL}
    for i in "${MYFIELD[@]}"
      do
        echo -e "$i" >> ${GENERAL}
        echo -e "\n---------------------------------" >> ${GENERAL}
    done
  #fi
}

#Cleaning
cleaning() {
  rm -rf ${WORKLOG}
}

#Get releasess
get_that_series() {
  #Get page #1
  curl https://next-episode.net/recent/ > ${WORKLOG}
  echo "=========================" > ${LOG}
  echo -e "TV Series log $(date +%d-"%m-%Y")" >> ${LOG}
}

#Main function
today() {
  echo "=========================" >> ${LOG}
  echo "  Today's TV Episodes:" >> ${LOG}
  echo "=========================" >> ${LOG}

  for i in "${MYFIELD[@]}"
    do
      cat ${WORKLOG} | grep -A 2 "Today.s\sTV\sEpisodes\:" | grep -Po "(?<=$i\<\/a\>\<\/h3\>\&nbsp\;\-\&nbsp\;)\d{1,2}x\d{1,2}(?=\s\-\s\<span)" &>1
      if [[ "$?" == 0 ]]; then
        #add TV show name
        echo -n "$i" >> ${LOG}
        EPISODE=$(cat ${WORKLOG} | grep -A 2 "Today.s\sTV\sEpisodes\:" | grep -Po "(?<=$i\<\/a\>\<\/h3\>\&nbsp\;\-\&nbsp\;)\d{1,2}x\d{1,2}(?=\s\-\s\<span)")
        #Series single number wc -m = 2
        if [[ $(echo "${EPISODE}" | grep -oP '(^\d{1,2})(?=x\d{1,2})' | wc -m ) == "2" ]]; then
          EPISODE=$(echo "${EPISODE}" | sed -e "s/^/0/")
        fi
        #Edit to regular format
        EPISODE=$(echo "${EPISODE}" | sed -e "s/^/S/g" -e "s/x/E/g")
        echo -n " ${EPISODE}" >> ${LOG}
        echo -e "\n" >> ${LOG}
        if [[ $(echo "${EPISODE}" | wc -l) == "2" ]]; then
          EPISODES=$(echo "${EPISODE}" | paste -sd "," -)
          IFS=',' read -r -a array <<< "${EPISODES}"
          for e in "${array[@]}"
            do
            cat ${GENERAL} | awk "/$i/,/^$/" | head -n-1 | tail -n+2 | sed -e 's/ //g' | grep "$e" &>1
            if [[ "$?" != 0 ]]; then
              #Series single number wc -m = 2
              if [[ $(echo "$e" | grep -oP '(^\d{1,2})(?=x\d{1,2})' | wc -m ) == "2" ]]; then
                e=$(echo "$e" | sed -e "s/^/0/")
              fi
              #Edit to regular format
              e=$(echo "$e" | sed -e "s/^/S/g" -e "s/x/E/g")
              sed -i "/^$i/a \ $e" ${GENERAL}
            fi
          done
        else
          cat ${GENERAL} | awk "/$i/,/^$/" | head -n-1 | tail -n+2 | sed -e 's/ //g' | grep "${EPISODE}" &>1
          if [[ "$?" != 0 ]]; then
            sed -i "/^$i/a \ ${EPISODE}" ${GENERAL}
          fi
        fi
      fi
    done
}

tomorrow() {
  echo "=========================" >> ${LOG}
  echo "  Tomorrow's TV Episodes:" >> ${LOG}
  echo "=========================" >> ${LOG}
  for i in "${MYFIELD[@]}"
    do
      cat ${WORKLOG} | grep -A 2 "Tomorrow.s\sTV\sEpisodes\:" | grep -Po "(?<=$i\<\/a\>\<\/h3\>\&nbsp\;\-\&nbsp\;)\d{1,2}x\d{1,2}(?=\s\-\s\<span)" &>1
      if [[ "$?" == 0 ]]; then
        echo "$i" >> ${LOG}
        EPISODE=$(cat ${WORKLOG} | grep -A 2 "Tomorrow.s\sTV\sEpisodes\:" | grep -Po "(?<=$i\<\/a\>\<\/h3\>\&nbsp\;\-\&nbsp\;)\d{1,2}x\d{1,2}(?=\s\-\s\<span)")
        echo "${EPISODE}" >> ${LOG}
        echo -e "" >> ${LOG}
      fi
  done
}

yesterday() {
  echo "=========================" >> ${LOG}
  echo "  Yesterday's TV Episodes:" >> ${LOG}
  echo "=========================" >> ${LOG}
  for i in "${MYFIELD[@]}"
    do
      cat ${WORKLOG} | grep -A 2 "Yesterday.s\sTV\sEpisodes\:" | grep -Po "(?<=$i\<\/a\>\<\/h3\>\&nbsp\;\-\&nbsp\;)\d{1,2}x\d{1,2}(?=\s\-\s\<span)" &>1
      if [[ "$?" == 0 ]]; then
        echo -n "$i" >> ${LOG}
        EPISODE=$(cat ${WORKLOG} | grep -A 2 "Yesterday.s\sTV\sEpisodes\:" | grep -Po "(?<=$i\<\/a\>\<\/h3\>\&nbsp\;\-\&nbsp\;)\d{1,2}x\d{1,2}(?=\s\-\s\<span)")
        #Series single number wc -m = 2
        if [[ $(echo "${EPISODE}" | grep -oP '(^\d{1,2})(?=x\d{1,2})' | wc -m ) == "2" ]]; then
          EPISODE=$(echo "${EPISODE}" | sed -e "s/^/0/")
        fi
        #Edit to regular format
        EPISODE=$(echo "${EPISODE}" | sed -e "s/^/S/g" -e "s/x/E/g")
        echo -n " ${EPISODE}" >> ${LOG}
        echo -e "\n" >> ${LOG}
        if [[ $(echo "${EPISODE}" | wc -l) == "2" ]]; then
          EPISODES=$(echo "${EPISODE}" | paste -sd "," -)
          IFS=',' read -r -a array <<< "${EPISODES}"
          for e in "${array[@]}"
            do
            cat ${GENERAL} | awk "/$i/,/^$/" | head -n-1 | tail -n+2 | sed -e 's/ //g' | grep "$e" &>1
            if [[ "$?" != 0 ]]; then
              sed -i "/^$i/a \ $e" ${GENERAL}
            fi
          done
        else
          cat ${GENERAL} | awk "/$i/,/^$/" | head -n-1 | tail -n+2 | sed -e 's/ //g' | grep "${EPISODE}" &>1
          if [[ "$?" != 0 ]]; then
            sed -i "/^$i/a \ ${EPISODE}" ${GENERAL}
          fi
        fi
      fi
    done
}

SORT_UNIQ() {
  for i in "${MYFIELD[@]}"
    do
      UNIQ=$(cat ${GENERAL} | awk "/$i/,/^$/" | head -n-1 | tail -n+2 | sed -e 's/ //g' |sort -r | uniq | sed -e 's/$/\\n/g' | tr -d '\n ')
      cat ${GENERAL} | sed -e ':a;N;$!ba' -e "s#$i.*---------------------------------#$i\n${UNIQ}\n---------------------------------#" > 1.txt
      mv 1.txt ${GENERAL}
    done
}

#read log
read_log() {
  cat ${LOG}
}

#createGENERAL
get_that_series
yesterday
today
tomorrow
read_log
cleaning
