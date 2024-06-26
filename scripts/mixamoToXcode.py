# This script is to convert a downloaded .dae file from mixamo as .zip or unzipped into a format that FuFight project can just accept
# This will do the following
# 1. Unzip files and properly rename its files and folders
# 2. Update the .dae file's texture
# 3. Run the ConvertToXcodeCollada script to the .dae files

import os
import shutil
import subprocess
import sys
import zipfile

from enum import Enum
from os.path import abspath, expanduser

from Logger import *

try:
    from subprocess import DEVNULL  # python3
except ImportError:
    DEVNULL = open(os.devnull, 'wb')

#----------------------------------------------------------------------------------------------------------------
############################################### CUSTOMIZABLE SETTINGS ###########################################
#----------------------------------------------------------------------------------------------------------------
SHOULDUNZIP = True

USERDOWNLOADSFOLDER = abspath(expanduser("~/") + '/Downloads')
WORKFLOWPATH_ConvertToXcodeCollada = abspath(expanduser("~/") + '/Desktop/StreamCodes/scripts/ConvertToXcodeCollada/ConvertToXcodeCollada.workflow')
#----------------------------------------------------------------------------------------------------------------
#################################################### Objects ####################################################
#----------------------------------------------------------------------------------------------------------------

class Fighter:
    def __init__(self, fighterType):
        self.fighterType = fighterType
        self.folderName = MIXAMO_FOLDERNAMES[fighterType]
        self.mixamoName = MIXAMO_NAMES[fighterType]
        self.textureName = getTextureKey(fighterType)
        self.name = FIGHTER_NAMES[fighterType]

class FighterType(Enum):
    samuel = "samuel"
    clara = "clara"
    sophie = "sophie"
    michelle = "michelle"
    eric = "eric"
    olivia = "olivia" #corrupted .dae
    jad = "jad"
    pete = "pete"
    david = "david"
    jody = "jody"
    manuel = "manuel"
    jennifer = "jennifer" #unused for now
    neverRight = "neverRight"

#----------------------------------------------------------------------------------------------------------------
#################################################### Constants ##################################################
#----------------------------------------------------------------------------------------------------------------

#Can get after downloading the .dae zipped files
MIXAMO_FOLDERNAMES = {
    FighterType.samuel: "samuel", 
    FighterType.clara: "clara",
    FighterType.sophie: "Ch02_nonPBR",
    FighterType.michelle: "Ch03_nonPBR",
    FighterType.eric: "Ch08_nonPBR",
    FighterType.olivia: "Ch11_nonPBR",
    FighterType.jad: "Ch16_nonPBR",
    FighterType.pete: "Ch17_nonPBR",
    FighterType.david: "Ch28_nonPBR",
    FighterType.jody: "Ch37_nonPBR",
    FighterType.manuel: "Ch42_nonPBR",
    FighterType.jennifer: "Ch47_nonPBR",
    FighterType.neverRight: "Prisoner B Styperek",
}

MIXAMO_NAMES = {
    FighterType.samuel: "fiverr-samuel",
    FighterType.clara: "fiverr-clara",
    FighterType.sophie: "Sophie",
    FighterType.michelle: "Michelle",
    FighterType.eric: "Adam",
    FighterType.olivia: "Olivia",
    FighterType.jad: "Chad",
    FighterType.pete: "Pete",
    FighterType.david: "David",
    FighterType.jody: "Jody",
    FighterType.manuel: "Bryce",
    FighterType.jennifer: "Jennifer",
    FighterType.neverRight: "Prisoner B Styperek",
}

FIGHTER_NAMES = {
    FighterType.samuel: "Samuel",
    FighterType.clara: "Clara",
    FighterType.sophie: "Sophie",
    FighterType.michelle: "Michelle",
    FighterType.eric: "Eric",
    FighterType.olivia: "Olivia",
    FighterType.jad: "Jad",
    FighterType.pete: "Pete",
    FighterType.david: "David",
    FighterType.jody: "Jody",
    FighterType.manuel: "Manuel",
    FighterType.jennifer: "Jennifer",
    FighterType.neverRight: "Never Right",
}

# Set to true if after downloading .dae zipped files, and the textures 
# folder has 1001 and 1002 in the image names
MIXAMO_HAS_MULTIPLE_TEXTURE_VERSION = {
    FighterType.samuel: False,
    FighterType.clara: False,
    FighterType.sophie: True,
    FighterType.michelle: False,
    FighterType.eric: True,
    FighterType.olivia: True,
    FighterType.jad: True,
    FighterType.pete: True,
    FighterType.david: False,
    FighterType.jody: True,
    FighterType.manuel: True,
    FighterType.jennifer: True,
    FighterType.neverRight: False,
}

#----------------------------------------------------------------------------------------------------------------
#################################################### Helper Methods #############################################
#----------------------------------------------------------------------------------------------------------------
def getNameFromPath(path, withExtension = False):
    name = os.path.basename(path)
    if not withExtension:
        name = os.path.splitext(os.path.basename(path))[0]
    return name

def getFolderFromPath(path):
    return os.path.dirname(path)

def getExtensionFromPath(path):
    return os.path.splitext(getNameFromPath(path, withExtension=True))[1]

def exist(path):
    return os.path.exists(path)

def isFolder(path):
    return os.path.isdir(path)

def deleteAllFromPath(path):
    if exist(path):
        try:
            if os.path.isfile(path) or os.path.islink(path):
                os.unlink(path)
            elif os.path.isdir(path):
                shutil.rmtree(path)
        except Exception as e:
            LOGE('Failed to delete %s. Reason: %s' % (path, e))

def renamePath(path, newPath):
    if exist(newPath):
        deleteAllFromPath(newPath)
    # os.rename(path, newPath) #causes unexpected bugs like a file not getting unzipped but will override existing newPath
    shutil.move(path, newPath) #fails if newPath already exist

def getMixamoKey(fighterType):
    # Returns the "Ch02" in "Ch02_nonPBR" or "Prisoner B Styperek"
    mixamoKey = MIXAMO_FOLDERNAMES[fighterType]
    if mixamoKey.startswith("Ch"):
        # If fighter's folder name contains Ch, then 
        # its key is the first 4 characters e.g. Ch02
        mixamoKey = mixamoKey[:4]
    LOGA(f"Mixamo key for {fighterType.value} is {mixamoKey}")
    return mixamoKey

def getTextureKey(fighterType):
    """Returns something like either "Ch17_100" or "Ch03_1001" or "prisoner\""""
    textureName = getMixamoKey(fighterType)
    hasMultipleVersion = MIXAMO_HAS_MULTIPLE_TEXTURE_VERSION[fighterType]
    if not textureName.startswith("Ch"):
        if fighterType == FighterType.samuel:
            textureName = FighterType.samuel.value
        elif fighterType == FighterType.clara:
            textureName = FighterType.clara.value
        elif fighterType == FighterType.neverRight:
            textureName = "prisoner"
    else:
        if hasMultipleVersion:
            textureName += "_100"
        else:
            textureName += "_1001"
    return textureName

def getTextureOldName(fighterType, filePath):
    """Returns something like "Ch17_1002_Normal.png\""""
    textureName = getMixamoKey(fighterType)
    folderPath = getFolderFromPath(filePath)
    hasMultipleVersion = MIXAMO_HAS_MULTIPLE_TEXTURE_VERSION[fighterType]
    LOGD(f"texture name is {textureName} at {filePath}")
    if not textureName.startswith("Ch"):
        if fighterType == FighterType.samuel:
            textureName = FighterType.samuel.value
        elif fighterType == FighterType.clara:
            textureName = FighterType.clara.value
        elif fighterType == FighterType.neverRight:
            textureName = "prisoner"
    else:
        if hasMultipleVersion:
            textureName += "_100"
        else:
            textureName += "_1001"

    fighter = Fighter(fighterType)
    LOGA(f"Texture's OLD name for {fighter.name} from {filePath} IS {textureName}")
    return textureName

def getTextureNewName(fighterType, filePath):
    """Returns something like "sophieTexture2_Diffuse.png\""""
    oldTextureKeyToReplace = getTextureKey(fighterType)
    currentTextureName = os.path.basename(filePath)
    textureName = currentTextureName.replace(oldTextureKeyToReplace, f"{fighterType.value}Texture")
    LOGA(f"Texture's NEW name for {fighterType.value} with old key {oldTextureKeyToReplace} is {textureName}")
    return textureName

def check_path_contains_files_with_type(path, file_type):
    for filename in os.listdir(path):
        if filename.endswith(file_type):
            return True
    return False

def unzipFile(path, isOneFile = False):
    """Unzips the path provided. 
    Set isOneFile to True for zip containing multiple files, and this method will extract into a new directory.
    isOneFile = false will place the extracted files into the same directory"""
    with zipfile.ZipFile(path, 'r') as zip_ref:
        unzippedPath = path if isOneFile else getFolderFromPath(path) + "/" + getNameFromPath(path)
        #If path already exist, delete previous folder contents before unzipping
        if exist(unzippedPath):
            deleteAllFromPath(unzippedPath)
            LOGA(f"Fighter's folder already exist. Deleting old folder {unzippedPath}")
        if isOneFile:
            zip_ref.extractall(getFolderFromPath(path))
        else:
            zip_ref.extractall(unzippedPath)
        LOGA(f"Finished unzipping file in {path} to {unzippedPath}")

#----------------------------------------------------------------------------------------------------------------
#################################################### Methods ####################################################
#----------------------------------------------------------------------------------------------------------------
# Validates inputs and returns the path to convert
def getPathToConvert():
    userPath = expanduser("~/")
    # Defaults to converting user's Downloads folder if path is not provided
    pathToConvert = ""
    if len(sys.argv) == 2:
        pathToConvert = sys.argv[1]
    if len(sys.argv) == 1:
        pathToConvert = USERDOWNLOADSFOLDER
    else:
        LOGE("Error Usage: python mixamoToXcode.py <optional_directory_path>")
        LOGW("""WARNING: Executing this script will default to converting files downloaded in 
              your Downloads folder if a path is not provided""")
        sys.exit(1)
    return pathToConvert

def getFighterPaths(fromPath):
    fighterPathsDic = {}
    # Iterate over files in directory
    for filePath in os.scandir(fromPath):
        fileName = os.path.basename(filePath)
        fullPath = os.path.join(fromPath, filePath)
        #if path is a folder and contains a .dae file...
        if os.path.isdir(filePath):
            if check_path_contains_files_with_type(fullPath, ".dae"):
                for fighterType, mixamoFolderName in MIXAMO_FOLDERNAMES.items():
                    if fileName.startswith(mixamoFolderName):
                        fighterPathsDic[fighterType] = fullPath
        else:
            if SHOULDUNZIP:
                #Handle expected zipped file names. Else skip
                for fighterType, mixamoFolderName in MIXAMO_FOLDERNAMES.items():
                    if fileName.startswith(mixamoFolderName):
                        if fullPath.endswith(".zip"):
                            LOGA(f"Unzipping file at {fullPath}")
                            unzipFile(fullPath)
                            #Add path to the new unzipped file
                            unzippedPath = f"{getFolderFromPath(fullPath)}/{getNameFromPath(fullPath)}"
                            if check_path_contains_files_with_type(unzippedPath, ".dae"):
                                fighterPathsDic[fighterType] = unzippedPath
    return fighterPathsDic

def updateDaeFile(fighterType, daePath):
    """
    Update the fighter's .dae to the renamed textures
    """
    if not exist(daePath):
        return
    fighter = Fighter(fighterType)
    # Read in the file
    with open(daePath, 'r') as file:
        filedata = file.read()
        # Replace the target string
        textToReplace = f"textures/{getTextureKey(fighter.fighterType)}"
        filedata = filedata.replace(textToReplace, f"assets/{fighterType.value}Texture")
        # Write the file out again
        with open(daePath, 'w') as file:
            file.write(filedata)
            LOGA(f"Finished updating dae file in {daePath}. Replacing all contents from {textToReplace} into {fighterType.value}Texture")

def executeConvertToXcodeColladaWorkflow(daePath):
    """Executes ConvertXcodeCollada workflow and to the dae path, then deletes the unneeded .dae file"""
    if not exist(WORKFLOWPATH_ConvertToXcodeCollada):
        LOGE(f"File missing for ConvertToXcodeCollada {WORKFLOWPATH_ConvertToXcodeCollada}")
    if not exist(daePath):
        LOGE(f"File missing for dae to convert {daePath}")
    try:
        # Execute the workflow
        proc = subprocess.check_output(["/usr/bin/automator", "-i", daePath, WORKFLOWPATH_ConvertToXcodeCollada],                                
                                        stderr=DEVNULL)
        #Remove unneeded .dae file the workflow generated
        uneededDaeFileName = f"{getNameFromPath(daePath, withExtension=True)}-e"
        uneededDaePath = f"{getFolderFromPath(daePath)}/{uneededDaeFileName}"
        os.remove(uneededDaePath)
        LOGA(f"Executed ConvertToXcodeCollada to daePath: {daePath} and deleted {uneededDaeFileName}")
    except subprocess.CalledProcessError as e:
        LOGE(f"Failed to execute script at path: {daePath}\n\tWith error code: {e.returncode} \tand output: {e.output}")
        # LOGE('Python Error executing ConvertToXcodeCollada workflow with error: [%d]\n{!r}'.format(e.returncode, e.output))
        sys.exit(1)

def updateFighters(fighterType, fighterPath):
    """
    1. Update the .dae's name in fighterPath
    2. Update the textures folder to assets in fighterPath
    3. Update the name of the .png files in fighterPath/assets
    4. Rename the root fighter's path to its name
    5. Delete old fighterPath
    6. Update .dae file's contents to still point to the updated assets
    7. Run the script ConvertToXcodeCollada on the .dae file
    """
    LOGA(f"Updating fighterType: {fighterType.value}")

    if not os.path.isdir(fighterPath) or not check_path_contains_files_with_type(fighterPath, ".dae"):
        LOGE(f"Path is invalid: {fighterPath}")
        return
    fighter = Fighter(fighterType)
    for filePath in os.scandir(fighterPath):
        fileName = os.path.basename(filePath)
        fullPath = os.path.join(fighterPath, filePath)
        if fileName.endswith(".dae"):
            #1. Update the .dae's name
            daePath = f"{fighterPath}/{fileName}"
            newDaeFileName = f"{fighterPath}/{fighter.fighterType.value}.dae"
            renamePath(daePath, newDaeFileName)
            LOGA(f"Renamed .dae file from {fileName} to {fighter.fighterType.value}.dae")
        elif fileName == "textures":
            #2. Update the textures folder to assets
            newFolderName = os.path.join(fighterPath, "assets")
            renamePath(fullPath, newFolderName)
            LOGA(f"Renamed textures to assets {fullPath}")
    #3. Update the name of the .png files in assets
    assetsPath = f"{fighterPath}/assets"
    if exist(assetsPath):
        for filePath in os.scandir(assetsPath):
            fullPath = os.path.join(fighterPath, filePath)
            newName = getTextureNewName(fighterType, filePath)
            newPath = f"{assetsPath}/{newName}"
            renamePath(fullPath, newPath)
            LOGA(f"Finished renaming image from {fullPath} to {newPath}")
    else:
        print(f"TODO: Handle or manually convert assets for fighter: {fighterType.value}")

    #4. Rename the root fighter's path to its name
    pathName = getNameFromPath(fighterPath)
    pathDir = getFolderFromPath(fighterPath)
    newName = pathName.replace(fighter.folderName, fighter.name) #TODO captiali
    newFighterPath = f"{pathDir}/{newName}"
    renamePath(fighterPath, newFighterPath)

    #5. Delete old fighterPath
    deleteAllFromPath(fighterPath)

    #6. Update .dae's file content to correct texture
    daePath = os.path.join(newFighterPath, f"{fighterType.value}.dae")
    updateDaeFile(fighterType, daePath)

    #7. Execute ConvertXcodeCollada and delete the unneeded .dae file
    executeConvertToXcodeColladaWorkflow(daePath)
    
#----------------------------------------------------------------------------------------------------------------
#################################################### Main #######################################################
#----------------------------------------------------------------------------------------------------------------
if __name__ == "__main__":
    """
    Must have ConvertToXcodeCollada in Desktop/StreamCodes/scripts/ConvertToXcodeCollada/ConvertToXcodeCollada.workflow
    """
    pathToConvert = getPathToConvert()
    fighterPathsDic = getFighterPaths(pathToConvert)
    for (index, (fighterType, fighterPath)) in enumerate(fighterPathsDic.items()):
        updateFighters(fighterType, fighterPath)
        LOGA(f"Finished converting fighter#{index+1} in path {fighterPath} to {fighterType.name}")
    
    LOG(f"RESULT: Total converted paths in <{pathToConvert}> is {len(fighterPathsDic)}")
    LOG(f"✅✅✅")
