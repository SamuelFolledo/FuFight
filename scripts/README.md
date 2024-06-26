# FuFight's Scripts
Use these character and animation scripts to prepare .dae files downloaded from mixamo. It is important to have ConvertToXcodeCollada workflow downloaded

## Use mixamoToXcode.py for characters
`python3 mixamoToXcode.py`

### This script will:
1. Unzip files and properly rename its files and folders
2. Update the .dae file's texture
3. Run the ConvertToXcodeCollada script to the .dae files

### Each dae.zip file will: 
1. Update the .dae's name in fighterPath
2. Update the textures folder to assets in fighterPath
3. Update the name of the .png files in fighterPath/assets
4. Rename the root fighter's path to its name
5. Delete old fighterPath
6. Update .dae file's contents to still point to the updated assets
7. Run the script ConvertToXcodeCollada on the .dae file

## Use mixamoAnimToXcode.py for animations
This script is used to prepare animations to Xcode. 
Note: This script will perform differently depending on the arguments passed

1. If zip file is passed, unzip and convert into a usable .dae file
    `python3 "mixamoAnimToXcode.py" <path_to_zip> <optional_new_name>`
    e.g. `python3 "mixamoAnimToXcode.py" '~/Downloads/Hard Head Nod.zip' idleStand`

2. If folder is passed, unzip the contents and convert into a usable .dae files
    `python3 "mixamoAnimToXcode.py" <path_to_folder>`
    e.g. `python3 "mixamoAnimToXcode.py" '/Users/samuelfolledo/Downloads/Hard Head Nod.zip' idleStand`   

License under [MIT License](https://github.com/SamuelFolledo/FuFight/blob/master/LICENSE)
