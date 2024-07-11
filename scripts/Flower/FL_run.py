import os, sys, time

directory = sys.argv[1]
s = os.path.basename(os.path.normpath(directory)).split(".")
p = int(s[0].split("_")[1]) # number of variables for LR
k = int(s[-1].split("_")[1]) # number of clients

# ### strategy1: fedavg
output = "output_flwr_fedavg.txt"
cmd = "nohup python server_fedavg.py {} > {} 2>&1 &".format(directory, os.path.join(directory, output))
os.system(cmd)
print(cmd)

# ### strategy2: fedavgM
# output = "output_flwr_fedavgM.txt"
# cmd = "nohup python server_fedavgM.py {} > {} 2>&1 &".format(directory, os.path.join(directory, output))
# os.system(cmd)
# print(cmd)

# ## strategy3: Qfedavg
# output = "output_flwr_Qfedavg.txt"
# cmd = "nohup python server_Qfedavg.py {} > {} 2>&1 &".format(directory, os.path.join(directory, output))
# os.system(cmd)
# print(cmd)

# time.sleep(1)
# loop through all files in the directory:
for filename in os.listdir(directory):
    if "Site" not in filename or 'Coef' in filename or 'train' not in filename:
        continue
    cmd = "nohup python client.py {} {} >/dev/null 2>&1 &".format(directory, filename)
    os.system(cmd)
    print(cmd)

