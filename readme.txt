See the web page which is also a work in progress https://logrewind.wordpress.com

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

# Install pip if not already present in virtual env
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py

# Update pip
pip install -U pip

pip install opencv-python
pip install scikit-image
pip install imutils

Normal use
1. open ContextLogger.app
2. start recording using the first status menu item
3. allow accessibility access, screen recording access and documents folder access (first run only)
4. do the sequence you want to record
5. stop the ContextLogger in GUI
6. open OutputImageFolder folder under ~/Documents

repeat :)





