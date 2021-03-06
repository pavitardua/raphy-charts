# Copyright 2012 Joshua Carver  
#  
# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
#  
# http://www.apache.org/licenses/LICENSE-2.0 
#  
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License. 


# @import point.coffee
# @import label.coffee
# @import scaling.coffee
# @import base_chart.coffee

bar = (label, value, average, comparison) ->
  {
    label: label,
    value: value,
    average: average
    comparison: comparison
  }


class BulletChart extends BaseChart
  constructor: (dom_id, options = {}) ->
    super dom_id, new BulletChartOptions(options)
    @bars = []

  add: (label, value, average, comparison) ->
    @bars.push bar.apply(bar, arguments)


  draw_background: (point, y_offset) ->
    rect = @r.rect(
      @options.x_padding,
      y_offset,
      point.x,
      @options.area_width
    )

    rect.attr({
      fill: @options.area_color
      "stroke": "none" 
    })

  draw_line: (point, background_midpoint) ->
    y = background_midpoint.y - @options.line_width/2
    rect = @r.rect(
      @options.x_padding,
      y,
      point.x,
      @options.line_width
    )

    rect.attr({
      fill: @options.line_color
      "stroke" : "none"
    })

  
  draw_average: (point, midpoint_y) ->
    rect = @r.rect(
      point.x - (@options.average_width/2),
      midpoint_y - @options.average_height/2,
      @options.average_width,
      @options.average_height
    )

    rect.attr({
      fill: @options.average_color
      "stroke" : "none"
    })

  draw_label: (text, offset) ->


  clear: () ->
    super()
    @bars = []


  draw: () ->
    for bar, i in @bars

      p = [
            new Point(bar.comparison, 0),
            new Point(bar.value, 0),
            new Point(bar.average, 0),
            new Point(0,0) # dummy for scaling
          ]

      [max_x, min_x, max_y, min_y] = Scaling.get_ranges_for_points(p)

      x = new Scaler()
      .domain([min_x, max_x])
      .range([@options.x_padding, @width - @options.x_padding])

      points = (new Point(x(point.x), 0) for point in p)

      y_offset = i * (@options.area_width + @options.bar_margin)
      @draw_background(points[0], y_offset)

      midpoint_y = y_offset + @options.area_width/2
      @draw_line(points[1], new Point(points[0].x, midpoint_y))

      @draw_average(points[2], midpoint_y)

      new Label(
       @r,
       0,
       y_offset + @options.area_width/2,
       bar.label,
       "",
       @size = 14,
       @options.font_family
      ).draw()

exports.BulletChart = BulletChart
