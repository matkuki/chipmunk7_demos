
import
    ../chipmunk,
    ../data,
    sdl2,
    math,
    random,
    strutils,
    strfmt

var space: chipmunk.Space


proc springForce(spring: chipmunk.Constraint, 
                 dist: chipmunk.Float): chipmunk.Float {.cdecl.} = 
    var clamp: chipmunk.Float = 20.0
    result = fclamp(
        DampedSpring(spring).restLength() - dist, 
        -clamp, 
        clamp
    ) * DampedSpring(spring).stiffness

proc new_spring(a, b: Body, anchor_A, anchor_B: chipmunk.Vect, 
                rest_length, stiff, damp: chipmunk.Float): Constraint = 
    result = newDampedSpring(
        a, b, anchor_A, anchor_B, rest_length, stiff, damp
    )
    DampedSpring(result).springForceFunc = springForce

proc add_bar(space: Space, a, b: chipmunk.Vect, group: cint): chipmunk.Body = 
    var 
        center: chipmunk.Vect = vmult(vadd(a, b), 1.0 / 2.0)
        length: chipmunk.Float = vlength(vsub(b, a))
        mass: chipmunk.Float = length / 160.0
    result = space.addBody(newBody(mass, mass * length * length / 12.0))
    result.position = center
    var shape: Shape = space.addShape(
        result.newSegmentShape(vsub(a, center), vsub(b, center), 10.0)
    )
    shape.filter = ShapeFilter(
        group: cast[Group](group),
        categories: data.GRABBABLE_MASK_BIT,
        mask: data.GRABBABLE_MASK_BIT
    )
    shape.set_random_color()

proc init_space() = 
    space = newSpace()
    var 
        static_body = space.staticBody()
        body1: chipmunk.Body = add_bar(space, chipmunk.v(- 240, 160), chipmunk.v(- 160, 80), 1)
        body2: chipmunk.Body = add_bar(space, chipmunk.v(- 160, 80), chipmunk.v(- 80, 160), 1)
        body3: chipmunk.Body = add_bar(space, chipmunk.v(0, 160), chipmunk.v(80, 0), 0)
        body4: chipmunk.Body = add_bar(space, chipmunk.v(160, 160), chipmunk.v(240, 160), 0)
        body5: chipmunk.Body = add_bar(space, chipmunk.v(- 240, 0), chipmunk.v(- 160, - 80), 2)
        body6: chipmunk.Body = add_bar(space, chipmunk.v(- 160, - 80), chipmunk.v(- 80, 0), 2)
        body7: chipmunk.Body = add_bar(space, chipmunk.v(- 80, 0), chipmunk.v(0, 0), 2)
        body8: chipmunk.Body = add_bar(space, chipmunk.v(0, - 80), chipmunk.v(80, - 80), 0)
        body9: chipmunk.Body = add_bar(space, chipmunk.v(240, 80), chipmunk.v(160, 0), 3)
        body10: chipmunk.Body = add_bar(space, chipmunk.v(160, 0), chipmunk.v(240, - 80), 3)
        body11: chipmunk.Body = add_bar(space, chipmunk.v(- 240, - 80), chipmunk.v(- 160, - 160), 4)
        body12: chipmunk.Body = add_bar(space, chipmunk.v(- 160, - 160), chipmunk.v(- 80, - 160), 4)
        body13: chipmunk.Body = add_bar(space, chipmunk.v(0, - 160), chipmunk.v(80, - 160), 0)
        body14: chipmunk.Body = add_bar(space, chipmunk.v(160, - 160), chipmunk.v(240, - 160), 0)
    discard space.addConstraint(newPivotJoint(body1, body2, chipmunk.v(40, - 40), chipmunk.v(- 40, - 40)))
    discard space.addConstraint(newPivotJoint(body5, body6, chipmunk.v(40, - 40), chipmunk.v(- 40, - 40)))
    discard space.addConstraint(newPivotJoint(body6, body7, chipmunk.v(40, 40), chipmunk.v(- 40, 0)))
    discard space.addConstraint(newPivotJoint(body9, body10, chipmunk.v(- 40, - 40), chipmunk.v(- 40, 40)))
    discard space.addConstraint(newPivotJoint(body11, body12, chipmunk.v(40, - 40), chipmunk.v(- 40, 0)))
    const
        stiff: chipmunk.Float = 100.0
        damp: chipmunk.Float = 0.5
    discard space.addConstraint(new_spring(staticBody, body1, chipmunk.v(- 320, 240), chipmunk.v(- 40, 40), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(staticBody, body1, chipmunk.v(- 320, 80), chipmunk.v(- 40, 40), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(staticBody, body1, chipmunk.v(- 160, 240), chipmunk.v(- 40, 40), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(staticBody, body2, chipmunk.v(- 160, 240), chipmunk.v(40, 40), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(staticBody, body2, chipmunk.v(0, 240), chipmunk.v(40, 40), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(staticBody, body3, chipmunk.v(80, 240), chipmunk.v(- 40, 80), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(staticBody, body4, chipmunk.v(80, 240), chipmunk.v(- 40, 0), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(staticBody, body4, chipmunk.v(320, 240), chipmunk.v(40, 0), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(staticBody, body5, chipmunk.v(- 320, 80), chipmunk.v(- 40, 40), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(staticBody, body9, chipmunk.v(320, 80), chipmunk.v(40, 40), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(staticBody, body10, chipmunk.v(320, 0), chipmunk.v(40, - 40), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(staticBody, body10, chipmunk.v(320, - 160), chipmunk.v(40, - 40), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(staticBody, body11, chipmunk.v(- 320, - 160), chipmunk.v(- 40, 40), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(staticBody, body12, chipmunk.v(- 240, - 240), chipmunk.v(- 40, 0), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(staticBody, body12, chipmunk.v(0, - 240), chipmunk.v(40, 0), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(staticBody, body13, chipmunk.v(0, - 240), chipmunk.v(- 40, 0), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(staticBody, body13, chipmunk.v(80, - 240), chipmunk.v(40, 0), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(staticBody, body14, chipmunk.v(80, - 240), chipmunk.v(- 40, 0), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(staticBody, body14, chipmunk.v(240, - 240), chipmunk.v(40, 0), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(staticBody, body14, chipmunk.v(320, - 160), chipmunk.v(40, 0), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(body1, body5, chipmunk.v(40, - 40), chipmunk.v(- 40, 40), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(body1, body6, chipmunk.v(40, - 40), chipmunk.v(40, 40), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(body2, body3, chipmunk.v(40, 40), chipmunk.v(- 40, 80), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(body3, body4, chipmunk.v(- 40, 80), chipmunk.v(- 40, 0), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(body3, body4, chipmunk.v(40, - 80), chipmunk.v(- 40, 0), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(body3, body7, chipmunk.v(40, - 80), chipmunk.v(40, 0), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(body3, body7, chipmunk.v(- 40, 80), chipmunk.v(- 40, 0), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(body3, body8, chipmunk.v(40, - 80), chipmunk.v(40, 0), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(body3, body9, chipmunk.v(40, - 80), chipmunk.v(- 40, - 40), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(body4, body9, chipmunk.v(40, 0), chipmunk.v(40, 40), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(body5, body11, chipmunk.v(- 40, 40), chipmunk.v(- 40, 40), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(body5, body11, chipmunk.v(40, - 40), chipmunk.v(40, - 40), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(body7, body8, chipmunk.v(40, 0), chipmunk.v(- 40, 0), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(body8, body12, chipmunk.v(- 40, 0), chipmunk.v(40, 0), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(body8, body13, chipmunk.v(- 40, 0), chipmunk.v(- 40, 0), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(body8, body13, chipmunk.v(40, 0), chipmunk.v(40, 0), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(body8, body14, chipmunk.v(40, 0), chipmunk.v(- 40, 0), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(body10, body14, chipmunk.v(40, - 40), chipmunk.v(- 40, 0), 0.0, stiff, damp))
    discard space.addConstraint(new_spring(body10, body14, chipmunk.v(40, - 40), chipmunk.v(- 40, 0), 0.0, stiff, damp))


## Procs for usage in the chipmunk_demo module
proc init*() {.procvar.} =
    init_space()

proc update*(dt: cdouble) {.procvar.} = 
    space.step(dt)

proc draw*() {.procvar.} =
    space.default_draw_implementation()
    data.draw_text(
        "Move the sticks to see the springs in action.",
        Vect(x: DEMO_TEXT_X_OFFSET, y: DEMO_TEXT_Y_OFFSET_LINE_1)
    )

proc get_space*(): chipmunk.Space {.procvar.} =
    result = space

proc clean_up*() {.procvar.} =
    space.eachShape(data.clean_up_shape_color, nil)
    space.clean_up_children()
    space.destroy()