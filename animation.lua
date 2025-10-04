-- File: Animation.lua
-- A simple, reusable library for managing spritesheet animations in Love2D.

local Animation = {}
-- Sets up the metatable. This is the standard pattern for creating a 'class' in Lua.
Animation.__index = Animation

---
-- Constructor: Creates a new animation object.
-- @param imagePath: Path to the spritesheet image file.
-- @param frameWidth: The width of each individual frame.
-- @param frameHeight: The height of each individual frame.
-- @param frameDuration: The time (in seconds) to display each frame (defaults to 0.1).
---
function Animation.new(imagePath, frameWidth, frameHeight, frameDuration)
    -- Creates a new object instance and assigns its metatable.
    local self = setmetatable({}, Animation)

    -- CORE PROPERTIES
    self.spriteSheet = love.graphics.newImage(imagePath) -- Loads the spritesheet image.
    self.frameWidth = frameWidth
    self.frameHeight = frameHeight
    self.frameDuration = frameDuration or 0.1 -- Duration per frame.
    self.timer = 0                            -- Timer to track elapsed time.
    self.currentFrame = 1                     -- Index of the frame currently being shown (starts at 1).
    self.playing = true                       -- Animation state (running or paused).

    -- SPRITESHEET SLICING (QUAD SETUP)
    local imageWidth = self.spriteSheet:getWidth()
    local imageHeight = self.spriteSheet:getHeight()
    self.frames = {} -- Table to store all Love2D Quad objects.

    -- Iterate through rows (Y)
    for y = 0, (imageHeight / frameHeight) - 1 do
        -- Iterate through columns (X)
        for x = 0, (imageWidth / frameWidth) - 1 do
            -- Create a Love2D Quad (the cutting area)
            local quad = love.graphics.newQuad(
                x * frameWidth, y * frameHeight, -- Starting X and Y position on the spritesheet
                frameWidth, frameHeight,         -- Width and Height of the cut
                imageWidth, imageHeight          -- Total width and height of the spritesheet
            )
            table.insert(self.frames, quad)
        end
    end

    return self
end

---
-- Updates the animation logic. Must be called in love.update(dt).
-- @param dt: Delta time (time elapsed since the last frame).
---
function Animation:update(dt)
    -- Exit the function if the animation is paused.
    if not self.playing then return end

    -- Add the delta time to the internal timer.
    self.timer = self.timer + dt
    
    -- Check if it's time to advance to the next frame.
    if self.timer >= self.frameDuration then
        self.timer = 0
        self.currentFrame = self.currentFrame + 1
        
        -- Check for looping: if we passed the last frame.
        if self.currentFrame > #self.frames then
            self.currentFrame = 1 -- Reset to the first frame.
        end
    end
end

---
-- Draws the current animation frame to the screen. Must be called in love.draw().
-- @param x, y: Position to draw the animation.
-- @param r: Rotation (optional, defaults to 0).
-- @param sx, sy: Scale factors for X and Y (optional, defaults to 1).
---
function Animation:draw(x, y, r, sx, sy)
    love.graphics.draw(
        self.spriteSheet,
        self.frames[self.currentFrame], -- The currently active frame Quad
        x, y,
        r or 0,
        sx or 1,
        sy or 1
        -- Note: Origin points (ox, oy) are left at default (top-left corner)
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
    -- Check that the frame number is valid (within bounds).
    if n >= 1 and n <= #self.frames then
        self.currentFrame = n
    end
end

return Animation
