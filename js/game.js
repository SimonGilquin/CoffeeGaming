// Generated by CoffeeScript 1.6.2
(function() {
  var canvas, context, createButton, createGame, createHud, createSurface, createText, debug, drawChildrenFrom, enableLog, game,
    __slice = [].slice;

  debug = false;

  enableLog = function(object) {
    var id, overload, prop;

    overload = function(name, instance) {
      var old,
        _this = this;

      old = instance[name];
      return instance[name] = function() {
        var args;

        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        console.log("" + name + "(" + args + ")");
        return old.apply(instance, args);
      };
    };
    for (id in object) {
      prop = object[id];
      if (typeof prop === 'function') {
        overload(id, object);
      }
    }
    return true;
  };

  canvas = document.createElement('canvas');

  canvas.width = 1001;

  canvas.height = 601;

  document.body.appendChild(canvas);

  context = canvas.getContext('2d');

  if (debug) {
    enableLog(context);
  }

  createSurface = function(width, height) {
    var surface;

    return surface = {
      width: width,
      height: height,
      drawLine: function(x1, y1, x2, y2, width) {
        if (width == null) {
          width = 1;
        }
        context.beginPath();
        context.lineWidth = width;
        context.moveTo(x1 + width / 2, y1 + width / 2);
        context.lineTo(x2 + width / 2, y2 + width / 2);
        return context.stroke();
      },
      context: context,
      draw: function() {
        context.clearRect(0, 0, canvas.width, canvas.height);
        return game.hud.draw();
      }
    };
  };

  drawChildrenFrom = function(x, y) {
    var elem, id, _results;

    _results = [];
    for (id in this) {
      elem = this[id];
      _results.push(typeof elem.drawFrom === "function" ? elem.drawFrom(x, y) : void 0);
    }
    return _results;
  };

  createText = function(text, style, size, x, y) {
    var drawFrom;

    if (style == null) {
      style = 'black';
    }
    if (size == null) {
      size = 12;
    }
    if (x == null) {
      x = 0;
    }
    if (y == null) {
      y = 0;
    }
    drawFrom = function(x, y) {
      context.textBaseline = 'middle';
      context.textAlign = 'center';
      context.fillStyle = this.style;
      context.font = this.font;
      return context.fillText(this.text, this.x + x, this.y + y);
    };
    if (typeof text === 'object') {
      return text.drawFrom = drawFrom;
    } else {
      return {
        text: text,
        style: style,
        font: "" + size + "px sans-serif",
        x: x,
        y: y,
        drawFrom: drawFrom
      };
    }
  };

  createButton = function(x, y, w, h, color) {
    if (color == null) {
      color = 'black';
    }
    return {
      drawChildrenFrom: drawChildrenFrom,
      drawFrom: function(x, y) {
        context.fillStyle = this.color;
        context.fillRect(this.x + x, this.y + y, this.w, this.h);
        return this.drawChildrenFrom(this.x + x, this.y + y);
      },
      color: color,
      x: x,
      y: y,
      w: w,
      h: h,
      withText: function() {
        var args;

        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        this.content = createText.apply(null, args);
        this.content.x = w / 2;
        this.content.y = h / 2;
        return this;
      }
    };
  };

  createHud = function() {
    return {
      x: 0,
      y: 0,
      w: canvas.width,
      h: canvas.height,
      drawChildrenFrom: drawChildrenFrom,
      draw: function() {
        return this.drawChildrenFrom(this.x, this.y);
      },
      pauseScreen: {
        visible: false,
        text: createText('Game paused', 'black', 48, canvas.width / 2, 280),
        resumeButton: createButton(420, 320, 160, 40, '#00aaaa').withText('Resume...', '#fff', 28),
        drawChildrenFrom: drawChildrenFrom,
        x: 0,
        y: 0,
        drawFrom: function(x, y) {
          if (this.visible) {
            context.fillStyle = '#eee';
            context.fillRect(x + this.x, y + this.y, canvas.width, canvas.height);
            return this.drawChildrenFrom(this.x + x, this.y + y);
          }
        }
      }
    };
  };

  createGame = function() {
    var running;

    running = null;
    return {
      surface: createSurface(800, 600),
      hud: createHud(),
      init: function() {
        var _this = this;

        setInterval(this.surface.draw, 1000 / 60);
        canvas.onmousemove = function(e) {
          return _this.events.push({
            type: 'mousemove',
            x: e.offsetX,
            y: e.offsetY
          });
        };
        return this;
      },
      pause: function() {
        running = false;
        return this.hud.pauseScreen.visible = true;
      },
      play: function() {
        return running = true;
      },
      isPaused: function() {
        return !running;
      },
      events: [],
      update: function() {}
    };
  };

  window.game = game = createGame();

  game.init().pause();

}).call(this);

/*
//@ sourceMappingURL=game.map
*/
