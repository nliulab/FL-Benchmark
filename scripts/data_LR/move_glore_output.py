import os
import sys

def list_output_files(path):
    cnt = 0
    for root, dirs, files in os.walk(path):
        for file in files:
            if 'glore' in file.lower():
                cnt += 1
                old_path = os.path.join(root, file)
                if not os.path.exists('../GLORE/output/'):
                    os.mkdir('../GLORE/output/')
                new_path = os.path.join('..', 'GLORE', 'output', root)
                if not os.path.exists(new_path):
                    os.mkdir(new_path)
                cmd = 'cp ' + old_path + ' ' + new_path
                print(cmd)
                os.system(cmd)
    print(cnt)

def main():
    directory = sys.argv[1]
    list_output_files(directory)


if __name__ == '__main__':
    main()