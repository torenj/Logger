The generated screenshots will be placed under the folder
/Users/<username>/Library/Application Support/dk.logging.Logger/
Get then to the input folder using the getInputFiles.sh script

During development it is needed to give access to ContextLogger under accessibility

To postprocess the images the python scripts needs to be run
sh postProcessing.sh

dot.py is handling all the mouse clicks
generateImageDiffs.py is generating the bounding boxes around changes between start and end of character sequences

To do this OpenCV is used via an Anaconda virtual environment which is activated in the following way:
source activate logger

Installation

Install Anaconda from
https://www.anaconda.com/distribution/#download-section

conda create -n logger python=3
conda activate logger

pip install opencv-python
pip install scikit-image
pip install imutils

sh setupEnvironment.sh

Normal use
1. start ContextLogger
2. do the sequence
3. stop the ContextLogger
4. open terminal in the git workspace
5. sh getInputFiles.sh
6. sh postProcessing.sh
7. open output

repeat :)





