# Chipmunk7 demos for Nim [![nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png)](https://github.com/yglukhov/nimble-tag)

## Description:
Chipmunk7 demos for the Nim programming language using BlaXpirit's nim-chipmunk library (https://github.com/BlaXpirit/nim-chipmunk).<br>
Demo video: https://www.youtube.com/watch?v=Gg79LT1ItWo
## List of demos:
* Nim logo smash
* Player
* Sticky balls
* Spaces
* Weight scale
* Pyramid
* Springs
* Dominos
* Bead curtain
* Liquid tub

## Licenses:
The project is licensed under the MIT license.<br><br>
Chipmunk7 is licensed under the MIT license and was created by Scott Lemcke and Howling Moon Software.<br>
The Nim Chipmunk7 library is licensed under the MIT license and was created by BlaXpirit.<br>
The Nim sdl2, Nim opengl and SDL2 libraries are licensed under the MIT license.<br>
The SDL2_gfx library is licensed under zlib license.<br>


## Dependencies:
* Nim sdl2 library (https://github.com/nim-lang/sdl2)
* Nim opengl library (https://github.com/nim-lang/opengl)
* Chipmunk7 (https://chipmunk-physics.net/)
* SDL2, installed on your system (https://www.libsdl.org/)
* SDL2_gfx, installed on your system (http://www.ferzkopp.net/wordpress/2016/01/02/sdl_gfx-sdl2_gfx/)
* OpenGL

## Embedded dependencies (included in the project)
* Chipmunk7 wrapper library (https://github.com/BlaXpirit/nim-chipmunk)

## Installation/compilation notes
* compiling with the ```--define:chipmunkUnsafe``` flag
  * Compiles the demos in UNSAFE mode, which shows extra details about the internal workings of the Chipmunk library
* Nim sdl2 and opengl can be installed using Nimble (https://github.com/nim-lang/nimble)
* Chipmunk7 should be installed from source, but there may be some precompiled binaries for Windows out there, I haven't checked.
* The SDL2 and SDL2_gfx libraries have to be installed on your system.
  * GNU/Linux: you have to either install them using your distro's package manager (APT, dpkg, ...) or install it from source.
  * Windows: Use the precompiled dynamic libraries (dll's) by just placing them next to the Nim compiled binary or put them on the system's PATH. It's prefered to compile them from the source, as I found some bugs in the old precompiled dll's.
* OpenGL is probably already installed on both GNU/Linux or Windows systems. If you have any problems, check their websites for more information.

## Notes/warnings:
* The Chipmunk7 wrapper is slightly modified for the project and should be treated as EXPERIMENTAL. Do not use it in production code as
it uses the non-public API, which may change at any time.
