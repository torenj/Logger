import os, fnmatch
import re

listOfFiles = os.listdir('.')
pattern = "*mouseDown*.jpg"
for entry in listOfFiles:
    if fnmatch.fnmatch(entry, pattern):
        print (entry)
        latitude = re.search('{mouseDown\((.*),(.*)\)}', entry, re.IGNORECASE).group(1)
        longitude = re.search('{mouseDown\((.*),(.*)\)}', entry, re.IGNORECASE).group(2)
        print(latitude)
        print(longitude)
