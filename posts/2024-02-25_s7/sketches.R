library(S7)

# classes that define shapes ----------------------------------------------

# style is the class used to define the graphical properties of a drawable
# object. it is essentially a container for arguments that are passed to
# grid::gpar()
style <- new_class(
  name = "style",
  properties = list(
    color     = new_property(class_character, default = "black"),
    fill      = new_property(class_character, default = "black"),
    linewidth = new_property(class_numeric, default = 1)
  )
)

# points is the class used to represent vertices of a polygon. most drawables
# will contain a points object as a computed property, but there's also the
# basic shape class in which the user can specify the points directly
points <- new_class(
  name = "points",
  properties = list(
    x = class_numeric,
    y = class_numeric
  ),
  validator = function(self) {
    if (length(self@x) != length(self@y)) {
      "x and y must be the same length"
    }
  }
)

# drawable is the parent class used to enforce structure: all drawables must
# contain a computed aesthetic object and a computed points object
drawable <- new_class(
  name = "drawable",
  properties = list(
    style = new_property(
      class = style,
      default = style()
    ),
    points = new_property(
      class = points,
      getter = function(self) points(x = numeric(0L), y = numeric(0L))
    )
  ),
  constructor = function(...) new_object(S7_object(), style = style(...))
)

# shapes are the simplest kind of drawable object: the user passes the
# x and y coordinates directly, and the points object is computed in the
# most trivial possible way. generally you wouldn't use this but it is
# nevertheless helpful to have this "minimal" class.
shape <- new_class(
  name = "shape",
  parent = drawable,
  properties = list(
    x = class_numeric,
    y = class_numeric,
    points = new_property(
      class = points,
      getter = function(self) {
        points(x = self@x, y = self@y)
      }
    )
  ),
  validator = function(self) {
    if (length(self@x) != length(self@y)) {
      "x and y must be the same length"
    }
  },
  constructor = function(x, y, ...) {
    new_object(
      drawable(),
      x = x,
      y = y,
      style = style(...)
    )
  }
)

# circles inherit from drawables, and are defined by a centroid,
# a radius, and the number of points n used to draw the shape:
# the x and y coordinates associated with the circle are computed
# properties
circle <- new_class(
  name = "circle",
  parent = drawable,
  properties = list(
    x      = class_numeric,
    y      = class_numeric,
    radius = class_numeric,
    n      = class_integer,
    points = new_property(
      class = points,
      getter = function(self) {
        angle <- seq(0, 2 * pi, length.out = self@n)
        points(
          x = self@x + self@radius * cos(angle),
          y = self@y + self@radius * sin(angle)
        )
      }
    )
  ),
  validator = function(self) {
    if (length(self@x) != 1) return("x must be length 1")
    if (length(self@y) != 1) return("y must be length 1")
    if (length(self@radius) != 1) return("radius must be length 1")
    if (length(self@n) != 1) return("n must be length 1")
    if (self@radius < 0) return("radius must be a non-negative number")
    if (self@n < 1L) return("n must be a positive integer")
  },
  constructor = function(x = 0, y = 0, radius = 1, n = 100L, ...) {
    new_object(
      drawable(),
      x = x,
      y = y,
      radius = radius,
      n = n,
      style = style(...)
    )
  }
)

# blobs are essentially "circles with a non-constant radius", where the
# irregularity in the radius is a smoothly varying distortion created with perlin
# noise
blob <- new_class(
  name = "blob",
  parent = drawable,
  properties = list(
    x          = class_numeric,
    y          = class_numeric,
    radius     = class_numeric,
    range      = class_numeric,
    n          = class_integer,
    frequency  = class_numeric,
    octaves    = class_integer,
    seed       = class_integer,
    points = new_property(
      class = points,
      getter = function(self) {
        angle <- seq(0, 2*pi, length.out = self@n)
        pointwise_radius <- ambient::fracture(
          noise = ambient::gen_simplex,
          fractal = ambient::fbm,
          x = self@x + cos(angle) * self@radius,
          y = self@y + sin(angle) * self@radius,
          frequency = self@frequency,
          seed = self@seed,
          octaves = self@octaves
        ) |>
          ambient::normalize(to = self@radius + c(-1, 1) * self@range)
        points(
          x = self@x + pointwise_radius * cos(angle),
          y = self@y + pointwise_radius * sin(angle)
        )
      }
    )
  ),
  constructor = function(x = 0,
                         y = 0,
                         radius = 1,
                         range = 0.2,
                         n = 100L,
                         frequency = 1,
                         octaves = 2L,
                         seed = 1L,
                         ...) {
    new_object(
      drawable(),
      x = x,
      y = y,
      radius = radius,
      range = range,
      n = n,
      frequency = frequency,
      octaves = octaves,
      seed = seed,
      style = style(...)
    )
  },
  validator = function(self) {
    if (length(self@x) != 1) return("x must be length 1")
    if (length(self@y) != 1) return("y must be length 1")
    if (length(self@radius) != 1) return("radius must be length 1")
    if (length(self@range) != 1) return("range must be length 1")
    if (length(self@n) != 1) return("n must be length 1")
    if (length(self@frequency) != 1) return("frequency must be length 1")
    if (length(self@octaves) != 1) return("octaves must be length 1")
    if (length(self@seed) != 1) return("seed must be length 1")
    if (self@radius < 0) return("radius must be a non-negative number")
    if (self@range < 0) return("range must be a non-negative number")
    if (self@frequency < 0) return("frequency must be a non-negative number")
    if (self@n < 1L) return("n must be a positive integer")
    if (self@octaves < 1L) return("octaves must be a positive integer")
  }
)

# ribbons are similar to blobs, but the polygon is defined by movement along a
# line rather than around a circle
ribbon <- new_class(
  name = "ribbon",
  parent = drawable,
  properties = list(
    x          = class_numeric,
    y          = class_numeric,
    xend       = class_numeric,
    yend       = class_numeric,
    width      = class_numeric,
    n          = class_integer,
    frequency  = class_numeric,
    octaves    = class_integer,
    seed       = class_integer,
    points = new_property(
      class = points,
      getter = function(self) {
        x <- seq(self@x, self@xend, length.out = self@n)
        y <- seq(self@y, self@yend, length.out = self@n)
        displacement <- ambient::fracture(
          noise = ambient::gen_simplex,
          fractal = ambient::fbm,
          x = x,
          y = y,
          frequency = self@frequency,
          seed = self@seed,
          octaves = self@octaves
        ) |>
          ambient::normalize(to = c(0, 1))
        taper <- sqrt(
          seq(0, 1, length.out = self@n) * seq(1, 0, length.out = self@n)
        )
        width <- displacement * taper * self@width
        dx <- self@xend - self@x
        dy <- self@yend - self@y
        points(
          x = c(x - width * dy, x[self@n:1L] + width[self@n:1L] * dy),
          y = c(y + width * dx, y[self@n:1L] - width[self@n:1L] * dx)
        )
      }
    )
  ),
  constructor = function(x = 0,
                         y = 0,
                         xend = 1,
                         yend = 1,
                         width = 0.2,
                         n = 100L,
                         frequency = 1,
                         octaves = 2L,
                         seed = 1L,
                         ...) {
    new_object(
      drawable(),
      x = x,
      y = y,
      xend = xend,
      yend = yend,
      width = width,
      n = n,
      frequency = frequency,
      octaves = octaves,
      seed = seed,
      style = style(...)
    )
  },
  validator = function(self) {
    if (length(self@x) != 1) return("x must be length 1")
    if (length(self@y) != 1) return("y must be length 1")
    if (length(self@xend) != 1) return("xend must be length 1")
    if (length(self@yend) != 1) return("yend must be length 1")
    if (length(self@width) != 1) return("width must be length 1")
    if (length(self@n) != 1) return("n must be length 1")
    if (length(self@frequency) != 1) return("frequency must be length 1")
    if (length(self@octaves) != 1) return("octaves must be length 1")
    if (length(self@seed) != 1) return("seed must be length 1")
    if (self@width < 0) return("width must be a non-negative number")
    if (self@frequency < 0) return("frequency must be a non-negative number")
    if (self@n < 1L) return("n must be a positive integer")
    if (self@octaves < 1L) return("octaves must be a positive integer")
  }
)

# sketch class ------------------------------------------------------------

# a sketch is a list of drawables
sketch <- new_class(
  name = "sketch",
  properties = list(
    shapes = new_property(class = class_list, default = list())
  ),
  validator = function(self) {
    if (!all(purrr::map_lgl(self@shapes, \(d) inherits(d, "drawable")))) {
      "shapes must be a list of drawable-classed objects"
    }
  }
)

# ggplot2 style "addition" operator TODO: not happy with this tbh
`+.sketch` <- function(e1, e2) {
  e1@shapes <- c(e1@shapes, e2)
  e1
}

# draw generic and methods ------------------------------------------------

# s7 generic function used for plotting
draw <- new_generic("draw", dispatch_args = "object")

# draw method for any simple drawable
method(draw, drawable) <- function(object, xlim = NULL, ylim = NULL, ...) {

  # plotting area is a single viewport with equal-axis scaling
  if (is.null(xlim)) xlim <- range(object@points@x)
  if (is.null(ylim)) ylim <- range(object@points@x)
  x_width <- xlim[2] - xlim[1]
  y_width <- ylim[2] - ylim[1]
  vp <- grid::viewport(
    xscale = xlim,
    yscale = ylim,
    width  = grid::unit(min(1, x_width / y_width), "snpc"),
    height = grid::unit(min(1, y_width / x_width), "snpc"),
  )

  # shapes are always polygon grobs
  grob <- grid::polygonGrob(
    x = object@points@x,
    y = object@points@y,
    gp = grid::gpar(
      col = object@style@color,
      fill = object@style@fill,
      lwd = object@style@linewidth
    ),
    vp = vp,
    default.units = "native"
  )

  # draw the grob
  grid::grid.newpage()
  grid::grid.draw(grob)
}

method(draw, sketch) <- function(object, xlim = NULL, ylim = NULL, ...) {

  # set default axis limits
  if (is.null(xlim)) {
    xlim <- c(
      min(purrr::map_dbl(object@shapes, \(s, id) min(s@points@x))),
      max(purrr::map_dbl(object@shapes, \(s, id) max(s@points@x)))
    )
  }
  if (is.null(ylim)) {
    ylim <- c(
      min(purrr::map_dbl(object@shapes, \(s) min(s@points@y))),
      max(purrr::map_dbl(object@shapes, \(s) max(s@points@y)))
    )
  }

  # plotting area is a single viewport with equal-axis scaling
  x_width <- xlim[2] - xlim[1]
  y_width <- ylim[2] - ylim[1]
  vp <- grid::viewport(
    xscale = xlim,
    yscale = ylim,
    width  = grid::unit(min(1, x_width / y_width), "snpc"),
    height = grid::unit(min(1, y_width / x_width), "snpc"),
  )

  # draw the grobs
  grid::grid.newpage()
  for(s in object@shapes) {
    grob <- grid::polygonGrob(
      x = s@points@x,
      y = s@points@y,
      gp = grid::gpar(
        col = s@style@color,
        fill = s@style@fill,
        lwd = s@style@linewidth
      ),
      vp = vp,
      default.units = "native"
    )
    grid::grid.draw(grob)
  }
}

# catchall method for non-drawables
method(draw, class_any) <- function(object, ...) {
  rlang::warn("Non-drawable objects ignored by draw()")
  return(invisible(NULL))
}

# convert methods ---------------------------------------------------------

# convert a drawable to a plain shape
method(convert, list(drawable, shape)) <- function(from, to) {
  shape(
    style = from@style,
    x = from@points@x,
    y = from@points@y
  )
}
