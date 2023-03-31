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
local startBricksX = 10
local startBricksY = 20
-- game states
local MENU = 1
local GAME = 2
local QUIT = 3
local gameState = MENU
-- menu options
local menuBalls = {
    {x = screenWidth / 2, y = screenHeight / 2, radius = 2, dx = 1, dy = -1, color = 11},
    {x = screenWidth / 2 + 20, y = screenHeight / 2 - 20, radius = 2, dx = -1, dy = 1, color = 8},
    {x = screenWidth / 2 - 30, y = screenHeight / 2 + 15, radius = 2, dx = 1, dy = 1, color = 10},
    {x = screenWidth / 2 + 10, y = screenHeight / 2 + 30, radius = 2, dx = -1, dy = -1, color = 9},
    {x = screenWidth / 2 - 25, y = screenHeight / 2 - 25, radius = 2, dx = 1, dy = 1, color = 12}
    -- TODO: put more balls here
}
local time = 0
local menuPaddle = {x = screenWidth / 2 - 25, y = screenHeight - 10, width = 50, height = 5, dx = 1}
-- game options
local score = 0
local highScore = 0
local lives = 3


-- Init function
function init()
    paddle = {x = screenWidth / 2 - 25, y = screenHeight - 10, width = 50, height = 5}
    ball = {x = screenWidth / 2, y = screenHeight / 2, radius = 2, dx = 1, dy = -1}
    bricks = {}

    for i = 1, 6 do
        for j = 1, 10 do
            local brick = {
                x = startBricksX + (j - 1) * 22,
                y = startBricksY + (i - 1) * 10,
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
        -- reset games scores and lives
        score = 0
        lives = 3
        -- continue with normal
        updateMenu()
        updateMenuBalls()
        updateMenuPaddle()
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

-- draw grid background function
function drawGrid()
    local gridSize = 8
    local gridColor = 1

    for x = 0, screenWidth, gridSize do
        line(x, 0, x, screenHeight, gridColor)
    end

    for y = 0, screenHeight, gridSize do
        line(0, y, screenWidth, y, gridColor)
    end
end

function updateMenuPaddle()
    menuPaddle.x = menuPaddle.x + menuPaddle.dx

    if menuPaddle.x < 0 then
        menuPaddle.x = 0
        menuPaddle.dx = -menuPaddle.dx
    elseif menuPaddle.x + menuPaddle.width > screenWidth then
        menuPaddle.x = screenWidth - menuPaddle.width
        menuPaddle.dx = -menuPaddle.dx
    end
end

function getTextWidth(text, scale)
    return #text * 6 * scale
end


function drawMenu()
    cls()

    -- Clear the area behind the Arkanoid title
    rect(screenWidth / 2 - 28 * 1.2, screenHeight / 4, 6 * 8 * 1.2, 8 * 1.2, 0)

    -- Draw the grid background
    drawGrid()

    -- Draw high score in main menu
    if highScore > 0 then
        local highScoreText = "High Score: " .. highScore
        local highScoreX = screenWidth - getTextWidth(highScoreText, 1) - 10
        local highScoreY = 2
        print(highScoreText, highScoreX, highScoreY, 15) -- 15 is white color
    end


    -- Draw the menu balls
    for _, ball in ipairs(menuBalls) do
        circ(ball.x, ball.y, ball.radius, ball.color)
    end

    -- Draw the menu paddle
    rect(menuPaddle.x, menuPaddle.y, menuPaddle.width, menuPaddle.height, 12)

    -- Draw the Arkanoid title with a growing and shrinking effect
    local titleScale = 1 + 0.5 * math.sin(time * 0.05)
    local titleText = "Arkanoid"
    local titleWidth = getTextWidth(titleText, titleScale)
    for i = 1, #titleText do
        local c = titleText:sub(i, i)
        local xOffset = (6 * (i - 1) * titleScale)
        print(c, screenWidth / 2 - titleWidth / 2 + xOffset, screenHeight / 4, 14, titleScale)
    end

    local mx, my, md = mouse()
    local mouseX = mx
    local mouseY = my
    local newGameScale = 1
    local quitScale = 1

    -- New Game button
    if mouseX >= screenWidth / 2 - 26 and mouseX <= screenWidth / 2 + 26 and mouseY >= screenHeight / 2 and mouseY <= screenHeight / 2 + 8 then
        newGameScale = 1.5
    end

    -- Quit button
    if mouseX >= screenWidth / 2 - 10 and mouseX <= screenWidth / 2 + 10 and mouseY >= screenHeight / 2 + 10 and mouseY <= screenHeight / 2 + 18 then
        quitScale = 1.5
    end

    -- Draw New Game button with scale
    local newGameText = "New Game"
    local newGameWidth = getTextWidth(newGameText, newGameScale)
    for i = 1, #newGameText do
        local c = newGameText:sub(i, i)
        local xOffset = (6 * (i - 1) * newGameScale)
        print(c, screenWidth / 2 - newGameWidth / 2 + xOffset, screenHeight / 2, 7, newGameScale)
    end

    -- Draw Quit button with scale
    local quitText = "Quit"
    local quitWidth = getTextWidth(quitText, quitScale)
    for i = 1, #quitText do
        local c = quitText:sub(i, i)
        local xOffset = (6 * (i - 1) * quitScale)
        print(c, screenWidth / 2 - quitWidth / 2 + xOffset, screenHeight / 2 + 10, 7, quitScale)
    end
end

-- Update menu balls function, which replace unique ball update function
function updateMenuBalls()
    for _, ball in ipairs(menuBalls) do
        ball.x = ball.x + ball.dx
        ball.y = ball.y + ball.dy

        if ball.x < 0 or ball.x + ball.radius > screenWidth then
            ball.dx = -ball.dx
        end
        if ball.y < 0 or ball.y + ball.radius > screenHeight then
            ball.dy = -ball.dy
        end
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
    -- Update high score
    highScore = math.max(score, highScore) 
    
    -- paddle-ball collision out of the screen
    if ball.y + ball.radius > screenHeight then
        lives = lives - 1
        if lives > 0 then
            ball.x = screenWidth / 2
            ball.y = screenHeight / 2
            ball.dx = 1
            ball.dy = -1
            paddle.x = screenWidth / 2 - 25
            paddle.y = screenHeight - 10
        else
            gameState = MENU
            init()
        end
    end
    
    
end

-- colisions function
function checkCollisions()
    -- paddle-ball collision
    if ball.y + ball.radius >= paddle.y and ball.y + ball.radius <= paddle.y + paddle.height and ball.x + ball.radius >= paddle.x and ball.x - ball.radius <= paddle.x + paddle.width then
        ball.dy = -ball.dy
    end
    
    -- ball collision
    for i, brick in ipairs(bricks) do
        if brick.alive then
            if ball.y - ball.radius <= brick.y + brick.height and ball.y + ball.radius >= brick.y and ball.x + ball.radius >= brick.x and ball.x - ball.radius <= brick.x + brick.width then
                ball.dy = -ball.dy
                brick.alive = false
                score = score + 15 -- Increment score
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

    -- Draw score
    print("Score: " .. score, 10, 2, 7)
    -- Draw high score
    if highScore > 0 then
        print("High Score: " .. highScore, 10, 10, 7)
    end

    -- Draw lives
    print("Lives: " .. lives, screenWidth - 60, 2, 7)
    
    -- draw ball
    circ(ball.x, ball.y, ball.radius, 11)
    
    -- draw blocks
    for i, brick in ipairs(bricks) do
        if brick.alive then
            rect(brick.x, brick.y, brick.width, brick.height, 8)
        end
    end

end