import matplotlib.pyplot as plt


base_bandwidth = {}
withCorun_bandwidth = {}

def ParseData(arr):
    for dp in arr:
        co = dp[0]
        victim_core = dp[1]
        victim_slice = dp[2]
        attacker_slice = dp[3]
        bw = dp[4]
        key = victim_core + "~" + victim_slice
        if co == 'no':
            base_bandwidth[key] = float(bw)
        else:
            if key not in withCorun_bandwidth: # key doesnt yet exist
                withCorun_bandwidth[key] = {}
            withCorun_bandwidth[key][attacker_slice] = float(bw)
            

lines = []
data = []
with open("./stats.txt", "r") as f:
    lines = f.readlines()
     
for line in lines:
    data_point  = line.strip().split(",")
    data.append(data_point)

ParseData(data)


    
print(base_bandwidth)
print(withCorun_bandwidth)
fig, axs = plt.subplots(4, 4, figsize=(20, 10))

for key in withCorun_bandwidth:
    victim_core = key[0]
    victim_slice = key[2]

    x_index = int(victim_core)
    y_index = int(victim_slice)
    

    x_attacker_slices = list(withCorun_bandwidth[key].keys())
    y_bandwidths = list(withCorun_bandwidth[key].values())
    print(f"{x_index}, {y_index}, {y_bandwidths}")
    axs[x_index, y_index].plot(x_attacker_slices, y_bandwidths)
    axs[x_index, y_index].set_ylim(0, 100000)
    axs[x_index, y_index].set_title(f"VictimCore={victim_core} VictimSlice={victim_slice}")
    axs[x_index, y_index].set_xlabel('Attacker Slice Target')
    axs[x_index, y_index].set_ylabel('Victim Bandwidth(MB/s)')

    # Save the plot
    #plt.savefig('plot.png')  # Save as PNG file

plt.tight_layout()
plt.show()
    