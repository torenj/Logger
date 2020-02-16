import cv2

image = cv2.imread('./Test.jpg')
cv2.circle(image,(867, 398), 25, (0,0,255),3)
cv2.imwrite('/Users/Tore/Personal/Logger/TestOut.jpg',image)
