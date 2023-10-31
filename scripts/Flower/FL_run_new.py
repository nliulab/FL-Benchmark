import os, sys, time
from multiprocessing import Process, freeze_support

directory = sys.argv[1]
s = os.path.basename(os.path.normpath(directory)).split(".")
p = int(s[0].split("_")[1]) # number of variables for LR
k = int(s[-1].split("_")[1]) # number of clients

# config = "clients = {}\nfeatures = {}\nsocket = 2828\n".format(k, p + 1)

# f = open("server_config", "w")
# f.write(config)
# f.close()

# output = "output_glore.txt"

# cmd = "nohup java -cp Jama-1.0.2.jar:. Server > {} 2>&1 &".format(os.path.join(directory, output))
# os.system(cmd)
# print(cmd)

# time.sleep(1)

# for filename in os.listdir(directory):
#     if filename == output:
#         continue
#     f = os.path.join(directory, filename)
#     cmd = "nohup java -cp Jama-1.0.2.jar:. Client {} >/dev/null 2>&1 &".format(f)
#     os.system(cmd)
#     print(cmd)


### strategy1: fedavg
output = "output_flwr_fedavg.txt"
#cmd = "python server_fedavg.py {} > {}".format(directory, os.path.join(directory, output))
cmd = "python server_fedavg.py {}".format(directory)
# os.system(cmd)

# time.sleep(1)
# loop through all files in the directory:
cmds = [cmd]
for filename in os.listdir(directory):
    if "Site" not in filename or 'Coef' in filename:
        continue
    cmd = "python client.py {} {}".format(directory, filename)
    cmds.append(cmd)
    # os.system(cmd)
    # subprocess.run(cmd, shell=True)

if __name__ == "__main__":
    freeze_support()
    for command in cmds:
        print(command)
        p = Process(target=os.system(command),args=(command,))
        print("processing start")
        p.start()
        
    p.join()
    print("processing over")
