import cv2
import os
import re
import fnmatch

listOfFiles = os.listdir('./input')
pattern = "*mouseDown*.jpg"
regex_pattern = '{mouseDown\\((.*),(.*)\\)}'

for entry in filter(lambda file: fnmatch.fnmatch(file, pattern), listOfFiles):
    match = re.search(regex_pattern, entry, re.IGNORECASE)
    x, y = map(int, match.groups())
    image_path = os.path.join('./input', entry)
    image = cv2.imread(image_path)
    height, _, _ = image.shape
    cv2.circle(image, (x * 2, height - y * 2), 25, (0, 0, 255), 5)
    cv2.imwrite(os.path.join('./output', entry), image)
    
print("dots processed")
