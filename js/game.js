// Generated by CoffeeScript 1.6.2
(function() {
  var Button, Drawable, Engine, Hud, Image, Screen, Text, canvas, context, createSurface, debug, enableLog, game,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

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
        return game.engine.hud.draw();
      }
    };
  };

  Drawable = (function() {
    function Drawable() {}

    Drawable.prototype.visible = true;

    Drawable.prototype.isInElement = function(x, y) {
      return (this.x <= x && x <= this.x + this.w) && (this.y <= y && y <= this.y + this.h);
    };

    Drawable.prototype.drawFrom = function(x, y) {
      if (this.visible) {
        if (typeof this.drawElement === "function") {
          this.drawElement(x, y);
        }
        return this.drawChildrenFrom(this.x + x, this.y + y);
      }
    };

    Drawable.prototype.drawChildrenFrom = function(x, y) {
      var elem, id, _results;

      _results = [];
      for (id in this) {
        elem = this[id];
        _results.push(elem != null ? typeof elem.drawFrom === "function" ? elem.drawFrom(x, y) : void 0 : void 0);
      }
      return _results;
    };

    return Drawable;

  })();

  Text = (function(_super) {
    __extends(Text, _super);

    function Text(text, style, size, x, y) {
      this.text = text;
      this.style = style != null ? style : 'black';
      if (size == null) {
        size = 12;
      }
      this.x = x != null ? x : 0;
      this.y = y != null ? y : 0;
      this.font = "" + size + "px sans-serif";
    }

    Text.prototype.drawElement = function(x, y) {
      context.textBaseline = 'middle';
      context.textAlign = 'center';
      context.fillStyle = this.style;
      context.font = this.font;
      return context.fillText(this.text, this.x + x, this.y + y);
    };

    return Text;

  })(Drawable);

  Image = (function(_super) {
    __extends(Image, _super);

    function Image(x, y, url) {
      this.x = x;
      this.y = y;
      this.url = url;
      game.images[this.url] = null;
    }

    Image.prototype.drawElement = function(x, y) {
      if (game.images[this.url] != null) {
        return context.drawImage(game.images[this.url], this.x + x, this.y + y);
      }
    };

    return Image;

  })(Drawable);

  Button = (function(_super) {
    __extends(Button, _super);

    Button.prototype.color = '#0aa';

    Button.prototype.activecolor = '#088';

    Button.prototype.hovercolor = '#099';

    Button.prototype.getStateColor = function() {
      switch (this.state) {
        case 'active':
          return this.activecolor;
        case 'hover':
          return this.hovercolor;
        default:
          return this.color;
      }
    };

    function Button(x, y, w, h) {
      this.x = x;
      this.y = y;
      this.w = w;
      this.h = h;
      game.buttons.push(this);
    }

    Button.prototype.drawElement = function(x, y) {
      context.fillStyle = this.getStateColor();
      return context.fillRect(this.x + x, this.y + y, this.w, this.h);
    };

    Button.prototype.withText = function() {
      var args;

      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this.content = (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return Object(result) === result ? result : child;
      })(Text, args, function(){});
      this.content.x = this.w / 2;
      this.content.y = this.h / 2;
      return this;
    };

    Button.prototype.withImage = function(url) {
      this.content = new Image(0, 0, 'pause.png');
      return this;
    };

    return Button;

  })(Drawable);

  Screen = (function(_super) {
    __extends(Screen, _super);

    Screen.prototype.visible = false;

    function Screen(x, y, w, h, background) {
      this.x = x;
      this.y = y;
      this.w = w;
      this.h = h;
      this.background = background;
      this.text = new Text('Game paused', 'black', 48, canvas.width / 2, 280);
      this.resumeButton = new Button(420, 320, 160, 40).withText('Resume...', '#fff', 28);
    }

    Screen.prototype.drawElement = function(x, y) {
      if (this.background) {
        context.fillStyle = this.background;
        context.fillRect(x + this.x, y + this.y, canvas.width, canvas.height);
      }
      return this.drawChildrenFrom(this.x + x, this.y + y);
    };

    Screen.prototype.draw = function() {
      return this.drawFrom(this.x, this.y);
    };

    return Screen;

  })(Drawable);

  Hud = (function(_super) {
    __extends(Hud, _super);

    Hud.prototype.x = 0;

    Hud.prototype.y = 0;

    Hud.prototype.w = canvas.width;

    Hud.prototype.h = canvas.height;

    Hud.prototype.visible = true;

    function Hud() {
      this.pauseScreen = new Screen(this.x, this.y, this.w, this.h, '#eee');
      this.pauseButton = new Button(canvas.width - 40, 10, 20, 20).withImage('pause.png');
      delete this.background;
    }

    return Hud;

  })(Screen);

  Engine = (function() {
    function Engine() {
      this.update = __bind(this.update, this);
      this.play = __bind(this.play, this);
      this.pause = __bind(this.pause, this);
      this.mainLoop = __bind(this.mainLoop, this);      this.hud = new Hud();
    }

    Engine.prototype.running = null;

    Engine.prototype.counters = {
      start: Date.now(),
      frames: 0,
      add: function() {
        var countersElement, fps, fpsValue;

        countersElement = document.createElement('div');
        countersElement.setAttribute('class', 'counters');
        fps = document.createElement('p');
        fps.innerHTML = 'FPS: ';
        fpsValue = document.createElement('span');
        fpsValue.setAttribute('class', 'fps');
        fps.appendChild(fpsValue);
        countersElement.appendChild(fps);
        document.body.appendChild(countersElement);
        fpsValue.lastUpdate = Date.now();
        fpsValue.lastFrameCount = 0;
        return this.update = function() {
          var now;

          now = Date.now();
          this.frames++;
          if (now - fpsValue.lastUpdate > 250) {
            fpsValue.innerHTML = this.fps = Math.round((this.frames - fpsValue.lastFrameCount) * 1000 / (now - fpsValue.lastUpdate));
            fpsValue.lastUpdate = now;
            fpsValue.lastFrameCount = this.frames;
          }
          return this.lastUpdate = now;
        };
      }
    };

    Engine.prototype.cursor = {
      x: null,
      y: null
    };

    Engine.prototype.surface = createSurface(800, 600);

    Engine.prototype.mainLoop = function() {
      var _base;

      this.update();
      this.surface.draw();
      return typeof (_base = this.counters).update === "function" ? _base.update() : void 0;
    };

    Engine.prototype.init = function() {
      var animFrame, recursive,
        _this = this;

      this.counters.add();
      animFrame = window.requestAnimationFrame;
      if (animFrame == null) {
        window.webkitRequestAnimationFrame;
      }
      if (animFrame == null) {
        window.mozRequestAnimationFrame;
      }
      if (animFrame == null) {
        window.oRequestAnimationFrame;
      }
      if (animFrame == null) {
        window.msRequestAnimationFrame;
      }
      if (animFrame != null) {
        recursive = function() {
          _this.mainLoop();
          return animFrame(recursive, canvas);
        };
        recursive();
      } else {
        setInterval(this.mainLoop, 1000 / 60);
      }
      canvas.onmousemove = function(e) {
        return _this.events.push({
          type: 'mousemove',
          x: e.offsetX,
          y: e.offsetY
        });
      };
      canvas.onmousedown = function(e) {
        return _this.events.push({
          type: 'mousedown',
          x: e.offsetX,
          y: e.offsetY
        });
      };
      canvas.onmouseup = function(e) {
        return _this.events.push({
          type: 'mouseup',
          x: e.offsetX,
          y: e.offsetY
        });
      };
      return this;
    };

    Engine.prototype.pause = function() {
      this.running = false;
      this.hud.pauseScreen.visible = true;
      return this.hud.pauseButton.visible = false;
    };

    Engine.prototype.play = function() {
      this.running = true;
      this.hud.pauseScreen.visible = false;
      return this.hud.pauseButton.visible = true;
    };

    Engine.prototype.isPaused = function() {
      return !this.running;
    };

    Engine.prototype.events = [];

    Engine.prototype.handleButton = function(button, whenActive) {
      if (button.isInElement(this.cursor.x, this.cursor.y)) {
        if (this.cursor.state === 'down') {
          return button.state = 'active';
        } else if (this.cursor.state === 'up' && button.state === 'active') {
          whenActive();
          return delete button.state;
        } else {
          return button.state = 'hover';
        }
      } else if (button.state === 'hover' || this.cursor.state === 'up') {
        return delete button.state;
      }
    };

    Engine.prototype.update = function() {
      var event, _results;

      _results = [];
      while (this.events.length > 0) {
        event = this.events.shift();
        switch (event.type) {
          case 'mousemove':
            this.cursor.x = event.x;
            this.cursor.y = event.y;
            break;
          case 'mousedown':
            this.cursor.state = 'down';
            this.cursor.x = event.x;
            this.cursor.y = event.y;
            break;
          case 'mouseup':
            this.cursor.state = 'up';
            this.cursor.x = event.x;
            this.cursor.y = event.y;
        }
        if (this.isPaused()) {
          this.handleButton(this.hud.pauseScreen.resumeButton, this.play);
        } else {
          this.handleButton(this.hud.pauseButton, this.pause);
        }
        if (event.type === 'mouseup') {
          _results.push(delete this.cursor.type);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    return Engine;

  })();

  window.game = game = {
    buttons: [],
    images: {},
    load: function() {
      var counter, image, url, _ref, _results,
        _this = this;

      this.engine = new Engine();
      counter = 0;
      _ref = this.images;
      _results = [];
      for (url in _ref) {
        image = _ref[url];
        counter++;
        image = new window.Image();
        image.src = "img/" + url;
        _results.push(image.onload = function() {
          _this.images[url] = image;
          counter--;
          if (counter === 0) {
            return _this.engine.init().pause();
          }
        });
      }
      return _results;
    }
  };

  game.load();

}).call(this);

/*
//@ sourceMappingURL=game.map
*/
