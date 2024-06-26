import os
import sys

def split_path(path):
    #Splits a path and returns directory and name
    directory, filename = os.path.split(path)
    return directory, filename

def replace_filenames_in_directory(directoryPath, nameToReplace, textToReplaceTo):
    # Check if the directory exists
    if not os.path.isdir(directoryPath):
        print(f"ERROR: The directory at {directoryPath} does not exist.")
        sys.exit(1)
        return
    # Number of nameToReplace in the path we replace
    maximumOccurrence = 1
    # Iterate through each file in the directory
    for count, filename in enumerate(os.listdir(directoryPath)):
        if filename.startswith(textToReplaceTo):
            # Do not convert file names that does not begin with the textToReplaceTo
            continue
        # Create the new file name
        newFileName = f"{filename.replace(nameToReplace, textToReplaceTo, maximumOccurrence)}"
        # Construct full file paths
        old_file_path = os.path.join(directoryPath, filename)
        new_file_path = os.path.join(directoryPath, newFileName)

        # Rename the file
        os.rename(old_file_path, new_file_path)
        print(f"Renamed file #{count}: {old_file_path} to {new_file_path}")

# Example usage
# /Users/samuelfolledo/Downloads/jeniffer/textures/Ch47
if __name__ == "__main__":
    # Check if the correct number of arguments are provided
    if len(sys.argv) != 3:
        print("Error Usage: python fileRenamer.py <directory_path_and_name> <new_file_name>")
        sys.exit(1)

    # Get the two inputs
    fullPath = sys.argv[1]
    textToReplaceTo = sys.argv[2]

    # Split the path into directory and file name
    directoryPath, fileNameToReplace = split_path(fullPath)

    # Form the complete path
    replace_filenames_in_directory(directoryPath, fileNameToReplace, textToReplaceTo)

    # Print the Directory and name to replace
    print(f"Finished replacing all files in path {directoryPath} with name starting in: {fileNameToReplace} into: {textToReplaceTo}")
