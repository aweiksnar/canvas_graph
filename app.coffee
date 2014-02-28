class CanvasGraph
  constructor: (@canvas, @data) ->
    @ctx = @canvas.getContext('2d')
    window.ctx = @ctx
    window.canvas = @canvas
    window.canvasGraph = @

    @smallestX = Math.min (point.x for point in @data)...
    @smallestY = Math.min (point.y for point in @data)...

    @largestX = Math.max (point.x for point in @data)...
    @largestY = Math.max (point.y for point in @data)...

    @marks = new Marks
    window.marks = @marks
    # @mirrorVertically()

    canvas.addEventListener 'mousedown', (e) =>
      e.preventDefault()
      # @dragging = true
      @mark = new Mark(e, @)
      @marks.create(@mark)
      @mark.dragging = true
      @mark.draw(e)

    canvas.addEventListener 'mousemove', (e) =>
      e.preventDefault()
      @mark?.draw(e) if @mark?.dragging

    zoomBtn = document.getElementById('toggle-zoom')
    zoomBtn.addEventListener 'click', (e) =>
      e.preventDefault()
      @zoomed = !@zoomed
      if @zoomed then canvasState.plotZoomedPoints(5,20) else canvasState.rescale()

  drawAxes: ->
    #draws non-scaled axes
    for num in [0..@canvas.width] by 100
      @ctx.moveTo(num-.5, 0)
      @ctx.lineTo(num-.5, @canvas.height)

    for num in [0..@canvas.height] by 100
      @ctx.moveTo(0, num-.5)
      @ctx.lineTo(@canvas.width, num-.5)

    @ctx.strokeStyle = "gray"
    @ctx.stroke()

  plotPoints: ->
    for point in @data
      x = ((point.x - @smallestX) / (@largestX - @smallestX)) * @canvas.width
      y = ((point.y - @largestY) / (@smallestY - @largestY)) * @canvas.height
      @ctx.fillStyle = "#fff"
      @ctx.fillRect(x, y,2,2)

    @scale = (@largestX - @smallestX) / @largestX

    # @marks.drawAll(@scale)

  plotZoomedPoints: (xMin, xMax) ->
    @clearCanvas()
    for point in @data
      x = ((point.x - xMin) / (xMax - xMin)) * @canvas.width
      y = ((point.y - @largestY) / (@smallestY - @largestY)) * @canvas.height
      @ctx.fillStyle = "#fff"
      @ctx.fillRect(x, y,2,2)

    @scale = 1 + (xMax - xMin) / @largestX
    # @marks.drawAll(@scale)

  rescale: ->
    @clearCanvas()
    @plotPoints()

  clearCanvas: -> @ctx.clearRect(0,0,@canvas.width, @canvas.height)

  mirrorVertically: ->
    @ctx.translate(0,@canvas.height)
    @ctx.scale(1,-1)

  toCanvasXCoord: (dataPoint) -> ((dataPoint - @smallestX) / (@largestX - @smallestX)) * @canvas.width

  toDataXCoord: (canvasPoint) -> (canvasPoint / @canvas.width) * (@largestX - @smallestX)

  # TODO: fix the math on this one....
  toDomXCoord: (dataPoint) -> ((dataPoint / @canvas.width) * (@largestX - @smallestX) * @canvas.width) + @canvas.getBoundingClientRect().left

class Marks
  constructor: -> @all = []

  create: (mark) -> document.getElementById('marks-container').appendChild(mark.element)

  add: (mark) -> @all.push(mark)

  remove: (mark) ->
    @all.splice(@all.indexOf(mark), 1)
    document.getElementById('marks-container').removeChild(mark.element)

  destroyAll: ->
    document.getElementById('marks-container').innerHTML = ""
    @all = []

  # drawAll: (scale = 1) ->
  #   for mark in @all
  #     mark.element.style.width = parseFloat(mark.element.style.width, 10) * +scale

class Mark
  constructor: (e, @canvasGraph) ->
    #TODO: make an active state
    @element = document.createElement('div')
    @element.className = "mark"
    @element.style.left = e.x
    @element.style.top = e.target.offsetTop
    @startingPoint = e.x
    @dragging = false

    @element.addEventListener 'mousedown', (e) =>
      # resizing
      if (Math.abs e.layerX - (@domXMax-@domXMin)) < 12
        @startingPoint = @domXMin
        @dragging = true
      else if e.layerX < 12
        @startingPoint = @domXMax
        @dragging = true
      else if e.layerY > 15
        @moving = true
        @movingStart = e.x

    @element.addEventListener 'mousemove', (e) =>
      @draw(e) if @dragging
      @move(e) if @moving

    @element.addEventListener 'mouseup', (e) =>
      if @dragging
        @canvasGraph.marks.add(@)
        document.getElementById('points').innerHTML += "x1: #{@dataXMin}, x2: #{@dataXMax}</br>"
        console.log "Marks", @canvasGraph.marks
        @dragging = false
      else if @moving
        @save(@domXMin, @domXMax)
        @moving = false

    @element.addEventListener 'click', (e) =>
      @canvasGraph.marks.remove(@) if e.layerY < 15

  draw: (e) ->
    markLeftX = Math.min @startingPoint, e.x
    markRightX = Math.max @startingPoint, e.x

    @element.style.left = Math.min markLeftX, markRightX
    @element.style.width = Math.abs markRightX - markLeftX
    # @element.style.webkitTransform = "rotate(-2deg)" #whoa

    @save(markLeftX, markRightX)

  move: (e) ->
    markLeftX = @domXMin - (@movingStart - e.x)
    markRightX = @domXMax - (@movingStart - e.x)

    @element.style.left = Math.min markLeftX, markRightX
    @element.style.width = Math.abs markRightX - markLeftX

  save: (markLeftX, markRightX) ->
    # need to update starting point (or remove)

    #dom coords
    @domXMin = markLeftX
    @domXMax = markRightX

    #canvas coords
    @canvasXMin = markLeftX - @canvasGraph.canvas.getBoundingClientRect().left
    @canvasXMax = markRightX - @canvasGraph.canvas.getBoundingClientRect().left

    #data coords
    @dataXMin = @canvasGraph.toDataXCoord(@canvasXMin)
    @dataXMax = @canvasGraph.toDataXCoord(@canvasXMax)


canvas = document.getElementById("graph")
canvasState = new CanvasGraph(canvas, light_curve_data)
# canvasState.drawAxes()
canvasState.plotPoints()
# canvasState.rescale()
# canvasState.plotZoomedPoints(15,34.98)

#TODO:

#zoom

#add a scaling function to redraw marks
#only do 'pointer-events: none' if drawing, take off if clicking inside a mark
#add handles, dragging and such

#make Marks create #marks-container, and CanvasGraph possibly create canvas
#math
