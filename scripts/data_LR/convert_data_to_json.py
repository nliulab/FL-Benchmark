import pandas as pd
import json
import os
import re
import sys


def get_fin_data(file):
        all_data = {}
        num_sample = []
        users = []
        for file_name in file:
            file_path = os.path.join(fin_path,file_name)
            output = to_dict(file_path)
            file_data = output[0]
            #num_sample
            match = re.search(r'N_(\d+)', file_name)
            num_from_name = int(match.group(1))
            if num_from_name == output[1]:
                num_sample.append(output[1])
            else:
                print("Error: num_sample not match")
                print("Please double check simulated data.")
                return
            site_name = re.sub(r'\..*$', '', file_name)
            if not site_name[4:].isnumeric():
                continue
            users.append(site_name)
            all_data.update({site_name: file_data})
        if len(num_sample) == 4:
            num_sample = num_sample[:-1]
        fin_data = {}
        fin_data.update({'num_sample': num_sample, 'users': users, 'user_data': all_data})
        return fin_data

def to_dict(file_path):
        input = pd.read_csv(file_path)
        num_sample = input.shape[0]
        x_data = input.drop('y', axis=1)
        output = {}
        output['y'] = input['y'].values.tolist()
        output['x'] = x_data.values.tolist()
        return output, num_sample


if __name__ == '__main__':
    in_data_path = sys.argv[1]
    folders = [folder for folder in os.listdir(in_data_path) if os.path.isdir(os.path.join(in_data_path, folder))]

    for folder_name in folders:
        data_path = os.path.join(in_data_path, folder_name)
        # get total number of seeds in the folder:
        seed_sum = 0
        for root, dirs, files in os.walk(data_path):
             if 'seed' in root:
                seed_sum = seed_sum + 1
        # for each folder, loop through all seeds
        for seed in range(seed_sum):
            fin_path = os.path.join(data_path, os.listdir(data_path)[seed])
            pattern = r'^(?=.*csv)(?!.*Coef).*'
            data_file = [file for file in os.listdir(fin_path) if re.match(pattern, file)]
            train_data = [file for file in data_file if file.find('train') != -1]
            test_data = [file for file in data_file if file.find('test') != -1 and 'DAC' not in file]

            fin_train_data = get_fin_data(train_data)
            json_str = json.dumps(fin_train_data)
            with open(os.path.join(fin_path, 'train.json'), 'w') as json_file:
                json_file.write(json_str)
            fin_test_data = get_fin_data(test_data)
            json_str = json.dumps(fin_test_data)
            with open(os.path.join(fin_path, 'test.json'), 'w') as json_file:
                json_file.write(json_str)
