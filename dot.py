import cv2

import os, fnmatch
import re

listOfFiles = os.listdir('.')
pattern = "*mouseDown*.jpg"
for entry in listOfFiles:
    if fnmatch.fnmatch(entry, pattern):
        print (entry)
        x = re.search('{mouseDown\((.*),(.*)\)}', entry, re.IGNORECASE).group(1)
        y = re.search('{mouseDown\((.*),(.*)\)}', entry, re.IGNORECASE).group(2)
        image = cv2.imread(entry)
        cv2.circle(image,(int(x), int(y)), 25, (0,0,255),3)
        cv2.imwrite('./output/'+entry,image)

