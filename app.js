// Generated by CoffeeScript 1.7.1
(function() {
  var CanvasGraph, Mark, Marks, canvas, canvasState,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  CanvasGraph = (function() {
    function CanvasGraph(canvas, data) {
      var point, zoomBtn;
      this.canvas = canvas;
      this.data = data;
      this.ctx = this.canvas.getContext('2d');
      window.ctx = this.ctx;
      window.canvas = this.canvas;
      window.canvasGraph = this;
      this.smallestX = Math.min.apply(Math, (function() {
        var _i, _len, _ref, _results;
        _ref = this.data;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          point = _ref[_i];
          _results.push(point.x);
        }
        return _results;
      }).call(this));
      this.smallestY = Math.min.apply(Math, (function() {
        var _i, _len, _ref, _results;
        _ref = this.data;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          point = _ref[_i];
          _results.push(point.y);
        }
        return _results;
      }).call(this));
      this.largestX = Math.max.apply(Math, (function() {
        var _i, _len, _ref, _results;
        _ref = this.data;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          point = _ref[_i];
          _results.push(point.x);
        }
        return _results;
      }).call(this));
      this.largestY = Math.max.apply(Math, (function() {
        var _i, _len, _ref, _results;
        _ref = this.data;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          point = _ref[_i];
          _results.push(point.y);
        }
        return _results;
      }).call(this));
      this.marks = new Marks;
      window.marks = this.marks;
      canvas.addEventListener('mousedown', (function(_this) {
        return function(e) {
          e.preventDefault();
          _this.mark = new Mark(e, _this);
          _this.marks.create(_this.mark);
          _this.mark.dragging = true;
          return _this.mark.draw(e);
        };
      })(this));
      zoomBtn = document.getElementById('toggle-zoom');
      zoomBtn.addEventListener('click', (function(_this) {
        return function(e) {
          e.preventDefault();
          _this.zoomed = !_this.zoomed;
          if (_this.zoomed) {
            return canvasState.plotPoints(5, 20);
          } else {
            return canvasState.plotPoints();
          }
        };
      })(this));
    }

    CanvasGraph.prototype.plotPoints = function(xMin, xMax) {
      var mark, point, scaledMax, scaledMin, x, y, _i, _j, _len, _len1, _ref, _ref1, _results;
      if (xMin == null) {
        xMin = this.smallestX;
      }
      if (xMax == null) {
        xMax = this.largestX;
      }
      this.xMin = xMin;
      this.xMax = xMax;
      this.clearCanvas();
      _ref = this.data;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        point = _ref[_i];
        x = ((point.x - xMin) / (xMax - xMin)) * this.canvas.width;
        y = ((point.y - this.largestY) / (this.smallestY - this.largestY)) * this.canvas.height;
        this.ctx.fillStyle = "#fff";
        this.ctx.fillRect(x, y, 2, 2);
      }
      _ref1 = this.marks.all;
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        mark = _ref1[_j];
        scaledMin = ((mark.dataXMin - xMin) / (xMax - xMin)) * this.canvas.width;
        scaledMax = ((mark.dataXMax - xMin) / (xMax - xMin)) * this.canvas.width;
        mark.element.style.width = (scaledMax - scaledMin) + "px";
        mark.element.style.left = scaledMin + "px";
        _results.push(mark.save(scaledMin, scaledMax));
      }
      return _results;
    };

    CanvasGraph.prototype.clearCanvas = function() {
      return this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    };

    CanvasGraph.prototype.mirrorVertically = function() {
      this.ctx.translate(0, this.canvas.height);
      return this.ctx.scale(1, -1);
    };

    CanvasGraph.prototype.toCanvasXCoord = function(dataPoint) {
      return ((dataPoint - this.xMin) / (this.xMax - this.xMin)) * this.canvas.width;
    };

    CanvasGraph.prototype.toDataXCoord = function(canvasPoint) {
      return ((canvasPoint / this.canvas.width) * (this.xMax - this.xMin)) + this.xMin;
    };

    return CanvasGraph;

  })();

  Marks = (function() {
    function Marks() {
      this.all = [];
    }

    Marks.prototype.create = function(mark) {
      return document.getElementById('marks-container').appendChild(mark.element);
    };

    Marks.prototype.add = function(mark) {
      return this.all.push(mark);
    };

    Marks.prototype.update = function(mark) {
      return this.all[this.all.indexOf(mark)] = mark;
    };

    Marks.prototype.remove = function(mark) {
      this.all.splice(this.all.indexOf(mark), 1);
      return document.getElementById('marks-container').removeChild(mark.element);
    };

    Marks.prototype.destroyAll = function() {
      document.getElementById('marks-container').innerHTML = "";
      return this.all = [];
    };

    return Marks;

  })();

  Mark = (function() {
    var MAX_WIDTH, MIN_WIDTH;

    MIN_WIDTH = 10;

    MAX_WIDTH = 150;

    function Mark(e, canvasGraph) {
      this.canvasGraph = canvasGraph;
      this.canvas = this.canvasGraph.canvas;
      this.element = document.createElement('div');
      this.element.className = "mark";
      this.element.style.left = this.pointerXInElement(e) + "px";
      this.element.style.position = 'absolute';
      this.element.style.top = e.target.offsetTop + "px";
      this.element.style.height = this.canvas.height - 13 + 'px';
      this.element.style.backgroundColor = 'rgba(255,0,0,.5)';
      this.element.style.border = '2px solid red';
      this.element.style.borderTop = '13px solid red';
      this.element.style.pointerEvents = 'auto';
      this.startingPoint = this.toCanvasXPoint(e) - MIN_WIDTH;
      this.dragging = false;
      this.element.addEventListener('mouseover', (function(_this) {
        return function(e) {
          return _this.hovering = true;
        };
      })(this));
      this.element.addEventListener('mouseout', (function(_this) {
        return function(e) {
          return _this.hovering = false;
        };
      })(this));
      this.element.addEventListener('mousedown', (function(_this) {
        return function(e) {
          return _this.onMouseDown(e);
        };
      })(this));
      this.element.addEventListener('click', (function(_this) {
        return function(e) {
          if (_this.pointerYInElement(e) < 15) {
            return _this.canvasGraph.marks.remove(_this);
          }
        };
      })(this));
      window.addEventListener('mousemove', (function(_this) {
        return function(e) {
          return _this.onMouseMove(e);
        };
      })(this));
      window.addEventListener('mouseup', (function(_this) {
        return function(e) {
          return _this.onMouseUp(e);
        };
      })(this));
    }

    Mark.prototype.draw = function(e) {
      var markLeftX, markRightX, width;
      markLeftX = Math.min(this.startingPoint, this.toCanvasXPoint(e));
      markRightX = Math.max(this.startingPoint, this.toCanvasXPoint(e));
      width = Math.min(Math.max(Math.abs(markRightX - markLeftX), MIN_WIDTH), MAX_WIDTH);
      this.element.style.left = (Math.min(markLeftX, markRightX)) + "px";
      this.element.style.width = width + "px";
      return this.save(markLeftX, markLeftX + width);
    };

    Mark.prototype.move = function(e) {
      var leftXPos;
      leftXPos = this.toCanvasXPoint(e) - this.pointerOffset;
      this.element.style.left = leftXPos + "px";
      return this.save(leftXPos, leftXPos + parseInt(this.element.style.width, 10));
    };

    Mark.prototype.save = function(markLeftX, markRightX) {
      this.canvasXMin = markLeftX;
      this.canvasXMax = markRightX;
      this.dataXMin = this.canvasGraph.toDataXCoord(this.canvasXMin);
      return this.dataXMax = this.canvasGraph.toDataXCoord(this.canvasXMax);
    };

    Mark.prototype.updateCursor = function(e) {
      if (this.pointerYInElement(e) < 15) {
        return this.element.style.cursor = "pointer";
      } else if (((Math.abs(this.pointerXInElement(e) - (this.canvasXMax - this.canvasXMin))) < 10) || this.pointerXInElement(e) < 10) {
        return this.element.style.cursor = "ew-resize";
      } else {
        return this.element.style.cursor = "move";
      }
    };

    Mark.prototype.onMouseMove = function(e) {
      e.preventDefault();
      if (this.dragging) {
        this.draw(e);
      }
      if (this.moving) {
        this.move(e);
      }
      if (this.hovering) {
        return this.updateCursor(e);
      }
    };

    Mark.prototype.onMouseDown = function(e) {
      e.preventDefault();
      this.element.parentNode.appendChild(this.element);
      if ((Math.abs(this.pointerXInElement(e) - (this.canvasXMax - this.canvasXMin))) < 10) {
        this.startingPoint = this.canvasXMin;
        return this.dragging = true;
      } else if (this.pointerXInElement(e) < 10) {
        this.startingPoint = this.canvasXMax;
        return this.dragging = true;
      } else if (this.pointerYInElement(e) > 15) {
        this.moving = true;
        return this.pointerOffset = this.toCanvasXPoint(e) - this.canvasXMin;
      }
    };

    Mark.prototype.onMouseUp = function(e) {
      var mark, _i, _len, _ref;
      e.preventDefault();
      _ref = this.canvasGraph.marks.all;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        mark = _ref[_i];
        mark.dragging = false;
        mark.moving = false;
      }
      if ((__indexOf.call(this.canvasGraph.marks.all, this) >= 0)) {
        this.canvasGraph.marks.update(this);
      } else {
        this.canvasGraph.marks.add(this);
      }
      this.dragging = false;
      return this.moving = false;
    };

    Mark.prototype.toCanvasXPoint = function(e) {
      return e.pageX - this.canvas.getBoundingClientRect().left - window.scrollX;
    };

    Mark.prototype.pointerXInElement = function(e) {
      return e.offsetX || e.clientX - e.target.offsetLeft + window.pageXOffset - this.canvas.getBoundingClientRect().left;
    };

    Mark.prototype.pointerYInElement = function(e) {
      return e.offsetY || e.clientY - e.target.offsetTop + window.pageYOffset - this.canvas.getBoundingClientRect().top;
    };

    return Mark;

  })();

  canvas = document.getElementById("graph");

  canvasState = new CanvasGraph(canvas, light_curve_data);

  canvasState.plotPoints();

}).call(this);
