from std/strformat import `&`
import std/rdstdin
import std/strutils
import std/os

proc ensureFile*(filename: string): bool =
    if not filename.fileExists:
        echo &"\x1b[31;1mError: File \"{filename}\" does not exist.\x1b[0m"
        return false
    return true

proc warnIfFile*(filename: string): bool =
    if filename.fileExists:
        echo &"\x1b[33;1mWarning: Output file \"{filename}\" already exists.\x1b[0m"
        let response = readLineFromStdin("Overwrite file? [y/N] ").toLower
        if response != "y":
            return false
        echo "Continuing with doing stuff..."
    true
