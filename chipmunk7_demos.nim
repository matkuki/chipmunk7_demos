
import
    chipmunk,
    sdl2,
    sdl2/gfx,
    os,
    math,
    random,
    strutils,
    strformat,
    data,
    demos / [
        logo_smash,
        player,
        sticky,
        spaces,
        weight_scale,
        pyramid,
        springs,
        dominos,
        chains,
        buoyancy
    ]

var
    running = true
    pause = false
    step = false
    fps_manager: gfx.FPSmanager
    frame_rate: cint
    time_delta: float
    selected_demo: int
    # Input variables
    numkeys: ptr int = nil
    key_states: array[0 .. SDL_NUM_SCANCODES.int, uint8]
    event: sdl2.Event
    event_list: seq[sdl2.Event]
    # Cross module functions
    init_func: proc()
    update_func: proc(dt: cdouble)
    input_func: proc(space: var chipmunk.Space, event: sdl2.EventType, 
                     key_event: sdl2.KeyboardEventObj, 
                     key: cint, modifier: bool)
    draw_func: proc()
    get_space_func: proc(): chipmunk.Space
    clean_up_func: proc()
    # Various globals
    current_space: chipmunk.Space
    mouse_body: chipmunk.Body = nil
    mouse_joint: chipmunk.Constraint = nil

proc select_demo(number: int) =
    var clean_up_needed {.global.} = false
    if clean_up_needed == true:
        clean_up_needed = false
        clean_up_func()
    case number:
        of 1:
            init_func = logo_smash.init
            update_func = logo_smash.update
            input_func = nil
            draw_func = logo_smash.draw
            get_space_func = logo_smash.get_space
            clean_up_func = logo_smash.clean_up
        
        of 2:
            init_func = player.init
            update_func = player.update
            input_func = player.input
            draw_func = player.draw
            get_space_func = player.get_space
            clean_up_func = player.clean_up
        
        of 3:
            init_func = sticky.init
            update_func = sticky.update
            input_func = nil
            draw_func = sticky.draw
            get_space_func = sticky.get_space
            clean_up_func = sticky.clean_up
        
        of 4:
            init_func = spaces.init
            update_func = spaces.update
            input_func = spaces.input
            draw_func = spaces.draw
            get_space_func = spaces.get_space
            clean_up_func = spaces.clean_up
        
        of 5:
            init_func = weight_scale.init
            update_func = weight_scale.update
            input_func = nil
            draw_func = weight_scale.draw
            get_space_func = weight_scale.get_space
            clean_up_func = weight_scale.clean_up
        
        of 6:
            init_func = pyramid.init
            update_func = pyramid.update
            input_func = nil
            draw_func = pyramid.draw
            get_space_func = pyramid.get_space
            clean_up_func = pyramid.clean_up
        
        of 7:
            init_func = springs.init
            update_func = springs.update
            input_func = nil
            draw_func = springs.draw
            get_space_func = springs.get_space
            clean_up_func = springs.clean_up
        
        of 8:
            init_func = dominos.init
            update_func = dominos.update
            input_func = nil
            draw_func = dominos.draw
            get_space_func = dominos.get_space
            clean_up_func = dominos.clean_up
        
        of 9:
            init_func = chains.init
            update_func = chains.update
            input_func = nil
            draw_func = chains.draw
            get_space_func = chains.get_space
            clean_up_func = chains.clean_up
        
        of 0:
            init_func = buoyancy.init
            update_func = buoyancy.update
            input_func = nil
            draw_func = buoyancy.draw
            get_space_func = buoyancy.get_space
            clean_up_func = buoyancy.clean_up
        
        else:
            echo "Invalid demo number!"
            return
    
    # Initialize the selected demo
    init_func()
    current_space = get_space_func()
    clean_up_needed = true
    selected_demo = number

proc draw_info() =
    const
        TEXT_X_OFFSET_0 = 10.0
        TEXT_X_OFFSET_1 = 480.0
        TEXT_Y_OFFSET_0 = 10.0
    
    var 
        demo_time {.global.}: float = 0.0
        info_string: string = ""
    # Store the running time
    demo_time += time_delta
    
    when defined(chipmunkUnsafe):
        # Initialize the information variables
        var
            max_arbiters {.global.}: int = 0
            max_points {.global.}: int = 0
            max_constraints {.global.}: int = 0
            arbiter_count: int = current_space.arbiters.num
            arbiters = cast[ptr array[0, chipmunk.Arbiter]](
                current_space.arbiters.arr
            )
            points: int = 0
            body_array = current_space.dynamicBodies
            bodies = cast[ptr array[0, chipmunk.Body]](body_array.arr)
            ke: chipmunk.Float = 0.0
    
        for i in 0..arbiter_count-1:
            points += arbiters[i].count
    
        var constraints: int = (current_space.constraints.num + points) * 
                                current_space.iterations
        max_arbiters = if arbiter_count > max_arbiters:
                           arbiter_count 
                       else: 
                           max_arbiters
        max_points = if points > max_points: points else: max_points
        max_constraints = if constraints > max_constraints:
                              constraints
                          else:
                              max_constraints
    
        for i in 0..body_array.num-1:
            if (bodies[i].m == INFINITY) or (bodies[i].i == INFINITY):
                continue
            ke += bodies[i].m * vdot(bodies[i].v, bodies[i].v) +
                  bodies[i].i * bodies[i].w * bodies[i].w
    
        # Draw the statistics text
        info_string = "Arbiters: $1 ($2)" % [$arbiter_count, $max_arbiters]
        data.draw_text(info_string, Vect(x: TEXT_X_OFFSET_1, y: TEXT_Y_OFFSET_0))
        info_string = "Contact Points: $1 ($2)" % [$points, $max_points]
        data.draw_text(
            info_string, 
            Vect(x: TEXT_X_OFFSET_1, y: TEXT_Y_OFFSET_0 + data.FONT_SIZE)
        )
        info_string = "Other Constraints: $1" % $current_space.constraints.num
        data.draw_text(
            info_string, 
            Vect(x: TEXT_X_OFFSET_1, y: TEXT_Y_OFFSET_0 + 2*data.FONT_SIZE)
        )
        info_string = "Iterations: $1" % $current_space.iterations
        data.draw_text(
            info_string, 
            Vect(x: TEXT_X_OFFSET_1, y: TEXT_Y_OFFSET_0 + 3*data.FONT_SIZE)
        )
        info_string = "Constraints x Iterations: $1 ($2)" %
                      [$constraints, $max_constraints]
        data.draw_text(
            info_string, 
            Vect(x: TEXT_X_OFFSET_1, y: TEXT_Y_OFFSET_0 + 4*data.FONT_SIZE)
        )
        info_string = "Rotating kinetic energy : $1" % [if ke < 1e-10f: 
                                                            fmt"{0.0:5.2e}"
                                                        else: 
                                                            fmt"{ke:5.2e}"]
        data.draw_text(
            info_string, 
            Vect(x: TEXT_X_OFFSET_1, y: TEXT_Y_OFFSET_0 + 5*data.FONT_SIZE)
        )
        info_string = "Running time: $1s" % fmt"{demo_time:5.2f}"
        data.draw_text(
            info_string, 
            Vect(x: TEXT_X_OFFSET_1, y: TEXT_Y_OFFSET_0 + 7*data.FONT_SIZE)
        )
        when data.DRAW_WITH_OPENGL == true:
            info_string = "Rendering with: OpenGL"
        else:
            info_string = "Rendering with: SDL"
        data.draw_text(
            info_string, 
            Vect(x: TEXT_X_OFFSET_1, y: TEXT_Y_OFFSET_0 + 8*data.FONT_SIZE)
        )
        info_string = "Frame Rate: $1" % $(1/time_delta)
        data.draw_text(
            info_string, 
            Vect(x: TEXT_X_OFFSET_1, y: TEXT_Y_OFFSET_0 + 9*data.FONT_SIZE)
        )
    else:
        # Display that 'Safe Mode' is active
        info_string = "Chipmunk is running in safe mode."
        data.draw_text(info_string, Vect(x: TEXT_X_OFFSET_1, y: TEXT_Y_OFFSET_0))
        info_string = "Running time: $1s" % fmt"{demo_time:5.2f}"
        data.draw_text(
            info_string, 
            Vect(x: TEXT_X_OFFSET_1, y: TEXT_Y_OFFSET_0 + 2*data.FONT_SIZE)
        )
        when data.DRAW_WITH_OPENGL == true:
            info_string = "Rendering with: OpenGL"
        else:
            info_string = "Rendering with: SDL"
        data.draw_text(
            info_string, 
            Vect(x: TEXT_X_OFFSET_1, y: TEXT_Y_OFFSET_0 + 3*data.FONT_SIZE)
        )
        info_string = "Frame Rate: $1" % $(1/time_delta)
        data.draw_text(
            info_string, 
            Vect(x: TEXT_X_OFFSET_1, y: TEXT_Y_OFFSET_0 + 4*data.FONT_SIZE)
        )
    
    # Draw the information text
    info_string = "Select demo with:"
    data.draw_text(info_string, Vect(x: 10.0, y: TEXT_Y_OFFSET_0))
    info_string = "    0 - 9 (also restarts demo)"
    data.draw_text(
        info_string, 
        Vect(x: TEXT_X_OFFSET_0, y: TEXT_Y_OFFSET_0 + data.FONT_SIZE)
    )
    info_string = "Pause demo with:"
    data.draw_text(
        info_string, 
        Vect(x: TEXT_X_OFFSET_0, y: TEXT_Y_OFFSET_0 + 2*data.FONT_SIZE)
    )
    info_string = "    P or Pause"
    data.draw_text(
        info_string, 
        Vect(x: TEXT_X_OFFSET_0, y: TEXT_Y_OFFSET_0 + 3*data.FONT_SIZE)
    )
    info_string = "Step-up in 'Pause' mode:"
    data.draw_text(
        info_string, 
        Vect(x: TEXT_X_OFFSET_0, y: TEXT_Y_OFFSET_0 + 4*data.FONT_SIZE)
    )
    info_string = "    Space"
    data.draw_text(
        info_string, 
        Vect(x: TEXT_X_OFFSET_0, y: TEXT_Y_OFFSET_0 + 5*data.FONT_SIZE)
    )
    info_string = "Move movable objects with:"
    data.draw_text(
        info_string, 
        Vect(x: TEXT_X_OFFSET_0, y: TEXT_Y_OFFSET_0 + 6*data.FONT_SIZE)
    )
    info_string = "    click&drag them with the mouse"
    data.draw_text(
        info_string, 
        Vect(x: TEXT_X_OFFSET_0, y: TEXT_Y_OFFSET_0 + 7*data.FONT_SIZE)
    )
    # Render logos
    when data.DRAW_WITH_OPENGL == true:
        data.render_surface(
            data.nim_logo_surface, 
            data.nim_logo_rectangle
        )
        data.render_surface(
            data.sdl_logo_surface, 
            data.sdl_logo_rectangle
        )
        data.render_surface(
            data.opengl_logo_surface, 
            data.opengl_logo_rectangle
        )
        data.render_surface(
            data.chipmunk_logo_surface, 
            data.chipmunk_logo_rectangle
        )
    else:
        data.render_texture(
            data.nim_logo_texture, 
            data.nim_logo_rectangle
        )
        data.render_texture(
            data.sdl_logo_texture, 
            data.sdl_logo_rectangle
        )
        data.render_texture(
            data.opengl_logo_texture, 
            data.opengl_logo_rectangle
        )
        data.render_texture(
            data.chipmunk_logo_texture, 
            data.chipmunk_logo_rectangle
        )

proc filter_input() =
    pumpEvents()
    # Key states
    key_states = sdl2.getKeyboardState(numkeys)[]
    # Mouse position
    var x, y: cint
    discard sdl2.getMouseState(x, y)
    var 
        chipmunk_xy = chipmunk.Vect(
            x: x.float - (data.WINDOW_SIZE.width/2), 
            y: -y.float + (data.WINDOW_SIZE.height/2)
        )
        new_point = vlerp(
            mouse_body.position, 
            chipmunk_xy, 
            0.25
        )
    mouse_body.velocity = vmult(vsub(new_point, mouse_body.position), 60.0f)
    mouse_body.position = new_point
    # Events
    event_list = newSeq[sdl2.Event]()
    while sdl2.pollEvent(event):
        event_list.add(event)
    for i in 0..event_list.high:
        case event_list[i].kind:
            of sdl2.EventType.QuitEvent:
                running = false
                break
            of sdl2.EventType.KeyDown:
                var
                    key_event: sdl2.KeyboardEventObj
                    key: cint
                    modifier: bool
                key_event = sdl2.key(event_list[i])[]
                key = key_event.keysym.sym
                modifier = (key_event.keysym.modstate == KMOD_LCTRL)
                modifier = modifier or (key_event.keysym.modstate == KMOD_RCTRL)
                if key == K_ESCAPE:
                    running = false
                    break
                elif key == K_1:
                    select_demo(1)
                elif key == K_2:
                    select_demo(2)
                elif key == K_3:
                    select_demo(3)
                elif key == K_4:
                    select_demo(4)
                elif key == K_5:
                    select_demo(5)
                elif key == K_6:
                    select_demo(6)
                elif key == K_7:
                    select_demo(7)
                elif key == K_8:
                    select_demo(8)
                elif key == K_9:
                    select_demo(9)
                elif key == K_0:
                    select_demo(0)
                elif (key == K_P or key == K_PAUSE):
                    pause = not pause
                elif key == K_SPACE:
                    if pause == true:
                        step = true
                # Execute the demo's input function if applicable
                if input_func != nil:
                    input_func(
                        current_space,
                        event_list[i].kind,
                        key_event,
                        key,
                        modifier
                    )
            of sdl2.EventType.KeyUp:
                var
                    key_event: sdl2.KeyboardEventObj
                    key: cint
                    modifier: bool
                key_event = sdl2.key(event_list[i])[]
                key = key_event.keysym.sym
                modifier = (key_event.keysym.modstate == KMOD_LCTRL)
                modifier = modifier or (key_event.keysym.modstate == KMOD_RCTRL)
                # Execute the demo's input function if applicable
                if input_func != nil:
                    input_func(
                        current_space,
                        event_list[i].kind,
                        key_event,
                        key,
                        modifier
                    )
            of sdl2.EventType.MouseButtonDown:
                var
                    mouse_event: sdl2.MouseButtonEventObj
                    button: uint8
                    cp_mouse_position: chipmunk.Vect
                mouse_event = sdl2.button(event_list[i])[]
                cp_mouse_position = chipmunk.Vect(
                    x: mouse_event.x.float - (data.WINDOW_SIZE.width/2), 
                    y: -mouse_event.y.float + (data.WINDOW_SIZE.height/2)
                )
                button = mouse_event.button
                if button == sdl2.BUTTON_LEFT:
                    var
                        radius = 5.0
                        info: PointQueryInfo
                        shape = current_space.pointQueryNearest(
                            cp_mouse_position,
                            radius,
                            GRAB_FILTER,
                            addr(info)
                        )
                    if (shape != nil) and (shape.body.mass < INFINITY):
                        var
                            nearest = if info.distance > 0.0: 
                                          info.point 
                                      else: 
                                          cp_mouse_position
                        mouse_joint = newPivotJoint(
                            mouse_body,
                            shape.body,
                            chipmunk.vzero,
                            shape.body.worldToLocal(nearest)
                        )
                        mouse_joint.maxForce = 50000.0
                        mouse_joint.errorBias = math.pow(1.0 - 0.15, 60.0)
                        discard current_space.addConstraint(mouse_joint)
                elif button == sdl2.BUTTON_RIGHT:
                    discard
                else:
                    discard
            of sdl2.EventType.MouseButtonUp:
                var
                    mouse_event: sdl2.MouseButtonEventObj
                    button: uint8
                mouse_event = sdl2.button(event_list[i])[]
                button = mouse_event.button
                if button == sdl2.BUTTON_LEFT:
                    if mouse_joint != nil:
                        current_space.removeConstraint(mouse_joint)
                        mouse_joint.destroy()
                        mouse_joint = nil
                elif button == sdl2.BUTTON_RIGHT:
                    discard
                else:
                    discard
            else:
                discard


## Initialization
os.setCurrentDir(os.getAppDir())
random.randomize()
# SDL
data.init()
# Frame manager
fps_manager.init()
fps_manager.setFramerate(60)
# Select the starting demo
select_demo(1)
# Initialize the mouse stuff
mouse_body = newKinematicBody()

## Main loop
while running == true:
    frame_rate = fps_manager.getFramerate()
    time_delta = 1.0/float(frame_rate)
    
    if (pause == false) or (step == true):
        update_func(time_delta)
        step = false
    
    draw_func()
    
    draw_info()
    
    data.render_everything()
    
    filter_input()
    
    fps_manager.delay()


## Clean up SDL stuff
data.clean_up_font()
data.clean_up_sdl()




