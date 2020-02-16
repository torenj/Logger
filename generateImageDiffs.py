import os, fnmatch
import re
from skimage.measure import compare_ssim
import imutils
import cv2

listOfFiles = sorted(os.listdir('./input'))
pattern = "*.jpg"
characters = []
markNext = False
previousEntry = ""
imageTuples = []
for entry in listOfFiles:
    if fnmatch.fnmatch(entry, pattern):
        if markNext and not "mouseDown" in entry:
            print("mark first:"+entry)
            imageTuples.append(("first",entry))
            markNext = False
        if not markNext and "mouseDown" in entry:
            print("mark last:"+previousEntry)
            imageTuples.append(("last",previousEntry))
            markNext = True
        print (entry)
        previousEntry = entry
        char = ''
        if "mouseDown" in entry:
            char = 'mouseDown'
            markNext = True
        else:
            char = re.search('{(.*)}', entry, re.IGNORECASE).group(1)
        characters.append(char)

if imageTuples[0][0] == "last":
    del imageTuples[0]
imagePairs = []
pairIndex = 0
firstEntry = ""
for (i,tuple) in enumerate(imageTuples):
    print(tuple)
    if i % 2 == 0:
        firstEntry = tuple[1]
    else:
        imagePairs.append((firstEntry,tuple[1]))
print(imagePairs)
for (i,(firstImage,lastImage)) in enumerate(imagePairs):
    imagePath1 = "./input/"+firstImage
    imagePath2 = "./input/"+lastImage
    print(imagePath2)
    # load the two input images
    imageA = cv2.imread(imagePath1)
    imageB = cv2.imread(imagePath2)
    print(imageB.dtype)

    # convert the images to grayscale
    grayA = cv2.cvtColor(imageA, cv2.COLOR_BGR2GRAY)
    grayB = cv2.cvtColor(imageB, cv2.COLOR_BGR2GRAY)

    # compute the Structural Similarity Index (SSIM) between the two
    # images, ensuring that the difference image is returned
    (score, diff) = compare_ssim(grayA, grayB, full=True)
    diff = (diff * 255).astype("uint8")
    print("SSIM: {}".format(score))

    # threshold the difference image, followed by finding contours to
    # obtain the regions of the two input images that differ
    thresh = cv2.threshold(diff, 0, 255, cv2.THRESH_BINARY_INV | cv2.THRESH_OTSU)[1]
    cnts = cv2.findContours(thresh.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    cnts = imutils.grab_contours(cnts)

    # loop over the contours
    for c in cnts:
        # compute the bounding box of the contour and then draw the
        # bounding box on both input images to represent where the two
        # images differ
        (x, y, w, h) = cv2.boundingRect(c)
        cv2.rectangle(imageA, (x, y), (x + w, y + h), (0, 0, 255), 2)
        cv2.rectangle(imageB, (x, y), (x + w, y + h), (0, 0, 255), 2)
    print(lastImage[:23])
    cv2.imwrite("./output/"+lastImage[:22]+"_diff"+str(i)+".jpg",imageB)