// Generated by CoffeeScript 1.6.3
(function() {
  describe('The HUD', function() {
    var engine, hud;
    hud = null;
    engine = null;
    beforeEach(function() {
      game.load();
      game.engine.init();
      engine = game.engine;
      return hud = engine.hud;
    });
    it('can be drawn', function() {
      return expect(typeof hud.draw).toBe('function');
    });
    it('has a pause screen', function() {
      return expect(hud.pauseScreen).toBeDefined();
    });
    describe('when the game is paused', function() {
      beforeEach(function() {
        return engine.pause();
      });
      it('clicking on the resume button resumes the game', function() {
        mouseDownAt(430, 330);
        mouseUpAt(430, 330);
        engine.update();
        return expect(engine.isPaused()).toBeFalsy();
      });
      describe('the pause screen', function() {
        var screen;
        screen = null;
        beforeEach(function() {
          return screen = hud.pauseScreen;
        });
        it('should be visible', function() {
          return expect(screen.visible).toBeTruthy();
        });
        it('should display "Game paused"', function() {
          expect(screen.text.text).toBe('Game paused');
          expect(screen.text.style).toBe('black');
          return expect(screen.text.font).toBe('48px sans-serif');
        });
        return describe('when drawn', function() {
          var contextMock;
          contextMock = null;
          beforeEach(function() {
            return contextMock = createMockFor(CanvasRenderingContext2D);
          });
          return it('should have the correct elements', function() {
            hud.draw();
            expect(contextMock.fillText).toHaveBeenCalledWith('Game paused', 500.5, 280);
            return expect(contextMock.fillText).toHaveBeenCalledWith('Resume...', 500, 340);
          });
        });
      });
      return describe('when the mouse is over the resume button', function() {
        it('should be hovered', function() {
          moveMouseTo(430, 330);
          engine.update();
          expect(hud.pauseScreen.resumeButton.isInElement(430, 330)).toBeTruthy();
          return expect(hud.pauseScreen.resumeButton.state).toBe('hover');
        });
        it('when clicking it is active', function() {
          mouseDownAt(430, 330);
          engine.update();
          return expect(hud.pauseScreen.resumeButton.state).toBe('active');
        });
        return it('is not active after leaving', function() {
          moveMouseTo(430, 330);
          moveMouseTo(230, 130);
          engine.update();
          expect(hud.pauseScreen.resumeButton.isInElement(230, 130)).toBeFalsy();
          return expect(hud.pauseScreen.resumeButton.state).not.toBe('hover');
        });
      });
    });
    return describe('when the game is running', function() {
      beforeEach(function() {
        return engine.play();
      });
      return it('has a pause button', function() {
        expect(hud.pauseButton).toBeDefined();
        return expect(hud.pauseButton.visible).toBeTruthy();
      });
    });
  });

}).call(this);
