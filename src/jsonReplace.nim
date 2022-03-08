from std/strformat import `&`
from math import floor
import std/[strutils, json, os, re]

import stringRemover
import fileCheck

type RegexReplace = object
    rgx: re.Regex
    replace: string

proc merge(a: var JsonNode, b: JsonNode, keep = true): JsonNode =
    ## Add all of b's keys to a. b will not overwrite a by default.
    ## Setting param keep to false will enable overwriting though.
    result = %*{}
    for key in a.keys:
        result[key] = a[key]
    for key in b.keys:
        if keep and result.hasKey key:
            continue
        result[key] = b[key]

proc langReplace*(
        inFile, outFile: string,
        replaces: seq[string],
        joinFile = true,
        keepOld = true,
        ignoreCase = false): int =

    if not inFile.ensureFile:
        return 1

    var regexes: seq[RegexReplace] = @[]

    # Construct the replace map.
    block:
        var regexesIndex = 0
        for i, str2 in replaces:
            var str = str2

            # Add the actual regex.
            if i mod 2 == 0:
                # Make the regex case insensitive.
                if ignoreCase:
                    str = "(?i)" & str
                # Convert the string to a regex and add it to the seq.
                regexes.add RegexReplace(rgx: str.re)
                continue

            # Add the string to replace.
            regexes[regexesIndex].replace = str
            inc regexesIndex

    echo "Reading and parsing JSON file..."
    let
        inputJson = parseFile inFile
        numItems = inputJson.len
    echo "Done parsing file."

    var resultJson: JsonNode = %*{}

    echo "Scanning and replacing stuff in text..."
    # For the progress thingy
    var translationsScanned = 0
    # Actually do stuff
    for key in inputJson.keys:
        inc translationsScanned

        # Remove stuff inside {}'s, to avoid translating them and breaking stuff.
        let
            str: string = inputJson[key].getStr
            removeResult = str.removeInside('{', '}')
            removals: seq[string] = removeResult[1]
        var modString: string = removeResult[0]

        for r in regexes:
            modString = modString.replace(r.rgx, r.replace)

        modString = modString.replaceStuff('{', '}', removals)

        # Add the key to the result, only if it is modified and not empty
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
        let origJson: JsonNode = parseFile outFile
        resultJson = resultJson.merge(origJson, not keepOld)

    writeFile outFile, resultJson.pretty
    echo "Write complete."
    0
