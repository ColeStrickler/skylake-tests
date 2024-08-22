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


while true; do
# for some reason we are getting the id of something other than BkPLL
perf stat -e LLC-loads,LLC-load-misses ./BkPLLVictim -m 2000 -b 0x0 -e $victim_slice -z -l 12 -c $victim_core -i 250000 1>out.txt 2>&1 &
perf_pid=$!
sleep .060
#pgrep BkPLLVictim
victim_pid=$(pgrep BkPLLVictim)
echo $victim_pid

if [ -z "$victim_pid" ]; then
    killall -9 perf
    killall -9 BkPLLVictim
    continue
else 
    echo $victim_pid > /sys/fs/cgroup/palloc/part1/cgroup.procs
    wait $perf_pid
    llc_miss_rate=$(grep "LLC-load-misses" out.txt |awk '{match($0, /([0-9]+\.[0-9]+)%/, arr); print arr[1]}')
    echo "LLC Miss rate: $llc_miss_rate"
fi

# We do not want to record this test data if the LLC miss rate is what is causing the slowdown
if echo "$llc_miss_rate < 1.00" | bc -l | grep -q '^1'; then
    break
fi
done

bw=$(grep "bandwidth" out.txt | awk '{ print $2 }')
echo "$corun,$victim_core,$victim_slice,$attacker_slice,$bw" >> stats.txt
echo -e "\nVictim done....."


echo "killing co-runners"
killall -9 BkPLL
