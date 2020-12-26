
import
    ../chipmunk,
    ../data,
    sdl2,
    math,
    random,
    strutils


const 
    COLLISION_TYPE_STICKY = 1
    STICK_SENSOR_THICKNESS = 2.5
    GRAVITY = 1000.0

var space: chipmunk.Space

proc post_step_add_joint(space: Space, key: pointer, data: pointer) {.cdecl.} = 
  var joint: Constraint = cast[Constraint](key)
  discard space.addConstraint(joint)

proc sticky_pre_solve(arb: chipmunk.Arbiter, space: chipmunk.Space,
                       data: pointer): bool {.cdecl.} = 
    # We want to fudge the collisions a bit to allow shapes to overlap more.
    # This simulates their squishy sticky surface, and more importantly
    # keeps them from separating and destroying the joint.
    # Track the deepest collision point and use that to determine if a rigid collision should occur.
    var 
        deepest: chipmunk.Float = INFINITY
        contacts: chipmunk.ContactPointSet = arb.contactPointSet
    # Grab the contact set and iterate over them.
    for i in 0..contacts.count-1:
        # Sink the contact points into the surface of each shape.
        contacts.points[i].pointA = vsub(contacts.points[i].pointA, vmult(
            contacts.normal, STICK_SENSOR_THICKNESS))
        contacts.points[i].pointB = vadd(contacts.points[i].pointB, vmult(
            contacts.normal, STICK_SENSOR_THICKNESS))
        deepest = fmin(deepest, contacts.points[i].distance)
    # Set the new contact point data.
    arb.contactPointSet = addr(contacts)
    # If the shapes are overlapping enough, then create a
    # joint that sticks them together at the first contact point.
    if arb.userData == nil and deepest <= 0.0:
        var body_a, body_b: chipmunk.Body
        arb.bodies(addr(body_a), addr(body_b))
        # Create a joint at the contact point to hold the body in place.
        var 
            anchor_a: chipmunk.Vect = body_a.worldToLocal(
                contacts.points[0].pointA
            )
            anchor_b: chipmunk.Vect = body_b.worldToLocal(
                contacts.points[0].pointB
            )
            joint: Constraint = newPivotJoint(
                body_a, body_b, anchor_a, anchor_b
            )
        # Give it a finite force for the stickyness.
        joint.maxForce = 3000.0
        # Schedule a post-step() callback to add the joint.
        discard space.addPostStepCallback(post_step_add_joint, joint, nil)
        # Store the joint on the arbiter so we can remove it later.
        arb.userData = joint
    result = deepest <= 0.0
    # Lots more that you could improve upon here as well:
    # * Modify the joint over time to make it plastic.
    # * Modify the joint in the post-step to make it conditionally plastic (like clay).
    # * Track a joint for the deepest contact point instead of the first.
    # * Track a joint for each contact point. (more complicated since you only get one data pointer).

proc post_step_remove_joint(space: Space, key: pointer, 
                             data: pointer) {.cdecl.} = 
    var joint: Constraint = cast[Constraint](key)
    space.removeConstraint(joint)
    joint.destroy()

proc sticky_separate(arb: Arbiter; space: Space; data: pointer) {.cdecl.} = 
    var joint: Constraint = cast[Constraint](arb.userData)
    if joint != nil: 
        # The joint won't be removed until the step is done.
        # Need to disable it so that it won't apply itself.
        # Setting the force to 0 will do just that
        joint.maxForce = 0.0
        # Perform the removal in a post-step() callback.
        discard space.addPostStepCallback(post_step_remove_joint, joint, nil)
        # NULL out the reference to the joint.
        # Not required, but it's a good practice.
        arb.userData = nil

proc init_space() = 
    space = chipmunk.newSpace()
    space.iterations = 10
    space.gravity = chipmunk.Vect(x: 0.0, y: -GRAVITY)
    space.collisionSlop = 2.0
    var 
        static_body: Body = space.static_body()
        shape: Shape
    # Create segments around the edge of the screen.
    shape = space.addShape(
        newSegmentShape(
            static_body, 
            chipmunk.v(-340, -260), 
            chipmunk.v(-340, 260), 
            20.0
        )
    )
    shape.elasticity = 1.0
    shape.friction = 1.0
    shape.filter = data.NOT_GRABBABLE_FILTER
    shape = space.addShape(
        newSegmentShape(
            static_body, 
            chipmunk.v(340, -260), 
            chipmunk.v(340, 260), 
            20.0
        )
    )
    shape.elasticity = 1.0
    shape.friction = 1.0
    shape.filter = data.NOT_GRABBABLE_FILTER
    shape = space.addShape(
        newSegmentShape(
            static_body, 
            chipmunk.v(-340, -260), 
            chipmunk.v(340, -260), 
            20.0
        )
    )
    shape.elasticity = 1.0
    shape.friction = 1.0
    shape.filter = data.NOT_GRABBABLE_FILTER
    shape = space.addShape(
        newSegmentShape(
            static_body, 
            chipmunk.v(-340, 260), 
            chipmunk.v(340, 260), 
            20.0
        )
    )
    shape.elasticity = 1.0
    shape.friction = 1.0
    shape.filter = data.NOT_GRABBABLE_FILTER
    for i in 0..199: 
        var 
            mass: chipmunk.Float = 0.15
            radius: chipmunk.Float = 10.0
            body: Body = space.addBody( 
                newBody(
                    mass, 
                    mass.momentForCircle(0.0, radius, chipmunk.vzero)
                )
            )
        body.position = v(
            flerp(-150.0, 150.0, random.rand(1.0)), 
            flerp(-150.0, 150.0, random.rand(1.0))
        )
        var shape: Shape = space.addShape( 
            newCircleShape(
                body, 
                radius + STICK_SENSOR_THICKNESS, 
                chipmunk.vzero
            )
        )
        shape.friction = 0.9
        shape.collisionType = cast[CollisionType](COLLISION_TYPE_STICKY)
        shape.set_random_color()
    var handler: ptr CollisionHandler = space.addWildcardHandler(
        cast[CollisionType](COLLISION_TYPE_STICKY)
    )
    handler.preSolveFunc = sticky_pre_solve
    handler.separateFunc = sticky_separate


## Procs for usage in the chipmunk_demo module
proc init*() {.procvar.} =
    init_space()

proc update*(dt: cdouble) {.procvar.} = 
    space.step(dt)

proc draw*() {.procvar.} =
    space.default_draw_implementation()
    data.draw_text(
        "Use the mouse to fling the sticky balls.",
        Vect(x: DEMO_TEXT_X_OFFSET, y: DEMO_TEXT_Y_OFFSET_LINE_1)
    )

proc get_space*(): chipmunk.Space {.procvar.} =
    result = space

proc clean_up*() {.procvar.} =
    space.eachShape(data.clean_up_shape_color, nil)
    space.clean_up_children()
    space.destroy()


