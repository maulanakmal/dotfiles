function handleEvent(event)
  local button = event:getProperty(hs.eventtap.event.properties["mouseEventButtonNumber"])
  local flags = event:getFlags()

  print("Mouse button: " .. tostring(button))
  if flags.ctrl then
    print("Control key is held down")
  end

  if button == 3 and flags.ctrl then
        print("Ctrl + Left Click")
        -- hs.eventtap.keyStroke({"ctrl"}, "left")  -- simulate Ctrl + ←
        hs.timer.doAfter(0.1, function()
    hs.eventtap.keyStroke({"ctrl"}, "left")
end)
        return true  -- intercept the event
    end

  return true  -- intercept the event (optional)
end 

eventTypes = {
  -- hs.eventtap.event.types.keyDown,
  -- hs.eventtap.event.types.systemDefined,
  hs.eventtap.event.types.otherMouseDown
}
hs.eventtap.new(eventTypes, handleEvent):start()