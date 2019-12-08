#!/bin/bash

##### Ignore this Section for NOW!!!!!
##### Building interactive section to create text file used below to decom pool-member/nodes

read -p 'Environment?: ' envvar
read -p 'Task Number?: ' taskvar

# touch "$HOME"/bin/received_nodes_"$envvar"_"$taskvar".txt
# 
# echo received_nodes_"$envvar"_"$taskvar".txt created!!

##!!## Copy your nodes into the file using vi or some other editor

# #
## NextNode="\n"
## until [ "last$NextNode" = "last" ];do
##     echo "Enter Node: "
##     read NextNode
##     Nodes=$Nodes"\n"$NextNode
##  done
##  echo -e $Nodes
##  echo -e $Nodes >> "$HOME"/bin/received_nodes_"$envvar"_"$taskvar".txt


#### Script starts here!!!!!

## Script assumes a text file exists containing all nodes to be verified and decommed
## must have nodes in 'partition/node_name' format

Hosts=$(awk /./ "$HOME"/bin/received_nodes_test1.txt)

DownNodes=$(while read -r line; do
    x=$(tmsh -q -c 'cd /; list ltm node '"$line"' one-line' | grep '^.*state down.*$' | awk '{ print $3 }')
    if [ -n "$x" ]; then
            echo "$x"
    elif [ -z "$x" ]; then
            continue
    fi
done <<< "$Hosts")

echo "$DownNodes"
	
if [ -z "$DownNodes" ]; then
	echo "No arp-failed nodes, therefore nothing to do..."
	exit
fi
	
echo 'cd /' >> "$HOME"/bin/actionplan_"$envvar"_"$taskvar".txt

### Loop to get verification commands for pools

while read -r line; do
  POOLNAME=$(tmsh -q -c 'cd /; list ltm pool one-line recursive' | grep ''"$line"':[a-z0-9]*\s' | awk '{ print $3 }')
    # POOLNAME is pool name
  POOLMEMBER=$(tmsh -q -c 'cd /; list ltm pool one-line recursive' | sed -n 's@^.*\('"$line"':[a-z0-9]*\)\s.*$@\1@p')
    # POOLMEMBER is line:someportnumb
      
	paste -d "@" <(echo "$POOLNAME") <(echo "$POOLMEMBER") | sed -n 's#^\(.*@\).*\/\(.*:[a-z0-9]*\)$#\1\2#p' | awk -F "@" '{print "list ltm pool", $1, "one-line"}' >> "$HOME"/bin/actionplan_"$envvar"_"$taskvar".txt/
done <<< "$DownNodes"

### Loop to append removal of arp failed pool members, from pools

while read -r line; do
    echo "For Node:"
    echo "$line"
       
  POOLNAME=$(tmsh -q -c 'cd /; list ltm pool one-line recursive' | grep ''"$line"':[a-z0-9]*\s' | awk '{ print $3 }')
    # POOLNAME is pool name(s)
      echo "Poolnames/members:"
      echo "$POOLNAME"
  POOLMEMBER=$(tmsh -q -c 'cd /; list ltm pool one-line recursive' | sed -n 's@^.*\('"$line"':[a-z0-9]*\)\s.*$@\1@p')
    # POOLMEMBER is line:someportnumber
      echo "$POOLMEMBER"

  paste -d "@" <(echo "$POOLNAME") <(echo "$POOLMEMBER") | sed -n 's#^\(.*@\).*\/\(.*:[a-z0-9]*\)$#\1\2#p' | awk -F "@" '{print "modify ltm pool", $1, "members delete {", $2, "}" }' >> "$HOME"/bin/actionplan_"$envvar"_"$taskvar".txt
  # Informational:  partition_1/testpool@partition_1/testpoolmember:8080 | sed -n 's#^\(.*@\).*\/\(.*:[a-z0-9]*\)$#\1\2#p' = partition_1/testpool@testpoolmember:8080

done <<< "$DownNodes"

### Loops to append action plan file with node verification/removals

while read -r line; do
		echo "list ltm node ${line} one-line" >> "$HOME"/bin/actionplan_"$envvar"_"$taskvar".txt
done <<< "$DownNodes"

while read -r line; do
    echo "delete ltm node ${line}" >> "$HOME"/bin/actionplan_"$envvar"_"$taskvar".txt
done <<< "$DownNodes"