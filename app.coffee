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
      @dragging = true
      @mark = new Mark(e, @)
      @marks.create(@mark)
      @mark.draw(e)

    canvas.addEventListener 'mousemove', (e) =>
      @mark.draw(e) if @dragging

    zoomBtn = document.getElementById('toggle-zoom')
    zoomBtn.addEventListener 'click', (e) =>
      @zoomed = !@zoomed
      if @zoomed then canvasState.plotZoomedPoints(5,20) else canvasState.rescale()

    @dragging = false

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

    @marks.drawAll(@scale)

  plotZoomedPoints: (xMin, xMax) ->
    @clearCanvas()
    for point in @data
      x = ((point.x - xMin) / (xMax - xMin)) * @canvas.width
      y = ((point.y - @largestY) / (@smallestY - @largestY)) * @canvas.height
      @ctx.fillStyle = "#fff"
      @ctx.fillRect(x, y,2,2)

    @scale = 1 + (xMax - xMin) / @largestX
    @marks.drawAll(@scale)

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

  drawAll: (scale = 1) ->
    for mark in @all
      mark.element.style.width = parseFloat(mark.element.style.width, 10) * +scale

class Mark
  constructor: (e, @canvasGraph) ->
    @element = document.createElement('div')
    @element.className = "mark"
    @element.style.left = e.x
    @element.style.top = e.target.offsetTop
    @startingPoint = e.x

    @element.addEventListener 'mousedown', (e) =>
      console.log "e", e
      if (Math.abs e.layerX - (@domXMax-@domXMin)) < 10
        @startingPoint = @domXMin
        @canvasGraph.dragging = true
      else if e.layerX < 10
        @startingPoint = @domXMax
        @canvasGraph.dragging = true

    @element.addEventListener 'mousemove', (e) =>
      @draw(e) if @canvasGraph.dragging

    @element.addEventListener 'mouseup', (e) =>
      if @canvasGraph.dragging
        @canvasGraph.dragging = false
        @canvasGraph.marks.add(@)

        document.getElementById('points').innerHTML += "x1: #{@dataXMin}, x2: #{@dataXMax}</br>"
        console.log "Marks", @canvasGraph.marks

    @element.addEventListener 'click', (e) =>
      @canvasGraph.marks.remove(@) if e.offsetY < 15

  draw: (e) ->
    markLeftX = (Math.min @startingPoint, e.x)
    markRightX = (Math.max @startingPoint, e.x)

    @element.style.left = Math.min markLeftX, markRightX
    @element.style.width = Math.abs markRightX - markLeftX
    # @element.style.webkitTransform = "rotate(-2deg)" #whoa

    #dom coords
    @domXMin = markLeftX
    @domXMax = markRightX

    #canvas coords
    @canvasXMin = markLeftX - @canvasGraph.canvas.getBoundingClientRect().left
    @canvasXMax = markRightX - @canvasGraph.canvas.getBoundingClientRect().left

    #data coords
    @dataXMin = @canvasGraph.toDataXCoord(@canvasXMin)
    @dataXMax = @canvasGraph.toDataXCoord(@canvasXMax)


  # move: ->

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

