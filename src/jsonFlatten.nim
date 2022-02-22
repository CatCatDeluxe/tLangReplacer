import std/json

import fileCheck

proc flattenTo(node: JsonNode, outNode: var JsonNode, path = ""): void =
    var realPath = path
    if realPath != "":
        realPath.add '.'

    for child in node.pairs:
        if child.val.kind == JObject:
            child.val.flattenTo outNode, realPath & child.key
            continue
        outNode[realPath & child.key] = child.val

proc flattenJsonFile*(inFile, outFile: string): int =
    if not inFile.ensureFile:
        return 1
    if not outFile.warnIfFile:
        return 0

    echo "Reading JSON..."
    let inputJson = parseFile inFile
    echo "Done reading json."
    var resultJson = %*{}

    inputJson.flattenTo resultJson

    writeFile outFile, resultJson.pretty
