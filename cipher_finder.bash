#!/bin/bash
# RUN ON STANDBY

searchVip()
{
        for i in ${profilesArr[@]}; do
                if [[ $1 =~ ^.*$i[[:space:]].*$ ]]; then
                        echo "$i"
                        echo "$1"
                        echo "$1" | awk '{ print $3 }' >> "$HOME"/"$3"_offenders_"$2"_dups.txt
                fi
        done
}

partitions=($(tmsh -q -c 'cd /; list auth partition one-line' | awk '{ print $3 }'))

echo ""
echo ""
echo ""
echo "Partitions: ${partitions[@]}"
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

read -p "What partition should we check?: " env
sleep .5
echo ""
read -p "What string should we search for in the client-ssl profiles (this usually corresponds to the offending cipher)?:  " cipher

profilesArr=($(tmsh -q -c 'cd /; list ltm profile client-ssl all-properties one-line recursive' | grep -v ''"$cipher"'' | awk '{print $4}' ))
echo "${profilesArr[@]}"

allVipsFullLine=$(tmsh -q -c 'cd /; list ltm virtual one-line recursive' | grep ''"$env"'')
echo "$allVipsFullLine" | awk '{print $3}'

while read -r line; do
        searchVip "$line" "$env" "$cipher"

done <<< "$allVipsFullLine"

echo ""
echo ""
sleep .5

if [ -e "$HOME"/"$cipher"_offenders_"$env"_dups.txt ]; then
        sort -u "$HOME"/"$cipher"_offenders_"$env"_dups.txt > "$HOME"/"$cipher"_offenders_"$env".txt
fi

if [ -e "$HOME"/"$cipher"_offenders_"$env".txt ]; then
    echo "${cipher}_offenders_${env}.txt created, or appended in your home directory..."
else
    echo "No ${cipher} Offenders in the ${env} partition.."
        echo ""
        echo "Try Again?..."
fi