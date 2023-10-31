import os
import sys
import itertools
from concurrent.futures import ThreadPoolExecutor, as_completed
import tensorflow._api.v2.compat.v1 as tf
tf.disable_v2_behavior()


def main():
    subdataset = sys.argv[1]
    folder_name = os.path.join(os.getcwd(), 'simulated', subdataset)

    # check if folder already exists
    if not os.path.exists(os.path.join(os.getcwd(), 'simulated')):
        os.mkdir(os.path.join(os.getcwd(), 'simulated'))
    if not os.path.exists(folder_name):
        # create folder if it doesn't exist
        os.mkdir(folder_name)
        print("Folder created: ", folder_name)
    else:
        print("Folder already exists: ", folder_name)

    # get number of seeds
    main_path = os.path.join('../../data/simulated', subdataset)
    # get total number of seeds in the folder:
    seed_sum = 0
    for root, dirs, files in os.walk(main_path):
         if 'seed' in root:
            seed_sum = seed_sum + 1
    seed_sum = int(seed_sum * 0.5)
    print(main_path)
    print(seed_sum)

    # do parallel:
    with ThreadPoolExecutor() as executor:
        futures = []
        for seed in range(1, seed_sum+1):
            futures.append(executor.submit(tune_fedprox_oneseed, subdataset, seed))
        for future in as_completed(futures):
            try:
                result = future.result()
                print(result)
            except Exception as e:
                print(f'Error occurred: {e}')


def tune_fedprox_oneseed(dataset, seed):
    lr_options = [0.01]
    mu_options = [0]
    grid = list(itertools.product(lr_options, mu_options))
    subfolder = dataset + '/seed' + str(seed)
    folder_name = os.path.join(os.getcwd(), 'simulated', subfolder)
     # check if folder already exists
    if not os.path.exists(folder_name):
        # create folder if it doesn't exist
        os.mkdir(folder_name)
        print("Folder created: ", folder_name)
    else:
        print("Folder already exists: ", folder_name)
    
    for lr, mu in grid:
        cmd = 'python3 -u main.py --dataset=simulated --optimizer=\'fedprox\' --learning_rate={} --num_rounds=10 --clients_per_round=3 ' \
                  '--eval_every=1 --batch_size=10 --num_epochs=20 --drop_percent=0 --model=\'mclr\' --mu={} --folder={} --folderSeed={}' \
              '| tee simulated/{}/fedprox_lr{}_drop0_mu{}'.format(lr, mu, dataset, seed, subfolder, lr, mu)
        os.system(cmd)


if __name__ == '__main__':
    main()


