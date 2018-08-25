
import
    ../chipmunk,
    ../data,
    sdl2,
    math,
    random,
    strutils,
    strformat

var 
    space: chipmunk.Space
    # Static body that we will be making into a scale
    scale_static_body: chipmunk.Body
    ball_body: chipmunk.Body
    # Variables for calculating the weight force
    impulse_sum: chipmunk.Vect
    force: chipmunk.Float
    g: chipmunk.Vect
    weight: chipmunk.Float
    # Variables for calculating the contact count
    contact_count: int
    # Variables for calculating the crush force
    magnitude_sum: chipmunk.Float
    vector_sum: chipmunk.Vect
    crush_force: chipmunk.Float


proc impulse_calculator(body: Body, arb: chipmunk.Arbiter, 
                        custom_data: pointer) {.cdecl.} =
        impulse_sum = vadd(impulse_sum, arb.totalImpulse())

proc contact_counter(body: Body, arb: chipmunk.Arbiter, 
                     custom_data: pointer) {.cdecl.} =
    # Ported from C macro:
    #     CP_ARBITER_GET_SHAPES(__arb__, __a__, __b__) cpShape *__a__, *__b__; cpArbiterGetShapes(__arb__, &__a__, &__b__);
    var
        a: chipmunk.Shape
        b: chipmunk.Shape
        points: seq[chipmunk.Vect] = @[]
    arb.shapes(addr(a), addr(b))
    data.draw_bounding_box(b.bB, data.CHIPMUNK_RED)
    inc(contact_count)

proc crush_force_calculator(body: Body, arb: chipmunk.Arbiter, 
                            custom_data: pointer) {.cdecl.} =
    var j = arb.totalImpulse()
    magnitude_sum += j.vlength()
    vector_sum = vadd(vector_sum, j)
    
proc update_space(dt: cdouble) =
    impulse_sum = chipmunk.vzero
    scaleStaticBody.eachArbiter(BodyArbiterIteratorFunc(impulse_calculator), nil)
    # Calculate the force of the scale
    force = impulse_sum.vlength() / dt
    weight = vdot(space.gravity, impulse_sum) / (space.gravity.vlengthsq()*dt)
    
    # Get the number of shapes touching the ball
    contact_count = 0
    ballBody.eachArbiter(BodyArbiterIteratorFunc(contact_counter), nil)
    
    # Get the force pressing on the ball
    magnitude_sum = 0.0f
    vector_sum = chipmunk.vzero
    ballBody.eachArbiter(BodyArbiterIteratorFunc(crush_force_calculator), nil)
    crush_force = (magnitude_sum - vectorSum.vlength()) * dt

proc init_space() = 
    space = newSpace()
    space.iterations = 30
    space.gravity = chipmunk.v(0, -300)
    space.collisionSlop = 0.5
    space.sleepTimeThreshold = 1.0f

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

    scaleStaticBody = space.addBody(newStaticBody())
    shape = space.addShape(
        newSegmentShape(
            scale_static_body, 
            chipmunk.Vect(x: -240, y: -180), 
            chipmunk.Vect(x: -140, y: -180), 
            4.0
        )
    )
    shape.elasticity = 1.0
    shape.friction = 1.0
    shape.filter = data.NOT_GRABBABLE_FILTER

    # add some boxes to stack on the scale
    for i in 0..4:
        body = space.addBody(newBody(1.0f, momentForBox(1.0f, 30.0f, 30.0f)))
        body.position = chipmunk.v(0.0, float(i)*32 - 220)
        
        shape = space.addShape(newBoxShape(body, 30.0f, 30.0f, 0.0))
        shape.elasticity = 0.0
        shape.friction = 0.8
        shape.set_random_color()

    # Add a ball that we'll track which objects are beneath it.
    var radius = 15.0f
    ball_body = space.addBody(
        newBody(1.0f, momentForCircle(10.0f, 0.0f, radius, chipmunk.vzero))
    )
    ball_body.position = chipmunk.v(120, -240 + radius+5)
    
    shape = space.addShape(newCircleShape(ball_body, radius, chipmunk.vzero))
    shape.elasticity = 0.0
    shape.friction = 0.9
    shape.set_random_color()


## Procs for usage in the chipmunk_demo module
proc init*() {.procvar.} =
    init_space()

proc update*(dt: cdouble) {.procvar.} = 
    space.step(dt)
    update_space(dt)

proc draw*() {.procvar.} =
    space.default_draw_implementation()
    data.draw_text(
        "Place objects on the scale to weigh them. The ball marks the shapes it's sitting on.",
        Vect(x: DEMO_TEXT_X_OFFSET, y: DEMO_TEXT_Y_OFFSET_LINE_0)
    )
    data.draw_text(
        "Total force: $1, Total weight: $2. The ball is touching $3 shapes." % [
            fmt"{force:5.2f}",
            fmt"{weight:5.2f}",
            $contact_count
        ],
        Vect(x: DEMO_TEXT_X_OFFSET, y: DEMO_TEXT_Y_OFFSET_LINE_1)
    )
    if crush_force > 10.0:
        data.draw_text(
            "The ball is being crushed. (f: $1)" % fmt"{crush_force:.2f}",
            Vect(x: DEMO_TEXT_X_OFFSET, y: DEMO_TEXT_Y_OFFSET_LINE_2)
        )
    else:
        data.draw_text(
            "The ball is not being crushed. (f: $1)" % fmt"{crush_force:.2f}",
            Vect(x: DEMO_TEXT_X_OFFSET, y: DEMO_TEXT_Y_OFFSET_LINE_2)
        )

proc get_space*(): chipmunk.Space {.procvar.} =
    result = space

proc clean_up*() {.procvar.} =
    space.eachShape(data.clean_up_shape_color, nil)
    space.clean_up_children()
    space.destroy()


