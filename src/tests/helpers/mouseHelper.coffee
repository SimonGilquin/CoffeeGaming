canvas = getCanvas()
window.moveMouseTo = (x, y) ->
  canvas.onmousemove
    offsetX: x
    offsetY: y
window.mouseUpAt = (x, y) ->
  canvas.onmouseup
    offsetX: x
    offsetY: y
window.mouseDownAt = (x, y) ->
  canvas.onmousedown
    offsetX: x
    offsetY: y
