#!/bin/bash
# RUN ON STANDBY to test

#   1.  Read in partition (env)
#   2.  Create array of all virtual names based on partition
#   3.  Run 'show ltm virtual' for each virtual and determine if 1.0 or 1.1 is being used
#   4.  Output to file/list


searchVip()
{
  x=$(tmsh -q -c 'cd /; show ltm virtual '"$1"' profiles' | grep -A 35 'Ltm::ClientSSL Profile' | grep 'TLS Protocol Version 1.0' | awk '{print $6}')
  y=$(tmsh -q -c 'cd /; show ltm virtual '"$1"' profiles' | grep -A 35 'Ltm::ClientSSL Profile' | grep 'TLS Protocol Version 1.1' | awk '{print $6}')
  z=$(tmsh -q -c 'cd /; show ltm virtual '"$1"' profiles' | grep 'Ltm::ClientSSL Profile')
  
  # echo "${x}, ${y}"

  if [ -z "$z" ]; then
      :
  elif [ "$x" = 0 ] && [ "$y" = 0 ] && [ -n "$env" ]; then
      echo "$1" >> "$HOME"/TLS_1_2_only_"$env".txt
  elif [ "$x" = 0 ] && [ "$y" = 0 ] && [ -z "$env" ]; then
      echo "$1" >> "$HOME"/TLS_1_2_only_all_partitions.txt
  elif [ "$x" != 0 ] || [ "$y" != 0 ]; then
    if [ -n "$env" ]; then
        echo "$1" >> "$HOME"/TLS_offenders_"$env".txt
    elif [ -z "$env" ]; then
        echo "$1" >> "$HOME"/TLS_offenders_all_partitions.txt
    fi
  fi
}

pauseIt()
{
  echo ""
  echo ""
  echo ""
  sleep .5
  echo -n "*"
  sleep .5
  echo -n "*"
  sleep .5
  echo -n "*"
  sleep .5
  echo ""
  echo ""
  echo ""
}

partitions=($(tmsh -q -c 'cd /; list auth partition one-line' | awk '{ print $3 }'))

pauseIt

echo "Partitions: ${partitions[@]} *ALL*"
echo ""

read -p "What partition should we check?...<enter> key to check all partitions: " env
sleep .5
echo ""

if [ -n "$env" ]; then
    echo "env defined is /${env}"
else
    echo "env defined is /"
fi

pauseIt

vipsArr=($(tmsh -q -c 'cd /'"$env"'; list ltm virtual one-line recursive' | awk '{print $3}' ))
echo "${vipsArr[@]}"

for i in ${vipsArr[@]}; do
  if [ -n "$env" ]; then
    i="${env}/${i}"
  fi
  echo "$i"
  searchVip "$i"
done