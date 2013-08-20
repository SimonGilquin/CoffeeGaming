window.moveMouseTo = (x, y) ->
  window.getCanvas().onmousemove
    offsetX: x
    offsetY: y
window.mouseUpAt = (x, y) ->
  window.getCanvas().onmouseup
    offsetX: x
    offsetY: y
window.mouseDownAt = (x, y) ->
  window.getCanvas().onmousedown
    offsetX: x
    offsetY: y
window.pressKey = (keyCode) ->
  document.onkeydown
    keyCode: keyCode