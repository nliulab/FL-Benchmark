import os, sys, time

directory = sys.argv[1]
s = os.path.basename(os.path.normpath(directory)).split(".")
p = int(s[0].split("_")[1])
k = int(s[-1].split("_")[1])

config = "clients = {}\nfeatures = {}\nsocket = 2828\n".format(k, p + 1)

f = open("server_config", "w")
f.write(config)
f.close()

output = "output_glore.txt"

cmd = "start /min java -cp Jama-1.0.2.jar:. Server > {}".format(os.path.join(directory, output))
#cmd = "start /B java -cp Jama-1.0.2.jar:. Server > {}".format(os.path.join(directory, output))
os.system(cmd)
print(cmd)

time.sleep(20)

for filename in os.listdir(directory):
    if filename == output:
        continue
    f = os.path.join(directory, filename)
    cmd = "start /min java -cp Jama-1.0.2.jar:. Client {}".format(f)
    os.system(cmd)
    print(cmd)