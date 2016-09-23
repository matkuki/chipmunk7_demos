
import
    ../chipmunk,
    ../data,
    sdl2,
    math,
    random,
    strutils,
    strfmt

var space: chipmunk.Space


proc init_space() =
    space = newSpace()
    space.iterations = 30
    space.gravity = chipmunk.v(0, -100)
    space.collisionSlop = 0.5
    space.sleepTimeThreshold = 0.1f

    var
        body, static_body: chipmunk.Body = space.staticBody()
        shape: chipmunk.Shape
    # Create segments around the edge of the screen.
    shape = space.addShape(
        newSegmentShape(
            static_body, 
            chipmunk.Vect(x: -320, y: -240), 
            chipmunk.Vect(x: -320, y: 240), 
            0.0
        )
    )
    shape.elasticity = 1.0
    shape.friction = 1.0
    shape.filter = data.NOT_GRABBABLE_FILTER
    
    shape = space.addShape(
        newSegmentShape(
            static_body, 
            chipmunk.Vect(x: 320, y: -240), 
            chipmunk.Vect(x: 320, y: 240), 
            0.0
        )
    )
    shape.elasticity = 1.0
    shape.friction = 1.0
    shape.filter = data.NOT_GRABBABLE_FILTER
    
    shape = space.addShape(
        newSegmentShape(
            static_body, 
            chipmunk.Vect(x: -320, y: -240), 
            chipmunk.Vect(x: 320, y: -240), 
            0.0
        )
    )
    shape.elasticity = 1.0
    shape.friction = 1.0
    shape.filter = data.NOT_GRABBABLE_FILTER
    
    # Add lots of boxes.
    
    for i in 0..13:
        for j in 0..i:
            body = space.addBody(newBody(1.0f, momentForBox(1.0f, 30.0f, 30.0f)))
            body.position = chipmunk.v(float(j)*32 - float(i)*16, 300 - float(i)*32)
            shape = space.addShape(newBoxShape(body, 30.0f, 30.0f, 0.5f))
            shape.elasticity = 0.0
            shape.friction = 0.8
            shape.set_random_color()
    
    # Add a ball to make things more interesting
    var radius = 15.0f
    body = space.addBody(
        newBody(1.0f, momentForCircle(10.0f, 0.0f, radius, chipmunk.vzero))
    )
    body.position = chipmunk.v(0, -240 + radius+5)
    shape = space.addShape(newCircleShape(body, radius, chipmunk.vzero))
    shape.elasticity = 0.0
    shape.friction = 0.9
    shape.set_random_color()


## Procs for usage in the chipmunk_demo module
proc init*() {.procvar.} =
    init_space()

proc update*(dt: cdouble) {.procvar.} = 
    space.step(dt)

proc draw*() {.procvar.} =
    space.default_draw_implementation()
    data.draw_text(
        "Pyramid stack crashing on a ball.",
        Vect(x: DEMO_TEXT_X_OFFSET, y: DEMO_TEXT_Y_OFFSET_LINE_1)
    )

proc get_space*(): chipmunk.Space {.procvar.} =
    result = space

proc clean_up*() {.procvar.} =
    space.eachShape(data.clean_up_shape_color, nil)
    space.clean_up_children()
    space.destroy()