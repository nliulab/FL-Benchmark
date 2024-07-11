import re
import os
import sys

def extract_fedprox_coef(path):
    print(path)
    dir, filename = os.path.dirname(path), os.path.basename(path)
    with open(path, 'r') as f:
        coef = []
        lines = f.readlines()
        iter = extract_fedprox_iteration(path)
        for i, line in enumerate(lines):
            if 'At round ' + str(iter) + ' model param' in line:
                coef = lines[i+1:]
                coef = [x.strip('\n').strip() for x in coef]
                coef = eval(''.join(coef).replace('array', '').replace('(', '').replace(')', ''))
    if dir.split('/')[0] == 'simulated':
        out_dir = ['../../data/simulated'] + dir.split('/')[1:]
        out_dir[2] = 'p_8.s_6.K_3_' + out_dir[2]
    elif dir.split('/')[0] == 'simulated_HD':
        out_dir = ['../../data/simulated_HD'] + dir.split('/')[1:]
        out_dir[2] = 'p_100.s_6.K_3_' + out_dir[2]
    else:
        raise ValueError("Only 'simulated' and 'simulated_HD' are supported directories")
    out_dir = '/'.join(out_dir)
    out_filename = 'coef_' + filename.replace('/', '_') + '.txt'
    with open(os.path.join(out_dir, out_filename), 'w') as f:
        f.write('Coef:\n')
        for x in coef[0]:
            f.write(str(x) + '\n')
        f.write('Bias:\n' + str(coef[1]))


def extract_fedprox_iteration(path):
    iter = 0
    with open(path) as f:
        lines = f.readlines()
        for line in lines:
            if 'At round' in line:
                iter = re.findall('\d+', line)
                iter = [int(x) for x in iter]
                iter = iter[0]
    return iter


def main():
    in_path = sys.argv[1]
    for root, dirs, files in os.walk(in_path):
        for file in files:
            if file.startswith('fed'):
                extract_fedprox_coef(os.path.join(root, file))

if __name__ == '__main__':
    main()
