-- title:  Arkanoid
-- author: bitstuffing
-- desc:   A Clone of the classic arkanoid for TIC80
-- script: lua

-- Variables globales
local paddle
local ball
local bricks
local screenWidth = 240
local screenHeight = 136

-- Función de inicialización
function init()
    paddle = {x = screenWidth / 2 - 25, y = screenHeight - 10, width = 50, height = 5}
    ball = {x = screenWidth / 2, y = screenHeight / 2, radius = 2, dx = 1, dy = -1}
    bricks = {}

    for i = 1, 6 do
        for j = 1, 10 do
            local brick = {
                x = 10 + (j - 1) * 22,
                y = 10 + (i - 1) * 10,
                width = 20,
                height = 8,
                alive = true
            }
            table.insert(bricks, brick)
        end
    end
end

-- Función de actualización
function TIC()
    if not paddle then
        init()
    end
    updatePaddle()
    updateBall()
    checkCollisions()
    draw()
end

-- Funciones de actualización
function updatePaddle()
    local mx, my, md = mouse()
    local mouseX = mx

    paddle.x = mouseX - paddle.width / 2

    if paddle.x < 0 then
        paddle.x = 0
    elseif paddle.x + paddle.width > screenWidth then
        paddle.x = screenWidth - paddle.width
    end
end

function updateBall()
    ball.x = ball.x + ball.dx
    ball.y = ball.y + ball.dy

    if ball.x < 0 or ball.x + ball.radius > screenWidth then
        ball.dx = -ball.dx
    end
    if ball.y < 0 then
        ball.dy = -ball.dy
    end
    if ball.y + ball.radius > screenHeight then
        init()
    end
end

-- Función de colisiones
function checkCollisions()
    -- Colisiones de la pelota con el paddle
    if ball.y + ball.radius >= paddle.y and ball.y + ball.radius <= paddle.y + paddle.height and ball.x + ball.radius >= paddle.x and ball.x - ball.radius <= paddle.x + paddle.width then
        ball.dy = -ball.dy
    end
    
  
    -- Colisiones de la pelota con los bloques
    for i, brick in ipairs(bricks) do
        if brick.alive then
            if ball.y - ball.radius <= brick.y + brick.height and ball.y + ball.radius >= brick.y and ball.x + ball.radius >= brick.x and ball.x - ball.radius <= brick.x + brick.width then
                ball.dy = -ball.dy
                brick.alive = false
            end
        end
    end
    
end
    
-- Función de dibujo
function draw()
    cls()
    -- Dibujar el paddle
    rect(paddle.x, paddle.y, paddle.width, paddle.height, 12)
    
    -- Dibujar la pelota
    circ(ball.x, ball.y, ball.radius, 11)
    
    -- Dibujar los bloques
    for i, brick in ipairs(bricks) do
        if brick.alive then
            rect(brick.x, brick.y, brick.width, brick.height, 8)
        end
    end
end