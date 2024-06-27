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
DELETE_TEXTURES = True #When True, it will delete animations with textures

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
        pathToConvert = sys.argv[1]
        newAnimationName = sys.argv[2]
    else:
        pathToConvert = sys.argv[1]
        # newAnimationName = getNameFromPath(pathToConvert)
    if not exist(pathToConvert):
        LOGE(f"Path to convert does not exist {pathToConvert}")
        sys.exit(1)
    LOGA(f"Converting {pathToConvert} and renaming to {newAnimationName}")
    return pathToConvert, newAnimationName

def prepareDaeAnimation(daePath, newAnimationName):
    """Unzips daePath and returns the unzipped dae file's path"""
    if not getExtensionFromPath(daePath) == ".zip":
        LOGE(f"Failed to unzip path: {daePath}")
    destinationPath = unzipFile(daePath, isAnimation=True)
    folderName = getFolderFromPath(daePath)
    isNewNameEmpty = len(newAnimationName) == 0
    zipName = getNameFromPath(daePath)
    daeName = zipName if isNewNameEmpty else newAnimationName
    unzippedDaePath = f"{destinationPath}/{zipName}.dae"
    # LOG(f"DATA are {destinationPath}\t{newAnimationName}={zipName}={daeName} ISSS {unzippedDaePath}")
    if zipName != daeName:
        #Rename animation name
        tempPath = f"{destinationPath}/{daeName}.dae"
        LOG(f"Renaming .dae file from {unzippedDaePath} to a custom name: {tempPath}")
        moveFile(unzippedDaePath, tempPath)
        unzippedDaePath = tempPath
    elif not exist(unzippedDaePath):
        #It will go here if zip file was renamed. It does not work due to extracting 
        #Fix by updating unzippedDaePath to the first .dae found
        LOG(f"Looking for dae in {destinationPath} becase {zipName}=={daeName}")
        for root, dirs, files in os.walk(destinationPath):
            for file in files:
                filePath = os.path.join(root, file)
                if getExtensionFromPath(filePath) == ".dae":
                    # unzippedDaePath = filePath
                    LOGD(f"Found the animation file at {filePath} and renaming to {unzippedDaePath}")
                    moveFile(filePath, unzippedDaePath)
                    break
            break

    if not exist(unzippedDaePath):
        LOGE(f"Missing dae file {unzippedDaePath} from {daePath}")
        sys.exit(1)
    #Handle animations with textures
    LOGA(f"Unzipped .dae file has textures for {unzippedDaePath}. Deleting unneeded texture files = {DELETE_TEXTURES}")
    if DELETE_TEXTURES:
        # Move .dae file to the parent folder and delete the folder
        finalDaePath = f"{folderName}/{daeName}.dae"
        moveFile(unzippedDaePath, finalDaePath)
        # Delete unneeded folder and zip file
        deleteAllFromPath(f"{folderName}/{zipName}")
        deleteAllFromPath(f"{folderName}/{zipName}.zip")
        LOGD(f"Finished moving unzipped .dae from {unzippedDaePath} into {finalDaePath} and deleted unneeded files")
        unzippedDaePath = finalDaePath            
    executeConvertToXcodeColladaWorkflow(unzippedDaePath)
    LOG(f"Finished preparing dae animations from {daePath} into {unzippedDaePath}")
    return unzippedDaePath

def handleZippedDae(path, newAnimationName):
    # Handle zip file
    if getExtensionFromPath(path) == ".zip":
        prepareDaeAnimation(path, newAnimationName)
        print("\n\n")

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
        e.g. python3 "mixamoAnimToXcode.py" '~/Downloads/samuel/animations/idle'
        
        a. If the folder's name is "animations", then the script will convert .zip files including subdirectories
        b. Any other names of a folder will not convert subdirectories
    """
    pathToConvert, newAnimationName = validateAndGetInput()
    if isFolder(pathToConvert):
        # If folder, then get all zip files to unzip
        if getNameFromPath(pathToConvert) == "animations":
            #If folder's name == animations, then check zip files including subdirectories
            for root, dirs, files in os.walk(pathToConvert):
                for file in files:
                    filePath = os.path.join(root, file)
                    handleZippedDae(filePath)
        else:
            for filename in os.listdir(pathToConvert):
                filePath = os.path.join(pathToConvert, filename)
                handleZippedDae(filePath)
    else:
        handleZippedDae(pathToConvert)
    LOG(f"✅✅✅")
