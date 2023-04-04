-- title:  Arkanoid
-- author: bitstuffing
-- desc:   A Clone of the classic arkanoid for TIC80
-- script: lua

-- global parameters
local paddle
local PADDLE_WIDTH_INIT = 50
local ball = {
    x = 0,
    y = 0,
    dx = 0,
    dy = 0,
    radius = 5,
    speed = 150,
    inPlay = false
}
local bricks
local screenWidth = 240
local screenHeight = 136
local startBricksX = 10
local startBricksY = 20
-- game states
local MENU = 1
local GAME = 2
local QUIT = 3
local PAUSED = 4
local CREDITS = 5

local pauseMenu = {
    x = screenWidth / 2 - 40,
    y = screenHeight / 2 - 20,
    width = 80,
    height = 40
}
local pauseMenuSelection = 1
-- default game screen -> menu
local gameState = MENU
local options = {"New Game", "Credits", "Quit"}

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

local HIGH_SCORE_INDEX = 0
local highScore = 0

local lives = 3
local level = 1
local maxBounceAngle = math.rad(1) --paddle ball collision angle
local colors = { 
    red = 8,
    orange = 9,
    yellow = 10,
    green = 11,
    blue = 12,
    darkBlue = 1,
    purple = 13,
    darkGrey = 15,
    black = 0,
    darkGreen = 6,
    lightGreen = 5
}
local powerUps = {} 
local powerUpsCollected = 0
local powerUpsSpawned = 0
local POWERUP_MAX = 2
local POWERUP_PROBABILITY = 0.05 -- powerUp chance

local introNotes = {
    {"C-4", 8}, {"D-4", 8}, {"E-4", 8}, {"F-4", 16}, {"G-4", 8}, {"A-4", 8}, {"B-4", 16},
    {"C-5", 8}, {"B-4", 8}, {"A-4", 8}, {"G-4", 16}, {"F-4", 8}, {"E-4", 8}, {"D-4", 16},
    {"C-4", 8}, {"E-4", 8}, {"G-4", 8}, {"C-5", 16}, {"G-4", 8}, {"E-4", 8}, {"C-4", 16},
    {"G-3", 8}, {"C-4", 8}, {"E-4", 8}, {"G-4", 16}, {"C-5", 8}, {"G-4", 8}, {"E-4", 16},
    {"A-4", 8}, {"C-5", 8}, {"E-5", 8}, {"A-5", 16}, {"E-5", 8}, {"C-5", 8}, {"A-4", 16},
    {"F-4", 8}, {"A-4", 8}, {"C-5", 8}, {"F-5", 16}, {"C-5", 8}, {"A-4", 8}, {"F-4", 16},
    {"E-4", 8}, {"G-4", 8}, {"C-5", 8}, {"E-5", 16}, {"C-5", 8}, {"G-4", 8}, {"E-4", 16},
    {"D-4", 8}, {"F-4", 8}, {"A-4", 8}, {"D-5", 16}, {"A-4", 8}, {"F-4", 8}, {"D-4", 16},
}

local newLiveNotes = {
    {{"C-4", "E-4", "G-4"}, 8}, {{"D-4", "F-4", "A-4"}, 8}, {{"E-4", "G-4", "B-4"}, 8},
    {{"F-4", "A-4", "C-5"}, 16}, {{"G-4", "B-4", "D-5"}, 8}, {{"A-4", "C-5", "E-5"}, 8},
    {{"B-4", "D-5", "F-5"}, 16}, {{"C-5", "E-5", "G-5"}, 8}, {{"C-5", "E-5", "G-5"}, 8}
}

local tensionNotes = {
    {{"C-4", "E-4", "G-4"}, 4}, {{"B-3", "D-4", "G-4"}, 4}, {{"A-3", "C-4", "F-4"}, 4}, {{"B-3", "D-4", "G-4"}, 4},
    {{"C-4", "E-4", "G-4"}, 4}, {{"C-4", "E-4", "G-4"}, 4}, {{"C-4", "E-4", "G-4"}, 2},
    {{"B-3", "D-4", "G-4"}, 4}, {{"B-3", "D-4", "G-4"}, 4}, {{"B-3", "D-4", "G-4"}, 2},
    {{"C-4", "E-4", "G-4"}, 4}, {{"D-4", "F-4", "A-4"}, 4}, {{"D-4", "F-4", "A-4"}, 4},
    {{"C-4", "E-4", "G-4"}, 4}, {{"B-3", "D-4", "G-4"}, 4}, {{"A-3", "C-4", "F-4"}, 4}, {{"B-3", "D-4", "G-4"}, 4},
    {{"C-4", "E-4", "G-4"}, 4}, {{"C-4", "E-4", "G-4"}, 4}, {{"C-4", "E-4", "G-4"}, 2},
    {{"B-3", "D-4", "G-4"}, 4}, {{"B-3", "D-4", "G-4"}, 4}, {{"C-4", "E-4", "G-4"}, 4}, {{"B-3", "D-4", "G-4"}, 4},
    {{"A-3", "C-4", "F-4"}, 8},
}

local normalNotes = {
    
    {{"C-4", "E-4", "G-4"}, 4}, {{"D-4", "F-4", "A-4"}, 4}, {{"E-4", "G-4", "B-4"}, 4}, {{"A-3", "C-4", "E-4"}, 4},
    {{"G-3", "B-3", "D-4"}, 4}, {{"C-4", "E-4", "G-4"}, 4}, {{"D-4", "F-4", "A-4"}, 4}, {{"G-4", "B-4", "D-5"}, 4},
    {{"E-4", "G-4", "B-4"}, 4}, {{"A-3", "C-4", "E-4"}, 4}, {{"G-3", "B-3", "D-4"}, 4}, {{"C-4", "E-4", "G-4"}, 4},
    {{"D-4", "F-4", "A-4"}, 4}, {{"E-4", "G-4", "B-4"}, 4}, {{"A-3", "C-4", "E-4"}, 4}, {{"G-3", "B-3", "D-4"}, 4},
    {{"C-4", "E-4", "G-4"}, 4}, {{"D-4", "F-4", "A-4"}, 4}, {{"E-4", "G-4", "B-4"}, 4}, {{"A-3", "C-4", "E-4"}, 4},
    {{"G-3", "B-3", "D-4"}, 4}, {{"C-4", "E-4", "G-4"}, 4}, {{"D-4", "F-4", "A-4"}, 4}, {{"G-4", "B-4", "D-5"}, 4},
    {{"E-4", "G-4", "B-4"}, 8},
    {{"C-4", "E-4", "G-4"}, 4}, {{"F-4", "A-4", "C-5"}, 4}, {{"G-4", "B-4", "D-5"}, 4}, {{"A-3", "C-4", "E-4"}, 4},
    {{"F-3", "A-3", "C-4"}, 4}, {{"G-3", "B-3", "D-4"}, 4}, {{"C-4", "E-4", "G-4"}, 4}, {{"D-4", "F-4", "A-4"}, 4},
    {{"E-4", "G-4", "B-4"}, 4}, {{"A-3", "C-4", "E-4"}, 4}, {{"F-3", "A-3", "C-4"}, 4}, {{"G-3", "B-3", "D-4"}, 4},
    {{"C-4", "E-4", "G-4"}, 4}, {{"F-4", "A-4", "C-5"}, 4}, {{"G-4", "B-4", "D-5"}, 4}, {{"A-3", "C-4", "E-4"}, 4},
    {{"F-3", "A-3", "C-4"}, 4}, {{"G-3", "B-3", "D-4"}, 4}, {{"C-4", "E-4", "G-4"}, 4}, {{"D-4", "F-4", "A-4"}, 4},
    {{"E-4", "G-4", "B-4"}, 4}, {{"A-3", "C-4", "E-4"}, 4}, {{"F-3", "A-3", "C-4"}, 4}, {{"G-3", "B-3", "D-4"}, 4},
    {{"C-4", "E-4", "G-4"}, 8}
}

local normalNoteCounter = 0
local normalTimer = 0
local normalSpeed = 8 -- speed melody plays at

function playNormalMelody()
    playMelody(normalNotes)
end
function playStressMelody()
    playMelody(tensionNotes)
end

function playMelody(normalNotes)
    local noteIndex = math.floor(normalNoteCounter / normalSpeed) % #normalNotes + 1
    local chord = normalNotes[noteIndex][1]
    local duration = normalNotes[noteIndex][2]

    if normalNoteCounter % normalSpeed == 0 then
        for i, note in ipairs(chord) do
            sfx(i, note, 5, 3, duration, 1)
        end
    end

    normalNoteCounter = normalNoteCounter + 1
end

local introNoteIndex = 1
local introTimer = 0
local introSpeed = 2 -- normal game melody speed

function playGameMelody()
    if introTimer <= 0 then
        local noteData = introNotes[introNoteIndex]
        local note = noteData[1]
        local duration = noteData[2] * introSpeed
        sfx(10, note, 5, 3, 10, 1) -- Reproduce la nota en el canal 0
        introTimer = duration

        introNoteIndex = introNoteIndex + 1
        if introNoteIndex > #introNotes then
            introNoteIndex = 1
        end
    end

    introTimer = introTimer - 1
end


function loadHighScore()
    local highScoreData = pmem(HIGH_SCORE_INDEX)
    
    if not highScoreData then
        return 0
    end

    local highScore = tonumber(highScoreData)
    
    return highScore
end

function saveHighScore(highScore)
    -- save("highscore.data", tostring(highScore))
    pmem(HIGH_SCORE_INDEX,highScore)
end



-- function to creates powerups and insert it in into table 
function spawnPowerUp(x, y, powerupType)
    local powerup = {
        x = x,
        y = y,
        speed = 1,
        width = 6,
        height = 6,
        type = powerupType,
        dy = ball.speed / 2, -- makes the power-up pill to fall at half the speed of the ball
        active = false,
        visible = true,
        color = colors.orange,
        duration = -1
    }
    table.insert(powerUps, powerup)
end

function spawnNewLife(x, y, powerupType)
    local powerup = {
        x = x,
        y = y,
        speed = 1,
        width = 6,
        height = 6,
        type = powerupType,
        dy = ball.speed / 2, -- makes the power-up pill to fall at half the speed of the ball
        active = false,
        visible = true,
        color = colors.red,
        duration = -1
    }
    table.insert(powerUps, powerup)
end

-- function to check if two elements colide with each other
function collide(a, b)
    return a.x < b.x + b.width and a.y < b.y + b.height and b.x < a.x + a.width and b.y < a.y + a.height
end

-- function to update the position of power-ups
function updatePowerUps()
    for _, p in ipairs(powerUps) do
        if p.duration >= 0 then
            p.duration = p.duration - 1
            if p.duration < 0 then
                removePowerUpEffect(p)
            end
        end
        if p.visible then
            p.y = p.y + p.speed

            -- check power-up pill collision with paddle
            if collide(p, paddle) then
                -- sound effect when paddle hits power-up pill
                sfx(1, "B-6", 3, 1, 10)
                sfx(2, "D-6", 3, 3, 10)
                
                if (p.type == 1) then
                    applyPowerUpEffect(p)
                elseif (p.type == 2) then
                    lives = lives + 1
                end
                
                p.visible = false
            end

            -- remove power-up if screen exits
            if p.y > screenHeight then
                p.active = false
                p.visible = false
            end
        end
    end
end

-- function to apply power-up effect
function removePowerUpEffect(powerup)
    if powerup.type == 1 and powerup.active then -- decrease paddle size
        powerup.active = false
        powerUpsCollected = powerUpsCollected - 1
        paddle.width = paddle.width - PADDLE_WIDTH_INIT * 0.25 --TODO review this way
    end
    -- TODO other powerUps must be here
    --table.remove(powerUps, powerup)
    for i, v in ipairs(powerUps) do
        if v == powerup then
          table.remove(powerUps, i)
          break
        end
      end
      
end

-- function to apply power-up effect
function applyPowerUpEffect(powerup)
    if powerup.type == 1 and not powerup.active then -- increase paddle size
        powerup.active = true
        powerup.duration = 600
        powerUpsCollected = powerUpsCollected + 1
        paddle.width = paddle.width + PADDLE_WIDTH_INIT * 0.25
    end
    -- TODO other powerups must be here
end

-- draw powerups function
function drawPowerUps()
    for _, powerUp in ipairs(powerUps) do
        if powerUp.visible then
            rect(powerUp.x, powerUp.y, powerUp.width, powerUp.height, powerUp.color)
        end
    end
end

-- Init function
function init()
    highScore = loadHighScore()
    -- reset/init power-ups
    powerUpsCollected = 0
    powerUpsSpawned = 0
    powerUps = {} 
    -- reset/init paddle
    paddle = {x = screenWidth / 2 - 25, y = screenHeight - 10, width = PADDLE_WIDTH_INIT, height = 5}
    -- reset/init balls
    ball = {x = screenWidth / 2, y = screenHeight / 2, radius = 2, dx = 1, dy = -1, speed = 150, inPlay = true}
    -- reset/init bricks
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
        playNormalMelody()
        -- reset games scores and lives
        score = 0
        lives = 3
        -- continue with normal
        updateMenu()
        updateMenuBalls()
        updateMenuPaddle()
        drawMenu()
    elseif gameState == GAME then
        if lives > 1 then
            playGameMelody()
        else
            playStressMelody()
        end
        if not paddle then
            init()
        end
        updatePaddle()
        updateBall()
        updatePowerUps()
        checkCollisions()
        draw()
        if checkLevelComplete() then
            -- reset/init power-ups counters
            powerUpsCollected = 0
            powerUpsSpawned = 0
            -- increase level 
            level = level + 1
            
            ball.dx = ball.dx * 1.2
            ball.dy = ball.dy * 1.2

            -- increase velocity of the ball
            ball.speed = ball.speed * 1.3

            -- reset ball position
            ball.x = screenWidth / 2
            ball.y = screenHeight / 2
            paddle.x = screenWidth / 2 - 25
            paddle.y = screenHeight - 10
            init()
        end
    elseif gameState == PAUSED then
        updatePauseMenu()
        drawPauseMenu()    
    elseif gameState == CREDITS then
        updateCredits()
        drawCredits()
    elseif gameState == QUIT then
        exit()
    end
end

function updateCredits() -- TODO put click
    if keyp(KEY_ENTER) then
        gameState = MENU
    end
end

function drawCredits()
    cls()

    local title = "Credits"
    local creditsText = {
        "Developed by",
        "@bitstuffing",
        "with love",
        "",
        "TIC80 community",
        "GitHub CoPilot"
    }

    print(title, screenWidth / 2 - getTextWidth(title, 1) / 2, 10, colors.darkGrey)

    for i, text in ipairs(creditsText) do
        -- print(text, screenWidth / 2 - #text * 2, 30 + i * 10, colors.darkGrey)
        print(text, screenWidth / 2 - getTextWidth(text, 1) / 2, 30 + i * 10, colors.darkGreen)
    end
end


function updatePauseMenu()
    local mx, my, md = mouse()
    local mouseX = mx
    local mouseY = my

    if mouseY >= screenHeight / 2 - 10 and mouseY <= screenHeight / 2  then
        pauseMenuSelection = 1
    elseif mouseY >= screenHeight / 2 + 2 and mouseY <= screenHeight / 2 + 12 then
        pauseMenuSelection = 2
    else
        pauseMenuSelection = 0
    end

    -- Resume button
    if mouseX >= pauseMenu.x + 10 and mouseX <= pauseMenu.x + 70 and mouseY >= pauseMenu.y + 8 and mouseY <= pauseMenu.y + 16 then
        if md then
            gameState = GAME
        end
    end

    -- Quit button
    if mouseX >= pauseMenu.x + 10 and mouseX <= pauseMenu.x + 70 and mouseY >= pauseMenu.y + 24 and mouseY <= pauseMenu.y + 32 then
        if md then
            gameState = MENU
            init()
        end
    end
end

function drawPauseMenu()
    cls()

    -- Draw game
    draw()

    -- Draw semi-transparent overlay
    rectb(pauseMenu.x, pauseMenu.y, pauseMenu.width, pauseMenu.height, colors.lightGreen)
    rect(pauseMenu.x + 1, pauseMenu.y + 1, pauseMenu.width - 2, pauseMenu.height - 2, colors.black)

    local quitText = "Quit"
    local resumeText = "Resume"

    if pauseMenuSelection == 1 then
        rect(screenWidth / 2 - getTextWidth(resumeText, 1) / 2 - 2, screenHeight / 2 - 12, getTextWidth(resumeText, 1) + 4, 10, colors.lightGreen)
    elseif pauseMenuSelection == 2 then
        rect(screenWidth / 2 - getTextWidth(quitText, 1) / 2 - 2, screenHeight / 2 + 4, getTextWidth(quitText, 1) + 4, 10, colors.lightGreen)
    end

    -- Print "Resume" 
    print(resumeText, screenWidth / 2 - getTextWidth(resumeText, 1) / 2, screenHeight / 2 - 10, colors.darkGreen)

    -- Print "Quit" 
    print(quitText, screenWidth / 2 - getTextWidth(quitText, 1) / 2, screenHeight / 2 + 6, colors.darkGreen)
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
        print(highScoreText, highScoreX, highScoreY, colors.darkGrey)
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
    
    local optionColor = nil
    for j, option in ipairs(options) do

        optionColor = colors.darkGrey
        local scale = 1

        local optionWidth = getTextWidth(option, 1.5)

        if mouseX >= screenWidth / 2 - optionWidth/2 and mouseX <= screenWidth / 2 + optionWidth/2 and mouseY >= screenHeight / 2 + j * 10 and mouseY <= screenHeight / 2 + ( j * 10 + 8 ) then
            optionColor = colors.red
            scale = 1.5
        end

        local newGameText = option
        local newGameWidth = getTextWidth(newGameText, scale)
        for i = 1, #newGameText do
            local c = newGameText:sub(i, i)
            local xOffset = (6 * (i - 1) * scale)
            print(c, screenWidth / 2 - newGameWidth / 2 + xOffset, screenHeight / 2 + j * 10, 7, scale)
        end
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

    for j, option in ipairs(options) do
        local optionWidth = getTextWidth(option, 1.5)
        if mouseX >= screenWidth / 2 - optionWidth/2 and mouseX <= screenWidth / 2 + optionWidth/2 and mouseY >= screenHeight / 2 + j * 10 and mouseY <= screenHeight / 2 + ( j * 10 + 8 ) then
            if md then
                if j == 1 then
                    gameState = GAME
                    init()
                elseif j == 2 then
                    gameState = CREDITS
                elseif j == 3 then
                    gameState = QUIT
                end
            end
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

    -- Pause input handling
    if keyp(KEY_ENTER) then
        gameState = PAUSED
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
        -- reset power-ups
        powerUpsCollected = 0
        powerUpsSpawned = 0
        powerUps = {} 
        paddle.width = PADDLE_WIDTH_INIT -- reset paddle width
        --TODO here will reset all power-ups
        if lives > 0 then
            ball.x = screenWidth / 2
            ball.y = screenHeight / 2
            ball.dx = 1
            ball.dy = -1
            paddle.x = screenWidth / 2 - 25
            paddle.y = screenHeight - 10
        else
            saveHighScore(highScore)
            gameState = MENU
            init()
        end
    end    
end

-- colisions function
function checkCollisions()
    -- paddle-ball collisions
    checkPaddleCollision()
    -- brick-ball collision with bricks
    checkBrickCollisions()
end

function shouldSpawnPowerUp(chance)
    return math.random() < chance
end

-- brick-ball collision function
function checkBrickCollisions()
    for i, brick in ipairs(bricks) do
        if brick.alive then
            if ball.y - ball.radius <= brick.y + brick.height and ball.y + ball.radius >= brick.y and ball.x + ball.radius >= brick.x and ball.x - ball.radius <= brick.x + brick.width then
                ball.dy = -ball.dy
                brick.alive = false
                score = score + 15 -- Increment score
                
                -- sound effect when brick is hit
                sfx(0, "B-3", 3, 0, 10)
                sfx(1, "D-3", 3, 2, 10)

                -- Spawn a power-up with a chance and limit to POWERUP_MAX power-ups per screen
                if (shouldSpawnPowerUp(POWERUP_PROBABILITY) and powerUpsSpawned < POWERUP_MAX ) then
                    spawnPowerUp(brick.x + brick.width / 2, brick.y + brick.height / 2, 1)
                    powerUpsSpawned = powerUpsSpawned + 1
                end
                if lives == 1 and math.random() < POWERUP_PROBABILITY then
                    spawnNewLife(brick.x + brick.width / 2, brick.y + brick.height / 2, 2)
                end
            end
        end
    end
end


-- paddle-ball collision function
function checkPaddleCollision()
    if ball.y + ball.radius >= paddle.y and ball.y + ball.radius <= paddle.y + paddle.height then
        if ball.x >= paddle.x and ball.x <= paddle.x + paddle.width then
            local paddleCenter = paddle.x + paddle.width / 2
            local ballDistanceFromPaddleCenter = ball.x - paddleCenter
            local normalizedBallDistance = ballDistanceFromPaddleCenter / (paddle.width / 2)
            local smoothFactor = 0.75
            local bounceAngle = maxBounceAngle * normalizedBallDistance * smoothFactor

            ball.dy = -ball.dy
            ball.dx = ball.speed * math.sin(bounceAngle)

            -- increase speed of ball after each paddle collision
            ball.speed = ball.speed * 1.05

            -- sound effect when paddle hits ball
            sfx(2, "B-4", 3, 1, 10)
            sfx(3, "D-4", 3, 3, 10)

            -- limit the maximum horizontal ball speed
            local maxHorizontalSpeed = ball.speed * 0.75
            if math.abs(ball.dx) > maxHorizontalSpeed then
                ball.dx = math.sign(ball.dx) * maxHorizontalSpeed
            end
        end
    end
end



-- Level completed check function 
function checkLevelComplete()
    for _, brick in ipairs(bricks) do
        if brick.alive then
            return false
        end
    end
    return true
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
    -- Draw level
    print("Level: " .. level, screenWidth - 60, 12, 7)

    -- Draw power-ups
    drawPowerUps()
    
    -- draw ball
    circ(ball.x, ball.y, ball.radius, 11)
    
    -- draw blocks
    for i, brick in ipairs(bricks) do
        if brick.alive then
            rect(brick.x, brick.y, brick.width, brick.height, 8)
        end
    end

end