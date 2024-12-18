import os, sys, re
import ast

def extract_coefficient(path):
    print(path)
    dir, filename = os.path.dirname(path), os.path.basename(path)
    with open(path, 'r') as f:
        lines = f.readlines()
        coef = []
        for i, line in enumerate(lines):
            if not line:
                continue
            elif "evaluating" in line:
                start = 1
                while not 'array' in lines[i+start]:
                    start += 1
                end = 1
                while not (')]' in lines[i+end] and 'array' in lines[i+end]):
                    end += 1
                coef = lines[i + start:i + end + 1]
                coef = [x.strip().strip('\n') for x in coef]
                #Low Dim
                coef = eval(''.join(coef).replace('array', '').replace('(', '').replace(')', ''))

                #High Dim
                # coef_str = ''.join(coef)            
                # start_index = coef_str.find('[array(')  
                # end_index = coef_str.find('])]') + len('])]')  
                # coef_str = coef_str[start_index:end_index]       
                # coef_str = coef_str.replace('array', '').replace('(', '').replace(')', '')

                # try:
                #     coef = ast.literal_eval(coef_str)
                # except (SyntaxError, ValueError) as e:
                #     print(f"Error parsing coefficients: {e}")
                #     coef = [] 
            

    out_filename = 'coef_flwr_fedavg.txt'
    with open(os.path.join(dir, out_filename), 'w') as f:
        f.write('Coef:\n')
        for x in coef[0]:
            f.write(str(x) + '\n')
        f.write('Bias:\n' + str(coef[1][0]))


if __name__ == "__main__":
    in_path = sys.argv[1]
    for root, dirs, files in os.walk(in_path):
        for file in files:
            if file == 'output_flwr_fedavg.txt':
                extract_coefficient(os.path.join(root, file))