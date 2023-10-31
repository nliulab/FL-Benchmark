import os, sys, time, re

directory = sys.argv[1]
s = os.path.basename(os.path.normpath(directory)).split(".")
print(s)
p = int(s[0].split("_")[1])
k = int(s[-1].split("_")[1])

config = "clients = {}\nfeatures = {}\nsocket = 2828\n".format(k, p + 1)

with open("server_config", "w") as f:
    f.write(config)

output = "output_glore.txt"

# os.system("pkill -f java")
cmd = "nohup java -cp Jama-1.0.2.jar:. Server > {} 2>&1 &".format(os.path.join(directory, output))
os.system(cmd)
print(cmd)

time.sleep(1)

for filename in os.listdir(directory):
    if not re.match(r'^Site[0-9]+.train.*', filename):
        continue
    f = os.path.join(directory, filename)
    cmd = "nohup java -cp Jama-1.0.2.jar:. Client {} > /dev/null 2>&1 &".format(f)
    os.system(cmd)
    print(cmd)