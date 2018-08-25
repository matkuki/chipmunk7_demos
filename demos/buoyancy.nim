
import
    ../chipmunk,
    ../data,
    sdl2,
    math,
    random,
    strutils

const
    FLUID_DENSITY = 0.00014
    FLUID_DRAG = 2.0

var space: chipmunk.Space


proc k_scalar_body(body: chipmunk.Body, 
                   point: chipmunk.Vect,
                   n: chipmunk.Vect): chipmunk.Float =
    var rcn: chipmunk.Float = chipmunk.vcross(
        chipmunk.vsub(point, body.position), 
        n
    )
    result = 1.0f/body.mass + rcn*rcn/body.moment

proc water_pre_solve(arb: chipmunk.Arbiter, 
                     space: chipmunk.Space, 
                     p: pointer): bool {.cdecl.} =
    # Ported from C macro:
    #     CP_ARBITER_GET_SHAPES(__arb__, __a__, __b__) cpShape *__a__, *__b__; cpArbiterGetShapes(__arb__, &__a__, &__b__);
    var water, poly: chipmunk.Shape
    arb.shapes(addr(water), addr(poly))
    var
        body: chipmunk.Body = poly.body
        # Get the top of the water sensor bounding box to use as the water level.
        level: chipmunk.Float = water.bB.t
        # Clip the polygon against the water level
        count: int = int(cast[chipmunk.PolyShape](poly).count - 1)
        j = count
        clippedCount: cint = 0
        clipped: seq[chipmunk.Vect] = newSeq[chipmunk.Vect](
            cast[chipmunk.PolyShape](poly).count + 1
        )
    
    for i in 0..count:
        var
            a: chipmunk.Vect = body.localToWorld(
                cast[chipmunk.PolyShape](poly).vert(cint(j))
            )
            b: chipmunk.Vect = body.localToWorld(
                cast[chipmunk.PolyShape](poly).vert(cint(i))
            )
        
        if a.y < level:
            clipped[clippedCount] = a
            clippedCount += 1
        
        var
            a_level: chipmunk.Float = a.y - level
            b_level: chipmunk.Float = b.y - level
        
        if (a_level*b_level) < 0.0f:
            var t: chipmunk.Float = chipmunk.fabs(
                a_level)/(chipmunk.fabs(a_level) + chipmunk.fabs(b_level)
            )
            
            clipped[clippedCount] = chipmunk.vlerp(a, b, t)
            clippedCount += 1
        
        j = i     
    
    # Calculate buoyancy from the clipped polygon area
    var
        clippedArea: chipmunk.Float = areaForPoly(clippedCount, addr(clipped[0]), 0.0f)
        displacedMass: chipmunk.Float = clippedArea*FLUID_DENSITY
        centroid: chipmunk.Vect = centroidForPoly(clippedCount, addr(clipped[0]))
    
    data.debug_draw_polygon(
        clippedCount, 
        addr(clipped[0]), 
        0.0f, 
        data.rgba_color(0, 0, 1, 1), 
        data.rgba_color(0, 0, 1, 0.1),
        nil
    )
    data.debug_draw_dot(5, centroid, data.rgba_color(0, 0, 1, 1), nil)
    
    var
        dt: chipmunk.Float = space.currentTimeStep
        g: chipmunk.Vect = space.gravity
    
    # Apply the buoyancy force as an impulse.
    body.applyImpulseAtWorldPoint(
        chipmunk.vmult(g, -displacedMass*dt), centroid
    )
    
    # Apply linear damping for the fluid drag.
    var
        v_centroid: chipmunk.Vect = body.velocityAtWorldPoint(centroid)
        k: chipmunk.Float = k_scalar_body(body, centroid, chipmunk.vnormalize(v_centroid))
        damping: chipmunk.Float = clippedArea*FLUID_DRAG*FLUID_DENSITY
        v_coef: chipmunk.Float = math.exp(-damping*dt*k) # linear drag
#        v_coef: chipmunk.Float = 1.0/(1.0 + damping*dt*chipmunk.vlength(v_centroid)*k) # quadratic drag
    body.applyImpulseAtWorldPoint(
        chipmunk.vmult(
            chipmunk.vsub(chipmunk.vmult(v_centroid, v_coef), v_centroid), 1.0/k
        ), 
        centroid
    )
    
    # Apply angular damping for the fluid drag.
    var
        cog: chipmunk.Vect = body.localToWorld(body.centerOfGravity)
        w_damping: chipmunk.Float = momentForPoly(
            FLUID_DRAG*FLUID_DENSITY*clippedArea, 
            clippedCount, 
            addr(clipped[0]), 
            chipmunk.vneg(cog), 
            0.0f
        )
    body.angularVelocity = body.angularVelocity * math.exp(-w_damping*dt/body.moment)
    
    result = true

proc init_space() =
    space = newSpace()
    space.iterations = 30
    space.gravity = chipmunk.v(0, -500)
#    space.damping = 0.5
    space.sleepTimeThreshold = 0.5f
    space.collisionSlop = 0.5f
    
    var
        body, static_body: chipmunk.Body = space.staticBody()
        shape: chipmunk.Shape
    
    template create_segment(point_from, point_to: chipmunk.Vect, 
                            radius: chipmunk.Float) =
        shape = space.addShape(
            space.staticBody().newSegmentShape(point_from, point_to, radius)
        )
        shape.elasticity = 1.0
        shape.friction = 1.0
        shape.filter = data.NOT_GRABBABLE_FILTER
    
    # Create segments around the edge of the screen.
    create_segment(chipmunk.v(-320,-240), chipmunk.v(-320,240), 0.0)
    create_segment(chipmunk.v(320,-240), chipmunk.v(320,240), 0.0)
    create_segment(chipmunk.v(-320,-240), chipmunk.v(320,-240), 0.0)
    create_segment(chipmunk.v(-320,240), chipmunk.v(320,240), 0.0)
    
    block add_bucket_with_water:
        # Add the edges of the bucket
        var
            bb: chipmunk.BB = newBB(-300, -200, 100, 0)
            radius: chipmunk.Float = 5.0
        
        create_segment(chipmunk.v(bb.l, bb.b), chipmunk.v(bb.l, bb.t), radius)
        create_segment(chipmunk.v(bb.r, bb.b), chipmunk.v(bb.r, bb.t), radius)
        create_segment(chipmunk.v(bb.l, bb.b), chipmunk.v(bb.r, bb.b), radius)
        
        # Add the sensor for the water.
        shape = space.addShape(newBoxShape(staticBody, bb, 0.0))
        shape.sensor = true
        shape.collisionType = cast[CollisionType](1)
        shape.set_color(data.rgba_color(1.0, 1.0, 1.0, 0.1))


    block first_floater:
        var
            width: chipmunk.Float = 200.0f
            height: chipmunk.Float = 50.0f
            mass: chipmunk.Float = 0.3*FLUID_DENSITY*width*height
            moment: chipmunk.Float = momentForBox(mass, width, height)
        
        body = space.addBody(newBody(mass, moment))
        body.position = chipmunk.v(-50, -100)
        body.velocity = chipmunk.v(0, -100)
        body.angularVelocity = 1.0
        
        shape = space.addShape(newBoxShape(body, width, height, 0.0))
        shape.friction = 0.8f
        shape.set_random_color()
    
    block second_floater:
        var
            width: chipmunk.Float = 40.0f
            height: chipmunk.Float = width*2
            mass: chipmunk.Float = 0.3*FLUID_DENSITY*width*height
            moment: chipmunk.Float = momentForBox(mass, width, height)
        
        body = space.addBody(newBody(mass, moment))
        body.position = chipmunk.v(-200, -50)
        body.velocity = chipmunk.v(0, -100)
        body.angularVelocity = 1.0
        
        shape = space.addShape(newBoxShape(body, width, height, 0.0))
        shape.friction = 0.8f
        shape.set_random_color()
    
    var
        handler: ptr chipmunk.CollisionHandler = space.addCollisionHandler(
            cast[CollisionType](1), cast[CollisionType](0)
        )
    handler.preSolveFunc = CollisionPreSolveFunc(water_pre_solve)
    

## Procs for usage in the chipmunk_demo module
proc init*() {.procvar.} =
    init_space()

proc update*(dt: cdouble) {.procvar.} = 
    space.step(dt)

proc draw*() {.procvar.} =
    space.default_draw_implementation()
    data.draw_text(
        "Buoyancy aka liquid testing.",
        Vect(x: DEMO_TEXT_X_OFFSET, y: DEMO_TEXT_Y_OFFSET_LINE_1)
    )

proc get_space*(): chipmunk.Space {.procvar.} =
    result = space

proc clean_up*() {.procvar.} =
    space.eachShape(data.clean_up_shape_color, nil)
    space.clean_up_children()
    space.destroy()