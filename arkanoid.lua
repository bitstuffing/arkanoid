-- title:  Arkanoid
-- author: bitstuffing
-- desc:   A Clone of the classic arkanoid for TIC80
-- script: lua

-- global parameters
local paddle
local ball
local bricks
local screenWidth = 240
local screenHeight = 136
-- game states
local MENU = 1
local GAME = 2
local QUIT = 3
local gameState = MENU
-- menu options
local menuBall = {x = screenWidth / 2, y = screenHeight / 2, radius = 2, dx = 1, dy = -1}
local time = 0



-- Init function
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

-- TIC main function
function TIC()
    
    time = time + 1

    if gameState == MENU then
        updateMenu()
        updateMenuBall()
        drawMenu()
    elseif gameState == GAME then
        if not paddle then
            init()
        end
        updatePaddle()
        updateBall()
        checkCollisions()
        draw()
    elseif gameState == QUIT then
        exit()
    end
end

function drawMenu()
    cls()

    -- Draw the menu ball
    circ(menuBall.x, menuBall.y, menuBall.radius, 11)

    -- Clear the area behind the Arkanoid title
    rect(screenWidth / 2 - 28 * 1.2, screenHeight / 4, 6 * 8 * 1.2, 8 * 1.2, 0)

    -- Draw the Arkanoid title with a growing and shrinking effect
    local titleScale = 1 + 0.2 * math.sin(time * 0.01)
    local titleText = "Arkanoid"
    for i = 1, #titleText do
        local c = titleText:sub(i, i)
        local xOffset = (6 * (i - 1) * titleScale)
        print(c, screenWidth / 2 - 28 * titleScale + xOffset, screenHeight / 4, 14, titleScale)
    end
    

    local mx, my, md = mouse()
    local mouseX = mx
    local mouseY = my
    local newGameScale = 1
    local quitScale = 1

    -- New Game button
    if mouseX >= screenWidth / 2 - 26 and mouseX <= screenWidth / 2 + 26 and mouseY >= screenHeight / 2 and mouseY <= screenHeight / 2 + 8 then
        newGameScale = 2
    end

    -- Quit button
    if mouseX >= screenWidth / 2 - 10 and mouseX <= screenWidth / 2 + 10 and mouseY >= screenHeight / 2 + 10 and mouseY <= screenHeight / 2 + 18 then
        quitScale = 2
    end

    -- Draw New Game button with scale
    local newGameText = "New Game"
    for i = 1, #newGameText do
        local c = newGameText:sub(i, i)
        local xOffset = (6 * (i - 1) * newGameScale)
        print(c, screenWidth / 2 - 26 * newGameScale + xOffset, screenHeight / 2, 7, newGameScale)
    end

    -- Draw Quit button with scale
    local quitText = "Quit"
    for i = 1, #quitText do
        local c = quitText:sub(i, i)
        local xOffset = (6 * (i - 1) * quitScale)
        print(c, screenWidth / 2 - 10 * quitScale + xOffset, screenHeight / 2 + 10, 7, quitScale)
    end
end

function updateMenuBall()
    menuBall.x = menuBall.x + menuBall.dx
    menuBall.y = menuBall.y + menuBall.dy

    if menuBall.x < 0 or menuBall.x + menuBall.radius > screenWidth then
        menuBall.dx = -menuBall.dx
    end
    if menuBall.y < 0 or menuBall.y + menuBall.radius > screenHeight then
        menuBall.dy = -menuBall.dy
    end
end


function updateMenu()
    local mx, my, md = mouse()
    local mouseX = mx
    local mouseY = my

    -- New Game button
    if mouseX >= screenWidth / 2 - 26 and mouseX <= screenWidth / 2 + 26 and mouseY >= screenHeight / 2 and mouseY <= screenHeight / 2 + 8 then
        if md then
            gameState = GAME
            init()
        end
    end

    -- Quit button
    if mouseX >= screenWidth / 2 - 10 and mouseX <= screenWidth / 2 + 10 and mouseY >= screenHeight / 2 + 10 and mouseY <= screenHeight / 2 + 18 then
        if md then
            gameState = QUIT
        end
    end
end


-- paddle update function
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

-- ball update function
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

-- colisions function
function checkCollisions()
    -- paddle-ball collision
    if ball.y + ball.radius >= paddle.y and ball.y + ball.radius <= paddle.y + paddle.height and ball.x + ball.radius >= paddle.x and ball.x - ball.radius <= paddle.x + paddle.width then
        ball.dy = -ball.dy
    end
    
  
    -- block-ball collision
    for i, brick in ipairs(bricks) do
        if brick.alive then
            if ball.y - ball.radius <= brick.y + brick.height and ball.y + ball.radius >= brick.y and ball.x + ball.radius >= brick.x and ball.x - ball.radius <= brick.x + brick.width then
                ball.dy = -ball.dy
                brick.alive = false
            end
        end
    end
    
end
    
-- Draw function
function draw()
    -- clean screen
    cls()
    -- draw paddle
    rect(paddle.x, paddle.y, paddle.width, paddle.height, 12)
    
    -- draw ball
    circ(ball.x, ball.y, ball.radius, 11)
    
    -- draw blocks
    for i, brick in ipairs(bricks) do
        if brick.alive then
            rect(brick.x, brick.y, brick.width, brick.height, 8)
        end
    end
end