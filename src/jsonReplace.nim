from std/strformat import `&`
from math import floor
import std/strutils
import std/tables
import std/json
import std/os

import stringRemover

# Add all of b's keys to a. b will not overwrite a by default.
# Setting param keep to false will enable overwriting though.
proc merge(a: var JsonNode, b: JsonNode, keep = true): JsonNode =
    result = %*{}
    for key in a.keys:
        result[key] = a[key]
    for key in b.keys:
        if keep and result.hasKey key:
            continue
        result[key] = b[key]

proc langReplace*(
        inFile: string,
        outFile: string,
        replaces: seq[string],
        joinFile = true,
        keepOld = true): int =

    if not inFile.fileExists:
        echo &"Error File \"{infile}\" does not exist."
        return 1

    var replaceMap = initTable[string, string]()
    # This is to avoid calling replaceMap.keys a lot.
    var replaceKeys: seq[string] = @[]

    # Construct the replace map.
    block:
        var keyName = ""
        for str in replaces:
            if keyName == "":
                keyName = str
                replaceKeys.add str
                continue
            replaceMap[keyName] = str
            keyName = ""

    echo "Reading and parsing JSON file..."
    let inputJson = parseFile inFile
    let numItems = inputJson.len
    echo "Done parsing file."

    var resultJson: JsonNode = %*{}

    echo "Scanning and replacing stuff in text..."
    # For the progress thingy
    var translationsScanned = 0
    # Actually do stuff
    for key in inputJson.keys:
        translationsScanned += 1
        let str = inputJson[key].getStr
        var modString = ""

        # Remove stuff inside {}'s, to avoid translating them and breaking stuff.
        let
            removeResult = str.removeInside('{', '}')
            alteredString = removeResult[0]
            removals = removeResult[1]

        for r in replaceKeys:
            # Check for replaceable stuff. This does not check for
            # replaceable stuff on the modified string, so the order
            # of the replace things probably doesn't matter
            if str.contains r:
                # Save on some memory if no strings match.
                if modString == "":
                    modString = alteredString
                modString = modString.replace(r, replaceMap[r])

        modString = modString.replaceStuff('{', '}', removals)

        # Add the key to the result.
        if modString != "" and modString != str:
            resultJson[key] = %*modString

        # Make a progress showing thingy
        let percentDone = floor(translationsScanned.float / numItems.float * 1000.0) / 10.0
        stdout.write &"\x1b[2K{translationsScanned} / {numItems} ({percentDone}%) translations scanned.\r"

    echo &"\nFinished, created {resultJson.len} replaced names."
    echo &"Writing to file \"{outFile}\"."

    # Join to an existing file.
    if outFile.fileExists and joinFile:
        echo "File already exists, merging files..."
        let origJson = parseFile outFile
        resultJson = merge(resultJson, origJson, not keepOld)

    writeFile outFile, resultJson.pretty
    echo "Write complete."
    0
