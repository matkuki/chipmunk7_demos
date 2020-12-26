
#[
    Build script
]#

import os
import strutils

mode = ScriptMode.Verbose

if defined(windows) or defined(linux):
    const
        working_directory = thisDir()
    var 
        flags = [
            "--define:chipmunkUnsafe",
            "--out:bin/chipmunk7_demos.exe",
#            "--gc:orc",
            "-d:release", "-d:danger",
            "chipmunk7_demos.nim",
        ]
        commands = [
            "nim compile " & flags.join(" "),
        ]
    cd(working_directory)
    for c in commands:
        echo "Executing: \n    ", c
        exec c

else:
    raise newException(Exception, "Not implemented for this OS!")

