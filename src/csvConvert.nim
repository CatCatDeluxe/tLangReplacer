from std/strformat import `&`
import std/parsecsv
import std/json

import fileCheck

proc convertCsv*(inFile, outFile, lang: string): int =
    echo &"Converting CSV file '{inFile}' to into JSON file '{outFile}'."
    echo &"language: {lang}"
    var resultJson = %*{}

    if not inFile.ensureFile:
        return 1
    if not outFile.warnIfFile:
        return 0

    var parser: CsvParser
    echo "Opening and parsing file..."
    parser.open inFile
    parser.readHeaderRow

    while parser.readRow:
        var tableKey = ""
        for col in parser.headers:
            # Set the table key name.
            if tableKey == "":
                tableKey = parser.rowEntry col
                continue
            # Assign the key in the table.
            if col == lang:
                resultJson[tableKey] = %*parser.rowEntry col
                break

    echo "Finished parsing file."
    echo &"Saving JSON to file \"{outFile}\"..."

    outFile.writeFile resultJson.pretty

    echo "Finished conversion."

    # Exit code 0.
    0
