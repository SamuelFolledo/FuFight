import os
import shutil
import subprocess
import sys
import zipfile

from enum import Enum
from os.path import abspath, expanduser


try:
    from subprocess import DEVNULL  # python3
except ImportError:
    DEVNULL = open(os.devnull, 'wb')

# Custom Files
from mixamoToXcode import *
from Logger import *

#----------------------------------------------------------------------------------------------------------------
############################################### CUSTOMIZABLE SETTINGS ###########################################
#----------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------
#################################################### Objects ####################################################
#----------------------------------------------------------------------------------------------------------------


#----------------------------------------------------------------------------------------------------------------
#################################################### Methods ####################################################
#----------------------------------------------------------------------------------------------------------------
def validateAndGetInput():
    """Validates inputs and returns the path to convert and new animation name"""
    userPath = expanduser("~/")
    # Defaults to converting user's Downloads folder if path is not provided
    pathToConvert = ""
    newAnimationName = ""
    if len(sys.argv) != 2 and len(sys.argv) != 3:
        LOGE("Error Usage: python3 mixamoAnimToXcode.py <dae_or_zip_file> <optional_new_animation_name>")
        LOGW("Running this script requires 1-2 additional parameters")
        sys.exit(1)
    if len(sys.argv) > 2:
        # print(f"Converting .dae files in folder: {pathToConvert}") 
        pathToConvert = sys.argv[1]
        newAnimationName = sys.argv[2]
    else: 
        pathToConvert = sys.argv[1]
        newAnimationName = getNameFromPath(pathToConvert)
    if not exist(pathToConvert):
        LOGE(f"Path to convert does not exist {pathToConvert}")
        sys.exit(1)
    LOGA(f"Converting {pathToConvert} and renaming to {newAnimationName}")
    return pathToConvert, newAnimationName

def unzipDae(daePath):
    """Unzips daePath and returns the unzipped dae file's path"""
    if not getExtensionFromPath(daePath) == ".zip":
        LOGE(f"Failed to unzip path: {daePath}")
    unzipFile(daePath, isOneFile=True)
    folderName = getFolderFromPath(daePath)
    unzippedDaePath = f"{folderName}/{getNameFromPath(daePath)}.dae"
    LOGA(f"Unzipped dae path {unzippedDaePath}")
    return unzippedDaePath

def prepareAnimation(unzippedDaePath, newAnimationName):
    """Renames the daePath if needed, runs the workflow script, and delete unneeded .dae"""
    # Run the ConvertToXcodeCollada script and delete the unneeded .dae file
    executeConvertToXcodeColladaWorkflow(unzippedDaePath)
    # Rename the unzipped dae if needed
    folderName = getFolderFromPath(unzippedDaePath)
    isNewNameEmpty = len(newAnimationName) == 0
    daePath = unzippedDaePath if isNewNameEmpty else f"{folderName}/{newAnimationName}.dae"
    if not isNewNameEmpty or (unzippedDaePath != daePath and isNewNameEmpty):
        renamePath(unzippedDaePath, daePath)
        LOGD(f"Renamed unzipped dae from: {unzippedDaePath} to {daePath}")
    LOG(f"Completed preparing animation from: {unzippedDaePath} to {daePath}")

#----------------------------------------------------------------------------------------------------------------
#################################################### Main #######################################################
#----------------------------------------------------------------------------------------------------------------
if __name__ == "__main__":
    """
    Must have ConvertToXcodeCollada in Desktop/StreamCodes/scripts/ConvertToXcodeCollada/ConvertToXcodeCollada.workflow

    Execute by
    1. If zip file is passed, unzip and convert into a usable .dae file
        python3 "mixamoAnimToXcode.py" <path_to_zip> <optional_new_name>
        e.g. python3 "mixamoAnimToXcode.py" '~/Downloads/Hard Head Nod.zip' idleStand
    2. If folder is passed, unzip the contents and convert into a usable .dae files
        python3 "mixamoAnimToXcode.py" <path_to_folder>
        e.g. python3 "mixamoAnimToXcode.py" '~/Downloads/samuel/animations'
    """
    pathToConvert, newAnimationName = validateAndGetInput()
    if isFolder(pathToConvert):
        # If folder, then get all zip files to unzip
        folderName = getNameFromPath(pathToConvert)
        for filename in os.listdir(pathToConvert):
            filePath = os.path.join(pathToConvert, filename)
            # checking if it is a file
            if os.path.isfile(filePath):
                # Handle zip file
                if getExtensionFromPath(filePath) == ".zip":
                    # Unzip file and get the unzipped .dae file
                    unzippedDaePath = unzipDae(filePath)
                    prepareAnimation(unzippedDaePath, "")

    else:
        # Handle zip file
        if getExtensionFromPath(pathToConvert) == ".zip":
            # Unzip file and get the unzipped .dae file
            unzippedDaePath = unzipDae(pathToConvert)
            prepareAnimation(unzippedDaePath, newAnimationName)
    LOG(f"✅✅✅")
