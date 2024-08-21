#!/bin/bash


rm ./stats.txt

# solo runs
for victim_core in 0 1 2 3; do
	for victim_slice in 0 1 2 3; do
		./test.sh no $victim_core $victim_slice -1
	done
done



for victim_core in 0 1 2 3; do
	for victim_slice in 0 1 2 3; do
		for attacker_slice in 0 1 2 3; do
			./test.sh co $victim_core $victim_slice $attacker_slice
		done
	done
done
