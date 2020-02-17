The generated screenshots will be placed under the folder
/Users/<username>/Library/Application Support/dk.logging.Logger/
Get then to the input folder using the getInputFiles.sh script

During development it is needed to give access to ContextLogger under accessibility


postProcessing.sh runs the python scripts needed to post process the recorded sequence of images

dot.py is handling all the mouse clicks
generateImageDiffs.py is generating the bounding boxes around changes between start and end of character sequences



Installation

Install Anaconda from
https://www.anaconda.com/distribution/#download-section


To do this OpenCV is used via an Anaconda virtual environment which is created/activated in the following way:
conda create -n logger python=3
conda activate logger

pip install opencv-python
pip install scikit-image
pip install imutils

Normal use
1. open ContextLogger.app
2. start recording using the first status menu item
3. do the sequence you want to record
4. stop the ContextLogger in GUI
5. open OutputImageFolder folder under ~/Documents

repeat :)





