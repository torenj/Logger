import cv2
import os, fnmatch
import re

listOfFiles = os.listdir('./input')
pattern = "*mouseDown*.jpg"
for entry in listOfFiles:
    if fnmatch.fnmatch(entry, pattern):
        x = re.search('{mouseDown\((.*),(.*)\)}', entry, re.IGNORECASE).group(1)
        y = re.search('{mouseDown\((.*),(.*)\)}', entry, re.IGNORECASE).group(2)
        image = cv2.imread('./input/'+entry)
        height, width, channels = image.shape
        xOnImage = int(x) * 2
        yOnImage = int(y) * 2
        cv2.circle(image,(int(xOnImage), int(height-yOnImage)), 25, (0,0,255),5)
        cv2.imwrite('./output/'+entry,image)
print("dots processed")
