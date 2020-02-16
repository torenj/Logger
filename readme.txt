The generated screenshots will be placed under the folder
/Users/<username>/Library/Application Support/dk.logging.Logger/
Get then to the input folder using the getInputFiles.sh script

During development it is needed to give access to ContextLogger under accessibility

To postprocess the images the python scripts needs to be run
dot.py is handling all the mouse clicks
generateImageDiffs.py is generating the bounding boxes around changes between start and end of character sequences
