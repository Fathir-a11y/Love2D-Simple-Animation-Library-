local Animation = {}
-- Sets up the metatable for class-like behavior in Lua.
Animation.__index = Animation

---
-- Constructor: Creates a new animation object.
-- @param imagePath: Path to the spritesheet image file.
-- @param frameWidth: The width of each individual frame.
-- @param frameHeight: The height of each individual frame.
-- @param frameDuration: Time (in seconds) to display each frame (default 0.1).
-- @param doLoop: Boolean to determine if the animation should loop (default true).
---
function Animation.new(imagePath, frameWidth, frameHeight, frameDuration, doLoop)
    -- Creates a new object instance.
    local self = setmetatable({}, Animation)

    -- CORE PROPERTIES
    self.spriteSheet = love.graphics.newImage(imagePath) -- Load the spritesheet image.
    self.frameWidth = frameWidth
    self.frameHeight = frameHeight
    self.frameDuration = frameDuration or 0.1 -- Time duration per frame.
    self.timer = 0                            -- Internal timer.
    self.currentFrame = 1                     -- Index of the frame currently being shown.
    self.playing = true                       -- Animation state (running/paused).
    
    
    self.doLoop = doLoop ~= false             -- Defaults to true if not explicitly set to false.

    -- SPRITESHEET SLICING (QUAD SETUP)
    local imageWidth = self.spriteSheet:getWidth()
    local imageHeight = self.spriteSheet:getHeight()
    self.frames = {} -- Table to store all Love2D Quad objects.

    -- Iterate through the spritesheet to slice it into Quads.
    for y = 0, (imageHeight / frameHeight) - 1 do
        for x = 0, (imageWidth / frameWidth) - 1 do
            local quad = love.graphics.newQuad(
                x * frameWidth, y * frameHeight, -- X/Y start position on the sheet
                frameWidth, frameHeight,         -- Frame width/height
                imageWidth, imageHeight          -- Total sheet dimensions
            )
            table.insert(self.frames, quad)
        end
    end

    return self
end

---
-- Updates the animation logic. Must be called in love.update(dt).
-- @param dt: Delta time.
---
function Animation:update(dt)
    -- Exit the function if the animation is paused.
    if not self.playing then return end

    self.timer = self.timer + dt
    
    -- Check if it's time to advance to the next frame.
    if self.timer >= self.frameDuration then
        self.timer = 0
        self.currentFrame = self.currentFrame + 1
        
        
        if self.currentFrame > #self.frames then
            if self.doLoop then
                self.currentFrame = 1 -- Reset to the first frame for looping.
            else
                -- If non-looping, stop on the last frame and pause the animation.
                self.currentFrame = #self.frames 
                self.playing = false
            end
        end
    end
end

---
-- Draws the current animation frame to the screen. Must be called in love.draw().
-- @param x, y: Position to draw the animation.
-- @param r: Rotation (optional, default 0).
-- @param sx, sy: Scale factors (optional, default 1).
---
function Animation:draw(x, y, r, sx, sy)
    love.graphics.draw(
        self.spriteSheet,
        self.frames[self.currentFrame], -- The currently active frame Quad
        x, y,
        r or 0,
        sx or 1,
        sy or 1
    )
end

-- CONTROL METHODS

function Animation:play() 
    self.playing = true -- Resumes the animation.
end

function Animation:pause() 
    self.playing = false -- Pauses the animation.
end

function Animation:stop() 
    self.playing = false  -- Stops the animation.
    self.currentFrame = 1 -- Resets the frame to the first one.
end

---
-- Manually sets the current animation frame.
-- @param n: The frame number to set (1-based index).
---
function Animation:setFrame(n)
    -- Check that the frame number is valid.
    if n >= 1 and n <= #self.frames then
        self.currentFrame = n
    end
end

return Animation
