// Generated by CoffeeScript 1.6.3
(function() {
  var Asteroid, Button, Drawable, Engine, Hud, Image, Screen, Text, Vessel, canvas, context, createAsteroidStore, createSurface, debug, enableLog, game, keymap, translate,
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
      scale: 1,
      draw: function() {
        var asteroid, _i, _len, _ref;
        context.clearRect(0, 0, canvas.width, canvas.height);
        _ref = game.engine.asteroids;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          asteroid = _ref[_i];
          asteroid.draw();
        }
        game.engine.vessel.draw();
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
      if (this.background != null) {
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
      this.pauseScreen = new Screen(this.x, this.y, this.w, this.h, 'rgba(0,0,0,0.05)');
      this.pauseButton = new Button(canvas.width - 40, 10, 20, 20).withImage('pause.png');
      delete this.background;
    }

    return Hud;

  })(Screen);

  Asteroid = (function() {
    function Asteroid(posX, posY, vectorX, vectorY, speed) {
      if (posX == null) {
        posX = 100;
      }
      if (posY == null) {
        posY = 40;
      }
      if (vectorX == null) {
        vectorX = 1;
      }
      if (vectorY == null) {
        vectorY = 0;
      }
      this.speed = speed != null ? speed : 1;
      this.direction = {
        x: vectorX,
        y: vectorY
      };
      this.position = {
        x: posX,
        y: posY
      };
    }

    Asteroid.image = (function() {
      var image, tempCanvas, tempContext, url;
      tempCanvas = document.createElement('canvas');
      tempCanvas.width = 20;
      tempCanvas.height = 20;
      tempContext = tempCanvas.getContext('2d');
      tempContext.translate(10, 10);
      tempContext.beginPath();
      tempContext.fillStyle = '#ccc';
      tempContext.moveTo(-10, -10);
      tempContext.lineTo(-5, -5);
      tempContext.lineTo(0, -10);
      tempContext.lineTo(+5, -10);
      tempContext.lineTo(+10, -5);
      tempContext.lineTo(+5, +5);
      tempContext.lineTo(+10, +10);
      tempContext.lineTo(+5, +10);
      tempContext.lineTo(0, +5);
      tempContext.lineTo(-5, +10);
      tempContext.lineTo(-10, 0);
      tempContext.lineTo(-5, -5);
      tempContext.lineTo(-10, -10);
      tempContext.fill();
      tempContext.getImageData(-10, -10, 20, 20);
      url = tempCanvas.toDataURL();
      image = new window.Image();
      image.src = url;
      return image;
    })();

    Asteroid.prototype.speed = 1;

    Asteroid.prototype.direction = {
      x: 1,
      y: 0
    };

    Asteroid.prototype.position = {
      x: 100,
      y: 40
    };

    Asteroid.prototype.draw = function() {
      var _ref, _ref1;
      if ((0 < (_ref = this.position.x) && _ref < canvas.width) && (0 < (_ref1 = this.position.y) && _ref1 < canvas.height)) {
        return context.drawImage(Asteroid.image, this.position.x, this.position.y);
      }
    };

    Asteroid.prototype.xdraw = function() {
      context.beginPath();
      context.fillStyle = '#ccc';
      context.moveTo(this.position.x - 10, this.position.y - 10);
      context.lineTo(this.position.x - 5, this.position.y - 5);
      context.lineTo(this.position.x, this.position.y - 10);
      context.lineTo(this.position.x + 5, this.position.y - 10);
      context.lineTo(this.position.x + 10, this.position.y - 5);
      context.lineTo(this.position.x + 5, this.position.y + 5);
      context.lineTo(this.position.x + 10, this.position.y + 10);
      context.lineTo(this.position.x + 5, this.position.y + 10);
      context.lineTo(this.position.x, this.position.y + 5);
      context.lineTo(this.position.x - 5, this.position.y + 10);
      context.lineTo(this.position.x - 10, this.position.y);
      context.lineTo(this.position.x - 5, this.position.y - 5);
      context.lineTo(this.position.x - 10, this.position.y - 10);
      return context.fill();
    };

    return Asteroid;

  })();

  createAsteroidStore = function() {
    var asteroids;
    asteroids = [];
    asteroids.create = function() {
      var args, asteroid;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      asteroid = (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return Object(result) === result ? result : child;
      })(Asteroid, args, function(){});
      this.push(asteroid);
      return asteroid;
    };
    asteroids.randomFill = function() {
      var i, j, pos, vector, _i, _j;
      for (i = _i = 0; _i < 20; i = ++_i) {
        for (j = _j = 0; _j < 15; j = ++_j) {
          if (!(!((i === 9 || i === 10) && j === 7))) {
            continue;
          }
          vector = 2 * Math.random() * Math.PI;
          pos = {
            x: (i + Math.random()) * canvas.width / 4 - 2 * canvas.width,
            y: (j + Math.random()) * canvas.height / 3 - 2 * canvas.height
          };
          asteroids.create(pos.x, pos.y, Math.cos(vector), Math.sin(vector), Math.random() + 1);
        }
      }
      return asteroids;
    };
    return asteroids;
  };

  translate = function(rad, x, y) {
    return {
      x: Math.cos(rad) * x - Math.sin(rad) * y,
      y: Math.sin(rad) * x + Math.cos(rad) * y
    };
  };

  Vessel = (function() {
    function Vessel() {
      this.acceleration = .1;
      this.position = {
        x: canvas.width / 2,
        y: canvas.height / 2
      };
      this.rotationalSpeed = .1;
      this.orientation = 0;
      this.vector = {
        x: 0,
        y: 0
      };
    }

    Vessel.prototype.draw = function() {
      var point, points, t, _i, _j, _len, _len1, _ref;
      context.beginPath();
      context.fillStyle = '#f00';
      points = [];
      points.push({
        x: 5,
        y: 0
      });
      points.push({
        x: -5,
        y: 5
      });
      points.push({
        x: -2,
        y: 0
      });
      points.push({
        x: -5,
        y: -5
      });
      points.push({
        x: 5,
        y: 0
      });
      for (_i = 0, _len = points.length; _i < _len; _i++) {
        point = points[_i];
        t = translate(this.orientation, point.x, point.y);
        point.x = t.x + this.position.x;
        point.y = t.y + this.position.y;
      }
      context.moveTo(points[0].x, points[0].y);
      _ref = points.slice(1);
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        point = _ref[_j];
        context.lineTo(point.x, point.y);
      }
      return context.fill();
    };

    return Vessel;

  })();

  keymap = {
    37: 'left',
    38: 'thrust',
    39: 'right',
    27: 'escape'
  };

  Engine = (function() {
    function Engine() {
      this.update = __bind(this.update, this);
      this.play = __bind(this.play, this);
      this.pause = __bind(this.pause, this);
      this.draw = __bind(this.draw, this);
      this.mainLoop = __bind(this.mainLoop, this);
      var code, key, keyboard;
      this.hud = new Hud();
      this.asteroids = createAsteroidStore();
      this.vessel = new Vessel();
      keyboard = {};
      for (code in keymap) {
        key = keymap[code];
        keyboard[key] = false;
      }
      this.keyboard = keyboard;
    }

    Engine.prototype.running = null;

    Engine.prototype.counters = {
      start: Date.now(),
      frames: 0,
      add: function() {
        var countersElement, drawTime, drawTimeValue, fps, fpsValue, oldDraw, oldUpdate, updateTime, updateTimeValue,
          _this = this;
        countersElement = document.createElement('div');
        countersElement.setAttribute('class', 'counters');
        fps = document.createElement('p');
        fps.innerHTML = 'FPS: ';
        fpsValue = document.createElement('span');
        fpsValue.setAttribute('class', 'fps');
        fps.appendChild(fpsValue);
        countersElement.appendChild(fps);
        updateTime = document.createElement('p');
        updateTime.innerHTML = 'Update: ';
        updateTimeValue = document.createElement('span');
        updateTimeValue.setAttribute('class', 'time');
        updateTime.appendChild(updateTimeValue);
        countersElement.appendChild(updateTime);
        drawTime = document.createElement('p');
        drawTime.innerHTML = 'Draw: ';
        drawTimeValue = document.createElement('span');
        drawTimeValue.setAttribute('class', 'time');
        drawTime.appendChild(drawTimeValue);
        countersElement.appendChild(drawTime);
        document.body.appendChild(countersElement);
        fpsValue.lastUpdate = performance.now();
        fpsValue.lastFrameCount = 0;
        oldUpdate = game.engine.update;
        oldDraw = game.engine.draw;
        game.engine.update = function() {
          var updateStart;
          updateStart = performance.now();
          oldUpdate();
          return updateTimeValue.innerHTML = Math.round(performance.now() - updateStart);
        };
        return game.engine.draw = function() {
          var drawStart, endLoop;
          drawStart = performance.now();
          oldDraw();
          endLoop = performance.now();
          drawTimeValue.innerHTML = Math.round(endLoop - drawStart);
          _this.frames++;
          if (endLoop - fpsValue.lastUpdate > 250) {
            fpsValue.innerHTML = _this.fps = Math.round((_this.frames - fpsValue.lastFrameCount) * 1000 / (endLoop - fpsValue.lastUpdate));
            fpsValue.lastUpdate = endLoop;
            fpsValue.lastFrameCount = _this.frames;
          }
          return _this.lastUpdate = endLoop;
        };
      }
    };

    Engine.prototype.cursor = {
      x: null,
      y: null
    };

    Engine.prototype.createVessel = function() {
      return new Vessel();
    };

    Engine.prototype.surface = createSurface(800, 600);

    Engine.prototype.mainLoop = function() {
      this.update();
      return this.draw();
    };

    Engine.prototype.draw = function() {
      return this.surface.draw();
    };

    Engine.prototype.init = function() {
      var animFrame, recursive,
        _this = this;
      if ((typeof performance !== "undefined" && performance !== null ? performance.now : void 0) != null) {
        this.counters.add();
      }
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
      document.onkeydown = function(e) {
        return _this.events.push({
          type: 'keydown',
          keyCode: e.keyCode,
          action: keymap[e.keyCode]
        });
      };
      document.onkeyup = function(e) {
        return _this.events.push({
          type: 'keyup',
          keyCode: e.keyCode,
          action: keymap[e.keyCode]
        });
      };
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
      this.asteroids.randomFill();
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
      var event;
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
            break;
          case 'keydown':
            this.keyboard[event.action] = true;
            break;
          case 'keyup':
            this.keyboard[event.action] = false;
        }
        if (this.isPaused()) {
          if (this.keyboard.escape) {
            this.play();
          }
          this.handleButton(this.hud.pauseScreen.resumeButton, this.play);
        } else {
          if (this.keyboard.escape) {
            this.pause();
          }
          this.handleButton(this.hud.pauseButton, this.pause);
        }
        if (event.type === 'mouseup') {
          delete this.cursor.type;
        }
      }
      if (!this.isPaused()) {
        this.updateAsteroids();
        return this.updateVessel(this.vessel);
      }
    };

    Engine.prototype.updateVessel = function(vessel) {
      vessel.position.x += vessel.vector.x;
      vessel.position.y += vessel.vector.y;
      vessel.thrust = this.keyboard['thrust'];
      if (vessel.thrust) {
        vessel.vector.x += Math.cos(vessel.orientation) * vessel.acceleration;
        vessel.vector.y += Math.sin(vessel.orientation) * vessel.acceleration;
      }
      if (this.keyboard['left']) {
        vessel.orientation -= vessel.rotationalSpeed;
      }
      if (this.keyboard['right']) {
        vessel.orientation += vessel.rotationalSpeed;
      }
      return vessel.orientation = vessel.orientation % (2 * Math.PI);
    };

    Engine.prototype.updateAsteroids = function() {
      var asteroid, _i, _len, _ref, _results;
      _ref = this.asteroids;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        asteroid = _ref[_i];
        asteroid.position.x += asteroid.direction.x * asteroid.speed;
        _results.push(asteroid.position.y += asteroid.direction.y * asteroid.speed);
      }
      return _results;
    };

    return Engine;

  })();

  window.game = game = {
    buttons: [],
    images: {
      'asteroid.png': null
    },
    load: function() {
      var counter, loadImage, url, _results,
        _this = this;
      this.engine = new Engine();
      counter = 0;
      loadImage = function(url) {
        var image;
        image = new window.Image();
        image.src = "img/" + url;
        return image.onload = function() {
          _this.images[url] = image;
          counter--;
          if (counter === 0) {
            return _this.engine.init().pause();
          }
        };
      };
      _results = [];
      for (url in this.images) {
        counter++;
        _results.push(loadImage(url));
      }
      return _results;
    },
    reset: function() {
      return delete this.engine;
    }
  };

  game.load();

}).call(this);
