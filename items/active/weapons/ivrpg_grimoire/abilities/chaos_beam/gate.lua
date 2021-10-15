require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  self.controlMovement = config.getParameter("controlMovement")
  self.controlRotation = config.getParameter("controlRotation")
  self.facingDirection = config.getParameter("facingDirection")
  self.rotationSpeed = 0
  self.timedActions = config.getParameter("timedActions", {})

  self.aimPosition = mcontroller.position()

  message.setHandler("updateProjectile", function(_, _, aimPosition)
      self.aimPosition = aimPosition
      return entity.id()
    end)

  message.setHandler("kill", function()
      projectile.die()
    end)
end

function update(dt)
  if self.aimPosition then
    for _, action in pairs(self.timedActions) do
      processTimedAction(action, dt)
    end
  end
end

function processTimedAction(action, dt)
  if self.facingDirection then
    action.direction[1] = self.facingDirection
  end
  if action.complete then
    return
  elseif action.delayTime then
    action.delayTime = action.delayTime - dt
    if action.delayTime <= 0 then
      action.delayTime = nil
    end
  elseif action.loopTime then
    action.loopTimer = action.loopTimer or 0
    action.loopTimer = math.max(0, action.loopTimer - dt)
    if action.loopTimer == 0 then
      projectile.processAction(action)
      action.loopTimer = action.loopTime
      if action.loopTimeVariance then
        action.loopTimer = action.loopTimer + (2 * math.random() - 1) * action.loopTimeVariance
      end
    end
  else
    projectile.processAction(action)
    action.complete = true
  end
end
