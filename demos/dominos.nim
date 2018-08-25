
import
    ../chipmunk,
    ../data,
    sdl2,
    math,
    random,
    strutils

const
    WIDTH = 4.0f
    HEIGHT = 30.0f
    
var space: chipmunk.Space


proc add_domino(space: chipmunk.Space, position: chipmunk.Vect, flipped: bool) =
    var
        mass: chipmunk.Float = 1.0f
        radius: chipmunk.Float = 0.5f
        moment: chipmunk.Float = momentForBox(mass, WIDTH, HEIGHT)
        body: chipmunk.Body = space.addBody(newBody(mass, moment))
        shape: chipmunk.Shape
    body.position = position
    shape = if flipped: 
                body.newBoxShape(HEIGHT, WIDTH, 0.0) 
            else: 
                body.newBoxShape(WIDTH - radius*2.0f, HEIGHT, radius)
    discard space.addShape(shape)
    shape.elasticity = 0.0
    shape.friction = 0.6
    shape.set_random_color()

proc init_space() =
    space = newSpace()
    space.iterations = 80
    space.gravity = chipmunk.v(0, -300)
    space.collisionSlop = 0.5f
    space.sleepTimeThreshold = 0.5f

    # Add a floor.
    var shape = space.addShape(
        space.staticBody().newSegmentShape(
            chipmunk.v(-600,-240), 
            chipmunk.v(600,-240), 
            0.0f
        )
    )
    
    # Add the dominoes.
    var n = 11
    for i in 0..n:
        for j in 0..(n-i-1):
            var offset: chipmunk.Vect = chipmunk.v(
                (float(j) - (float(n) - 1 - float(i))*0.5f)*1.5f*HEIGHT,
                (float(i) + 0.5f)*(HEIGHT + 2*WIDTH) - WIDTH - 240
            )
            add_domino(space, offset, false)
            add_domino(
                space, 
                vadd(offset, chipmunk.v(0, (HEIGHT + WIDTH)/2.0f)),
                true
            )
            if j == 0:
                add_domino(
                    space, 
                    vadd(offset, chipmunk.v(0.5f*(WIDTH - HEIGHT), HEIGHT + WIDTH)), 
                    false
                )
            if j != (n - i - 1):
                add_domino(
                    space, 
                    vadd(offset, chipmunk.v(HEIGHT*0.75f, (HEIGHT + 3*WIDTH)/2.0f)),
                    true
                )
            else:
                add_domino(
                    space, 
                    vadd(offset, chipmunk.v(0.5f*(HEIGHT - WIDTH), HEIGHT + WIDTH)), 
                    false
                )



## Procs for usage in the chipmunk_demo module
proc init*() {.procvar.} =
    init_space()

proc update*(dt: cdouble) {.procvar.} = 
    space.step(dt)

proc draw*() {.procvar.} =
    space.default_draw_implementation()
    data.draw_text(
        "Try moving one of the dominos ...",
        Vect(x: DEMO_TEXT_X_OFFSET, y: DEMO_TEXT_Y_OFFSET_LINE_1)
    )

proc get_space*(): chipmunk.Space {.procvar.} =
    result = space

proc clean_up*() {.procvar.} =
    space.eachShape(data.clean_up_shape_color, nil)
    space.clean_up_children()
    space.destroy()


