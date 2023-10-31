import os, sys, time

def extract_data_dir(filepath):
   for root, dirs, files in os.walk(filepath):
       if 'output_glore.txt' in files:
           cmd = 'python3 extract_glore.py ' + root
           print(cmd)
           os.system(cmd)
           time.sleep(1)


def main():
    data_root = sys.argv[1]
    extract_data_dir(data_root)


if __name__ == '__main__':
    main()