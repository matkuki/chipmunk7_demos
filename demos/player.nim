
import
    ../chipmunk,
    ../data,
    sdl2,
    math,
    random,
    strutils


const
    PLAYER_VELOCITY = 500.0
    PLAYER_GROUND_ACCEL_TIME = 0.1
    PLAYER_GROUND_ACCEL = (PLAYER_VELOCITY / PLAYER_GROUND_ACCEL_TIME)
    PLAYER_AIR_ACCEL_TIME = 0.25
    PLAYER_AIR_ACCEL = (PLAYER_VELOCITY / PLAYER_AIR_ACCEL_TIME)
    JUMP_HEIGHT = 50.0
    JUMP_BOOST_HEIGHT = 55.0
    FALL_VELOCITY = 900.0
    GRAVITY = 2000.0

var
    space: chipmunk.Space
    player_body*: chipmunk.Body = nil
    player_shape*: chipmunk.Shape = nil
    remaining_boost*: chipmunk.Float = 0
    grounded*: bool = false
    last_jump_state*: bool = false

proc select_player_ground_normal(body: chipmunk.Body, arb: chipmunk.Arbiter,
                                 groundNormal: ptr chipmunk.Vect) {.cdecl.} =
    var n: chipmunk.Vect = vneg(arb.normal)
    if n.y > ground_normal.y:
        (ground_normal[]) = n

proc player_update_velocity(body: chipmunk.Body, gravity: chipmunk.Vect, 
                            damping: chipmunk.Float, dt: chipmunk.Float) {.cdecl.} = 
    var jump_State: bool = (data.keyboard_vector.y > 0.0)
    # Grab the grounding normal from last frame
    var ground_normal: chipmunk.Vect = chipmunk.vzero
    playerBody.eachArbiter(
        cast[BodyArbiterIteratorFunc](select_player_ground_normal),
        addr(ground_normal)
    )
    grounded = (ground_normal.y > 0.0)
    if ground_normal.y < 0.0: 
        remaining_boost = 0.0
    var 
        boost: bool = (jump_state and remaining_boost > 0.0)
        g: chipmunk.Vect = (if boost: chipmunk.vzero else: gravity)
    body.updateVelocity(g, damping, dt)
    # Target horizontal speed for air/ground control
    var target_vx: chipmunk.Float = PLAYER_VELOCITY * keyboard_vector.x
    # Update the surface velocity and friction
    # Note that the "feet" move in the opposite direction of the player.
    var surface_velocity = chipmunk.Vect(x: -target_vx, y: 0.0)
    player_shape.surfaceVelocity = surface_velocity
    player_shape.friction = (if grounded: PLAYER_GROUND_ACCEL/GRAVITY else: 0.0)
    # Apply air control if not grounded
    if grounded == false: 
        # Smoothly accelerate the velocity
        player_body.velocity = chipmunk.Vect(
            x: flerpconst(player_body.velocity.x, 
                   target_vx, 
                   PLAYER_AIR_ACCEL * dt
               ),
            y: player_body.velocity.y
        )
    body.velocity = chipmunk.Vect(
        x: body.velocity.x,
        y: fclamp(body.velocity.y, -FALL_VELOCITY, INFINITY)
    )

proc init_space() =
    space = chipmunk.newSpace()
    space.iterations = 10
    space.gravity = chipmunk.Vect(x: 0.0, y: -GRAVITY)
    var 
        body: chipmunk.Body
        static_body: chipmunk.Body = space.staticBody()
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
    
    shape = space.addShape(
                newSegmentShape(
                    static_body, 
                    chipmunk.Vect(x: -320, y: 240), 
                    chipmunk.Vect(x: 320, y: 240), 
                    0.0
                )
            )
    shape.elasticity = 1.0
    shape.friction = 1.0
    shape.filter = data.NOT_GRABBABLE_FILTER
    
    # Set up the player
    body = space.addBody(newBody(1.0, INFINITY))
    body.position = chipmunk.Vect(x: 0.0, y: 0.0)
    body.velocityUpdateFunc = player_update_velocity
    player_body = body
    shape = space.addShape(
        newBoxShape(
            body=body, 
            box=newBB(-30.0, -30.0, 25.0, 50.0),
            radius=10.0
        )
    )
    shape.elasticity = 0.0
    shape.friction = 0.0
    shape.collisionType = cast[CollisionType](1)
    shape.userData = cast[chipmunk.DataPointer](
        alloc0(sizeof(chipmunk.SpaceDebugColor))
    )
    var color = cast[ptr chipmunk.SpaceDebugColor](shape.userData)
    color[] = chipmunk.SpaceDebugColor(r:1.0, g:0.7, b:0.0, a:1.0)
    player_shape = shape
    
    # Add some boxes to jump on
    for i in 0..5:
        for j in 0..2:
            body = space.addBody(newBody(4.0, INFINITY))
            body.position = chipmunk.Vect(
                x: 100.0 + float(j) * 60.0, 
                y: -200.0 + float(i) * 60.0
            )
            shape = space.addShape(newBoxShape(body, 50, 50, 0.0))
            shape.elasticity = 0.0
            shape.friction = 0.7
            shape.set_random_color()
    
    # Add a circle for fun
    body = space.addBody(newBody(1.0, 1.0))
    body.position = chipmunk.Vect(
        x: -200.0, 
        y: 0.0
    )
    shape = space.addShape(newCircleShape(body, 30.0, chipmunk.v(0.0, 0.0)))
    shape.elasticity = 0.1
    shape.friction = 0.7


## Procs for usage in the chipmunk_demo module
proc init*() {.procvar.} =
    init_space()

proc update*(dt: cdouble) {.procvar.}  = 
    var jump_state: bool = (data.keyboard_vector.y > 0.0)
    # If the jump key was just pressed this frame, jump!
    if (jump_state == true) and 
     (last_jump_state == false) and 
     (grounded == true): 
        var jump_velocity: chipmunk.Float = math.sqrt(2.0 * JUMP_HEIGHT * GRAVITY)
        player_body.velocity = vadd(
            playerBody.velocity, 
            chipmunk.Vect(x:0.0, y:jump_velocity)
        )
        remaining_boost = JUMP_BOOST_HEIGHT / jump_velocity
    space.step(dt)
    remaining_boost -= dt
    last_jump_state = jump_state

proc input*(in_space: var chipmunk.Space, 
            event: sdl2.EventType, key_event: sdl2.KeyboardEventObj, 
            key: cint, modifier: bool) {.procvar.} =
    if event == sdl2.EventType.KeyDown:
        if key_event.repeat == false:
            if key == K_UP:
                data.keyboard_vector.y += 1.0
            elif key == K_DOWN:
                data.keyboard_vector.y -= 1.0
            elif key == K_RIGHT:
                data.keyboard_vector.x += 1.0
            elif key == K_LEFT:
                data.keyboard_vector.x -= 1.0
    elif event == sdl2.EventType.KeyUp:
        if key_event.repeat == false:
            if key == K_UP:
                data.keyboard_vector.y -= 1.0
            elif key == K_DOWN:
                data.keyboard_vector.y += 1.0
            elif key == K_RIGHT:
                data.keyboard_vector.x -= 1.0
            elif key == K_LEFT:
                data.keyboard_vector.x += 1.0

proc draw*() {.procvar.} =
    space.default_draw_implementation()
    data.draw_text(
        "Move the 'player'(round rectangle) using UP, DOWN, LEFT, RIGHT.",
        Vect(x: DEMO_TEXT_X_OFFSET, y: DEMO_TEXT_Y_OFFSET_LINE_1)
    )
    data.draw_text(
        "Move the boxes/circle around with the mouse.",
        Vect(x: DEMO_TEXT_X_OFFSET, y: DEMO_TEXT_Y_OFFSET_LINE_2)
    )

proc get_space*(): chipmunk.Space {.procvar.} =
    result = space

proc clean_up*() {.procvar.} =
    space.eachShape(data.clean_up_shape_color, nil)
    space.clean_up_children()
    space.destroy()

