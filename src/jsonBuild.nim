from std/strformat import `&`
import std/strutils
import std/json

import fileCheck

proc idxOfLast(str: string, match: char): int =
    for i in countdown(str.len - 1, 0):
        if str[i] == match:
            return i
    0

proc buildJson*(inFile, outFile: string): int =
    if not inFile.ensureFile:
        return 1
    if not outFile.warnIfFile:
        return 0

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
