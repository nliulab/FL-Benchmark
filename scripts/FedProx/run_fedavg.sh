#!/usr/bin/env bash
python3  -u main.py --dataset=$1 --optimizer='fedavg' --learning_rate=0.01 --num_rounds=20 --clients_per_round=3 --eval_every=1 --batch_size=10 --num_epochs=20 --model='mclr' --drop_percent=0 --folder=differentX_mean_0.1_sd_0.8_1.2 --folderSeed=p_8.s_6.K_3_seed1
