#!/bin/bash

# palloc mask for pi5 cache partitioning
# L2 Cache: 256KB, 4way, 64byte cache lines (https://developer.arm.com/documentation/100798/0401/L2-memory-system/About-the-L2-memory-system)
# L3 cache: 4*1.5MB, 12way, 64byte
# L2 Set bits --> (2^18)/((2^2)(2^6)) = 10 bits
# L3 Set bits --> 1.5mb/((12)(2^6)) = 11 bits 
# 1 bit can be used to partition L3 --> Bit16



echo 0x70000 > /sys/kernel/debug/palloc/palloc_mask


#Create partitions
cgcreate -g palloc:part1
cgcreate -g palloc:part2
cgcreate -g palloc:part3
cgcreate -g palloc:part4
cgcreate -g palloc:part5
cgcreate -g palloc:part6
cgcreate -g palloc:part7
cgcreate -g palloc:part8

#Assign bins to partitions
echo 0-6 > /sys/fs/cgroup/palloc/part1/palloc.bins 
echo 7 > /sys/fs/cgroup/palloc/part2/palloc.bins
echo 0-1 > /sys/fs/cgroup/palloc/part3/palloc.bins

echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo 8 > /sys/kernel/debug/palloc/alloc_balance # wait until at least 8 colors are in the color cache
echo 1 > /sys/kernel/debug/palloc/use_palloc