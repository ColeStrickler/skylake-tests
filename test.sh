#!/bin/bash

corun=$1
victim_core=$2
victim_slice=$3
attacker_slice=$4


#> /sys/fs/cgroup/palloc/part1/cgroup.procs
#> /sys/fs/cgroup/palloc/part2/cgroup.procs

if [ "$corun" = "co" ]; then
    echo "Running attackers....."
    for i in 0 1 2 3; do 
	if [ "$i" -eq $victim_core ]; then
            echo "Skipping attacker with index $i"
            continue
        fi


        ./BkPLL -m 2000 -b 0x0 -e $attacker_slice -z -l 12 -c $i -i 999999999999 -a write > /dev/null 2>&1 &
        attacker_pid=$!
	echo $attacker_pid
        echo $attacker_pid >> /sys/fs/cgroup/palloc/part2/cgroup.procs
        #pagetype -k 0x70000 -p $attacker_pid | tail -9
    done

fi
sleep 1
echo -e "\nRunning victim....."



# for some reason we are getting the id of something other than BkPLL
perf stat -e LLC-loads,LLC-load-misses ./BkPLLVictim -m 2000 -b 0x0 -e $victim_slice -z -l 12 -c $victim_core -i 250000 > out.txt &
perf_pid=$!
sleep .050
pgrep BkPLLVictim
victim_pid=$(pgrep BkPLLVictim)
echo $victim_pid
echo $victim_pid > /sys/fs/cgroup/palloc/part1/cgroup.procs

wait $perf_pid

bw=$(grep "bandwidth" out.txt | awk '{ print $2 }')
echo "$corun,$victim_core,$victim_slice,$attacker_slice,$bw" >> stats.txt
echo -e "\nVictim done....."


echo "killing co-runners"
killall -9 BkPLL
