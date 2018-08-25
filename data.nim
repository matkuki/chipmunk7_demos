
import
    chipmunk,
    sdl2,
    sdl2 / [
        gfx,
        ttf,
        image
    ],
    opengl,
    glu,
    math,
    random,
    strutils


const
    DRAW_WITH_OPENGL* = true
    INFINITY* = 1e1000
    TWICE_PI* = 2.0f * math.PI
    WINDOW_SIZE* = (width: 800.0, height: 600.0)
    DRAW_OFFSET* = (x: WINDOW_SIZE.width/2, y: WINDOW_SIZE.height/2)
    SDL_WHITE* = (r:255.uint8,g:255.uint8,b:255.uint8,a:255.uint8)
    SDL_BACKGROUND_COLOR = (
        r:64.uint8, g:64.uint8, b:64.uint8, a:255.uint8
    )
    CHIPMUNK_WHITE* = chipmunk.SpaceDebugColor(
        r:1.0, g:1.0, b:1.0, a:1.0
    )
    CHIPMUNK_RED* = chipmunk.SpaceDebugColor(
        r:1.0, g:0.0, b:0.0, a:1.0
    )
    CHIPMUNK_BLUE* = chipmunk.SpaceDebugColor(
        r:0.0, g:0.0, b:1.0, a:1.0
    )
    CHIPMUNK_GREEN* = chipmunk.SpaceDebugColor(
        r:0.0, g:1.0, b:0.0, a:1.0
    )
    CHIPMUNK_GREY* = chipmunk.SpaceDebugColor(
        r:0.70, g:0.70, b:0.70, a:1.0
    )
    CHIPMUNK_DARK_GREY* = chipmunk.SpaceDebugColor(
        r:0.40, g:0.40, b:0.40, a:1.0
    )
    CHIPMUNK_BLACK* = chipmunk.SpaceDebugColor(
        r:0.0, g:0.0, b:0.0, a:1.0
    )
    DOT_COLOR* = chipmunk.SpaceDebugColor(
        r:1.0, g:1.0, b:1.0, a:1.0
    )
    BACKGROUND_COLOR = chipmunk.SpaceDebugColor(
        r:0.25, g:0.25, b:0.25, a:1.0
    )
    SHAPE_OUTLINE_COLOR = chipmunk.SpaceDebugColor(
        r: 200.0/255.0,
        g: 210.0/255.0,
        b: 230.0/255.0,
        a: 1.0
    )
    CONSTRAINT_COLOR = chipmunk.SpaceDebugColor(r:0.0, g:0.75, b:0.0, a:1.0)
    COLLISION_POINT_COLOR = chipmunk.SpaceDebugColor(r:1.0, g:0.0, b:0.0, a:1.0)
    FONT_SIZE* = 14.0
    RAND_MAX* = high(int)
    FLOAT_MAX* = float(RAND_MAX)
    GRABBABLE_MASK_BIT* = cuint(1 shl 31)
    CP_ALL_CATEGORIES* = chipmunk.Bitmask(0)
    CP_NO_GROUP* = cast[Group](0)
    GRAB_FILTER* = ShapeFilter(
        group: CP_NO_GROUP,
        categories: GRABBABLE_MASK_BIT,
        mask: GRABBABLE_MASK_BIT
    )
    NOT_GRABBABLE_FILTER* = ShapeFilter(
        group: CP_NO_GROUP,
        categories: not GRABBABLE_MASK_BIT,
        mask: not GRABBABLE_MASK_BIT
    )
    DEMO_TEXT_X_OFFSET* = 10.0
    DEMO_TEXT_Y_OFFSET_LINE_0* = data.WINDOW_SIZE.height - 3*data.FONT_SIZE - 10.0
    DEMO_TEXT_Y_OFFSET_LINE_1* = data.WINDOW_SIZE.height - 2*data.FONT_SIZE - 10.0
    DEMO_TEXT_Y_OFFSET_LINE_2* = data.WINDOW_SIZE.height - data.FONT_SIZE - 10.0

var
    main_window*: sdl2.WindowPtr
    main_renderer*: sdl2.RendererPtr    
    context: GlContextPtr
    version: cstring
    font: ttf.FontPtr
    keyboard_vector*: chipmunk.Vect

when DRAW_WITH_OPENGL == true:
    var
        nim_logo_surface*: sdl2.SurfacePtr
        nim_logo_rectangle* = (
            x: cint(725), y: cint(455), w: cint(70), h: cint(30)
        )
        chipmunk_logo_surface*: sdl2.SurfacePtr
        chipmunk_logo_rectangle* = (
            x: cint(725), y: cint(490), w: cint(73), h: cint(35)
        )
        sdl_logo_surface*: sdl2.SurfacePtr
        sdl_logo_rectangle* = (
            x: cint(730), y: cint(525), w: cint(60), h: cint(30)
        )
        opengl_logo_surface*: sdl2.SurfacePtr
        opengl_logo_rectangle* = (
            x: cint(730), y: cint(560), w: cint(60), h: cint(30)
        )
else:
    var
        nim_logo_texture*: sdl2.TexturePtr
        nim_logo_rectangle* = (
            x: cint(725), y: cint(455), w: cint(70), h: cint(30)
        )
        chipmunk_logo_texture*: sdl2.TexturePtr
        chipmunk_logo_rectangle* = (
            x: cint(725), y: cint(490), w: cint(73), h: cint(35)
        )
        sdl_logo_texture*: sdl2.TexturePtr
        sdl_logo_rectangle* = (
            x: cint(730), y: cint(525), w: cint(60), h: cint(30)
        )
        opengl_logo_texture*: sdl2.TexturePtr
        opengl_logo_rectangle* = (
            x: cint(730), y: cint(560), w: cint(60), h: cint(30)
        )


## Helper procedures, converters, ...
converter sdl2_to_cp_color(in_color: sdl2.Color): chipmunk.SpaceDebugColor =
    result.r = GLfloat(in_color.r) / 255.0
    result.g = GLfloat(in_color.g) / 255.0
    result.b = GLfloat(in_color.b) / 255.0
    result.a = GLfloat(in_color.a) / 255.0

converter cp_to_sdl2_color(in_color: chipmunk.SpaceDebugColor): sdl2.Color =
    result.r = uint8(in_color.r * 255)
    result.g = uint8(in_color.g * 255)
    result.b = uint8(in_color.b * 255)
    result.a = uint8(in_color.a * 255)

proc frand*(): Float {.inline.} = 
    result = chipmunk.Float(
        random.rand(float(high(int))) / chipmunk.Float(high(int))
    )

proc frand_unit_circle*(): chipmunk.Vect {.inline.} = 
    var v: chipmunk.Vect = v(frand() * 2.0 - 1.0, frand() * 2.0 - 1.0)
    result = if vlengthsq(v) < 1.0: 
                 v 
             else: 
                 frand_unit_circle()
                 
proc set_random_color*(shape: chipmunk.Shape) {.inline.} =
    shape.userData = cast[chipmunk.DataPointer](
        alloc0(sizeof(chipmunk.SpaceDebugColor))
    )
    var color = cast[ptr chipmunk.SpaceDebugColor](shape.userData)
    color[] = chipmunk.SpaceDebugColor(
        r: random.rand(1.0), 
        g: random.rand(1.0), 
        b: random.rand(1.0), 
        a: 1.0
    )

proc set_color*(shape: chipmunk.Shape, in_color: chipmunk.SpaceDebugColor) {.inline.} =
    shape.userData = cast[chipmunk.DataPointer](
        alloc0(sizeof(chipmunk.SpaceDebugColor))
    )
    var color = cast[ptr chipmunk.SpaceDebugColor](shape.userData)
    color[] = chipmunk.SpaceDebugColor(
        r: in_color.r, 
        g: in_color.g, 
        b: in_color.b, 
        a: in_color.a, 
    )


## Chipmunk clean up routines
proc shape_free_wrap(space: chipmunk.Space,
                     shape: chipmunk.Shape,
                     unused: pointer) {.cdecl.} =
    space.removeShape(shape)
    shape.destroy()

proc post_shape_free(shape: chipmunk.Shape, space: chipmunk.Space) {.cdecl.} =
    discard space.addPostStepCallback(
        cast[PostStepFunc](shape_free_wrap),
        shape,
        nil
    )

proc constraint_free_wrap(space: chipmunk.Space,
                          constraint: Constraint,
                          unused: pointer) {.cdecl.} =
    space.removeConstraint(constraint)
    constraint.destroy()

proc post_constraint_free(constraint: Constraint,
                          space: chipmunk.Space) {.cdecl.} =
    discard space.addPostStepCallback(
        cast[PostStepFunc](constraint_free_wrap),
        constraint,
        nil
    )

proc body_free_wrap(space: chipmunk.Space,
                    body: chipmunk.Body,
                    unused: pointer) {.cdecl.} =
    space.removeBody(body)
    body.destroy()

proc post_body_free(body: chipmunk.Body, space: chipmunk.Space) {.cdecl.} =
    discard space.addPostStepCallback(
        cast[PostStepFunc](body_free_wrap),
        body,
        nil
    )

proc clean_up_children*(space: chipmunk.Space) =
    space.eachShape(
        cast[SpaceShapeIteratorFunc](post_shape_free),
        space
    )
    space.eachConstraint(
        cast[SpaceConstraintIteratorFunc](post_constraint_free),
        space
    )
    space.eachBody(
        cast[SpaceBodyIteratorFunc](post_body_free),
        space
    )

proc clean_up_shape_color*(shape: Shape; data: pointer) {.cdecl.} =
    if shape.userData != nil:
        dealloc(shape.userData)
        shape.userData = nil

proc get_arc_points(cx, cy, r, start_angle, arc_angle :GLfloat, 
                    num_segments: int): seq[chipmunk.Vect] {.inline.} = 
    var
        # Theta is now calculated from the arc angle instead, 
        # the - 1 bit comes from the fact that the arc is open
        theta = arc_angle / float(num_segments - 1)
        tangetial_factor = math.tan(theta)
        radial_factor = math.cos(theta)
        # We now start at the start angle
        x = r * math.cos(start_angle)
        y = r * math.sin(start_angle)
    result = newSeq[chipmunk.Vect](num_segments)
    # Since the arc is not a closed curve, this is a strip now
    for i in 0..num_segments-1:
        result[i] = chipmunk.Vect(
            x: x + cx,
            y: y + cy
        )
        var
            tx = -y
            ty = x

        x += tx * tangetial_factor
        y += ty * tangetial_factor

        x *= radial_factor
        y *= radial_factor


## Text drawing procedures
proc init_font*() =
    if ttf.ttfInit() != sdl2.SdlSuccess:
        quit("An error occured while initializing ttf font!")
    font = openFont("resources/EffectsEighty.otf", 18)
    if font == nil:
        quit("An error occured while opening ttf font file!")

proc clean_up_font*() =
    close(font)

proc text_to_texture(text: string,
                     text_color: sdl2.Color=SDL_WHITE): sdl2.TexturePtr =
    ## Create texture from a TrueType font
    var text_surface: sdl2.SurfacePtr
    text_surface = ttf.renderUtf8Blended(font, text, text_color)
    if text_surface == nil:
        quit("Error creating text surface: '" & text & "'")
    # Create the new texture
    result =  sdl2.createTextureFromSurface(
        main_renderer,
        text_surface
    )
    if result == nil:
        quit("Error creating text texture: '" & text & "'")
    # Free the surface from memory,
    # it's a memory leak if this operation is skipped
    sdl2.freeSurface(text_surface)

proc draw_text_sdl(text: string, position: chipmunk.Vect) =
    var
        text_texture: sdl2.TexturePtr = text_to_texture(text)
        rectangle: sdl2.Rect
        geometry: tuple[width, height: cint]
    # Get the text texture size and create a SDL rectangle with it
    sdl2.queryTexture(
        text_texture,
        nil,
        nil,
        addr(geometry.width),
        addr(geometry.height)
    )
    rectangle = (
        x: cint(position.x),
        y: cint(position.y),
        w: cint(geometry.width),
        h: cint(geometry.height)
    )
    # Copy the texture to the renderer
    main_renderer.copyEx(
        text_texture,
        nil,
        addr(rectangle),
        0.cdouble,
        nil,
        0
    )
    # Clean up the temporary texture
    destroy(text_texture)


## SDL procedures
proc file_to_surface(image_file: string): sdl2.SurfacePtr =
    ## Load image surface from a file
    if image_file.toLowerAscii().endsWith(".png"):
        result = image.load(image_file)
    elif image_file.toLowerAscii().endsWith(".bmp"):
        result = sdl2.loadBMP(image_file)
    else:
        quit "'" & image_file & "' is in a unsupported format!"
    if result == nil:
        quit("Error loading image: '" & $image_file & "'")

proc surface_to_texture(in_surface: sdl2.SurfacePtr): sdl2.TexturePtr =
    ## Convert a SDL surface to a SDL texture
    if in_surface == nil:
        quit("Input surface cannot be nil!")
    # Create the new texture
    result = sdl2.createTextureFromSurface(
        main_renderer,
        in_surface
    )
    if result == nil:
        quit("Error creating image texture from a surface")
    # Free the surface from memory,
    # it's a memory leak if this operation is skipped
    sdl2.freeSurface(in_surface)

proc resize_surface(in_surface: sdl2.SurfacePtr, 
                    new_width, new_height: int): sdl2.SurfacePtr =
    var
        width_factor: cdouble = new_width / in_surface.w
        height_factor: cdouble = new_height / in_surface.h
    result = rotozoomSurfaceXY(
        in_surface, 
        0, 
        width_factor,
        height_factor,
        cint(1)
    )

proc render_texture*(texture: sdl2.TexturePtr, rectangle: var sdl2.Rect) =
    ##Copy the texture to the renderer
    main_renderer.copy(texture, nil, addr(rectangle))

proc init_sdl*() =
    sdl2.init(INIT_EVERYTHING)
    # Window
    main_window = sdl2.createWindow(
        "Nim-Chipmunk demo samples",
        sdl2.SDL_WINDOWPOS_CENTERED, 
        sdl2.SDL_WINDOWPOS_CENTERED,
        cint(WINDOW_SIZE.width),
        cint(WINDOW_SIZE.height),
        SDL_WINDOW_SHOWN
    )
    if main_window == nil:
        quit "Main window has to be initialized!"
    # Renderer
    main_renderer = sdl2.createRenderer(
        main_window,
        -1,
        Renderer_Accelerated or Renderer_PresentVsync or Renderer_TargetTexture
    )
    main_renderer.setDrawBlendMode(sdl2.BlendMode.BlendMode_Blend)
    if main_renderer == nil:
        echo sdl2.getError()
        quit "An error occured while creating the renderer!"
    # Initialize the TTF Fonts
    init_font()
    # Initialize the logo images
    when DRAW_WITH_OPENGL == false:
        nim_logo_texture = surface_to_texture(
            file_to_surface("resources/nim_logo.png") 
        )
        sdl_logo_texture = surface_to_texture(
            file_to_surface("resources/sdl_logo.png") 
        )
        opengl_logo_texture = surface_to_texture(
            file_to_surface("resources/opengl_logo.png")
        )
        chipmunk_logo_texture = surface_to_texture(
            file_to_surface("resources/chipmunk_logo.png")
        )

proc draw_dot_sdl(position: chipmunk.Vect,
                  color: chipmunk.SpaceDebugColor=DOT_COLOR) =
    data.main_renderer.setDrawColor(
        uint8(255 * color.r),
        uint8(255 * color.g),
        uint8(255 * color.b),
        uint8(255 * color.a)
    )
    data.main_renderer.drawPoint(
        cint(position.x + DRAW_OFFSET.x),
        cint(-position.y + DRAW_OFFSET.y) # Chipmunk Y coordinate is SDL reversed
    )

proc draw_circle_sdl(position: chipmunk.Vect,
                     radius: float,
                     outline_color: chipmunk.SpaceDebugColor,
                     fill_color: chipmunk.SpaceDebugColor) {.inline.} =
    var
        adjusted_position = chipmunk.Vect(
            x: position.x + DRAW_OFFSET.x,
            y: -position.y + DRAW_OFFSET.y
        )
    main_renderer.filledCircleRGBA(
        int16(adjusted_position.x),
        int16(adjusted_position.y),
        int16(radius),
        uint8(255 * fill_color.r),
        uint8(255 * fill_color.g),
        uint8(255 * fill_color.b),
        uint8(255 * fill_color.a)
    )
    main_renderer.circleRGBA(
        int16(adjusted_position.x),
        int16(adjusted_position.y),
        int16(radius),
        uint8(255 * outline_color.r),
        uint8(255 * outline_color.g),
        uint8(255 * outline_color.b),
        uint8(255 * outline_color.a)
    )
    main_renderer.setDrawBlendMode(sdl2.BlendMode.BlendMode_Blend)

proc draw_line_sdl(point_from, point_to: chipmunk.Vect,
                   color: chipmunk.SpaceDebugColor=CHIPMUNK_GREY) {.inline.} =
    main_renderer.setDrawColor(
        uint8(255 * color.r),
        uint8(255 * color.g),
        uint8(255 * color.b),
        uint8(255 * color.a)
    )
    main_renderer.drawLine(
        cint(point_from.x + DRAW_OFFSET.x),
        cint(-point_from.y + DRAW_OFFSET.y),
        cint(point_to.x + DRAW_OFFSET.x),
        cint(-point_to.y + DRAW_OFFSET.y)
    )

proc draw_thick_line_sdl(point_from, point_to: chipmunk.Vect,
                         radius: chipmunk.Float,
                         outline_color: chipmunk.SpaceDebugColor,
                         fill_color: chipmunk.SpaceDebugColor) {.inline.} =
    ## This version is alpha blended, HIGH CPU USAGE!
    #[
    main_renderer.thickLineRGBA(
        int16(point_from.x + DRAW_OFFSET.x),
        int16(-point_from.y + DRAW_OFFSET.y),
        int16(point_to.x + DRAW_OFFSET.x),
        int16(-point_to.y + DRAW_OFFSET.y),
        uint8(3),
        uint8(color.r),
        uint8(color.g),
        uint8(color.b),
        uint8(color.a)
    )
    main_renderer.setDrawBlendMode(sdl2.BlendMode.BlendMode_Blend)
    ]#
    ## Simple version with filled rectangle
    var
        vx: array[4, int16]
        vy: array[4, int16]
        point_1: chipmunk.Vect
        point_2: chipmunk.Vect
        point_3: chipmunk.Vect
        point_4: chipmunk.Vect
        normal: chipmunk.Vect
        thickness: float
    if radius < 2:
        thickness = 2.0
    else:
        thickness = radius
    # Draw the end circles
    draw_circle_sdl(point_from, radius, CHIPMUNK_GREY, fill_color)
    draw_circle_sdl(point_to, radius, CHIPMUNK_GREY, fill_color)
    # Offset the from point
    normal = (point_from - point_to).vnormalize()
    point_1 = point_from + (normal.vperp()*thickness)
    point_2 = point_from + (normal.vrperp()*thickness)
    vx[0] = int16(point_1.x + DRAW_OFFSET.x)
    vx[1] = int16(point_2.x + DRAW_OFFSET.x)
    vy[0] = int16(-point_1.y + DRAW_OFFSET.y)
    vy[1] = int16(-point_2.y + DRAW_OFFSET.y)
    # Offset the to point
    normal = (point_to - point_from).vnormalize()
    point_3 = point_to + (normal.vperp()*thickness)
    point_4 = point_to + (normal.vrperp()*thickness)
    vx[2] = int16(point_3.x + DRAW_OFFSET.x)
    vx[3] = int16(point_4.x + DRAW_OFFSET.x)
    vy[2] = int16(-point_3.y + DRAW_OFFSET.y)
    vy[3] = int16(-point_4.y + DRAW_OFFSET.y)
    main_renderer.filledPolygonRGBA(
        addr(vx[0]),
        addr(vy[0]),
        cint(4),
        uint8(255 * fill_color.r),
        uint8(255 * fill_color.g),
        uint8(255 * fill_color.b),
        uint8(255 * fill_color.a)
    )
    # Draw the side lines
    draw_line_sdl(point_1, point_4)
    draw_line_sdl(point_2, point_3)

proc draw_polygon_sdl(points: openarray[chipmunk.Vect],
                      color: chipmunk.SpaceDebugColor) =
    var
        vx: seq[int16] = @[]
        vy: seq[int16] = @[]
    for i in 0..points.high:
        vx.add(int16(points[i].x + DRAW_OFFSET.x))
        vy.add(int16(-points[i].y + DRAW_OFFSET.y))
    main_renderer.polygonRGBA(
        addr(vx[0]),
        addr(vy[0]),
        cint(points.len()),
        uint8(255 * color.r),
        uint8(255 * color.g),
        uint8(255 * color.b),
        uint8(255 * color.a)
    )

proc draw_filled_polygon_sdl(points: openarray[chipmunk.Vect],
                             color: chipmunk.SpaceDebugColor) =
    var
        vx: seq[int16] = @[]
        vy: seq[int16] = @[]
    for i in 0..points.high:
        vx.add(int16(points[i].x + DRAW_OFFSET.x))
        vy.add(int16(-points[i].y + DRAW_OFFSET.y))
    main_renderer.filledPolygonRGBA(
        addr(vx[0]),
        addr(vy[0]),
        cint(points.len()),
        uint8(255 * color.r),
        uint8(255 * color.g),
        uint8(255 * color.b),
        uint8(255 * color.a)
    )

proc draw_rounded_polygon_sdl(points: openarray[chipmunk.Vect], 
                              radius: GLfloat, 
                              outline_color: chipmunk.SpaceDebugColor,
                              fill_color: chipmunk.SpaceDebugColor) =
    type 
        ExtrudeVerts = object 
            offset: chipmunk.Vect
            n: chipmunk.Vect
    # Create the arc points
    if radius > 2.0:
        var
            count = points.len()
            extrude: seq[ExtrudeVerts] = newSeq[ExtrudeVerts](count)
            inset: chipmunk.Float = -fmax(0.0f, 1.0f - radius)
            outset = 1.0f + radius - inset
        # Extrude the polygon vertices according to the radius
        for i in 0..count-1:
            var 
                v0: chipmunk.Vect = points[(i - 1 + count) mod count]
                v1: chipmunk.Vect = points[i]
                v2: chipmunk.Vect = points[(i + 1) mod count]
                n1: chipmunk.Vect = vnormalize(vrperp(vsub(v1, v0)))
                n2: chipmunk.Vect = vnormalize(vrperp(vsub(v2, v1)))
                offset: chipmunk.Vect = vmult(
                    vadd(n1, n2), 
                    1.0 / (vdot(n1, n2) + 1.0)
                )
                v: ExtrudeVerts = ExtrudeVerts(offset: offset, n: n2)
            extrude[i] = v
        # Create the arc points
        const arc_segments = 8
        var pts: seq[chipmunk.Vect] = newSeq[chipmunk.Vect](arc_segments*count)
        for i in 0..count-1:
            var 
                j = if i == 0: count-1 else: i-1
                v_0: chipmunk.Vect = points[i]
                n_0: chipmunk.Vect = extrude[i].n
                n_1: chipmunk.Vect = extrude[j].n
                offset_0: chipmunk.Vect = extrude[i].offset
                inner_0: chipmunk.Vect = vadd(v_0, vmult(offset_0, inset))
                corner_0 = vadd(inner_0, vmult(n_1, outset))
                corner_1 = vadd(inner_0, vmult(n_0, outset))
                # The part that creates the starting and length angle
                vec_0 = (corner_0 - inner_0).vnormalize()
                start_angle = -arctan2(vec_0.x, vec_0.y) + math.PI/2.0
                vec_1 = (corner_1 - inner_0).vnormalize()
                arc_angle = math.arccos(vdot(vec_0, vec_1))
                arc_points = get_arc_points(
                    inner_0.x, 
                    inner_0.y, 
                    radius, 
                    start_angle, 
                    arc_angle, 
                    arc_segments-2
                )
                current_index = i*arc_segments
            pts[current_index] = corner_0
            var cnt = 1
            for p in arc_points:
                pts[current_index + cnt] = p
                cnt += 1
            pts[current_index + cnt] = corner_1
        # Draw the polygon
        draw_filled_polygon_sdl(pts, fill_color)
        draw_polygon_sdl(pts, outline_color)
    else:
        ## The curve is too small, just extrude the vertices by the radius
        var
            count = points.len()
            extrude: seq[ExtrudeVerts] = newSeq[ExtrudeVerts](count)
            inset: chipmunk.Float = -fmax(0.0f, 1.0f - radius)
            outset = 1.0f + radius - inset
        # Calculate the center
        var 
            center = chipmunk.vzero
            pts: seq[chipmunk.Vect] = newSeq[chipmunk.Vect](count)
        for i in 0..count-1:
            center = vadd(center, points[i])
        center = chipmunk.v(center.x / count.float(), center.y / count.float())
        # Extrude the vertices
        for i in 0..count-1:
            var normal = (points[i] - center).vnormalize()
            pts[i] = points[i] + (normal * radius)
        # Draw the polygon
        draw_filled_polygon_sdl(pts, fill_color)
        draw_polygon_sdl(pts, outline_color)

proc clean_up_sdl*() =
    destroy(main_renderer)
    destroy(main_window)


## OpenGL procedures
# This will identify our vertex buffer
var 
    vertexbuffer: GLuint
    g_vertex_buffer_data: array[6, GLfloat] = [
        100.0f, 100.0f,
        150.0f, 150.0f,
        50.0f,  150.0f
    ]

proc init_opengl() =
    if sdl2.init(INIT_EVERYTHING) != SDL_Success:
        quit "Error initializing SDL!"
    
    main_window = createWindow(
        "Nim-Chipmunk demo samples",
        sdl2.SDL_WINDOWPOS_CENTERED, 
        sdl2.SDL_WINDOWPOS_CENTERED,
        cint(WINDOW_SIZE.width),
        cint(WINDOW_SIZE.height),
        SDL_WINDOW_OPENGL #or SDL_WINDOW_RESIZABLE
    )
    if main_window == nil:
        quit "Error creating SDL window!"
    
    context = main_window.glCreateContext()
    if context == nil:
        quit "Error creating OpenGL context!"
    
    discard glSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE)
    discard glSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, GL_MAJOR_VERSION.ord)
    discard glSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, GL_MINOR_VERSION.ord)
    
    loadExtensions()
#    glMatrixMode(GL_PROJECTION)
#    glPushMatrix()
#    glLoadIdentity()
    gluOrtho2D(0, WINDOW_SIZE.width, WINDOW_SIZE.height, 0)
#    glMatrixMode(GL_MODELVIEW)
#    glPushMatrix()
#    glLoadIdentity()
    
    # Display the OpenGL Version string
    version = cast[cstring](glGetString(GL_VERSION))
    echo(version)
    
    if main_window.glMakeCurrent(context) != 0:
        quit "Error setting up OpenGL context!"
    
    # Initialize the TTF Fonts
    init_font()
    
    # Initialize the logos
    when DRAW_WITH_OPENGL == true:
        nim_logo_surface = resize_surface(
            file_to_surface("resources/nim_logo.png"),
            nim_logo_rectangle.w,
            nim_logo_rectangle.h,
        )
        sdl_logo_surface = resize_surface(
            file_to_surface("resources/sdl_logo.png"),
            sdl_logo_rectangle.w,
            sdl_logo_rectangle.h,
        )
        opengl_logo_surface = resize_surface(
            file_to_surface("resources/opengl_logo.png"),
            opengl_logo_rectangle.w,
            opengl_logo_rectangle.h,
        )
        chipmunk_logo_surface = resize_surface(
            file_to_surface("resources/chipmunk_logo.png"),
            chipmunk_logo_rectangle.w,
            chipmunk_logo_rectangle.h,
        )
        
        
        # Generate 1 buffer, put the resulting identifier in vertexbuffer
        glGenBuffers(1, addr(vertexbuffer))
        # The following commands will talk about our 'vertexbuffer' buffer
        glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer)
        # Give our vertices to OpenGL.
        glBufferData(
            GL_ARRAY_BUFFER, 
            len(g_vertex_buffer_data), 
            addr(g_vertex_buffer_data), 
            GL_STATIC_DRAW
        )

proc draw_text_opengl(text: string, position: chipmunk.Vect, 
                      color: chipmunk.SpaceDebugColor=CHIPMUNK_WHITE) =
    var
        text_surface: sdl2.SurfacePtr
        texture: GLuint
    
    glColor4f(color.r, color.g, color.b, color.a)
    
    glDisable(GL_DEPTH_TEST)
    glEnable(GL_TEXTURE_2D)
    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    
    glGenTextures(1, addr(texture))
    glBindTexture(GL_TEXTURE_2D, texture)
    
    text_surface = ttf.renderUtf8Blended(font, text, color)
    if text_surface == nil:
        quit("Error creating text surface: '" & text & "'")
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
    glTexImage2D(
        GL_TEXTURE_2D, 
        0, 
        GL_RGBA.ord,
        text_surface.w, 
        text_surface.h, 
        0, 
        GL_BGRA,
        GL_UNSIGNED_BYTE, 
        text_surface.pixels
    )
    
    glBegin(GL_QUADS)
    block:
        glTexCoord2f(0,0)
        glVertex2f(position.x, position.y)
        glTexCoord2f(1,0)
        glVertex2f(position.x + float(text_surface.w), position.y)
        glTexCoord2f(1,1)
        glVertex2f(
            position.x + float(text_surface.w), 
            position.y + float(text_surface.h)
        )
        glTexCoord2f(0,1)
        glVertex2f(position.x, position.y + float(text_surface.h))
    glEnd()

    glDeleteTextures(1, addr(texture))
    freeSurface(text_surface)

proc draw_dot_opengl(point: chipmunk.Vect,
                     size: chipmunk.Float=1.0,
                     color: chipmunk.SpaceDebugColor=DOT_COLOR) =
    glColor4f(color.r, color.g, color.b, color.a)
    glPointSize(size/2.0)
    glBegin(GL_POINTs);
    glVertex2f(
        point.x + DRAW_OFFSET.x, 
        -point.y + DRAW_OFFSET.y
    )
    glEnd()

proc draw_filled_circle_opengl(position: chipmunk.Vect, radius: GLfloat, 
                               color: chipmunk.SpaceDebugColor) =
    var triangleAmount = 30 # of triangles used to draw circle
    glColor4f(color.r, color.g, color.b, color.a)
    glBegin(GL_TRIANGLE_FAN)
    # Center of circle
    glVertex2f(
        position.x + DRAW_OFFSET.x, 
        -position.y + DRAW_OFFSET.y
    )
    for i in 0..triangleAmount: 
        glVertex2f(
            position.x + (radius * math.cos(GLfloat(i) * TWICE_PI / GLfloat(triangleAmount))) + DRAW_OFFSET.x, 
            -position.y + (radius * math.sin(GLfloat(i) * TWICE_PI / GLfloat(triangleAmount))) + DRAW_OFFSET.y
        )
    glEnd()

proc draw_circle_opengl(position: chipmunk.Vect, radius, angle: GLfloat,
                        color: chipmunk.SpaceDebugColor, draw_angle: bool=true) =
    var lineAmount = 30 # of triangles used to draw circle
    glColor4f(color.r, color.g, color.b, color.a)
    # Draw circle outline
    glBegin(GL_LINE_LOOP)
    for i in 0..lineAmount: 
        glVertex2f(
            position.x + (radius * math.cos(GLfloat(i) * TWICE_PI / GLfloat(lineAmount))) + DRAW_OFFSET.x, 
            -position.y + (radius * math.sin(GLfloat(i) * TWICE_PI / GLfloat(lineAmount))) + DRAW_OFFSET.y
        )
    glEnd()
    # Draw angle line
    if draw_angle == true:
        glBegin(GL_LINE_STRIP)
        var
            r: chipmunk.Vect = chipmunk.Vect(x: 0.0, y: 1.0)
            p: chipmunk.Vect = chipmunk.Vect(x: position.x, y: position.y) 
            c: float = math.cos(angle)
            s: float = math.sin(angle)
        r = chipmunk.Vect(
            x: r.x * c - r.y * s,
            y: r.x * s + r.y * c
        )
        r = r * radius
        r = r + p
        glVertex2f(
            position.x + DRAW_OFFSET.x, 
            -position.y + DRAW_OFFSET.y
        )
        glVertex2f(
            r.x + DRAW_OFFSET.x, 
            -r.y + DRAW_OFFSET.y
        )
        glEnd()

proc draw_arc_opengl(cx, cy, r, start_angle, arc_angle :GLfloat, num_segments: int) =
    var points = get_arc_points(cx, cy, r, start_angle, arc_angle, num_segments)
    glBegin(GL_LINE_STRIP)
    for p in points:
        glVertex2f(
            p.x + DRAW_OFFSET.x, 
            -p.y + DRAW_OFFSET.y
        )
    glEnd()

proc draw_filled_polygon_opengl(points: openarray[chipmunk.Vect], 
                                color: chipmunk.SpaceDebugColor) =
    glColor4f(color.r, color.g, color.b, color.a)
    glPointSize(1.0f)
    glBegin(GL_POLYGON)
    for point in points:
        glVertex2f(
            point.x + DRAW_OFFSET.x, 
            -point.y + DRAW_OFFSET.y
        )
    glEnd()

proc draw_polygon_opengl(points: openarray[chipmunk.Vect], 
                         color: chipmunk.SpaceDebugColor) =
    glColor4f(color.r, color.g, color.b, color.a)
    glPointSize(1.0f)
    glLineWidth(1.0f)
    glBegin(GL_LINE_LOOP)
    for point in points:
        glVertex2f(
            point.x + DRAW_OFFSET.x, 
            -point.y + DRAW_OFFSET.y
        )
    glEnd()

proc draw_line_opengl(point_from, point_to: chipmunk.Vect, 
                      color: chipmunk.SpaceDebugColor) =
    glColor4f(color.r, color.g, color.b, color.a)
    glPointSize(1.0f)
    glLineWidth(1.0f)
    glBegin(GL_LINE_STRIP)
    glVertex2f(
        point_from.x + DRAW_OFFSET.x, 
        -point_from.y + DRAW_OFFSET.y
    )
    glVertex2f(
        point_to.x + DRAW_OFFSET.x, 
        -point_to.y + DRAW_OFFSET.y
    )
    glEnd()

proc draw_thick_line_opengl(point_from, point_to: chipmunk.Vect, radius: GLfloat,
                            outline_color, fill_color: chipmunk.SpaceDebugColor) =
    var
        points: array[4, chipmunk.Vect]
        normal: chipmunk.Vect
        thickness = if radius < 1.0: 1.0 else: radius
        line_thickness = 0.975 * thickness # This makes the side lines look better
    # Circle at the 'from' point
    draw_filled_circle_opengl(point_from, thickness, fill_color)
    draw_circle_opengl(point_from, thickness, 0.0, outline_color, draw_angle=false)
    # Circle at the 'to' point
    draw_filled_circle_opengl(point_to, thickness, fill_color)
    draw_circle_opengl(point_to, thickness, 0.0, outline_color, draw_angle=false)
    # Draw the line with a polygon
    # Offset the from point
    normal = (point_from - point_to).vnormalize()
    points[0] = point_from + (normal.vperp()*line_thickness)
    points[1] = point_from + (normal.vrperp()*line_thickness)
    # Offset the to point
    normal = (point_to - point_from).vnormalize()
    points[2] = point_to + (normal.vperp()*line_thickness)
    points[3] = point_to + (normal.vrperp()*line_thickness)
    # Draw the polygon representing the line
    draw_filled_polygon_opengl(points, fill_color)
    # Draw the side lines
    draw_line_opengl(points[0], points[3], outline_color)
    draw_line_opengl(points[1], points[2], outline_color)

proc draw_triangle_opengl(p1, p2, p3: chipmunk.Vect, 
                          color: chipmunk.SpaceDebugColor) =
    var point_array: array[3, chipmunk.Vect] = [p1, p2, p3]
    glColor4f(color.r, color.g, color.b, color.a)
    glPointSize(1.0f)
    glLineWidth(1.0f)
    glBegin(GL_LINE_LOOP)
    for point in point_array:
        glVertex2f(
            point.x + DRAW_OFFSET.x,
            -point.y + DRAW_OFFSET.y
        )
    glEnd()

proc draw_filled_triangle_opengl(p1, p2, p3: chipmunk.Vect, 
                                 color: chipmunk.SpaceDebugColor) =
    glBegin(GL_TRIANGLES)
    glColor4f(color.r, color.g, color.b, color.a)
    glVertex2f(p1.x, p1.y)
    glVertex2f(p2.x, p2.y)
    glVertex2f(p3.x, p3.y)
    glEnd()

proc draw_rounded_polygon_opengl(points: openarray[chipmunk.Vect], 
                                 radius: GLfloat, 
                                 outline_color: chipmunk.SpaceDebugColor,
                                 fill_color: chipmunk.SpaceDebugColor) =
    type 
        ExtrudeVerts = object 
            offset: chipmunk.Vect
            n: chipmunk.Vect
    # Create the arc points
    if radius > 2.0:
        var
            count = points.len()
            extrude: seq[ExtrudeVerts] = newSeq[ExtrudeVerts](count)
            inset: chipmunk.Float = -fmax(0.0f, 1.0f - radius)
            outset = 1.0f + radius - inset
        # Extrude the polygon vertices according to the radius
        for i in 0..count-1:
            var 
                v0: chipmunk.Vect = points[(i - 1 + count) mod count]
                v1: chipmunk.Vect = points[i]
                v2: chipmunk.Vect = points[(i + 1) mod count]
                n1: chipmunk.Vect = vnormalize(vrperp(vsub(v1, v0)))
                n2: chipmunk.Vect = vnormalize(vrperp(vsub(v2, v1)))
                offset: chipmunk.Vect = vmult(
                    vadd(n1, n2), 
                    1.0 / (vdot(n1, n2) + 1.0)
                )
                v: ExtrudeVerts = ExtrudeVerts(offset: offset, n: n2)
            extrude[i] = v
        # Create the arc points
        const arc_segments = 8
        var pts: seq[chipmunk.Vect] = newSeq[chipmunk.Vect](arc_segments*count)
        for i in 0..count-1:
            var 
                j = if i == 0: count-1 else: i-1
                v_0: chipmunk.Vect = points[i]
                n_0: chipmunk.Vect = extrude[i].n
                n_1: chipmunk.Vect = extrude[j].n
                offset_0: chipmunk.Vect = extrude[i].offset
                inner_0: chipmunk.Vect = vadd(v_0, vmult(offset_0, inset))
                corner_0 = vadd(inner_0, vmult(n_1, outset))
                corner_1 = vadd(inner_0, vmult(n_0, outset))
                # The part that creates the starting and length angle
                vec_0 = (corner_0 - inner_0).vnormalize()
                start_angle = -arctan2(vec_0.x, vec_0.y) + math.PI/2.0
                vec_1 = (corner_1 - inner_0).vnormalize()
                arc_angle = math.arccos(vdot(vec_0, vec_1))
                arc_points = get_arc_points(
                    inner_0.x, 
                    inner_0.y, 
                    radius, 
                    start_angle, 
                    arc_angle, 
                    arc_segments-2
                )
                current_index = i*arc_segments
            pts[current_index] = corner_0
            var cnt = 1
            for p in arc_points:
                pts[current_index + cnt] = p
                cnt += 1
            pts[current_index + cnt] = corner_1
        # Draw the polygon
        draw_filled_polygon_opengl(pts, fill_color)
        draw_polygon_opengl(pts, outline_color)
    else:
        ## The curve is too small, just extrude the vertices by the radius
        var
            count = points.len()
            extrude: seq[ExtrudeVerts] = newSeq[ExtrudeVerts](count)
            inset: chipmunk.Float = -fmax(0.0f, 1.0f - radius)
            outset = 1.0f + radius - inset
        # Calculate the center
        var 
            center = chipmunk.vzero
            pts: seq[chipmunk.Vect] = newSeq[chipmunk.Vect](count)
        for i in 0..count-1:
            center = vadd(center, points[i])
        center = chipmunk.v(center.x / count.float(), center.y / count.float())
        # Extrude the vertices
        for i in 0..count-1:
            var normal = (points[i] - center).vnormalize()
            pts[i] = points[i] + (normal * radius)
        # Draw the polygon
        draw_filled_polygon_opengl(pts, fill_color)
        draw_polygon_opengl(pts, outline_color)

proc render_surface*(surface: sdl2.SurfacePtr, rectangle: sdl2.Rect) =
    var texture: GLuint
    
    # Reset the color to white
    glColor3f(1.0, 1.0, 1.0)
    
    glEnable(GL_TEXTURE_2D)
    
    glGenTextures(1, addr(texture))
    glBindTexture(GL_TEXTURE_2D, texture)
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
    
    glTexImage2D(
        GL_TEXTURE_2D, 
        0, 
        GL_RGBA.ord, 
        surface.w, 
        surface.h,  
        0, 
        GL_RGBA,
        GL_UNSIGNED_BYTE, 
        surface.pixels
    )
    
    glBegin(GL_QUADS)
    block:
        glTexCoord2f(0,0)
        glVertex2f(float(rectangle.x), float(rectangle.y))
        glTexCoord2f(1,0)
        glVertex2f(float(rectangle.x) + float(surface.w), float(rectangle.y))
        glTexCoord2f(1,1)
        glVertex2f(
            float(rectangle.x) + float(surface.w), 
            float(rectangle.y) + float(surface.h)
        )
        glTexCoord2f(0,1)
        glVertex2f(float(rectangle.x), float(rectangle.y) + float(surface.h))
    glEnd()

    glDeleteTextures(1, addr(texture))


## Debug draw procedures
proc debug_draw_dot*(size: chipmunk.Float, position: chipmunk.Vect,
                     color: chipmunk.SpaceDebugColor,
                     data: chipmunk.DataPointer) {.cdecl.} =
    when DRAW_WITH_OPENGL == true:
        draw_dot_opengl(position, size, color)
    else:
        draw_dot_sdl(position, color)

proc debug_draw_circle*(position: chipmunk.Vect, angle: chipmunk.Float,
                        radius: chipmunk.Float,
                        outline_color: chipmunk.SpaceDebugColor,
                        fill_color: SpaceDebugColor,
                        data: DataPointer) {.cdecl.} =
    when DRAW_WITH_OPENGL == true:
        draw_filled_circle_opengl(position, radius, fill_color)
        draw_circle_opengl(position, radius, angle, outline_color)
    else:
        var radius_point = vadd(position, vmult(vforangle(angle), radius - 0.5f))
        draw_circle_sdl(position, radius, outline_color, fill_color)
        draw_line_sdl(position, radius_point)


proc debug_draw_segment*(a: chipmunk.Vect, b: chipmunk.Vect,
                         color: chipmunk.SpaceDebugColor,
                         data: chipmunk.DataPointer) {.cdecl.} =
    when DRAW_WITH_OPENGL == true:
        draw_line_opengl(a, b, color)
    else:
        draw_line_sdl(a, b, color)

proc debug_draw_fat_segment*(a: chipmunk.Vect, b: chipmunk.Vect,
                             radius: chipmunk.Float,
                             outlineColor: chipmunk.SpaceDebugColor,
                             fillColor: chipmunk.SpaceDebugColor,
                             data: chipmunk.DataPointer) {.cdecl.} =
    when DRAW_WITH_OPENGL == true:
        if radius < 2.0:
            draw_line_opengl(a, b, outline_color)
        else:
            draw_thick_line_opengl(a, b, radius, outline_color, fill_color)
    else:
        if radius < 2.0:
            draw_line_sdl(a, b, outlineColor)
        else:
            draw_thick_line_sdl(a, b, radius, outlineColor, fillColor)

proc debug_draw_polygon*(count: cint, verts: ptr chipmunk.Vect,
                         radius: chipmunk.Float,
                         outline_color: chipmunk.SpaceDebugColor,
                         fill_color: chipmunk.SpaceDebugColor,
                         data: chipmunk.DataPointer) {.cdecl.} =
    var 
        points: seq[chipmunk.Vect] = @[]
        verts_array = cast[ptr array[0, chipmunk.Vect]](verts)
    for i in 0..count-1:
        points.add(chipmunk.v(verts_array[i].x, verts_array[i].y))
    when DRAW_WITH_OPENGL == true:
        if radius == 0.0:
            draw_filled_polygon_opengl(points, fill_color)
            draw_polygon_opengl(points, outline_color)
        else:
            draw_rounded_polygon_opengl(
                points,
                radius,
                outline_color,
                fill_color
            )
    else:
        if radius == 0.0:
            draw_filled_polygon_sdl(points, fill_color)
            draw_polygon_sdl(points, outline_color)
        else:
            draw_rounded_polygon_sdl(
                points,
                radius,
                outline_color,
                fill_color
            )


proc la_color(l: cfloat; a: cfloat): SpaceDebugColor {.inline.} =
    result = chipmunk.SpaceDebugColor(r: l, g: l, b: l, a: a)

proc rgba_color*(r, g, b, a: cfloat): SpaceDebugColor {.inline.} =
    result = chipmunk.SpaceDebugColor(r: r, g: g, b: b, a: a)

proc color_for_shape*(shape: Shape, data: DataPointer): SpaceDebugColor {.cdecl.} =
    if shape.sensor == true:
        result = la_color(1.0, 0.1)
    else:
        if shape.body.isSleeping():
            result = la_color(0.2, 1.0)
        elif shape.body.isSleeping():
            result = la_color(0.66, 1.0)
        elif shape.userData != nil:
            result = cast[ptr chipmunk.SpaceDebugColor](shape.userData)[]
        else:
            #result = chipmunk.SpaceDebugColor(r:1.0, g:0.5, b:1.0, a:1.0)
            result = CHIPMUNK_DARK_GREY

proc default_draw_implementation*(space: chipmunk.Space) =
    var draw_options = chipmunk.SpaceDebugDrawOptions(
            drawCircle: data.debug_draw_circle,
            drawSegment: data.debug_draw_segment,
            drawFatSegment: data.debug_draw_fat_segment,
            drawPolygon: data.debug_draw_polygon,
            drawDot: data.debug_draw_dot,
            flags: {
                SPACE_DEBUG_DRAW_SHAPES,
                SPACE_DEBUG_DRAW_CONSTRAINTS,
                SPACE_DEBUG_DRAW_COLLISION_POINTS
            },
            shapeOutlineColor: SHAPE_OUTLINE_COLOR,
            colorForShape: color_for_shape,
            constraintColor: CONSTRAINT_COLOR,
            collisionPointColor: COLLISION_POINT_COLOR,
            data: nil
        )
    space.debugDraw(addr(draw_options))


## General drawing procedures
proc init*() =
    when DRAW_WITH_OPENGL == true:
        init_opengl()
    else:
        init_sdl()

proc draw_dot*(body: chipmunk.Body, unused: pointer) {.cdecl.} =
    when DRAW_WITH_OPENGL == true:
        draw_dot_opengl(body.position)
    else:
        draw_dot_sdl(body.position)

proc draw_bounding_box*(bb: chipmunk.BB, color: chipmunk.SpaceDebugColor) =
    var vertices = [
        chipmunk.v(bb.r, bb.b),
        chipmunk.v(bb.r, bb.t),
        chipmunk.v(bb.l, bb.t),
        chipmunk.v(bb.l, bb.b),
    ]
    when DRAW_WITH_OPENGL == true:
        draw_polygon_opengl(vertices, color)
    else:
        draw_polygon_sdl(vertices, color)

proc draw_text*(text: string, position: chipmunk.Vect) =
    when DRAW_WITH_OPENGL == true:
        draw_text_opengl(text, position)
    else:
        draw_text_sdl(text, position)


proc render_everything*() {.inline.} =
    when DRAW_WITH_OPENGL == true:
        # Clear context
        main_window.glSwapWindow()
        glClearColor(
            BACKGROUND_COLOR.r, 
            BACKGROUND_COLOR.b, 
            BACKGROUND_COLOR.g,
            BACKGROUND_COLOR.a
        )
        glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
    else:
        main_renderer.present()
        main_renderer.setDrawColor(
            SDL_BACKGROUND_COLOR.r, 
            SDL_BACKGROUND_COLOR.g, 
            SDL_BACKGROUND_COLOR.b, 
            SDL_BACKGROUND_COLOR.a
        )
        main_renderer.clear()


