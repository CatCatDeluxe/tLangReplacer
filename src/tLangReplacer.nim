import std/os
import argparse

import jsonReplace
import csvConvert
import jsonBuild
import jsonFlatten

when isMainModule:
    var parser = newParser:
        command "conv":
            help "Convert a multi-language CSV file to a base intermediate " &
                "language pack JSON file."
            option "-l", "--language", default = some "en-US" 
            arg "fromFile" 
            arg "toFile", default = some "base.json" 
            run:
                let exitCode = convertCsv(
                    opts.fromFile,
                    opts.toFile,
                    lang = opts.language)
                quit exitCode

        command "replace":
            help "Replace one string with another one."
            option "-i", "--infile", default = some "base.json" 
            option "-o", "--outfile", default = some "int.json" 
            flag "-I", "--ignore-case", help = "Ignore upper and lower case when matching patterns."
            flag "-O", "--overwrite" 
            flag "-r", "--replace",
                help = "Whether to allow replacing translations already in the output file."
            flag "-c", "--cyclic",
                help = "Enables replacing text in the out file and sets the in file to the out file."
            arg "replaces", nargs = -1
            run:
                if opts.cyclic:
                    opts.inFile = opts.outfile
                    opts.replace = true

                let exitCode = langReplace(
                    opts.inFile,
                    opts.outFile,
                    opts.replaces,
                    joinFile = not opts.overwrite,
                    keepOld = not opts.replace,
                    ignoreCase = opts.ignoreCase)
                quit exitCode

        command "build":
            help """
Make an intermediate JSON file into the Terraria language pack format.
Remember, the format for pack names is <language, e.g en-US>[rest of filename].json""".strip
            arg "infile", default = some "int.json"
            arg "outfile"
            run:
                let exitCode = buildJson(
                    inFile = opts.inFile,
                    outFile = opts.outFile)
                quit exitCode
        
        command "flatten":
            help """
Flatten a nested JSON file into an intermediate file.""".strip
            arg "infile"
            arg "outfile", default = some "int.json"
            run:
                let exitCode = flattenJsonFile(opts.inFile, opts.outFile)
                quit exitCode

    parser.run commandLineParams()
