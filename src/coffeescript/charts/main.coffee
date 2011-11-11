# @import bezier.coffee
# @import scaling.coffee
# @import point.coffee
# @import tooltip.coffee
# @import dot.coffee
# @import line_chart_options.coffee



class LineChart
  constructor: (dom_id, options = {}) ->
    @container = document.getElementById(dom_id)
    @width   = parseInt(@container.style.width)
    @height  = parseInt(@container.style.height)
    @padding = 40 
    @options = new LineChartOptions(options)

    @r = Raphael(@container, @width, @height)

  add_line: (@raw_points, options = {}) ->
    @points = Scaling.scale_points(@width, @height, @raw_points, @padding)

  draw_curve: () ->
    path = @r.path Bezier.create_path(@points, 1 - @options.smoothing)
    path.attr({
      "stroke"       : @options.line_color
      "stroke-width" : @options.line_width
    })

  draw_area: () ->
    padded_height = @height
    padded_width = @width + @padding

    final_point = @points[@points.length-1]
    first_point = @points[0]

    path = ""

    for point, i in @points
      if i == 0
        path += "M #{first_point.x}, #{first_point.y}" 
      else
        path += "L #{point.x}, #{point.y}"

    path += "M #{final_point.x}, #{final_point.y}"
    path += "L #{final_point.x}, #{padded_height}"
    path += "L #{first_point.x}, #{padded_height}"
    path += "L #{first_point.x}, #{first_point.y}"
    path += "Z"

    @r.path(path).attr({
      "fill" : @options.area_color 
      "fill-opacity" : @options.area_opacity 
      "stroke" : "none"
    })

  draw: () ->
    @r.clear()
    @draw_curve()
    @draw_area() if @options.fill_area

    tooltips = []
    dots = []
    max_point = 0
    min_point = 0

    # draw individual points
    for point, i in @points
      dots.push new Dot(@r, point, @options)
      tooltips.push new Tooltip(@r, dots[i].element, @raw_points[i].y) 
      max_point = i if @raw_points[i].y >= @raw_points[max_point].y 
      min_point = i if @raw_points[i] > @raw_points[min_point].y 

    if @options.label_max
      tooltips[max_point].show()
      dots[max_point].activate()

    if @options.label_min
      tooltips[min_point].show()
      dots[min_point].activate()

    return


create_random_points = -> 
  points = (new Point(i, i*(i-1)) for i in [0..25])
  points.push(new Point(26, 30))
  points.push(new Point(27, 300))
  points.push(new Point(28, 800))
  points.push(new Point(29, 500))
  points.push(new Point(30, 600))
  points.push(new Point(31, 610))
  points.push(new Point(32, 620))
  points

create_random_points2 = -> 
  points = (new Point(i, Math.random() * i) for i in [0..25])
  points


draw_bars = (r, points) ->
  attach_handler = (element) ->
    element.mouseover () ->
      element.attr({ "fill" : "#333" })

    element.mouseout () ->
      element.attr({ "fill" : "#00aadd" })

  x = points[0].x 
  for point, i in points
    rect = r.rect(x-15, point.y, 15, 300 - point.y)
    x += 16 

    rect.attr({ 
      "fill"        : "#00aadd",
      "stroke"      : "transparent",
      "stroke-width": "0"
    })

    attach_handler(rect)

    new Tooltip(r, rect, Math.floor(points[i].y))

window.onload = () ->
  # line 
  raw_points = create_random_points()
  c = new LineChart('chart1')
  c.add_line(raw_points)
  c.draw()


  c = new LineChart('chart2', {
    line_color : "#118800"
    dot_color  : "#118800"
    dot_stroke_color: "#aaa"
    dot_stroke_size: 3 
    fill_area  : false
    label_min  : false
    smoothing  : 0.3
  })
  c.add_line(create_random_points2())
  c.draw()

  # bars
  chart2 = document.getElementById('chart3')
  [width, height, padding] = [1000, 300, 25]
  r2 = Raphael(chart2, width, height)
  points = Scaling.scale_points(width, height, raw_points, padding)
  draw_bars(r2, points)
