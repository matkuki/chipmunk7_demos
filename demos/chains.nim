
import
    ../chipmunk,
    ../data,
    sdl2,
    math,
    random,
    strutils,
    strfmt

const
    CHAIN_COUNT = 8
    LINK_COUNT = 10
    
var space: chipmunk.Space


proc breakable_joint_post_step_remove(space: chipmunk.Space, 
                                      joint: chipmunk.Constraint, 
                                      unused: pointer) {.cdecl.} =
    space.removeConstraint(joint)
    joint.destroy()

proc breakable_joint_post_solve(joint: chipmunk.Constraint, 
                                space: chipmunk.Space) {.cdecl.} =
    var 
        dt: chipmunk.Float = space.currentTimeStep()
        # Convert the impulse to a force by dividing it by the timestep.
        force: chipmunk.Float = joint.impulse() / dt
        maxForce: chipmunk.Float = joint.maxForce

    # If the force is almost as big as the joint's max force, break it.
    if force > (0.9*maxForce):
        discard space.addPostStepCallback(
            cast[PostStepFunc](breakable_joint_post_step_remove), 
            joint, 
            nil
        )

proc init_space() =
    space = newSpace()
    space.iterations = 30
    space.gravity = chipmunk.v(0, -100)
    space.sleepTimeThreshold = 0.5f
    
    var
        body, static_body: chipmunk.Body = space.staticBody()
        shape: chipmunk.Shape
    
    # Create segments around the edge of the screen.
    shape = space.addShape(
        space.staticBody().newSegmentShape(
            chipmunk.v(-320,-240), 
            chipmunk.v(-320,240), 
            0.0f
        )
    )
    shape.elasticity = 1.0
    shape.friction = 1.0
    shape.filter = data.NOT_GRABBABLE_FILTER
    
    shape = space.addShape(
        space.staticBody().newSegmentShape(
            chipmunk.v(320,-240), 
            chipmunk.v(320,240), 
            0.0f
        )
    )
    shape.elasticity = 1.0
    shape.friction = 1.0
    shape.filter = data.NOT_GRABBABLE_FILTER
    
    shape = space.addShape(
        space.staticBody().newSegmentShape(
            chipmunk.v(-320,-240), 
            chipmunk.v(320,-240), 
            0.0f
        )
    )
    shape.elasticity = 1.0
    shape.friction = 1.0
    shape.filter = data.NOT_GRABBABLE_FILTER
    
    shape = space.addShape(
        space.staticBody().newSegmentShape(
            chipmunk.v(-320,240), 
            chipmunk.v(320,240), 
            0.0f
        )
    )
    shape.elasticity = 1.0
    shape.friction = 1.0
    shape.filter = data.NOT_GRABBABLE_FILTER
    
    var
        mass: chipmunk.Float = 1
        width: chipmunk.Float = 20
        height: chipmunk.Float = 30
        spacing: chipmunk.Float = width * 0.3
    
    # Add lots of boxes.
    for i in 0..CHAIN_COUNT-1:
        var prev: chipmunk.Body = nil
        
        for j in 0..LINK_COUNT-1:
            var pos: chipmunk.Vect = chipmunk.v(
                40*(float(i) - (CHAIN_COUNT - 1)/2.0), 
                240 - (float(j) + 0.5)*height - (float(j) + 1)*spacing
            )
            
            body = space.addBody(
                newBody(mass, momentForBox(mass, width, height))
            )
            body.position = pos
            
            shape = space.addShape(
                newSegmentShape(
                    body, 
                    chipmunk.v(0, (height - width)/2.0), 
                    chipmunk.v(0, (width - height)/2.0), 
                    width/2.0
                )
            )
            shape.friction = 0.8
            shape.set_random_color()
            
            var
                breakingForce: chipmunk.Float = 80000
                constraint: chipmunk.Constraint = nil
            if prev == nil:
                constraint = space.addConstraint(
                    body.newSlideJoint(
                        staticBody, 
                        chipmunk.v(0, height/2), 
                        chipmunk.v(pos.x, 240), 
                        0, 
                        spacing
                    )
                )
            else:
                constraint = space.addConstraint(
                    body.newSlideJoint(
                        prev, 
                        chipmunk.v(0, height/2), 
                        chipmunk.v(0, -height/2), 
                        0, 
                        spacing
                    )
                )
            
            constraint.maxForce = breakingForce
            constraint.postSolveFunc = breakable_joint_post_solve
            constraint.collideBodies = false
            
            prev = body
            
    var radius: chipmunk.Float = 15.0f
    body = space.addBody(
        newBody(10.0f, momentForCircle(10.0f, 0.0f, radius, chipmunk.vzero))
    )
    body.position = chipmunk.v(0, -240 + radius+5)
    body.velocity = chipmunk.v(0, 300)

    shape = space.addShape(newCircleShape(body, radius, chipmunk.vzero))
    shape.elasticity = 0.0
    shape.friction = 0.9

    
## Procs for usage in the chipmunk_demo module
proc init*() {.procvar.} =
    init_space()

proc update*(dt: cdouble) {.procvar.} = 
    space.step(dt)

proc draw*() {.procvar.} =
    space.default_draw_implementation()
    data.draw_text(
        "A bead curtain from the 70's.",
        Vect(x: DEMO_TEXT_X_OFFSET, y: DEMO_TEXT_Y_OFFSET_LINE_1)
    )

proc get_space*(): chipmunk.Space {.procvar.} =
    result = space

proc clean_up*() {.procvar.} =
    space.eachShape(data.clean_up_shape_color, nil)
    space.clean_up_children()
    space.destroy()
