class CanvasGraph
  constructor: (@canvas, @data) ->
    @ctx = @canvas.getContext('2d')
    window.ctx = @ctx
    window.canvas = @canvas

    @smallestX = Math.min (point.x for point in @data)...
    @smallestY = Math.min (point.y for point in @data)...

    @largestX = Math.max (point.x for point in @data)...
    @largestY = Math.max (point.y for point in @data)...

    @marks = new Marks
    window.marks = @marks
    # @mirrorVertically()

    canvas.addEventListener 'mousedown', (e) =>
      @dragging = true
      @mark = new Mark(e)

    canvas.addEventListener 'mousemove', (e) =>
      @mark.draw(e) if @dragging
        
    canvas.addEventListener 'mouseup', (e) =>
      @dragging = false
      @marks.add(@mark)

      console.log @marks

      # console.log e.x-@getBoundingClientRect().left, e.y-@getBoundingClientRect().top

    zoomBtn = document.getElementById('toggle-zoom')
    zoomBtn.addEventListener 'click', (e) =>
      @zoomed = !@zoomed
      if @zoomed then canvasState.plotZoomedPoints(5,20) else canvasState.rescale()

    @dragging = false

  drawAxes: ->
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

  plotZoomedPoints: (xMin, xMax) ->
    @clearCanvas()
    for point in @data
      x = ((point.x - xMin) / (xMax - xMin)) * @canvas.width
      y = ((point.y - @largestY) / (@smallestY - @largestY)) * @canvas.height
      @ctx.fillStyle = "#fff"
      @ctx.fillRect(x, y,2,2)

  rescale: ->
    @clearCanvas()
    @plotPoints()

  clearCanvas: -> @ctx.clearRect(0,0,@canvas.width, @canvas.height)

  mirrorVertically: ->
    @ctx.translate(0,@canvas.height)
    @ctx.scale(1,-1)

class Marks
  constructor: -> @all = []

  add: (mark) -> @all.push(mark)

  remove: (mark) -> 
    @all.splice(@all.indexOf(mark), 1)
    document.getElementById('marks-container').removeChild(mark.element)

class Mark
  constructor: (e) ->
    @element = document.createElement('div')
    @element.className = "mark"
    @element.style.left = e.x
    @element.style.top = e.target.getBoundingClientRect().top
    document.getElementById('marks-container').appendChild(@element)
    @startingPoint = e.x

  draw: (e) ->
    if e.x > @startingPoint
      @element.style.width = e.x - @startingPoint
    else
      @element.style.width = @startingPoint - e.x
      @element.style.left = @startingPoint - parseFloat(@element.style.width, 10)

  # move: ->

canvas = document.getElementById("graph")
canvasState = new CanvasGraph(canvas, light_curve_data)
# canvasState.drawAxes()
canvasState.plotPoints()
# canvasState.rescale()
# canvasState.plotZoomedPoints(15,34.98)


#TODO:
#make a function that converts dom coordinates to data coordinates, and vise versa
#plotting scaling
#math

