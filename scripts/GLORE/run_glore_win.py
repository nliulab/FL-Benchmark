import os, sys
import time


def list_data_dir(filepath):
   commands = []
   for root, dirs, files in os.walk(filepath):
       if 'seed' in root:
           cmd = 'python FL_run_Windows.py ' + root
           print(cmd)
           commands.append(cmd)
           os.system(cmd)
           time.sleep(5)
   return commands


def main():
    data_root = sys.argv[1]
    list_data_dir(data_root)


if __name__ == '__main__':
    main()