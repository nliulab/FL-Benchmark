import os
import sys

def main():
    in_path = sys.argv[1]
    if not os.path.exists('../FedProx/data'):
        os.mkdir('../FedProx/data')
    if not os.path.exists('../FedProx/data/simulated'):
        os.mkdir('../FedProx/data/simulated')
    for root, dirs, files in os.walk(in_path):
        for file in files:
            if 'seed' in root:
                seed = root.split('_')[-1]
                if file.startswith('train.json'):
                    source_path = os.path.join(root, file)
                    dataset = str(source_path.split('/')[4])
                    target_path = os.path.join('..', 'FedProx', 'data', 'simulated', dataset, 'train_' + seed)
                    if not os.path.exists(target_path):
                        os.system('mkdir ' + os.path.join('..', 'FedProx', 'data', 'simulated', dataset))
                        os.system('mkdir ' + os.path.join('..', 'FedProx', 'data', 'simulated', dataset, 'train_' + seed))
                    cmd = 'cp ' + source_path + ' ' + target_path
                    print(cmd)
                    os.system(cmd)
                if file.startswith('test.json'):
                    source_path = os.path.join(root, file)
                    dataset = str(source_path.split('/')[4])
                    target_path = os.path.join('..', 'FedProx', 'data', 'simulated', dataset, 'test_' + seed)
                    if not os.path.exists(target_path):
                        os.system('mkdir ' + os.path.join('..', 'FedProx', 'data', 'simulated', dataset, 'test_' + seed))
                    cmd = 'cp ' + source_path + ' ' + target_path
                    print(cmd)
                    os.system(cmd)

if __name__ == '__main__':
    main()