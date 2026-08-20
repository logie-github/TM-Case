-- TM35 Metronome: gesture-only touch controls.
--   tap                       -> A
--   swipe from the right edge -> B
--   swipe up from the bottom edge -> Start
--   two-finger tap            -> Select
--   swipe and hold a direction -> that D-pad direction, held
--
-- Built on input.pointer (raw touch/mouse, first refusal to the on-screen
-- D-pad) and mod.input (source-safe GB button injection). The stock touch
-- overlay should be turned off in OPTIONS -> CONTROLS -- its virtual
-- buttons claim any touch that starts on them before this hook ever sees it.

return function(mod)
  -- Fractions of the game viewport, not raw pixels, so the thresholds hold
  -- steady across window sizes and orientations.
  local EDGE_ZONE = 0.14          -- how wide the bottom/right edge strip is
  local EDGE_SWIPE = 0.05         -- how far out of the edge strip counts as a swipe
  local TAP_SLOP = 0.04           -- movement under this is still a "tap"
  local DIRECTION_SWIPE = 0.06    -- movement past this commits to a held direction

  -- viewport size, refreshed every frame by the render.hud hook below;
  -- love.graphics is the fallback for the first frame before that fires.
  local gameW, gameH = love.graphics.getWidth(), love.graphics.getHeight()

  -- one record per live LOVE touch/mouse id:
  --   kind: "pending" (tap-or-swipe undecided), "direction", "edge_start",
  --         "edge_b", or "consumed" (already dispatched, ignore the rest)
  local pointers = {}

  local function dominantDirection(dx, dy)
    if math.abs(dx) >= math.abs(dy) then
      return dx > 0 and "right" or "left"
    end
    return dy > 0 and "down" or "up"
  end

  local function onPressed(game, ev)
    -- Two-finger tap: the second finger landing while the first is still an
    -- undecided tap-candidate is what "two-finger tap" means here, so it
    -- fires on press rather than waiting on both releases -- that also
    -- keeps ordinary single-finger A taps from ever paying a wait-and-see
    -- delay.
    for otherId, rec in pairs(pointers) do
      if otherId ~= ev.id and rec.kind == "pending" then
        mod.input:tap(game, "select")
        rec.kind = "consumed"
        pointers[ev.id] = { kind = "consumed" }
        return
      end
    end

    local kind = "pending"
    if ev.gameY >= gameH * (1 - EDGE_ZONE) then
      kind = "edge_start"
    elseif ev.gameX >= gameW * (1 - EDGE_ZONE) then
      kind = "edge_b"
    end
    pointers[ev.id] = { kind = kind, startX = ev.gameX, startY = ev.gameY }
  end

  local function onMoved(game, ev)
    local rec = pointers[ev.id]
    if not rec or rec.kind == "consumed" then return end
    local dx, dy = ev.gameX - rec.startX, ev.gameY - rec.startY

    if rec.kind == "pending" then
      -- Direction is decided once, at the first threshold crossing, and
      -- held for the rest of the gesture -- redeciding on every subsequent
      -- move would make a slightly wavering swipe flicker between D-pad
      -- buttons.
      if math.sqrt(dx * dx + dy * dy) >= DIRECTION_SWIPE * math.min(gameW, gameH) then
        local btn = dominantDirection(dx, dy)
        rec.kind = "direction"
        rec.token = mod.input:press(game, btn)
      end
    elseif rec.kind == "edge_start" then
      if (rec.startY - ev.gameY) >= EDGE_SWIPE * gameH then
        mod.input:tap(game, "start")
        rec.kind = "consumed"
      end
    elseif rec.kind == "edge_b" then
      if (rec.startX - ev.gameX) >= EDGE_SWIPE * gameW then
        mod.input:tap(game, "b")
        rec.kind = "consumed"
      end
    end
  end

  local function onEnded(game, ev, cancelled)
    local rec = pointers[ev.id]
    pointers[ev.id] = nil
    if not rec then return end
    if rec.kind == "direction" then
      mod.input:release(rec.token)
    elseif rec.kind == "pending" and not cancelled then
      mod.input:tap(game, "a")
    end
    -- edge_start / edge_b that never crossed its swipe threshold, and
    -- consumed pointers, resolve to nothing on release.
  end

  mod.hooks:wrap("input.pointer", function(_, game, ev)
    if not ev.insideGame and ev.phase == "pressed" then return false end
    if ev.phase == "pressed" then
      onPressed(game, ev)
    elseif ev.phase == "moved" then
      onMoved(game, ev)
    elseif ev.phase == "released" then
      onEnded(game, ev, false)
    elseif ev.phase == "cancelled" then
      onEnded(game, ev, true)
    end
    return true
  end)

  mod.hooks:wrap("render.hud", function(next, game, viewport)
    gameW, gameH = viewport.gameWidth, viewport.gameHeight
    return next(game, viewport)
  end)
end
