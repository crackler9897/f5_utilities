#!/bin/bash



#################
## FUNCTIONS
#################

workflow()
{
	echo ""
	sleep 2
    
	if [[ "$1" == node ]] || [[ "$1" == pool ]] || [[ "$1" == cert ]] || [[ "$1" == key ]] || [[ "$1" == monitor ]]; then
			echo "List of ${1}s..."
	else
			echo "List of ${1} profiles..."
	fi

			echo ""
			sleep .5
			echo -n "*"
			sleep .5
			echo -n "*"
			sleep .5
			echo -n "*"
			sleep .5
			echo -n "*"
			sleep .5
			echo ""
			echo "$inventory"
			echo ""
			echo "*************"
			echo ""

	if [[ "$1" == node ]] || [[ "$1" == pool ]] || [[ "$1" == cert ]] || [[ "$1" == key ]] || [[ "$1" == monitor ]]; then
			echo "Now for the orphaned ${1}s..."
	else
			echo "Now for the orphaned ${1} profiles..."
	fi

	echo ""
	sleep 1

}

orphaned_object_search()
{
	object=$1
	today=$(date +"%Y%m%d")

  if [[ "$object" == node ]] || [[ "$object" == pool ]]; then
    inventory=$(find /config -regextype posix-extended -regex '(^.*config/bigip.conf$)|(^.*partitions/.*/bigip.conf$)' -exec grep 'ltm '"$object"'' {} \; | awk '{print $3}')
		#### example:  Common/nodename
    #### example:  partition_1/anothernodename
    #### example:  partition_2/yetanothernodename

	  workflow $object

      while read -r line; do
      	#reading lines of $inventory and checking number of occurrences per entry
      	x=$(find /config -regextype posix-extended -regex '(^.*config/bigip.conf$)|(^.*partitions/.*/bigip.conf$)' -exec grep -o ''"$line"'' {} \; | wc -l)
				if [ "$x" -le 1 ]; then
						echo "$line"
						echo "$line" >> "$HOME"/orphaned_"$object"_"$env"_"$today".txt
				fi
			done <<< "$inventory"

	elif [[ "$object" == cert ]]; then
		inventory=$(find /config/filestore/files_d -regextype posix-extended -regex '^.*:.*:.*\.crt_.*_.*$')
		# example:  /config/filestore/files_d/Common_d/certificate_d/:Common:something.company.com.crt_839276_1
					
	  workflow $object
		
			while read -r line; do
			#reading lines of $inventory and checking number of occurrences per entry
        x=$(echo "$line" | sed -n 's@^.*:.*:\(.*\.crt\)_.*_.*$@\1@p')
				y=$(echo "$line" | awk -F "/" '{print $5}' | sed -n 's@^\(.*\)_d$@\1@p')
				z=$(find /config -regextype posix-extended -regex '(^.*config/bigip.conf$)|(^.*partitions/.*/bigip.conf$)' -exec grep ''"$x"'' {} \; | wc -l)
				if [ "$z" -le 3 ]; then
						echo /"$y"/"$x"
						echo /"$y"/"$x" >> "$HOME"/orphaned_"$object"_"$env"_"$today".txt
				fi
			done <<< "$inventory"
									
	elif [[ "$object" == key ]]; then
		inventory=$(find /config/filestore/files_d -regextype posix-extended -regex '^.*:.*:.*\.key_.*_.*$')
		# example:  /config/filestore/files_d/Common_d/certificate_key_d/:Common:something.company.com.key_819287_1
							
	  workflow $object
							
		  while read -r line; do
		  #reading lines of $inventory and checking number of occurrences per entry
		  	x=$(echo "$line" | sed -n 's@^.*:.*:\(.*\.key\)_.*_.*$@\1@p')
		  	y=$(echo "$line" | awk -F "/" '{print $5}' | sed -n 's@^\(.*\)_d$@\1@p')
		  	z=$(find /config -regextype posix-extended -regex '(^.*config/bigip.conf$)|(^.*partitions/.*/bigip.conf$)' -exec grep ''"$x"'' {} \; | wc -l)
		  	if [ "$z" -le 3 ]; then
		  			echo /"$y"/"$x"
		  			echo /"$y"/"$x" >> "$HOME"/orphaned_"$object"_"$env"_"$today".txt
		  	fi
		  done <<< "$inventory"
										
	else
		inventory=$(find /config -regextype posix-extended -regex '(^.*config/bigip.conf$)|(^.*partitions/.*/bigip.conf$)' -exec grep 'ltm profile '"$object"'\|ltm '"$object"'' {} \; | awk '{print $3, $4}')
		### example:  cookie /Common/cookie_test
    ### example:  client-ssl /Common/clientssl_test.rjf.com
		### example:  ldap /partition_3/monitor_test.company.com_90234
					
	  workflow $object

      while read -r line; do
        #reading lines of $inventory and checking number of occurrences per entry
        x=$(echo "$line" | awk '{print $2}')
        y=$(find /config -regextype posix-extended -regex '(^.*config/bigip.conf$)|(^.*partitions/.*/bigip.conf$)' -exec grep ''"$x"'' {} \; | wc -l)
				if [ "$y" -le 1 ]; then
						echo "$line"
						if [[ $object == monitor ]]; then
								echo "$line" >> "$HOME"/orphaned_"$object"_"$env"_"$today".txt
						else
								echo "$line" >> "$HOME"/orphaned_"$object"_profiles_"$env"_"$today".txt
						fi
				fi
			done <<< "$inventory"
  fi

#### Only objects that are referenced more times than needed to simply define them, will be put in this list.  This gives some certainty that the objects are orphaned.

}

#################
## MAIN BODY
#################

echo "Please define environment..."
read -p "Environment:" env

done_with_reports=0

	while (( !done_with_reports )); do
	
		title="Orphaned Object Reporting..."
		prompt="Take your pick..."
		options=("node" "monitor" "pool" "http" "tcp" "persistence" "cert" "key" "client-ssl")
		
		echo "$title"
		PS3="$prompt"
		select opt in "${options[@]}" "Quit" ; do
	
			case "$REPLY" in

			1 ) echo "Searching for orphaned objects of type: $opt"
					orphaned_object_search $opt; break ;;
			2 ) echo "Searching for orphaned objects of type: $opt"
				orphaned_object_search $opt; break ;;
			3 ) echo "Searching for orphaned objects of type: $opt"
				orphaned_object_search $opt; break ;;
			4 ) echo "Searching for orphaned objects of type: $opt"
				orphaned_object_search $opt; break ;;
			5 ) echo "Searching for orphaned objects of type: $opt"
				orphaned_object_search $opt; break ;;
			6 ) echo "Searching for orphaned objects of type: $opt"
				orphaned_object_search $opt; break ;;
			7 ) echo "Searching for orphaned objects of type: $opt"
				orphaned_object_search $opt; break ;;
			8 ) echo "Searching for orphaned objects of type: $opt"
				orphaned_object_search $opt; break ;;
			9 ) echo "Searching for orphaned objects of type: $opt"
				orphaned_object_search $opt; break ;;
			$(( ${#options[@]}+1 )) ) echo "Exiting...";break;;
			* ) echo "Invalid option. Try again.";continue;;
      
      esac
		done
	
	
		echo "More Reports?..."
					
					select opt in "Yes" "No"; do
							case $REPLY in
								1) break ;;
								2) echo "Exiting..."; done_with_reports=1 ; break ;;
								*) echo "Invalid option.  Try again." ;;
							esac
					done
	done
