require "/scripts/keybinds.lua"
require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/ivrpgutil.lua"

function init()
  self.id = projectile.sourceEntity()
  self.chainLimit = config.getParameter("chainLimit", 2)
  self.currentChain = 0
  self.startSeeking = false
  self.nearbyEntities = {}
  math.random()
end

function update(args)

  if self.currentChain > self.chainLimit then
    projectile.die()
  end

  local targets = enemyQuery(mcontroller.position(), 30, {includedTypes = {"creature"}}, self.id, true)
  if targets and not self.newTarget then
    for _,id in ipairs(targets) do
      if world.entityExists(id) then
        local pos = world.entityPosition(id)
        local distance = vec2.mag(world.distance(mcontroller.position(), pos))
        if distance <= 2.5 then
          self.startSeeking = id
        elseif not world.lineTileCollision(mcontroller.position(), pos, {"Block", "Slippery", "Null", "Dynamic"}) then
          table.insert(self.nearbyEntities, id)
        end
      end
    end
  end

  if self.startSeeking and #self.nearbyEntities > 0 and not self.newTarget then
    startSeeking()
  end

  if self.newTarget and world.entityExists(self.newTarget) then
    self.nearbyEntities = {}
    local distance = world.distance(world.entityPosition(self.newTarget), mcontroller.position())
    mcontroller.setVelocity(vec2.mul(vec2.norm(distance), projectile.getParameter("speed", 1)))
    if vec2.mag(distance) <= 2.5 then
      self.newTarget = nil
    end
  else
    self.newTarget = nil
  end
end

function startSeeking()
  local randIndex = math.random(#self.nearbyEntities)
  local newId = self.nearbyEntities[randIndex]
  if newId and newId ~= self.startSeeking then
    self.newTarget = newId
    self.currentChain = self.currentChain + 1
  end
end
