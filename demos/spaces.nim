
import
    ../chipmunk,
    ../data,
    sdl2,
    math,
    random,
    strutils


const
    bevel: chipmunk.Float = 1.0

var 
    space: chipmunk.Space
    simple_terrain_verts = [
        chipmunk.Vect(x: 350.0, y:  425.07), chipmunk.Vect(x: 336.0, y:  436.55),
        chipmunk.Vect(x: 272.0, y:  435.39), chipmunk.Vect(x: 258.0, y:  427.63),
        chipmunk.Vect(x: 225.28, y:  420.0), chipmunk.Vect(x: 202.82, y:  396.0),
        chipmunk.Vect(x: 191.81, y:  388.0), chipmunk.Vect(x: 189.0, y:  381.89),
        chipmunk.Vect(x: 173.0, y:  380.39), chipmunk.Vect(x: 162.59, y:  368.0),
        chipmunk.Vect(x: 150.47, y:  319.0), chipmunk.Vect(x: 128.0, y:  311.55),
        chipmunk.Vect(x: 119.14, y:  286.0), chipmunk.Vect(x: 126.84, y:  263.0),
        chipmunk.Vect(x: 120.56, y:  227.0), chipmunk.Vect(x: 141.14, y:  178.0),
        chipmunk.Vect(x: 137.52, y:  162.0), chipmunk.Vect(x: 146.51, y:  142.0),
        chipmunk.Vect(x: 156.23, y:  136.0), chipmunk.Vect(x: 158.0, y:  118.27),
        chipmunk.Vect(x: 170.0, y:  100.77), chipmunk.Vect(x: 208.43, y:  84.0),
        chipmunk.Vect(x: 224.0, y:  69.65), chipmunk.Vect(x: 249.3, y:  68.0),
        chipmunk.Vect(x: 257.0, y:  54.77), chipmunk.Vect(x: 363.0, y:  45.94),
        chipmunk.Vect(x: 374.15, y:  54.0), chipmunk.Vect(x: 386.0, y:  69.6),
        chipmunk.Vect(x: 413.0, y:  70.73), chipmunk.Vect(x: 456.0, y:  84.89),
        chipmunk.Vect(x: 468.09, y:  99.0), chipmunk.Vect(x: 467.09, y:  123.0),
        chipmunk.Vect(x: 464.92, y:  135.0), chipmunk.Vect(x: 469.0, y:  141.03),
        chipmunk.Vect(x: 497.0, y:  148.67), chipmunk.Vect(x: 513.85, y:  180.0),
        chipmunk.Vect(x: 509.56, y:  223.0), chipmunk.Vect(x: 523.51, y:  247.0),
        chipmunk.Vect(x: 523.0, y:  277.0), chipmunk.Vect(x: 497.79, y:  311.0),
        chipmunk.Vect(x: 478.67, y:  348.0), chipmunk.Vect(x: 467.9, y:  360.0),
        chipmunk.Vect(x: 456.76, y:  382.0), chipmunk.Vect(x: 432.95, y:  389.0),
        chipmunk.Vect(x: 417.0, y:  411.32), chipmunk.Vect(x: 373.0, y:  433.19),
        chipmunk.Vect(x: 361.0, y:  430.02), chipmunk.Vect(x: 350.0, y:  425.07)
    ]
    complex_terrain_verts = [
        chipmunk.Vect(x: 46.78, y: 479.0), chipmunk.Vect(x: 35.0, y: 475.63), 
        chipmunk.Vect(x: 27.52, y: 469.0), chipmunk.Vect(x: 23.52, y: 455.0), 
        chipmunk.Vect(x: 23.78, y: 441.0), chipmunk.Vect(x: 28.41, y: 428.0), 
        chipmunk.Vect(x: 49.61, y: 394.0), chipmunk.Vect(x: 59.0, y: 381.56), 
        chipmunk.Vect(x: 80.0, y: 366.03), chipmunk.Vect(x: 81.46, y: 358.0), 
        chipmunk.Vect(x: 86.31, y: 350.0), chipmunk.Vect(x: 77.74, y: 320.0), 
        chipmunk.Vect(x: 70.26, y: 278.0), chipmunk.Vect(x: 67.51, y: 270.0), 
        chipmunk.Vect(x: 58.86, y: 260.0), chipmunk.Vect(x: 57.19, y: 247.0), 
        chipmunk.Vect(x: 38.0, y: 235.6), chipmunk.Vect(x: 25.76, y: 221.0), 
        chipmunk.Vect(x: 24.58, y: 209.0), chipmunk.Vect(x: 27.63, y: 202.0), 
        chipmunk.Vect(x: 31.28, y: 198.0), chipmunk.Vect(x: 40.0, y: 193.72), 
        chipmunk.Vect(x: 48.0, y: 193.73), chipmunk.Vect(x: 55.0, y: 196.7), 
        chipmunk.Vect(x: 62.1, y: 204.0), chipmunk.Vect(x: 71.0, y: 209.04), 
        chipmunk.Vect(x: 79.0, y: 206.55), chipmunk.Vect(x: 88.0, y: 206.81), 
        chipmunk.Vect(x: 95.88, y: 211.0), chipmunk.Vect(x: 103.0, y: 220.49), 
        chipmunk.Vect(x: 131.0, y: 220.51), chipmunk.Vect(x: 137.0, y: 222.66), 
        chipmunk.Vect(x: 143.08, y: 228.0), chipmunk.Vect(x: 146.22, y: 234.0), 
        chipmunk.Vect(x: 147.08, y: 241.0), chipmunk.Vect(x: 145.45, y: 248.0), 
        chipmunk.Vect(x: 142.31, y: 253.0), chipmunk.Vect(x: 132.0, y: 259.3), 
        chipmunk.Vect(x: 115.0, y: 259.7), chipmunk.Vect(x: 109.28, y: 270.0), 
        chipmunk.Vect(x: 112.91, y: 296.0), chipmunk.Vect(x: 119.69, y: 324.0), 
        chipmunk.Vect(x: 129.0, y: 336.26), chipmunk.Vect(x: 141.0, y: 337.59), 
        chipmunk.Vect(x: 153.0, y: 331.57), chipmunk.Vect(x: 175.0, y: 325.74), 
        chipmunk.Vect(x: 188.0, y: 325.19), chipmunk.Vect(x: 235.0, y: 317.46), 
        chipmunk.Vect(x: 250.0, y: 317.19), chipmunk.Vect(x: 255.0, y: 309.12), 
        chipmunk.Vect(x: 262.62, y: 302.0), chipmunk.Vect(x: 262.21, y: 295.0), 
        chipmunk.Vect(x: 248.0, y: 273.59), chipmunk.Vect(x: 229.0, y: 257.93), 
        chipmunk.Vect(x: 221.0, y: 255.48), chipmunk.Vect(x: 215.0, y: 251.59), 
        chipmunk.Vect(x: 210.79, y: 246.0), chipmunk.Vect(x: 207.47, y: 234.0), 
        chipmunk.Vect(x: 203.25, y: 227.0), chipmunk.Vect(x: 179.0, y: 205.9), 
        chipmunk.Vect(x: 148.0, y: 189.54), chipmunk.Vect(x: 136.0, y: 181.45), 
        chipmunk.Vect(x: 120.0, y: 180.31), chipmunk.Vect(x: 110.0, y: 181.65), 
        chipmunk.Vect(x: 95.0, y: 179.31), chipmunk.Vect(x: 63.0, y: 166.96), 
        chipmunk.Vect(x: 50.0, y: 164.23), chipmunk.Vect(x: 31.0, y: 154.49), 
        chipmunk.Vect(x: 19.76, y: 145.0), chipmunk.Vect(x: 15.96, y: 136.0), 
        chipmunk.Vect(x: 16.65, y: 127.0), chipmunk.Vect(x: 20.57, y: 120.0), 
        chipmunk.Vect(x: 28.0, y: 114.63), chipmunk.Vect(x: 40.0, y: 113.67), 
        chipmunk.Vect(x: 65.0, y: 127.22), chipmunk.Vect(x: 73.0, y: 128.69), 
        chipmunk.Vect(x: 81.95, y: 120.0), chipmunk.Vect(x: 77.58, y: 103.0), 
        chipmunk.Vect(x: 78.18, y: 92.0), chipmunk.Vect(x: 59.11, y: 77.0), 
        chipmunk.Vect(x: 52.0, y: 67.29), chipmunk.Vect(x: 31.29, y: 55.0), 
        chipmunk.Vect(x: 25.67, y: 47.0), chipmunk.Vect(x: 24.65, y: 37.0), 
        chipmunk.Vect(x: 27.82, y: 29.0), chipmunk.Vect(x: 35.0, y: 22.55), 
        chipmunk.Vect(x: 44.0, y: 20.35), chipmunk.Vect(x: 49.0, y: 20.81), 
        chipmunk.Vect(x: 61.0, y: 25.69), chipmunk.Vect(x: 79.0, y: 37.81), 
        chipmunk.Vect(x: 88.0, y: 49.64), chipmunk.Vect(x: 97.0, y: 56.65), 
        chipmunk.Vect(x: 109.0, y: 49.61), chipmunk.Vect(x: 143.0, y: 38.96), 
        chipmunk.Vect(x: 197.0, y: 37.27), chipmunk.Vect(x: 215.0, y: 35.3), 
        chipmunk.Vect(x: 222.0, y: 36.65), chipmunk.Vect(x: 228.42, y: 41.0), 
        chipmunk.Vect(x: 233.3, y: 49.0), chipmunk.Vect(x: 234.14, y: 57.0), 
        chipmunk.Vect(x: 231.0, y: 65.8), chipmunk.Vect(x: 224.0, y: 72.38), 
        chipmunk.Vect(x: 218.0, y: 74.5), chipmunk.Vect(x: 197.0, y: 76.62), 
        chipmunk.Vect(x: 145.0, y: 78.81), chipmunk.Vect(x: 123.0, y: 87.41), 
        chipmunk.Vect(x: 117.59, y: 98.0), chipmunk.Vect(x: 117.79, y: 104.0), 
        chipmunk.Vect(x: 119.0, y: 106.23), chipmunk.Vect(x: 138.73, y: 120.0), 
        chipmunk.Vect(x: 148.0, y: 129.5), chipmunk.Vect(x: 158.5, y: 149.0), 
        chipmunk.Vect(x: 203.93, y: 175.0), chipmunk.Vect(x: 229.0, y: 196.6), 
        chipmunk.Vect(x: 238.16, y: 208.0), chipmunk.Vect(x: 245.2, y: 221.0), 
        chipmunk.Vect(x: 275.45, y: 245.0), chipmunk.Vect(x: 289.0, y: 263.24), 
        chipmunk.Vect(x: 303.6, y: 287.0), chipmunk.Vect(x: 312.0, y: 291.57), 
        chipmunk.Vect(x: 339.25, y: 266.0), chipmunk.Vect(x: 366.33, y: 226.0), 
        chipmunk.Vect(x: 363.43, y: 216.0), chipmunk.Vect(x: 364.13, y: 206.0), 
        chipmunk.Vect(x: 353.0, y: 196.72), chipmunk.Vect(x: 324.0, y: 181.05), 
        chipmunk.Vect(x: 307.0, y: 169.63), chipmunk.Vect(x: 274.93, y: 156.0), 
        chipmunk.Vect(x: 256.0, y: 152.48), chipmunk.Vect(x: 228.0, y: 145.13), 
        chipmunk.Vect(x: 221.09, y: 142.0), chipmunk.Vect(x: 214.87, y: 135.0), 
        chipmunk.Vect(x: 212.67, y: 127.0), chipmunk.Vect(x: 213.81, y: 119.0), 
        chipmunk.Vect(x: 219.32, y: 111.0), chipmunk.Vect(x: 228.0, y: 106.52), 
        chipmunk.Vect(x: 236.0, y: 106.39), chipmunk.Vect(x: 290.0, y: 119.4), 
        chipmunk.Vect(x: 299.33, y: 114.0), chipmunk.Vect(x: 300.52, y: 109.0), 
        chipmunk.Vect(x: 300.3, y: 53.0), chipmunk.Vect(x: 301.46, y: 47.0), 
        chipmunk.Vect(x: 305.0, y: 41.12), chipmunk.Vect(x: 311.0, y: 36.37), 
        chipmunk.Vect(x: 317.0, y: 34.43), chipmunk.Vect(x: 325.0, y: 34.81), 
        chipmunk.Vect(x: 334.9, y: 41.0), chipmunk.Vect(x: 339.45, y: 50.0), 
        chipmunk.Vect(x: 339.82, y: 132.0), chipmunk.Vect(x: 346.09, y: 139.0), 
        chipmunk.Vect(x: 350.0, y: 150.26), chipmunk.Vect(x: 380.0, y: 167.38), 
        chipmunk.Vect(x: 393.0, y: 166.48), chipmunk.Vect(x: 407.0, y: 155.54), 
        chipmunk.Vect(x: 430.0, y: 147.3), chipmunk.Vect(x: 437.78, y: 135.0), 
        chipmunk.Vect(x: 433.13, y: 122.0), chipmunk.Vect(x: 410.23, y: 78.0), 
        chipmunk.Vect(x: 401.59, y: 69.0), chipmunk.Vect(x: 393.48, y: 56.0), 
        chipmunk.Vect(x: 392.8, y: 44.0), chipmunk.Vect(x: 395.5, y: 38.0), 
        chipmunk.Vect(x: 401.0, y: 32.49), chipmunk.Vect(x: 409.0, y: 29.41), 
        chipmunk.Vect(x: 420.0, y: 30.84), chipmunk.Vect(x: 426.92, y: 36.0), 
        chipmunk.Vect(x: 432.32, y: 44.0), chipmunk.Vect(x: 439.49, y: 51.0), 
        chipmunk.Vect(x: 470.13, y: 108.0), chipmunk.Vect(x: 475.71, y: 124.0), 
        chipmunk.Vect(x: 483.0, y: 130.11), chipmunk.Vect(x: 488.0, y: 139.43), 
        chipmunk.Vect(x: 529.0, y: 139.4), chipmunk.Vect(x: 536.0, y: 132.52), 
        chipmunk.Vect(x: 543.73, y: 129.0), chipmunk.Vect(x: 540.47, y: 115.0), 
        chipmunk.Vect(x: 541.11, y: 100.0), chipmunk.Vect(x: 552.18, y: 68.0), 
        chipmunk.Vect(x: 553.78, y: 47.0), chipmunk.Vect(x: 559.0, y: 39.76), 
        chipmunk.Vect(x: 567.0, y: 35.52), chipmunk.Vect(x: 577.0, y: 35.45), 
        chipmunk.Vect(x: 585.0, y: 39.58), chipmunk.Vect(x: 591.38, y: 50.0), 
        chipmunk.Vect(x: 591.67, y: 66.0), chipmunk.Vect(x: 590.31, y: 79.0), 
        chipmunk.Vect(x: 579.76, y: 109.0), chipmunk.Vect(x: 582.25, y: 119.0), 
        chipmunk.Vect(x: 583.66, y: 136.0), chipmunk.Vect(x: 586.45, y: 143.0), 
        chipmunk.Vect(x: 586.44, y: 151.0), chipmunk.Vect(x: 580.42, y: 168.0), 
        chipmunk.Vect(x: 577.15, y: 173.0), chipmunk.Vect(x: 572.0, y: 177.13), 
        chipmunk.Vect(x: 564.0, y: 179.49), chipmunk.Vect(x: 478.0, y: 178.81), 
        chipmunk.Vect(x: 443.0, y: 184.76), chipmunk.Vect(x: 427.1, y: 190.0), 
        chipmunk.Vect(x: 424.0, y: 192.11), chipmunk.Vect(x: 415.94, y: 209.0), 
        chipmunk.Vect(x: 408.82, y: 228.0), chipmunk.Vect(x: 405.82, y: 241.0), 
        chipmunk.Vect(x: 411.0, y: 250.82), chipmunk.Vect(x: 415.0, y: 251.5), 
        chipmunk.Vect(x: 428.0, y: 248.89), chipmunk.Vect(x: 469.0, y: 246.29), 
        chipmunk.Vect(x: 505.0, y: 246.49), chipmunk.Vect(x: 533.0, y: 243.6), 
        chipmunk.Vect(x: 541.87, y: 248.0), chipmunk.Vect(x: 547.55, y: 256.0), 
        chipmunk.Vect(x: 548.48, y: 267.0), chipmunk.Vect(x: 544.0, y: 276.0), 
        chipmunk.Vect(x: 534.0, y: 282.24), chipmunk.Vect(x: 513.0, y: 285.46), 
        chipmunk.Vect(x: 468.0, y: 285.76), chipmunk.Vect(x: 402.0, y: 291.7), 
        chipmunk.Vect(x: 392.0, y: 290.29), chipmunk.Vect(x: 377.0, y: 294.46), 
        chipmunk.Vect(x: 367.0, y: 294.43), chipmunk.Vect(x: 356.44, y: 304.0), 
        chipmunk.Vect(x: 354.22, y: 311.0), chipmunk.Vect(x: 362.0, y: 321.36), 
        chipmunk.Vect(x: 390.0, y: 322.44), chipmunk.Vect(x: 433.0, y: 330.16), 
        chipmunk.Vect(x: 467.0, y: 332.76), chipmunk.Vect(x: 508.0, y: 347.64), 
        chipmunk.Vect(x: 522.0, y: 357.67), chipmunk.Vect(x: 528.0, y: 354.46), 
        chipmunk.Vect(x: 536.0, y: 352.96), chipmunk.Vect(x: 546.06, y: 336.0), 
        chipmunk.Vect(x: 553.47, y: 306.0), chipmunk.Vect(x: 564.19, y: 282.0), 
        chipmunk.Vect(x: 567.84, y: 268.0), chipmunk.Vect(x: 578.72, y: 246.0), 
        chipmunk.Vect(x: 585.0, y: 240.97), chipmunk.Vect(x: 592.0, y: 238.91), 
        chipmunk.Vect(x: 600.0, y: 239.72), chipmunk.Vect(x: 606.0, y: 242.82), 
        chipmunk.Vect(x: 612.36, y: 251.0), chipmunk.Vect(x: 613.35, y: 263.0), 
        chipmunk.Vect(x: 588.75, y: 324.0), chipmunk.Vect(x: 583.25, y: 350.0), 
        chipmunk.Vect(x: 572.12, y: 370.0), chipmunk.Vect(x: 575.45, y: 378.0), 
        chipmunk.Vect(x: 575.20, y: 388.0), chipmunk.Vect(x: 589.0, y: 393.81), 
        chipmunk.Vect(x: 599.20, y: 404.0), chipmunk.Vect(x: 607.14, y: 416.0), 
        chipmunk.Vect(x: 609.96, y: 430.0), chipmunk.Vect(x: 615.45, y: 441.0), 
        chipmunk.Vect(x: 613.44, y: 462.0), chipmunk.Vect(x: 610.48, y: 469.0), 
        chipmunk.Vect(x: 603.0, y: 475.63), chipmunk.Vect(x: 590.96, y: 479.0)
    ]
    bouncy_terrain_verts = [
        chipmunk.Vect(x: 537.18, y: 23.0), chipmunk.Vect(x: 520.5, y: 36.0), 
        chipmunk.Vect(x: 501.53, y: 63.0), chipmunk.Vect(x: 496.14, y: 76.0), 
        chipmunk.Vect(x: 498.86, y: 86.0), chipmunk.Vect(x: 504.0, y: 90.51000000000001), 
        chipmunk.Vect(x: 508.0, y: 91.36), chipmunk.Vect(x: 508.77, y: 84.0), 
        chipmunk.Vect(x: 513.0, y: 77.73), chipmunk.Vect(x: 519.0, y: 74.48), 
        chipmunk.Vect(x: 530.0, y: 74.67), chipmunk.Vect(x: 545.0, y: 54.65), 
        chipmunk.Vect(x: 554.0, y: 48.77), chipmunk.Vect(x: 562.0, y: 46.39), 
        chipmunk.Vect(x: 568.0, y: 45.94), chipmunk.Vect(x: 568.61, y: 47.0), 
        chipmunk.Vect(x: 567.9400000000001, y: 55.0), chipmunk.Vect(x: 571.27, y: 64.0), 
        chipmunk.Vect(x: 572.92, y: 80.0), chipmunk.Vect(x: 572.0, y: 81.39), 
        chipmunk.Vect(x: 563.0, y: 79.93000000000001), chipmunk.Vect(x: 556.0, y: 82.69), 
        chipmunk.Vect(x: 551.49, y: 88.0), chipmunk.Vect(x: 549.0, y: 95.76000000000001), 
        chipmunk.Vect(x: 538.0, y: 93.40000000000001), chipmunk.Vect(x: 530.0, y: 102.38), 
        chipmunk.Vect(x: 523.0, y: 104.0), chipmunk.Vect(x: 517.0, y: 103.02), 
        chipmunk.Vect(x: 516.22, y: 109.0), chipmunk.Vect(x: 518.96, y: 116.0), 
        chipmunk.Vect(x: 526.0, y: 121.15), chipmunk.Vect(x: 534.0, y: 116.48), 
        chipmunk.Vect(x: 543.0, y: 116.77), chipmunk.Vect(x: 549.28, y: 121.0), 
        chipmunk.Vect(x: 554.0, y: 130.17), chipmunk.Vect(x: 564.0, y: 125.67), 
        chipmunk.Vect(x: 575.6, y: 129.0), chipmunk.Vect(x: 573.31, y: 121.0), 
        chipmunk.Vect(x: 567.77, y: 111.0), chipmunk.Vect(x: 575.0, y: 106.47), 
        chipmunk.Vect(x: 578.51, y: 102.0), chipmunk.Vect(x: 580.25, y: 95.0), 
        chipmunk.Vect(x: 577.98, y: 87.0), chipmunk.Vect(x: 582.0, y: 85.70999999999999), 
        chipmunk.Vect(x: 597.0, y: 89.45999999999999), chipmunk.Vect(x: 604.8, y: 95.0), 
        chipmunk.Vect(x: 609.28, y: 104.0), chipmunk.Vect(x: 610.55, y: 116.0), 
        chipmunk.Vect(x: 609.3, y: 125.0), chipmunk.Vect(x: 600.8, y: 142.0), 
        chipmunk.Vect(x: 597.31, y: 155.0), chipmunk.Vect(x: 584.0, y: 167.23), 
        chipmunk.Vect(x: 577.86, y: 175.0), chipmunk.Vect(x: 583.52, y: 184.0), 
        chipmunk.Vect(x: 582.64, y: 195.0), chipmunk.Vect(x: 591.0, y: 196.56), 
        chipmunk.Vect(x: 597.81, y: 201.0), chipmunk.Vect(x: 607.4500000000001, y: 219.0), 
        chipmunk.Vect(x: 607.51, y: 246.0), chipmunk.Vect(x: 600.0, y: 275.46), 
        chipmunk.Vect(x: 588.0, y: 267.81), chipmunk.Vect(x: 579.0, y: 264.91), 
        chipmunk.Vect(x: 557.0, y: 264.41), chipmunk.Vect(x: 552.98, y: 259.0), 
        chipmunk.Vect(x: 548.0, y: 246.18), chipmunk.Vect(x: 558.0, y: 247.12), 
        chipmunk.Vect(x: 565.98, y: 244.0), chipmunk.Vect(x: 571.1, y: 237.0), 
        chipmunk.Vect(x: 571.61, y: 229.0), chipmunk.Vect(x: 568.25, y: 222.0), 
        chipmunk.Vect(x: 562.0, y: 217.67), chipmunk.Vect(x: 544.0, y: 213.93), 
        chipmunk.Vect(x: 536.73, y: 214.0), chipmunk.Vect(x: 535.6, y: 204.0), 
        chipmunk.Vect(x: 539.6900000000001, y: 181.0), chipmunk.Vect(x: 542.84, y: 171.0), 
        chipmunk.Vect(x: 550.43, y: 161.0), chipmunk.Vect(x: 540.0, y: 156.27), 
        chipmunk.Vect(x: 536.62, y: 152.0), chipmunk.Vect(x: 534.7000000000001, y: 146.0), 
        chipmunk.Vect(x: 527.0, y: 141.88), chipmunk.Vect(x: 518.59, y: 152.0), 
        chipmunk.Vect(x: 514.51, y: 160.0), chipmunk.Vect(x: 510.33, y: 175.0), 
        chipmunk.Vect(x: 519.38, y: 183.0), chipmunk.Vect(x: 520.52, y: 194.0), 
        chipmunk.Vect(x: 516.0, y: 201.27), chipmunk.Vect(x: 505.25, y: 206.0), 
        chipmunk.Vect(x: 507.57, y: 223.0), chipmunk.Vect(x: 519.9, y: 260.0), 
        chipmunk.Vect(x: 529.0, y: 260.48), chipmunk.Vect(x: 534.0, y: 262.94), 
        chipmunk.Vect(x: 538.38, y: 268.0), chipmunk.Vect(x: 540.0, y: 275.0), 
        chipmunk.Vect(x: 537.06, y: 284.0), chipmunk.Vect(x: 530.0, y: 289.23), 
        chipmunk.Vect(x: 520.0, y: 289.23), chipmunk.Vect(x: 513.0, y: 284.18), 
        chipmunk.Vect(x: 509.71, y: 286.0), chipmunk.Vect(x: 501.69, y: 298.0), 
        chipmunk.Vect(x: 501.56, y: 305.0), chipmunk.Vect(x: 504.3, y: 311.0), 
        chipmunk.Vect(x: 512.0, y: 316.43), chipmunk.Vect(x: 521.0, y: 316.42), 
        chipmunk.Vect(x: 525.67, y: 314.0), chipmunk.Vect(x: 535.0, y: 304.98), 
        chipmunk.Vect(x: 562.0, y: 294.8), chipmunk.Vect(x: 573.0, y: 294.81), 
        chipmunk.Vect(x: 587.52, y: 304.0), chipmunk.Vect(x: 600.89, y: 310.0), 
        chipmunk.Vect(x: 596.96, y: 322.0), chipmunk.Vect(x: 603.28, y: 327.0), 
        chipmunk.Vect(x: 606.52, y: 333.0), chipmunk.Vect(x: 605.38, y: 344.0), 
        chipmunk.Vect(x: 597.65, y: 352.0), chipmunk.Vect(x: 606.36, y: 375.0), 
        chipmunk.Vect(x: 607.16, y: 384.0), chipmunk.Vect(x: 603.4, y: 393.0), 
        chipmunk.Vect(x: 597.0, y: 398.14), chipmunk.Vect(x: 577.0, y: 386.15), 
        chipmunk.Vect(x: 564.35, y: 373.0), chipmunk.Vect(x: 565.21, y: 364.0), 
        chipmunk.Vect(x: 562.81, y: 350.0), chipmunk.Vect(x: 553.0, y: 346.06), 
        chipmunk.Vect(x: 547.48, y: 338.0), chipmunk.Vect(x: 547.48, y: 330.0), 
        chipmunk.Vect(x: 550.0, y: 323.3), chipmunk.Vect(x: 544.0, y: 321.53), 
        chipmunk.Vect(x: 537.0, y: 322.7), chipmunk.Vect(x: 532.0, y: 326.23), 
        chipmunk.Vect(x: 528.89, y: 331.0), chipmunk.Vect(x: 527.83, y: 338.0), 
        chipmunk.Vect(x: 533.02, y: 356.0), chipmunk.Vect(x: 542.0, y: 360.73), 
        chipmunk.Vect(x: 546.68, y: 369.0), chipmunk.Vect(x: 545.38, y: 379.0), 
        chipmunk.Vect(x: 537.58, y: 386.0), chipmunk.Vect(x: 537.63, y: 388.0), 
        chipmunk.Vect(x: 555.0, y: 407.47), chipmunk.Vect(x: 563.0, y: 413.52), 
        chipmunk.Vect(x: 572.5700000000001, y: 418.0), chipmunk.Vect(x: 582.72, y: 426.0), 
        chipmunk.Vect(x: 578.0, y: 431.12), chipmunk.Vect(x: 563.21, y: 440.0), 
        chipmunk.Vect(x: 558.0, y: 449.27), chipmunk.Vect(x: 549.0, y: 452.94), 
        chipmunk.Vect(x: 541.0, y: 451.38), chipmunk.Vect(x: 536.73, y: 448.0), 
        chipmunk.Vect(x: 533.0, y: 441.87), chipmunk.Vect(x: 520.0, y: 437.96), 
        chipmunk.Vect(x: 514.0, y: 429.69), chipmunk.Vect(x: 490.0, y: 415.15), 
        chipmunk.Vect(x: 472.89, y: 399.0), chipmunk.Vect(x: 472.03, y: 398.0), 
        chipmunk.Vect(x: 474.0, y: 396.71), chipmunk.Vect(x: 486.0, y: 393.61), 
        chipmunk.Vect(x: 492.0, y: 385.85), chipmunk.Vect(x: 492.0, y: 376.15), 
        chipmunk.Vect(x: 489.04, y: 371.0), chipmunk.Vect(x: 485.0, y: 368.11), 
        chipmunk.Vect(x: 480.0, y: 376.27), chipmunk.Vect(x: 472.0, y: 379.82), 
        chipmunk.Vect(x: 463.0, y: 378.38), chipmunk.Vect(x: 455.08, y: 372.0), 
        chipmunk.Vect(x: 446.0, y: 377.69), chipmunk.Vect(x: 439.0, y: 385.24), 
        chipmunk.Vect(x: 436.61, y: 391.0), chipmunk.Vect(x: 437.52, y: 404.0), 
        chipmunk.Vect(x: 440.0, y: 409.53), chipmunk.Vect(x: 463.53, y: 433.0), 
        chipmunk.Vect(x: 473.8, y: 441.0), chipmunk.Vect(x: 455.0, y: 440.3), 
        chipmunk.Vect(x: 443.0, y: 436.18), chipmunk.Vect(x: 436.0, y: 431.98), 
        chipmunk.Vect(x: 412.0, y: 440.92), chipmunk.Vect(x: 397.0, y: 442.46), 
        chipmunk.Vect(x: 393.59, y: 431.0), chipmunk.Vect(x: 393.71, y: 412.0), 
        chipmunk.Vect(x: 400.0, y: 395.1), chipmunk.Vect(x: 407.32, y: 387.0), 
        chipmunk.Vect(x: 408.54, y: 380.0), chipmunk.Vect(x: 407.42, y: 375.0), 
        chipmunk.Vect(x: 403.97, y: 370.0), chipmunk.Vect(x: 399.0, y: 366.74), 
        chipmunk.Vect(x: 393.0, y: 365.68), chipmunk.Vect(x: 391.23, y: 374.0), 
        chipmunk.Vect(x: 387.0, y: 380.27), chipmunk.Vect(x: 381.0, y: 383.52), 
        chipmunk.Vect(x: 371.56, y: 384.0), chipmunk.Vect(x: 364.98, y: 401.0), 
        chipmunk.Vect(x: 362.96, y: 412.0), chipmunk.Vect(x: 363.63, y: 435.0), 
        chipmunk.Vect(x: 345.0, y: 433.55), chipmunk.Vect(x: 344.52, y: 442.0), 
        chipmunk.Vect(x: 342.06, y: 447.0), chipmunk.Vect(x: 337.0, y: 451.38), 
        chipmunk.Vect(x: 330.0, y: 453.0), chipmunk.Vect(x: 325.0, y: 452.23), 
        chipmunk.Vect(x: 318.0, y: 448.17), chipmunk.Vect(x: 298.0, y: 453.7), 
        chipmunk.Vect(x: 284.0, y: 451.49), chipmunk.Vect(x: 278.62, y: 449.0), 
        chipmunk.Vect(x: 291.47, y: 408.0), chipmunk.Vect(x: 291.77, y: 398.0), 
        chipmunk.Vect(x: 301.0, y: 393.83), chipmunk.Vect(x: 305.0, y: 393.84), 
        chipmunk.Vect(x: 305.6, y: 403.0), chipmunk.Vect(x: 310.0, y: 409.47), 
        chipmunk.Vect(x: 318.0, y: 413.07), chipmunk.Vect(x: 325.0, y: 412.4), 
        chipmunk.Vect(x: 332.31, y: 407.0), chipmunk.Vect(x: 335.07, y: 400.0), 
        chipmunk.Vect(x: 334.4, y: 393.0), chipmunk.Vect(x: 329.0, y: 385.69), 
        chipmunk.Vect(x: 319.0, y: 382.79), chipmunk.Vect(x: 301.0, y: 389.23), 
        chipmunk.Vect(x: 289.0, y: 389.97), chipmunk.Vect(x: 265.0, y: 389.82), 
        chipmunk.Vect(x: 251.0, y: 385.85), chipmunk.Vect(x: 245.0, y: 389.23), 
        chipmunk.Vect(x: 239.0, y: 389.94), chipmunk.Vect(x: 233.0, y: 388.38), 
        chipmunk.Vect(x: 226.0, y: 382.04), chipmunk.Vect(x: 206.0, y: 374.75), 
        chipmunk.Vect(x: 206.0, y: 394.0), chipmunk.Vect(x: 204.27, y: 402.0), 
        chipmunk.Vect(x: 197.0, y: 401.79), chipmunk.Vect(x: 191.0, y: 403.49), 
        chipmunk.Vect(x: 186.53, y: 407.0), chipmunk.Vect(x: 183.6, y: 412.0), 
        chipmunk.Vect(x: 183.6, y: 422.0), chipmunk.Vect(x: 189.0, y: 429.31), 
        chipmunk.Vect(x: 196.0, y: 432.07), chipmunk.Vect(x: 203.0, y: 431.4), 
        chipmunk.Vect(x: 209.47, y: 427.0), chipmunk.Vect(x: 213.0, y: 419.72), 
        chipmunk.Vect(x: 220.0, y: 420.21), chipmunk.Vect(x: 227.0, y: 418.32), 
        chipmunk.Vect(x: 242.0, y: 408.41), chipmunk.Vect(x: 258.98, y: 409.0), 
        chipmunk.Vect(x: 250.0, y: 435.43), chipmunk.Vect(x: 239.0, y: 438.78), 
        chipmunk.Vect(x: 223.0, y: 448.19), chipmunk.Vect(x: 209.0, y: 449.7), 
        chipmunk.Vect(x: 205.28, y: 456.0), chipmunk.Vect(x: 199.0, y: 460.23), 
        chipmunk.Vect(x: 190.0, y: 460.52), chipmunk.Vect(x: 182.73, y: 456.0), 
        chipmunk.Vect(x: 178.0, y: 446.27), chipmunk.Vect(x: 160.0, y: 441.42), 
        chipmunk.Vect(x: 148.35, y: 435.0), chipmunk.Vect(x: 149.79, y: 418.0), 
        chipmunk.Vect(x: 157.72, y: 401.0), chipmunk.Vect(x: 161.0, y: 396.53), 
        chipmunk.Vect(x: 177.0, y: 385.0), chipmunk.Vect(x: 180.14, y: 380.0), 
        chipmunk.Vect(x: 181.11, y: 374.0), chipmunk.Vect(x: 180.0, y: 370.52), 
        chipmunk.Vect(x: 170.0, y: 371.68), chipmunk.Vect(x: 162.72, y: 368.0), 
        chipmunk.Vect(x: 158.48, y: 361.0), chipmunk.Vect(x: 159.56, y: 349.0), 
        chipmunk.Vect(x: 154.0, y: 342.53), chipmunk.Vect(x: 146.0, y: 339.85), 
        chipmunk.Vect(x: 136.09, y: 343.0), chipmunk.Vect(x: 130.64, y: 351.0), 
        chipmunk.Vect(x: 131.74, y: 362.0), chipmunk.Vect(x: 140.61, y: 374.0), 
        chipmunk.Vect(x: 130.68, y: 387.0), chipmunk.Vect(x: 120.75, y: 409.0), 
        chipmunk.Vect(x: 118.09, y: 421.0), chipmunk.Vect(x: 117.92, y: 434.0), 
        chipmunk.Vect(x: 100.0, y: 432.4), chipmunk.Vect(x: 87.0, y: 427.48), 
        chipmunk.Vect(x: 81.59, y: 423.0), chipmunk.Vect(x: 73.64, y: 409.0), 
        chipmunk.Vect(x: 72.56999999999999, y: 398.0), chipmunk.Vect(x: 74.62000000000001, y: 386.0), 
        chipmunk.Vect(x: 78.8, y: 378.0), chipmunk.Vect(x: 88.0, y: 373.43), 
        chipmunk.Vect(x: 92.49, y: 367.0), chipmunk.Vect(x: 93.31999999999999, y: 360.0), 
        chipmunk.Vect(x: 91.3, y: 353.0), chipmunk.Vect(x: 103.0, y: 342.67), 
        chipmunk.Vect(x: 109.0, y: 343.1), chipmunk.Vect(x: 116.0, y: 340.44), 
        chipmunk.Vect(x: 127.33, y: 330.0), chipmunk.Vect(x: 143.0, y: 327.24), 
        chipmunk.Vect(x: 154.3, y: 322.0), chipmunk.Vect(x: 145.0, y: 318.06), 
        chipmunk.Vect(x: 139.77, y: 311.0), chipmunk.Vect(x: 139.48, y: 302.0), 
        chipmunk.Vect(x: 144.95, y: 293.0), chipmunk.Vect(x: 143.0, y: 291.56), 
        chipmunk.Vect(x: 134.0, y: 298.21), chipmunk.Vect(x: 118.0, y: 300.75), 
        chipmunk.Vect(x: 109.4, y: 305.0), chipmunk.Vect(x: 94.67, y: 319.0), 
        chipmunk.Vect(x: 88.0, y: 318.93), chipmunk.Vect(x: 81.0, y: 321.69), 
        chipmunk.Vect(x: 67.24, y: 333.0), chipmunk.Vect(x: 56.68, y: 345.0), 
        chipmunk.Vect(x: 53.0, y: 351.4), chipmunk.Vect(x: 47.34, y: 333.0), 
        chipmunk.Vect(x: 50.71, y: 314.0), chipmunk.Vect(x: 56.57, y: 302.0), 
        chipmunk.Vect(x: 68.0, y: 287.96), chipmunk.Vect(x: 91.0, y: 287.24), 
        chipmunk.Vect(x: 110.0, y: 282.36), chipmunk.Vect(x: 133.8, y: 271.0), 
        chipmunk.Vect(x: 147.34, y: 256.0), chipmunk.Vect(x: 156.47, y: 251.0), 
        chipmunk.Vect(x: 157.26, y: 250.0), chipmunk.Vect(x: 154.18, y: 242.0), 
        chipmunk.Vect(x: 154.48, y: 236.0), chipmunk.Vect(x: 158.72, y: 229.0), 
        chipmunk.Vect(x: 166.71, y: 224.0), chipmunk.Vect(x: 170.15, y: 206.0), 
        chipmunk.Vect(x: 170.19, y: 196.0), chipmunk.Vect(x: 167.24, y: 188.0), 
        chipmunk.Vect(x: 160.0, y: 182.67), chipmunk.Vect(x: 150.0, y: 182.66), 
        chipmunk.Vect(x: 143.6, y: 187.0), chipmunk.Vect(x: 139.96, y: 195.0), 
        chipmunk.Vect(x: 139.5, y: 207.0), chipmunk.Vect(x: 136.45, y: 221.0), 
        chipmunk.Vect(x: 136.52, y: 232.0), chipmunk.Vect(x: 133.28, y: 238.0), 
        chipmunk.Vect(x: 129.0, y: 241.38), chipmunk.Vect(x: 119.0, y: 243.07), 
        chipmunk.Vect(x: 115.0, y: 246.55), chipmunk.Vect(x: 101.0, y: 253.16), 
        chipmunk.Vect(x: 86.0, y: 257.32), chipmunk.Vect(x: 63.0, y: 259.24), 
        chipmunk.Vect(x: 57.0, y: 257.31), chipmunk.Vect(x: 50.54, y: 252.0), 
        chipmunk.Vect(x: 47.59, y: 247.0), chipmunk.Vect(x: 46.3, y: 240.0), 
        chipmunk.Vect(x: 47.58, y: 226.0), chipmunk.Vect(x: 50.0, y: 220.57), 
        chipmunk.Vect(x: 58.0, y: 226.41), chipmunk.Vect(x: 69.0, y: 229.17), 
        chipmunk.Vect(x: 79.0, y: 229.08), chipmunk.Vect(x: 94.5, y: 225.0), 
        chipmunk.Vect(x: 100.21, y: 231.0), chipmunk.Vect(x: 107.0, y: 233.47), 
        chipmunk.Vect(x: 107.48, y: 224.0), chipmunk.Vect(x: 109.94, y: 219.0), 
        chipmunk.Vect(x: 115.0, y: 214.62), chipmunk.Vect(x: 122.57, y: 212.0), 
        chipmunk.Vect(x: 116.0, y: 201.49), chipmunk.Vect(x: 104.0, y: 194.57), 
        chipmunk.Vect(x: 90.0, y: 194.04), chipmunk.Vect(x: 79.0, y: 198.21), 
        chipmunk.Vect(x: 73.0, y: 198.87), chipmunk.Vect(x: 62.68, y: 191.0), 
        chipmunk.Vect(x: 62.58, y: 184.0), chipmunk.Vect(x: 64.42, y: 179.0), 
        chipmunk.Vect(x: 75.0, y: 167.7), chipmunk.Vect(x: 80.39, y: 157.0), 
        chipmunk.Vect(x: 68.79000000000001, y: 140.0), chipmunk.Vect(x: 61.67, y: 126.0), 
        chipmunk.Vect(x: 61.47, y: 117.0), chipmunk.Vect(x: 64.43000000000001, y: 109.0), 
        chipmunk.Vect(x: 63.1, y: 96.0), chipmunk.Vect(x: 56.48, y: 82.0), 
        chipmunk.Vect(x: 48.0, y: 73.88), chipmunk.Vect(x: 43.81, y: 66.0), 
        chipmunk.Vect(x: 43.81, y: 56.0), chipmunk.Vect(x: 50.11, y: 46.0), 
        chipmunk.Vect(x: 59.0, y: 41.55), chipmunk.Vect(x: 71.0, y: 42.64), 
        chipmunk.Vect(x: 78.0, y: 36.77), chipmunk.Vect(x: 83.0, y: 34.75), 
        chipmunk.Vect(x: 99.0, y: 34.32), chipmunk.Vect(x: 117.0, y: 38.92), 
        chipmunk.Vect(x: 133.0, y: 55.15), chipmunk.Vect(x: 142.0, y: 50.7), 
        chipmunk.Vect(x: 149.74, y: 51.0), chipmunk.Vect(x: 143.55, y: 68.0), 
        chipmunk.Vect(x: 153.28, y: 74.0), chipmunk.Vect(x: 156.23, y: 79.0), 
        chipmunk.Vect(x: 157.0, y: 84.0), chipmunk.Vect(x: 156.23, y: 89.0), 
        chipmunk.Vect(x: 153.28, y: 94.0), chipmunk.Vect(x: 144.58, y: 99.0), 
        chipmunk.Vect(x: 151.52, y: 112.0), chipmunk.Vect(x: 151.51, y: 124.0), 
        chipmunk.Vect(x: 150.0, y: 126.36), chipmunk.Vect(x: 133.0, y: 130.25), 
        chipmunk.Vect(x: 126.71, y: 125.0), chipmunk.Vect(x: 122.0, y: 117.25), 
        chipmunk.Vect(x: 114.0, y: 116.23), chipmunk.Vect(x: 107.73, y: 112.0), 
        chipmunk.Vect(x: 104.48, y: 106.0), chipmunk.Vect(x: 104.32, y: 99.0), 
        chipmunk.Vect(x: 106.94, y: 93.0), chipmunk.Vect(x: 111.24, y: 89.0), 
        chipmunk.Vect(x: 111.6, y: 85.0), chipmunk.Vect(x: 107.24, y: 73.0), 
        chipmunk.Vect(x: 102.0, y: 67.56999999999999), chipmunk.Vect(x: 99.79000000000001, y: 67.0), 
        chipmunk.Vect(x: 99.23, y: 76.0), chipmunk.Vect(x: 95.0, y: 82.27), 
        chipmunk.Vect(x: 89.0, y: 85.52), chipmunk.Vect(x: 79.84, y: 86.0), 
        chipmunk.Vect(x: 86.73, y: 114.0), chipmunk.Vect(x: 98.0, y: 136.73), 
        chipmunk.Vect(x: 99.0, y: 137.61), chipmunk.Vect(x: 109.0, y: 135.06), 
        chipmunk.Vect(x: 117.0, y: 137.94), chipmunk.Vect(x: 122.52, y: 146.0), 
        chipmunk.Vect(x: 122.94, y: 151.0), chipmunk.Vect(x: 121.0, y: 158.58), 
        chipmunk.Vect(x: 134.0, y: 160.97), chipmunk.Vect(x: 153.0, y: 157.45), 
        chipmunk.Vect(x: 171.3, y: 150.0), chipmunk.Vect(x: 169.06, y: 142.0), 
        chipmunk.Vect(x: 169.77, y: 136.0), chipmunk.Vect(x: 174.0, y: 129.73), 
        chipmunk.Vect(x: 181.46, y: 126.0), chipmunk.Vect(x: 182.22, y: 120.0), 
        chipmunk.Vect(x: 182.2, y: 111.0), chipmunk.Vect(x: 180.06, y: 101.0), 
        chipmunk.Vect(x: 171.28, y: 85.0), chipmunk.Vect(x: 171.75, y: 80.0), 
        chipmunk.Vect(x: 182.3, y: 53.0), chipmunk.Vect(x: 189.47, y: 50.0), 
        chipmunk.Vect(x: 190.62, y: 38.0), chipmunk.Vect(x: 194.0, y: 33.73), 
        chipmunk.Vect(x: 199.0, y: 30.77), chipmunk.Vect(x: 208.0, y: 30.48), 
        chipmunk.Vect(x: 216.0, y: 34.94), chipmunk.Vect(x: 224.0, y: 31.47), 
        chipmunk.Vect(x: 240.0, y: 30.37), chipmunk.Vect(x: 247.0, y: 32.51), 
        chipmunk.Vect(x: 249.77, y: 35.0), chipmunk.Vect(x: 234.75, y: 53.0), 
        chipmunk.Vect(x: 213.81, y: 93.0), chipmunk.Vect(x: 212.08, y: 99.0), 
        chipmunk.Vect(x: 213.0, y: 101.77), chipmunk.Vect(x: 220.0, y: 96.77), 
        chipmunk.Vect(x: 229.0, y: 96.48), chipmunk.Vect(x: 236.28, y: 101.0), 
        chipmunk.Vect(x: 240.0, y: 107.96), chipmunk.Vect(x: 245.08, y: 101.0), 
        chipmunk.Vect(x: 263.0, y: 65.31999999999999), chipmunk.Vect(x: 277.47, y: 48.0), 
        chipmunk.Vect(x: 284.0, y: 47.03), chipmunk.Vect(x: 286.94, y: 41.0), 
        chipmunk.Vect(x: 292.0, y: 36.62), chipmunk.Vect(x: 298.0, y: 35.06), 
        chipmunk.Vect(x: 304.0, y: 35.77), chipmunk.Vect(x: 314.0, y: 43.81), 
        chipmunk.Vect(x: 342.0, y: 32.56), chipmunk.Vect(x: 359.0, y: 31.32), 
        chipmunk.Vect(x: 365.0, y: 32.57), chipmunk.Vect(x: 371.0, y: 36.38), 
        chipmunk.Vect(x: 379.53, y: 48.0), chipmunk.Vect(x: 379.7, y: 51.0), 
        chipmunk.Vect(x: 356.0, y: 52.19), chipmunk.Vect(x: 347.0, y: 54.74), 
        chipmunk.Vect(x: 344.38, y: 66.0), chipmunk.Vect(x: 341.0, y: 70.27), 
        chipmunk.Vect(x: 335.0, y: 73.52), chipmunk.Vect(x: 324.0, y: 72.38), 
        chipmunk.Vect(x: 317.0, y: 65.75), chipmunk.Vect(x: 313.0, y: 67.79000000000001), 
        chipmunk.Vect(x: 307.57, y: 76.0), chipmunk.Vect(x: 315.0, y: 78.62000000000001), 
        chipmunk.Vect(x: 319.28, y: 82.0), chipmunk.Vect(x: 322.23, y: 87.0), 
        chipmunk.Vect(x: 323.0, y: 94.41), chipmunk.Vect(x: 334.0, y: 92.49), 
        chipmunk.Vect(x: 347.0, y: 87.47), chipmunk.Vect(x: 349.62, y: 80.0), 
        chipmunk.Vect(x: 353.0, y: 75.73), chipmunk.Vect(x: 359.0, y: 72.48), 
        chipmunk.Vect(x: 366.0, y: 72.31999999999999), chipmunk.Vect(x: 372.0, y: 74.94), 
        chipmunk.Vect(x: 377.0, y: 81.34), chipmunk.Vect(x: 382.0, y: 83.41), 
        chipmunk.Vect(x: 392.0, y: 83.40000000000001), chipmunk.Vect(x: 399.0, y: 79.15000000000001), 
        chipmunk.Vect(x: 404.0, y: 85.74), chipmunk.Vect(x: 411.0, y: 85.06), 
        chipmunk.Vect(x: 417.0, y: 86.62000000000001), chipmunk.Vect(x: 423.38, y: 93.0), 
        chipmunk.Vect(x: 425.05, y: 104.0), chipmunk.Vect(x: 438.0, y: 110.35), 
        chipmunk.Vect(x: 450.0, y: 112.17), chipmunk.Vect(x: 452.62, y: 103.0), 
        chipmunk.Vect(x: 456.0, y: 98.73), chipmunk.Vect(x: 462.0, y: 95.48), 
        chipmunk.Vect(x: 472.0, y: 95.79000000000001), chipmunk.Vect(x: 471.28, y: 92.0), 
        chipmunk.Vect(x: 464.0, y: 84.62000000000001), chipmunk.Vect(x: 445.0, y: 80.39), 
        chipmunk.Vect(x: 436.0, y: 75.33), chipmunk.Vect(x: 428.0, y: 68.45999999999999), 
        chipmunk.Vect(x: 419.0, y: 68.52), chipmunk.Vect(x: 413.0, y: 65.27), 
        chipmunk.Vect(x: 408.48, y: 58.0), chipmunk.Vect(x: 409.87, y: 46.0), 
        chipmunk.Vect(x: 404.42, y: 39.0), chipmunk.Vect(x: 408.0, y: 33.88), 
        chipmunk.Vect(x: 415.0, y: 29.31), chipmunk.Vect(x: 429.0, y: 26.45), 
        chipmunk.Vect(x: 455.0, y: 28.77), chipmunk.Vect(x: 470.0, y: 33.81), 
        chipmunk.Vect(x: 482.0, y: 42.16), chipmunk.Vect(x: 494.0, y: 46.85), 
        chipmunk.Vect(x: 499.65, y: 36.0), chipmunk.Vect(x: 513.0, y: 25.95), 
        chipmunk.Vect(x: 529.0, y: 22.42), chipmunk.Vect(x: 537.18, y: 23.0)
    ]
    selected_space: int = 0
    

proc add_circle*(space: chipmunk.Space, 
                 index: cint, 
                 radius: chipmunk.Float,
                 position: chipmunk.Vect,
                 velocity: chipmunk.Vect,
                 elasticity: chipmunk.Float,
                 friction: chipmunk.Float) = 
    var 
        mass: chipmunk.Float = radius * radius / 25.0
        body: chipmunk.Body = space.addBody(
            newBody(mass, momentForCircle(mass, 0.0, radius, chipmunk.vzero))
        )
    body.position = position
    body.velocity = velocity
    var shape: Shape = space.addShape( 
        newCircleShape(body, radius, chipmunk.vzero)
    )
    shape.elasticity = elasticity
    shape.friction = friction
    shape.set_random_color()

proc add_box*(space: chipmunk.Space, 
              index: cint, 
              size: chipmunk.Float,
              position: chipmunk.Vect,
              velocity: chipmunk.Vect,
              elasticity: chipmunk.Float,
              friction: chipmunk.Float) = 
    var
        mass: chipmunk.Float = size * size / 100.0
        body: chipmunk.Body = space.addBody(
            newBody(mass, momentForBox(mass, size, size))
        )
    body.position = position
    body.velocity = velocity
    var shape: Shape = space.addShape( 
        newBoxShape(body, size - bevel * 2, size - bevel * 2, 0.0)
    )
#    shape.radius = bevel # Chipmunk2D PRO function 'cpPolyShapeSetRadius'
    shape.elasticity = elasticity
    shape.friction = friction
    shape.set_random_color()

proc add_hexagon*(space: chipmunk.Space, 
                  index: cint, 
                  radius: chipmunk.Float,
                  position: chipmunk.Vect,
                  velocity: chipmunk.Vect,
                  elasticity: chipmunk.Float,
                  friction: chipmunk.Float) = 
    var 
        hexagon: array[6, chipmunk.Vect]
    for i in 0..len(hexagon)-1: 
        var angle: chipmunk.Float = -(math.PI * 2.0 * float(i) / 6.0)
        hexagon[i] = vmult(
            chipmunk.v(math.cos(angle), math.sin(angle)), 
            radius - bevel
        )
    var 
        mass: chipmunk.Float = radius * radius
        body: chipmunk.Body = space.addBody(
            newBody(
                mass, 
                momentForPoly(
                    mass, 
                    6, 
                    cast[ptr chipmunk.Vect](addr(hexagon)), 
                    chipmunk.vzero, 
                    0.0
                )
            )
        )
    body.position = position
    body.velocity = velocity
    var shape: chipmunk.Shape = space.addShape( 
        newPolyShape(
            body, 
            6, 
            cast[ptr chipmunk.Vect](addr(hexagon)), 
            TransformIdentity, 
            bevel
        )
    )
    shape.elasticity = elasticity
    shape.friction = friction
    #shape.set_random_color()
    shape.set_color(chipmunk.SpaceDebugColor(r:1.0, g:0.0, b:0.0, a:1.0))

proc setup_terrain(vertices: openarray[chipmunk.Vect], gravity: bool=true, 
                   elasticity: chipmunk.Float=0): chipmunk.Space = 
    result = newSpace()
    result.iterations = 10
    if gravity == true:
        result.gravity = chipmunk.v(0, -100)
    result.collisionSlop = 0.5
    var offset: chipmunk.Vect = chipmunk.v(-320, -240)
    for i in 0..(vertices.len()-2): 
        var 
            a: chipmunk.Vect = vertices[i]
            b: chipmunk.Vect = vertices[i + 1]
            shape = result.addShape(
                newSegmentShape(
                    result.staticBody(), 
                    vadd(a, offset), 
                    vadd(b, offset), 
                    0.0
                )
            )
        shape.elasticity = elasticity

## Simple terrain
proc init_simple_terrain(circle_count, box_count, hex_count: int) = 
    space = setup_terrain(simple_terrain_verts)
    for i in 0..circle_count-1:
        var position = chipmunk.vmult(frand_unit_circle(), 180.0)
        add_circle(space, cint(i), 5.0, position, chipmunk.vzero, 0.0, 0.9)
    for i in 0..box_count-1:
        var position = chipmunk.vmult(frand_unit_circle(), 180.0)
        add_box(space, cint(i), 10.0, position, chipmunk.vzero, 0.0, 0.9)
    for i in 0..hex_count-1:
        var position = chipmunk.vmult(frand_unit_circle(), 180.0)
        add_hexagon(space, cint(i), 5.0, position, chipmunk.vzero, 0.0, 0.9)

## Complex terrain
proc init_complex_terrain(circle_count, box_count, hex_count: int) = 
    space = setup_terrain(complex_terrain_verts)
    # Circles
    for i in 0..circle_count-1: 
        var position = vadd(
            vmult(data.frand_unit_circle(), 180.0), 
            chipmunk.v(0.0, 300.0)
        )
        add_circle(space, cint(i), 5.0, position, chipmunk.vzero, 0.0, 0.0)
    # Boxes
    for i in 0..box_count-1:
        var position = vadd(
            vmult(data.frand_unit_circle(), 180.0), 
            chipmunk.v(0.0, 300.0)
        )
        add_box(space, cint(i), 10.0, position, chipmunk.vzero, 0.0, 0.0)
    # Hexagons
    for i in 0..hex_count-1:
        var position = vadd(
            vmult(data.frand_unit_circle(), 180.0), 
            chipmunk.v(0.0, 300.0)
        )
        add_hexagon(space, cint(i), 5.0, position, chipmunk.vzero, 0.0, 0.0)

## Bouncy terrain
proc init_bouncy_terrain(circle_count, box_count, hex_count: int) = 
    space = setup_terrain(bouncy_terrain_verts, gravity=false, elasticity=1.0)
    for i in 0..circle_count-1:
        var 
            position = vadd(vmult(frand_unit_circle(), 130.0), chipmunk.vzero)
            velocity = vmult(frand_unit_circle(), 50.0)
        add_circle(space, cint(i), 5.0, position, velocity, 1.0, 0.7)
    for i in 0..box_count-1:
        var 
            position = vadd(vmult(frand_unit_circle(), 130.0), chipmunk.vzero)
            velocity = vmult(frand_unit_circle(), 50.0)
        add_box(space, cint(i), 10.0, position, velocity, 1.0, 0.7)
    for i in 0..hex_count-1:
        var 
            position = vadd(vmult(frand_unit_circle(), 100.0), chipmunk.vzero)
            velocity = vmult(frand_unit_circle(), 50.0)
        add_hexagon(space, cint(i), 5.0, position, velocity, 1.0, 0.0)

proc clean_up_space() =
    space.eachShape(data.clean_up_shape_color, nil)
    space.clean_up_children()
    space.destroy()

proc select_space(number: int) =
    if number == 0:
        init_simple_terrain(300, 300, 300)
    elif number == 1:
        init_complex_terrain(300, 300, 300)
    else:
        init_bouncy_terrain(0, 0, 1000)

var 
    current_color = chipmunk.SpaceDebugColor(r: 1.0, g: 0.0, b: 0.0, a: 1.0)
    color_direction: bool = false
proc change_shape_color(shape: Shape, data: pointer) {.cdecl.} =
    shape.set_color(current_color)


## Procs for usage in the chipmunk_demo module
proc init*() {.procvar.} =
    selected_space = 0
    select_space(selected_space)

proc update*(dt: cdouble) {.procvar.} = 
    space.step(dt)
    space.eachShape(change_shape_color, nil)
    # Add a little color changing
    if color_direction == false:
        current_color.g += 0.01
        current_color.b += 0.01
        if current_color.b > 1.0:
            color_direction = true
            current_color.g = 1.0
            current_color.b = 1.0
    else:
        current_color.g -= 0.01
        current_color.b -= 0.01
        if current_color.b < 0.0:
            color_direction = false
            current_color.g = 0.0
            current_color.b = 0.0

proc input*(in_space: var chipmunk.Space, event: sdl2.EventType, 
            key_event: sdl2.KeyboardEventObj, 
            key: cint, modifier: bool) {.procvar.} =
    if event == sdl2.EventType.KeyUp:
        if key_event.repeat == false:
            # Change the space
            if key == K_RIGHT:
                selected_space += 1
                if selected_space > 2:
                    selected_space = 0
                clean_up_space()
                select_space(selected_space)
                # This re-referencing is mandatory
                in_space = space
            elif key == K_LEFT:
                selected_space -= 1
                if selected_space < 0:
                    selected_space = 2
                clean_up_space()
                select_space(selected_space)
                # This re-referencing is mandatory
                in_space = space

proc draw*() {.procvar.} =
    space.default_draw_implementation()
    data.draw_text(
        "Various objects on various closed shape spaces.",
        Vect(x: DEMO_TEXT_X_OFFSET, y: DEMO_TEXT_Y_OFFSET_LINE_1)
    )
    data.draw_text(
        "Use LEFT and RIGHT to change the space.",
        Vect(x: DEMO_TEXT_X_OFFSET, y: DEMO_TEXT_Y_OFFSET_LINE_2)
    )

proc get_space*(): chipmunk.Space {.procvar.} =
    result = space

proc clean_up*() {.procvar.} =
    clean_up_space()


