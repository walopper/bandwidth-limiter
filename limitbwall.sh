#!/bin/bash

ETH="em1"


deletefilters(){
    #echo "tc filter del dev ${ETH} prio 1"
    tc filter del dev ${ETH} prio 1

    #echo "tc qdisc del dev em1 root"
    tc qdisc del dev em1 root

    # echo "tc class del dev em1 classid 1:11";
    # tc class del dev em1 classid 1:11

    # echo "tc class del dev em1 classid 1:10"
    # tc class del dev em1 classid 1:10
}

round(){ 
    awk -v n=$1 -v d=$2 'BEGIN{print int((n+d/2)/d) * d}'; 
}

if [ "$1" == "reset" ]; then
    deletefilters
    echo "Los limites fueron eliminados para todos los grupos"
    exit 0;
fi

if [ ! -f "./config" ]; then
    echo "Falta archivo de configuracion"
    exit 1;
fi

deletefilters

#echo "tc qdisc add dev ${ETH} root handle 1: htb default 10"
tc qdisc add dev ${ETH} root handle 1: htb default 10

#echo "tc class add dev ${ETH} parent 1: classid 1:1 htb rate 100000mbps"
tc class add dev ${ETH} parent 1: classid 1:1 htb rate 100000mbps

#echo "tc class add dev ${ETH} parent 1:1 classid 1:10 htb rate 100000mbps"
tc class add dev ${ETH} parent 1:1 classid 1:10 htb rate 100000mbps

i=11
while IFS='' read -r line || [[ -n "$line" ]]; do

    echo 
    confFile="./groups/$(cut -d' ' -f1 <<< $line)"
    group="$(cut -d' ' -f1 <<< $line)"
    bw="$(cut -d' ' -f2 <<< $line)"

    echo -e "Creando grupo \e[93m${group}\e[0m";

    NIPS=`cat $confFile | wc -l`
    if [ "$NIPS" == "0" ]; then
        NIPS=1
    fi

    BW=$((($bw * 1024) /8))
    echo -e "Limite de grupo \e[92m${bw}kbits/s\e[0m";

    echo -e "IPs en grupo \e[92m${NIPS}\e[0m"
    BMPERIP=$(($BW / $NIPS))
    echo -e "Limite por IP \e[92m${BMPERIP}Kbps\e[0m";
    #BMPERIP=$BW

    #echo "tc class add dev ${ETH} parent 1:1 classid 1:${i} htb rate ${BMPERIP}kbps ceil ${BMPERIP}kbps"
    tc class add dev ${ETH} parent 1:1 classid 1:${i} htb rate ${BMPERIP}kbps ceil ${BMPERIP}kbps

    for IP in `cat $confFile`; do 
        if [ $IP == "" ]; then
            continue;
        fi

        echo -e "Agregando IP \e[1m${IP}\e[0m a grupo \e[93m${group}\e[0m";
        #echo "tc filter add dev ${ETH} protocol ip parent 1:0 prio 1 u32 match ip src ${IP} flowid 1:${i}"
        tc filter add dev ${ETH} protocol ip parent 1:0 prio 1 u32 match ip src ${IP} flowid 1:${i}
    done

    i=$(($i + 1))

done < "./config"
