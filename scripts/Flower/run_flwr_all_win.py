import os, sys
import time


def list_data_dir(filepath):
   for root, dirs, files in os.walk(filepath):
       if 'seed' in root:
           cmd = 'python FL_run_win.py ' + root
           print(cmd)
           os.system(cmd)
           time.sleep(10)


def main():
    data_root = sys.argv[1]
    list_data_dir(data_root)


if __name__ == '__main__':
    main()