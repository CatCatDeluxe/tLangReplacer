from std/strformat import `&`
import std/strutils
import std/rdstdin
import std/json
import std/os

proc idxOfLast(str: string, match: char): int =
    for i in countdown(str.len - 1, 0):
        if str[i] == match:
            return i
    0

proc buildJson*(inFile: string, outFile: string): int =
    if not inFile.fileExists:
        echo "Error: file \"{inFile}\" does not exist."
        return 1

    if outFile.fileExists:
        echo &"\x1b[33mWarning: Output file \"{outFile}\" already exists.\x1b[0m"
        let response = readLineFromStdin("Overwrite file? [y/N] ").toLower
        if response != "y":
            return 0
        echo "Continuing with doing stuff..."

    echo &"Reading file \"{inFile}\"..."
    let inputJson = parseFile inFile
    echo "File reading complete."

    var resultJson = %*{}

    echo "Building JSON..."
    for key in inputJson.keys:
        let
            dotIndex = key.idxOfLast '.'
            keyPath = key.substr(0, dotIndex - 1)
            # Make sure keys with no path get parsed properly.
            keyName = if dotIndex > 0: key.substr(dotIndex + 1) else: key

        # No extra stuff is needed with an empty key path.
        if keyPath == "":
            resultJson[key] = inputJson[key]
            continue

        var node = resultJson
        for i in keyPath.split ".":
            if not node.contains i:
                node[i] = %*{}
            node = node[i]
        node[keyName] = inputJson[key]
    echo "Successfully built JSON."
    
    writeFile outFile, resultJson.pretty
    0
