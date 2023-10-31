import os, sys, re

def extract_coefficient(path):
    print(path)
    dir, filename = os.path.dirname(path), os.path.basename(path)
    with open(path, 'r') as f:
        lines = f.readlines()
        coef = []
        for i, line in enumerate(lines):
            if not line:
                continue
            elif 'array([[' in line:
                end = i
                while not (')]' in lines[end] and 'array' in lines[end]):
                    end += 1
                coef_line = lines[i:end+2]
                coef_line = [x.strip().replace('\n', '').replace('\r', '') for x in coef_line]
                pattern = r'array\(\[(.*?)\)\]'
                matches = re.findall(pattern, ''.join(coef_line))
                coef = re.findall(r'\[.*?\]',''.join(matches))
    out_filename = 'coef_flwr_Qfedavg.txt'
    with open(os.path.join(dir, out_filename), 'w') as f:
        f.write('Coef:\n' + str(coef[0]) + '\n')
        f.write('Bias:\n' + str(eval(coef[2])[0]))


if __name__ == "__main__":
    in_path = sys.argv[1]
    for root, dirs, files in os.walk(in_path):
        for file in files:
            if file == 'output_flwr_Qfedavg.txt':
                extract_coefficient(os.path.join(root, file))