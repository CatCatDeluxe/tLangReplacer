import json

import fileCheck

proc flattenJson*(inFile: string, outFile: string): int =
    if not inFile.ensureFile:
        return 1
    if not outFile.warnIfFile:
        return 0
