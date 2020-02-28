import glob
import os

resourcesPath = '../dist/'

downloaded_wadls = glob.glob(resourcesPath + '*.jar')
for wadl_path in downloaded_wadls:
    os.system("java -jar " + wadl_path)
    # wadl_name = wadl_path.replace(resourcesPath, '').replace('.wadl', '')
    # with open(resourcesPath + wadl_name + '.info', 'w') as fin:
    #     fin.write(wadl_name + '\n' + wadl_name.title() + '\nTool description.')
