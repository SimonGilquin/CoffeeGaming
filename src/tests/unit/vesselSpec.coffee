describe 'The vessel', ->
  engine = null
  oldImage = null
  beforeEach ->
    oldImage = window.Image
    window.Image = ImageHelper
    game.load()
    window.Image.loadAll()
    engine = game.engine
  afterEach ->
    window.Image = oldImage

  it 'when playing updates on game ticks', ->
    spyOn engine, 'updateVessel'
    engine.play()
    engine.update()
    expect(engine.updateVessel).toHaveBeenCalled()

  it 'does not update while paused', ->
    spyOn engine, 'updateVessel'
    engine.pause()
    engine.update()
    expect(engine.updateVessel).not.toHaveBeenCalled()

  it 'exists', ->
    expect(engine.vessel).toBeDefined()

  it 'has an acceleration of .1px/s', ->
    vessel = engine.createVessel()
    expect(vessel.acceleration).toBe .1

  it 'is stopped', ->
    vessel = engine.createVessel()
    expect(vessel.vector).toBeEqualTo
      x: 0
      y: 0

  it 'is in the center of the game surface', ->
    vessel = engine.createVessel()
    expect(vessel.position.x).toBe(engine.surface.width/2)
    expect(vessel.position.y).toBe(engine.surface.height/2)

  it 'moves horizontally when having speed', ->
    vessel = engine.createVessel()
    vessel.vector.x = 3
    x = vessel.position.x
    y = vessel.position.y
    engine.updateVessel vessel
    expect(vessel.position.x).toBe x + 3
    expect(vessel.position.y).toBe y
    engine.updateVessel vessel
    expect(vessel.position.x).toBe x + 6
    expect(vessel.position.y).toBe y

  it 'has an orientation of 0', ->
    vessel = engine.createVessel()
    expect(vessel.orientation).toBe 0

  it 'has a rotational speed of 0.1', ->
    vessel = engine.createVessel()
    expect(vessel.rotationalSpeed).toBe 0.1

  describe 'when exiting the game surface', ->
    it 'by the right side is moved to the left', ->
      vessel = engine.createVessel(engine.surface.width + 1, 100)
      engine.updateVessel vessel
      expect(vessel.position).toBeEqualTo
        x: 0
        y: 100
    it 'by the bottom side is moved to the top', ->
      vessel = engine.createVessel(100, engine.surface.height + 1)
      engine.updateVessel vessel
      expect(vessel.position).toBeEqualTo
        x: 100
        y: 0
    it 'by the left side is moved to the right', ->
      vessel = engine.createVessel(-1, 100)
      engine.updateVessel vessel
      expect(vessel.position).toBeEqualTo
        x: engine.surface.width
        y: 100
    it 'by the top side is moved to the bottom', ->
      vessel = engine.createVessel(100, -1)
      engine.updateVessel vessel
      expect(vessel.position).toBeEqualTo
        x: 100
        y: engine.surface.height

  describe 'pressing the thrust key', ->
    beforeEach ->
      engine.play()
      engine.events.push
        type: 'keydown'
        action: 'thrust'
      engine.update()
    it 'thrusts the vessel', ->
      expect(engine.vessel.thrust).toBeTruthy()
    it 'increases the x vector', ->
      vessel = engine.createVessel()
      oldVector =
        x:vessel.vector.x
        y:vessel.vector.y

      engine.updateVessel vessel
      expect(vessel.vector).toBeEqualTo
        x: oldVector.x + vessel.acceleration
        y: oldVector.y
  describe 'pressing the left key', ->
    vessel = null
    beforeEach ->
      vessel = engine.createVessel()
      engine.keyboard.left = true
      engine.keyboard.thrust = true
    it 'turns the vessel', ->
      oldVector = vessel.vector
      engine.updateVessel vessel
      expect(vessel.vector).toBeEqualTo
        x: .1
        y: 0
      expect(vessel.orientation).toBe -0.1
    afterEach ->
      engine.keyboard.left = false
  describe 'releasing the thrust', ->
    vessel = null
    beforeEach ->
      engine.keyboard.thrust = true
      engine.update()
    it 'does not thrusts', ->
      engine.keyboard.thrust = false
      engine.update()
      expect(engine.vessel.thrust).toBeFalsy()
    it 'keeps its speed', ->
      oldSpeed = engine.vessel.speed
      engine.keyboard.thrust = false
      engine.update()
      expect(engine.vessel.speed).toBe oldSpeed
