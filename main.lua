function love.load ()
    love.window.setTitle("Cellular Automata")

    tcolor = {24/255, 32/255, 48/255}
    bcolor = {209/255, 215/255, 215/255}

    love.graphics.setColor(tcolor)
    love.graphics.setBackgroundColor(bcolor)
    
    size = 4                               -- cell width
    m = love.graphics.getWidth() / size    -- rows
    n = love.graphics.getHeight() / size   -- columns

    init(m / 2)

    ruler = rules(1)
    hide = false
    state = 'play'
end

function init(s)
    cells = {}  -- stack of epoch vectors
    epoch = {}  -- epoch a vector of automata
    

    -- fill 1st epoch with zeros
    for i = 1, m do
        table.insert(epoch, 0)
    end

    -- set starting cell: m - 1 or m / 2 or m + 1
    epoch[s] = 1
    table.insert(cells, epoch)
end

function love.keypressed (key, scancode, isrepeat)
    if key == "s" then
        if state == 'pause' then state = 'play'
        elseif state == 'play' then state = 'pause' end
    end

    if key == "n" then
        ruler = rules(ruler.index() % ruler.len() + 1)
    end

    if key == "p" then
        ruler = rules((ruler.index() + ruler.len() - 2) % ruler.len() + 1)
    end

    if key == "r" then
        init(m + 1)
        state = 'play'
    end

    if key == "l" then
        init(0)
        state = 'play'
    end

    if key == "m" then
        init(m / 2)
        state = 'play'
    end

    if key == "h" then
        hide = not hide
    end

    if key == "i" then
        tcolor, bcolor = bcolor, tcolor
        love.graphics.setBackgroundColor(bcolor)
    end

    if key == "w" then
        tcolor = {math.random(), math.random(), math.random()}
        bcolor = {1 - tcolor[1], 1 - tcolor[2], 1 - tcolor[3]}
        love.graphics.setBackgroundColor(bcolor)
    end
end


function love.update (dt)
    -- for screenshot
    -- if #cells == n then state = 'pause' end

    if state == 'play' then
        local nextepoch = {}

        for i = 1, m do
            nextepoch[i] = ruler.apply(
                epoch[i - 1] or 0,
                epoch[i],
                epoch[i + 1] or 0)
        end

        epoch = nextepoch
        table.insert(cells, 1, epoch)
        
        -- delete off-screen generation to free memory
        if #cells >= n then
            table.remove(cells, n + 1)
        end
    end
end

function love.draw ()
    -- if os.getenv ("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    --     require ("lldebugger").start()
    -- end

    for i = 1, m do
        for j = 1, #cells do
            if cells[j][i] == 1 then
                love.graphics.rectangle('fill', (i - 1) * size, (n - j) * size, size, size)
            end
        end
    end

    love.graphics.setColor(tcolor[1], tcolor[2], tcolor[3], 250/255)

    -- mini-buffer
    if not hide then
        love.graphics.rectangle(
            'fill',
            0,
            love.graphics.getHeight() - 24,
            love.graphics.getWidth(),
            love.graphics.getHeight() + 24)

        love.graphics.setColor(bcolor)

        love.graphics.printf(
            "[r]ight\t[l]eft\t[m]iddle\t[s]top\t[n]ext\t[p]revious\t[h]ide\t[i]nvert\t[w]ow",
            4,
            love.graphics.getHeight() - 20,
            love.graphics.getWidth(),
            "left")

        love.graphics.printf(
            "current rule: " .. ruler.which(),
            love.graphics.getWidth() - 112,
            love.graphics.getHeight() - 20,
            love.graphics.getWidth(),
            "left")

        love.graphics.setColor(tcolor)
    end

end

function rules (i)
    local ruleset = {
        {0, 0, 0, 1, 1, 1, 1, 0}, -- Rule 30
        {0, 0, 1, 0, 1, 1, 0, 1}, -- Rule 45
        {0, 1, 0, 1, 1, 0, 1, 0}, -- Rule 90
        {0, 1, 1, 0, 1, 1, 1, 0}, -- rule 110
        {1, 0, 1, 1, 0, 1, 1, 0}, -- rule 182
        {1, 0, 1, 1, 1, 1, 1, 0}, -- rule 190
        {1, 1, 0, 1, 1, 1, 1, 0}, -- rule 222
    }

    local index = i or 1
    local rule = ruleset[index]
    
    return {
        apply = function (a, b, c) return rule[8 - (a * 4 + b * 2 + c * 1)] end,
        index = function () return index end,
        len = function () return #ruleset end,
        which = function ()
            local y = 0
            local x = {128, 64, 32, 16, 8, 4, 2, 1}

            for k, v in pairs(x) do
                y = y + ruleset[index][k] * v
            end
            return y
        end
    }
end