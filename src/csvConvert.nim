from std/strformat import `&`
import std/unicode
import std/parsecsv
import std/json
import std/strutils
import std/rdstdin
import std/os

proc default(a: string, b: string): string =
    if a == "":
        return b
    a

proc convertCsv*(inFile: string, outFile: string, lang: string): int =
    echo &"Converting CSV file '{inFile}' to into JSON file '{outFile}'."
    echo &"language: {lang}"
    var resultJson = %*{}

    if not inFile.fileExists:
        echo &"Error: File '{inFile}' does not exist."
        return 1

    if outFile.fileExists:
        echo &"\x1b[33mWarning: Output file \"{outFile}\" already exists.\x1b[0m"
        let response = readLineFromStdin("Overwrite file? [y/N] ").default("n").toLower
        if response != "y":
            return 0
        echo "Continuing with doing stuff..."

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
