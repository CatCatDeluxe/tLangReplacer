# tLangReplacer

A tool for replacing words with other words in Terraria language packs.

Example thing:

```sh
# Generate intermediate JSON files. en-US is the default language.
./tLangReplacer conv all_localizations.csv --language en-US
# Replace some stuff (case sensitive). The output file can be specified
# with the -o argument. The default out file is "int.json".
./tLangReplacer replace a b # Order is (word, what to replace it with)...
# You can load localizations from other files too.
./tLangReplacer replace -i other_file.json c d
# You can even make the program read from the same file as the output.
# By default, the program will not replace existing translations in the
# out file. You can override this with the -r flag.
# Also, for some reason argument chaining doesn't work sadly.
./tLangReplacer replace -r -i int.json e f
# Build the intermediate file to a format Terraria can read.
./tLangReplacer build en-US.json
```
