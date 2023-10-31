import os, sys, re
import pandas as pd


def extract_covariance(input_file):
    flist = open(input_file).readlines()
    cov = []

    parsing = False
    for line in flist:
       if "Covariance" in line:
           parsing = True
       elif "SD" in line:
           parsing = False
       if not line:
           continue
       if parsing:
           splitted = re.findall("-?\d+\.\d+", line)
           if splitted:
            cov.append(splitted)
    cov = pd.DataFrame(cov)
    cov.to_csv(os.path.join(directory,'Cov_glore.csv'), index=False)
    return cov


def extract_iterations(input_file):
    flist = open(input_file).readlines()
    iter = 0
    for line in flist:
        if "Iteration" in line:
            iter = re.findall('\d+', line)
            iter = [int(x) for x in iter]
            iter = iter[0]
    return iter


def extract_coef(input_file):
    flist = open(input_file).readlines()
    coef = []
    iter = extract_iterations(input_file)

    parsing = False
    for line in flist:
       if "Iteration {}".format(iter) in line:
           parsing = True
       elif "comp: releasing beta1 lock for iter {}".format(iter) in line:
           parsing = False
       if not line:
           continue
       if parsing:
           coef_temp = re.findall("-?\d+\.\d+", line)
           if coef_temp:
            coef.append(coef_temp)
    coef = pd.DataFrame(coef)
    coef.to_csv(os.path.join(directory, 'Coef_glore.csv'), index=False, header=False)

    with open(os.path.join(directory, 'Coef_glore.csv'), 'a') as f:
        f.write('Iterations: ' + str(iter) + '\n')
    return coef


directory = sys.argv[1]
# s = os.path.basename(os.path.normpath(directory)).split(".")
# p = int(s[0].split("_")[1])
# k = int(s[-1].split("_")[1])

f = os.path.join(directory, "output_glore.txt")
extract_coef(f)
extract_covariance(f)


