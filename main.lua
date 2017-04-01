anim = require 'anim8'
function love.load ()
  love.window.setFullscreen(true)

  -- create worlds
  love.physics.setMeter(60)
  world = love.physics.newWorld(0, 9.81*60, true)

  objects = {} -- uma table pra suportar nossos obj
  -- obj
  objects.bomb = {}
  objects.bomb.img = love.graphics.newImage('img/bomba.png')
  objects.bomb.posy = 10
  objects.bomb.time = 2
  objects.bomb.shot = false
  objects.bomb.body = love.physics.newBody(world, 0, 0, 'static')
  objects.bomb.shape = love.physics.newRectangleShape(158, 158)

  --ufo
  objects.ufo = {}
  objects.ufo.img = love.graphics.newImage('img/ufo.png')
  objects.ufo.posx  = 500
  objects.ufo.posy = 10
  objects.ufo.velocity = 2

  --bg
  objects.background = love.graphics.newImage('img/bg.png')
  -- chão
  objects.ground = {}
  objects.ground.body = love.physics.newBody(world, 2000/2, 600, type) -- cria um body
  objects.ground.shape = love.physics.newRectangleShape(2000, 50) -- cria um shape (vai ser atachado pelo centro)
  objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape) -- attach shape to body
  objects.ground.img = love.graphics.newImage('img/ground.png')

  --bola
  objects.zombie = {}
  objects.zombie.body = love.physics.newBody(world , 650/2,650/2, 'dynamic')
  objects.zombie.shape = love.physics.newRectangleShape(60 , 100) -- zombie radius 20
  objects.zombie.fixture = love.physics.newFixture(objects.zombie.body , objects.zombie.shape, 0.8) -- set density 1
  objects.zombie.walking = love.graphics.newImage('img/walking-zombie.png')
  objects.zombie.idle = love.graphics.newImage('img/idle-zombie.png')
  objects.zombie.direc = true
  -- anim8
  objects.zombie.walkinGrid = anim.newGrid(100, 123 , objects.zombie.walking:getWidth() , objects.zombie.walking:getHeight())
  objects.zombie.walkingAnim = anim.newAnimation(objects.zombie.walkinGrid('1-5', 1 , '1-5' , 2) , 0.07)

  objects.zombie.idleGrid = anim.newGrid(100 , 123 , objects.zombie.idle:getWidth() , objects.zombie.idle:getHeight())
  objects.zombie.idleAnim = anim.newAnimation(objects.zombie.idleGrid('1-5' , 1 , '1-5', 2 , '1-5' , 3) , 0.07)

end

function love.update(dt)

  world:update(dt) -- faz o mundo funcionar na mesma taxa de update
  x, y = objects.zombie.body:getLinearVelocity()
  --- ufo movement
  if objects.ufo.posx >= 1200 then
    objects.ufo.direc = false
    objects.ufo.velocity = objects.ufo.velocity + 0.6
  elseif objects.ufo.posx <= 10 then objects.ufo.direc = true end

  if objects.ufo.direc then
    objects.ufo.posx =objects.ufo.posx + objects.ufo.velocity
  elseif not objects.ufo.direc then
    objects.ufo.posx = objects.ufo.posx - objects.ufo.velocity
  end

  -- Bomb Drop
  objects.bomb.time =   objects.bomb.time -  1 * dt
  if objects.bomb.time <=0 then
    objects.bomb.body:destroy()
    objects.bomb.time = 2
    objects.bomb.body = love.physics.newBody(world, objects.bomb.posx, objects.bomb.posy, 'dynamic')
    objects.bomb.shape = love.physics.newRectangleShape(40, 80)
    objects.bomb.fixture = love.physics.newFixture(objects.bomb.body, objects.bomb.shape, 1)
    objects.bomb.shot = true
  end


  -- switch animations
  if x  == 0 then objects.zombie.idleAnim:update(dt) end

  if love.keyboard.isDown('right') then
    objects.zombie.body:applyForce(400, 0)
    objects.zombie.direc = true
    objects.zombie.walkingAnim:update(dt)
  elseif love.keyboard.isDown('left') then
    objects.zombie.body:applyForce(-400,0)
    objects.zombie.direc = false
    objects.zombie.walkingAnim:update(dt)
  end
end

-- Stop inertia
function love.keyreleased(k)
  if k == 'right' or k =='left' then objects.zombie.body:setLinearVelocity(0,0) end
end

-- Draw
function love.draw()
  love.graphics.draw(objects.background, 0 , 0) -- bg
  love.graphics.draw(objects.ground.img, 0, objects.ground.body:getY() - 420/2) -- chão
  love.graphics.draw(objects.ufo.img, objects.ufo.posx, objects.ufo.posy)
  --love.graphics.polygon("fill", objects.bomb.body:getWorldPoints(objects.bomb.shape:getPoints()))


  --shot
  for i = 0 , 3 , 1 do
    objects.bomb.posx = love.math.random(1 , 800)

    if objects.bomb.shot then
      love.graphics.draw(objects.bomb.img , objects.bomb.body:getX() - 80 , objects.bomb.body:getY() - 130)
    end
  end
  -- turnarround
  if  x > 0 or x < 0  then
    if objects.zombie.direc  then
      objects.zombie.walkingAnim:draw(objects.zombie.walking , objects.zombie.body:getX() , objects.zombie.body:getY() - 70 ,0 , 1 , 1 , 50 , 0)
    elseif not objects.zombie.direc then
      objects.zombie.walkingAnim:draw(objects.zombie.walking , objects.zombie.body:getX() , objects.zombie.body:getY() - 70 ,0 , -1 , 1 ,50 , 0)
    end
  elseif x == 0 then
    if objects.zombie.direc  then
      objects.zombie.idleAnim:draw(objects.zombie.idle , objects.zombie.body:getX() , objects.zombie.body:getY() - 70 ,0 , 1 , 1 , 50 , 0)
    elseif not objects.zombie.direc then
      objects.zombie.idleAnim:draw(objects.zombie.idle , objects.zombie.body:getX() , objects.zombie.body:getY() - 70 ,0 , -1 , 1 ,50 , 0)
    end
  end

end
