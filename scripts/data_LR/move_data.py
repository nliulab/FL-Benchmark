import os
import sys

def main():
    data_type = sys.argv[1]
    in_path = sys.argv[2]
    if not os.path.exists('../FedProx/data'):
        os.mkdir('../FedProx/data')
    if not os.path.exists(f'../FedProx/data/{data_type}'):
        os.mkdir(f'../FedProx/data/{data_type}')
    for root, dirs, files in os.walk(in_path):
        for file in files:
            if 'seed' in root:
                seed = root.split('_')[-1]
                if file.startswith('train.json'):
                    source_path = os.path.join(root, file)
                    dataset = str(source_path.split('/')[4])
                    target_path = os.path.join('..', 'FedProx', 'data', data_type, dataset, 'train_' + seed)
                    if not os.path.exists(target_path):
                        os.mkdir(os.path.join('..', 'FedProx', 'data', data_type, dataset))
                        os.mkdir(os.path.join('..', 'FedProx', 'data', data_type, dataset, 'train_' + seed))
                    cmd = 'cp ' + source_path + ' ' + target_path
                    print(cmd)
                    os.system(cmd)
                if file.startswith('test.json'):
                    source_path = os.path.join(root, file)
                    dataset = str(source_path.split('/')[4])
                    target_path = os.path.join('..', 'FedProx', 'data', data_type, dataset, 'test_' + seed)
                    if not os.path.exists(target_path):
                        os.mkdir(os.path.join('..', 'FedProx', 'data', data_type, dataset, 'test_' + seed))
                    cmd = 'cp ' + source_path + ' ' + target_path
                    print(cmd)
                    os.system(cmd)

if __name__ == '__main__':
    main()