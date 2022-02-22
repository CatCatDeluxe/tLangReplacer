proc removeInside*(str: string, beginChar, endChar: char): (string, seq[string]) =
    var resultString = ""
    var removed: seq[string] = @[]

    var depth = 0
    for ch in str:
        if ch == beginChar:
            inc depth
            if depth == 1:
                removed.add ""
                resultString.add beginChar & endChar
        elif ch == endChar:
            depth = max(depth - 1, 0)
            removed[removed.len - 1].add ch
            continue

        if depth > 0:
            removed[removed.len - 1].add ch
            continue

        resultString.add ch

    (resultString, removed)

# I can't think of a better name for this function, so it's called this now I guess
proc replaceStuff*(str: string, beginChar, endChar: char,
        extractedStrings: seq[string]): string =
    result = ""

    var extractedIdx = 0
    var idx = 0
    var skipNext = false
    for ch in str:
        if skipNext:
            skipNext = false
            inc idx
            continue

        if idx < str.len and ch == beginChar and str[idx + 1] == endChar:
            result.add extractedStrings[extractedIdx]
            inc extractedIdx
            inc idx
            skipNext = true
            continue

        result.add ch
        inc idx
