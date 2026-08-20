-- TM35 Metronome: gesture-only touch controls.
--   tap                       -> A
--   swipe from the right edge -> B
--   swipe up from the bottom edge -> Start
--   two-finger tap            -> Select
--   swipe and hold a direction -> that D-pad direction, held
--
-- Built on input.pointer (raw touch/mouse, first refusal to the on-screen
-- D-pad) and mod.input (source-safe GB button injection). The TOUCH INPUT
-- option below switches the native on-screen pad off automatically when set
-- to SWIPE, so there's one control instead of two to keep in sync.

return function(mod)
  mod.options:define({
    { key = "mode", label = "TOUCH INPUT", type = "choice", default = "buttons",
      choices = { { "BUTTONS", "buttons" }, { "SWIPE", "swipe" } } },
  })

  -- Fractions of the game viewport, not raw pixels, so the thresholds hold
  -- steady across window sizes and orientations.
  local EDGE_ZONE = 0.14          -- how close to the bottom/right edge a swipe must start
  local DIRECTION_SWIPE = 0.06    -- movement past this commits to a gesture instead of a tap

  -- viewport size, refreshed every frame by the render.hud hook below;
  -- love.graphics is the fallback for the first frame before that fires.
  local gameW, gameH = love.graphics.getWidth(), love.graphics.getHeight()

  -- one record per live LOVE touch/mouse id:
  --   kind: "pending" (tap-or-swipe undecided), "direction", or "consumed"
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
    pointers[ev.id] = { kind = "pending", startX = ev.gameX, startY = ev.gameY }
  end

  local function onMoved(game, ev)
    local rec = pointers[ev.id]
    if not rec or rec.kind ~= "pending" then return end
    local dx, dy = ev.gameX - rec.startX, ev.gameY - rec.startY
    if math.sqrt(dx * dx + dy * dy) < DIRECTION_SWIPE * math.min(gameW, gameH) then
      return
    end

    -- What the swipe becomes depends on where it started, not just where
    -- it's headed: only a start near the bottom edge can become Start, only
    -- a start near the right edge can become B. Everything else, including
    -- a swipe that starts in one of those strips but heads the other way,
    -- is a normal held direction. Checked here (once, at the moment a tap
    -- turns into a swipe) rather than at press time, so a plain tap that
    -- happens to land near an edge still just fires A.
    local horizontal = math.abs(dx) >= math.abs(dy)
    local startedNearBottom = rec.startY >= gameH * (1 - EDGE_ZONE)
    local startedNearRight = rec.startX >= gameW * (1 - EDGE_ZONE)

    if startedNearBottom and not horizontal and dy < 0 then
      mod.input:tap(game, "start")
      rec.kind = "consumed"
    elseif startedNearRight and horizontal and dx < 0 then
      mod.input:tap(game, "b")
      rec.kind = "consumed"
    else
      rec.kind = "direction"
      rec.token = mod.input:press(game, dominantDirection(dx, dy))
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

  -- Keeps the native on-screen pad in sync with TOUCH INPUT: only reacts to
  -- a change made through this row (lastMode starts as whatever the row
  -- already reads, so boot never silently flips a player's existing TOUCH
  -- PAD setting).
  local lastMode = nil

  mod.hooks:wrap("render.hud", function(next, game, viewport)
    gameW, gameH = viewport.gameWidth, viewport.gameHeight

    local mode = mod.options:get("mode") or "buttons"
    if lastMode == nil then
      lastMode = mode
    elseif mode ~= lastMode then
      lastMode = mode
      local o = game.save and game.save.options
      if o then
        o.touchControls = type(o.touchControls) == "table" and o.touchControls or {}
        o.touchControls.enabled = (mode ~= "swipe")
        game:applyOptions(o)
        game:writeOptions()
      end
    end

    return next(game, viewport)
  end)
end
