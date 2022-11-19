-- Collision detection function;
-- Returns true if two boxes overlap, false if they don't;
-- x1,y1 are the top-left coords of the first box, while w1,h1 are its width and height;
-- x2,y2,w2 & h2 are the same, but for the second box.
local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end

function love.load()
    love.window.setMode(492, 900)
    love.window.setTitle("Spirited Away Mini Game")
    background = love.graphics.newImage("background.jpg")
    soot = love.graphics.newImage("soot.png")
    redcandy = love.graphics.newImage("candy1.png")
    whitecandy = love.graphics.newImage("candy3.png")
    greencandy = love.graphics.newImage("candy2.png")
    yellowcandy = love.graphics.newImage("candy4.png")
    dirt1 = love.graphics.newImage("dirt1.png")
    dirt2 = love.graphics.newImage("dirt2.png")
    dirt3 = love.graphics.newImage("dirt3.png")
    worm1 = love.graphics.newImage("worm1.png")
    worm2 = love.graphics.newImage("worm2.png")
    sparkle1 = love.graphics.newImage("sparkle1.png")
    sparkle2 = love.graphics.newImage("sparkle2.png")
    sparkle3 = love.graphics.newImage("sparkle3.png")
    x = 211
    y = 800
    speed = 400
    candies = {} -- array of current white candies on screen
    worms = {}
    timersmax = {white = 0.8, green = 1.0, red = 1.2, yellow = 1.4, worm = 0.4}
    timers = {white = 0.8, green = 1.0, red = 1.2, yellow = 1.4, worm = 0.4}
    candyspeed = {white = 200, green = 400, red = 800, yellow = 1000, worm = 800}
    score = 0
    font = love.graphics.newFont("Minecraftia-Regular.ttf")
    ateworm = false
    displaydirt = false
    wormtimer = 0
    ycandytimer = 0
    twospeed = 2 --amount of time allowed to lapse before timer goes back to 0; 2 = timer of 2 seconds
    ateyellowcandy = false
    rulestimer = 0
    displayrules = true
    displaysparkle = false
    a = 255
    dirtopacity = 255
    sparkleopacity = 255
    gametimer = 0
    second = 0
    startgame = false
end

function love.update(dt)
    --quit game
    if love.keyboard.isDown("escape") then
        love.event.push('quit')
    end

    if gametimer < 60 and startgame == true then
        a = a - 1
        second = second + dt
        if second >= 1 then
            second = 0
            gametimer = gametimer + 1
        end
        for i in pairs(timers) do
            timers[i] = timers[i] - (1*dt)
            if timers[i] < 0 then
                timers[i] = timersmax[i]
                random = math.random(5, 462)
                if i == "worm" then
                    rworm = math.random(2)
                    if rworm == 1 then
                        newworm = {x = random, y = -30, img = worm1}
                    else
                        newworm = {x = random, y = -30, img = worm2}
                    end
                    table.insert(worms, newworm)
                else
                    if i == "white" then
                        newcandy = {x = random, y = -30, img = whitecandy, type = "white"}
                    elseif i == "green" then
                        newcandy = { x = random, y = -30, img = greencandy, type = "green"}
                    elseif i == "red" then
                        newcandy = { x = random, y = -30, img = redcandy, type = "red"}
                    elseif i == "yellow" then
                        newcandy = { x = random, y = -30, img = yellowcandy, type = "yellow"}
                    end
                    table.insert(candies, newcandy)
                end
            end     
        end

        --falling candies
        for i, candy in ipairs(candies) do
            if ateyellowcandy == false then
                candy.y = candy.y + (candyspeed[candy.type] * dt)
            else
                if candy.x < x then
                    candy.x = candy.x + (200 * 2.5 * dt)
                end
                if candy.x > x then
                    candy.x = candy.x - (200 * 2.5 * dt)
                end
                if candy.y < y then
                    candy.y = candy.y + (500 * 2.5 * dt)
                end
                if candy.y > y then
                    candy.y = candy.y - (500 * 2.5 * dt)
                end
            end
            if candy.y > 900 then -- remove off screen candies
                table.remove(candies, i)
            end
        end


        --falling worms
        for i, worm in ipairs(worms) do
            worm.y = worm.y + (600 * dt)
            if worm.y > 900 then
                table.remove(worms, i)
            end
        end

        --move soot
        if love.keyboard.isDown("right") then
            if x < 422 then
                x = x + (speed * dt)
            end
        end
        if love.keyboard.isDown("left") then
            if x > 0 then
                x = x - (speed * dt)
            end
        end
        if love.keyboard.isDown("down") then
            if y < 830 then
                y = y + (speed * dt)
            end
        end
        if love.keyboard.isDown("up") then
            if y > 0 then
                y = y - (speed * dt)
            end
        end

        --collison check for candies
        for i, candy in ipairs(candies) do
            if CheckCollision(candy.x, candy.y, candy.img:getWidth(), candy.img:getHeight(), x, y, 70, 69) then
                if candy.img == whitecandy then
                    table.remove(candies, i)
                    score = score + 1
                elseif candy.img == greencandy then
                    table.remove(candies, i)
                    score = score + 2
                elseif candy.img == redcandy then
                    table.remove(candies, i)
                    score = score + 4
                elseif candy.img == yellowcandy then
                    table.remove(candies, i)
                    ateyellowcandy = true
                end           
            end
        end

        --collision check for worms
        for i, worm in ipairs(worms) do
            if CheckCollision(worm.x, worm.y, worm.img:getWidth(), worm.img:getHeight(), x, y, 70, 69) then
                table.remove(worms, i)
                ateworm = true
                dirtopacity = 255
                displaydirt = false
                if score > 9 then
                    score = score - 10
                else
                    score = 0
                end
            end
        end

        if ateworm == true then
            dirtopacity = dirtopacity - 2
            wormtimer = wormtimer + dt * twospeed
            if wormtimer >= 6 then
                wormtimer = 0
                ateworm = false
                displaydirt = false
                dirtopacity = 255
            end
        end

        if ateyellowcandy == true then
            sparkleopacity = sparkleopacity - 4
            ycandytimer = ycandytimer + dt * twospeed
            if ycandytimer >= 2 then
                ycandytimer = 0
                ateyellowcandy = false
                sparkleopacity = 255
            end
        end

        if rulestimer >= 20 then
            displayrules = false
        else
            rulestimer = rulestimer + dt * 5
        end
    elseif startgame == true then
        startgame = false
        gametimer = 0
    end
    
end

function love.mousepressed(x, y, button, istouch)
    if startgame == false then
        if button == 1 then
            if x >= 232 and x <= 232 + 30 and y >= 450 and y <= 450 + 20 then
                startgame = true
                score = 0
            end
        end
    end
end

function love.draw()
    love.graphics.draw(background)
    love.graphics.print("Score: " .. score, font, 400, 30)

    if startgame == false then
        love.graphics.setColor(1, 1, 1)
        start = love.graphics.newText(font, "START")
        love.graphics.draw(start, 232, 450)
    end
    if gametimer < 60 and startgame == true then
        love.graphics.setColor(1, 1, 1, a/255)
        love.graphics.print("Collect as many candies as you can \n while avoiding worms for one minute!", font, 120, 350)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setColor(1, 1, 1, sparkleopacity/255)
        if ateyellowcandy == true then
            if displaysparkle == false then
                rsparkle = math.random(3)
                displaysparkle = true
            end
            if rsparkle == 1 then
                love.graphics.draw(sparkle1)
            elseif rsparkle == 2 then
                love.graphics.draw(sparkle2)
            else
                love.graphics.draw(sparkle3)
            end
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(soot, x, y)
        for i, candy in ipairs(candies) do
            love.graphics.draw(candy.img, candy.x, candy.y)
        end
        for i, worm in ipairs(worms) do
            love.graphics.draw(worm.img, worm.x, worm.y)
        end
        love.graphics.setColor(1, 1, 1, dirtopacity/255)
        if ateworm == true then
            if displaydirt == false then
                rdirt = math.random(3)
                displaydirt = true
            end
            if rdirt == 1 then
                love.graphics.draw(dirt1)
            elseif rdirt == 2 then
                love.graphics.draw(dirt2)
            else
                love.graphics.draw(dirt3)
            end  
        end
        love.graphics.setColor(1, 1, 1)
    end
end