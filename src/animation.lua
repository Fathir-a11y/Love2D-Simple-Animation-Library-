--[[
Animation.lua
A simple, lightweight 2D animation library for Love2D.
Supports looping and non-looping animations, scaling, rotation, and frame control.
--]]

local Animation = {}
-- Set the metatable for class-like behavior
Animation.__index = Animation

---
-- Constructor: Creates a new animation object.
-- @param imagePath: Path to the spritesheet image file.
-- @param frameWidth: Width of a single frame in pixels.
-- @param frameHeight: Height of a single frame in pixels.
-- @param frameDuration: Time (seconds) each frame is displayed (default 0.1).
-- @param doLoop: Boolean whether the animation should loop (default true).
-- @return: New Animation object
---
function Animation.new(imagePath, frameWidth, frameHeight, frameDuration, doLoop)
    local self = setmetatable({}, Animation)

    -- Load the spritesheet
    self.spriteSheet = love.graphics.newImage(imagePath)

    -- Frame dimensions
    self.frameWidth = frameWidth
    self.frameHeight = frameHeight

    -- Duration per frame
    self.frameDuration = frameDuration or 0.1

    -- Internal timer to track frame progression
    self.timer = 0

    -- Current frame index (1-based)
    self.currentFrame = 1

    -- Animation state
    self.playing = true

    -- Looping flag (default true)
    self.doLoop = doLoop ~= false

    -- Slice the spritesheet into quads (frames)
    self.frames = {}
    local imageWidth = self.spriteSheet:getWidth()
    local imageHeight = self.spriteSheet:getHeight()

    -- Calculate number of frames horizontally and vertically
    local cols = imageWidth / frameWidth
    local rows = imageHeight / frameHeight

    -- Create Quads for each frame
    for y = 0, rows - 1 do
        for x = 0, cols - 1 do
            local quad = love.graphics.newQuad(
                x * frameWidth, y * frameHeight,  -- Top-left of frame in sheet
                frameWidth, frameHeight,           -- Frame dimensions
                imageWidth, imageHeight            -- Spritesheet dimensions
            )
            table.insert(self.frames, quad)
        end
    end

    -- Safety check: no frames loaded
    if #self.frames == 0 then
        error("Animation Error: No frames found in " .. imagePath)
    end

    return self
end

---
-- Updates the animation logic.
-- Must be called in love.update(dt)
-- @param dt: Delta time in seconds
---
function Animation:update(dt)
    if not self.playing then return end -- Exit if paused

    -- Accumulate time
    self.timer = self.timer + dt

    -- Advance frames if timer exceeds frameDuration
    while self.timer >= self.frameDuration do
        self.timer = self.timer - self.frameDuration -- Subtract instead of reset to handle lag

        self.currentFrame = self.currentFrame + 1

        -- Looping or non-looping behavior
        if self.currentFrame > #self.frames then
            if self.doLoop then
                self.currentFrame = 1 -- Loop back to first frame
            else
                self.currentFrame = #self.frames -- Stay on last frame
                self.playing = false          -- Stop animation
                break
            end
        end
    end
end

---
-- Draws the current frame to the screen.
-- Must be called in love.draw()
-- @param x, y: Position to draw the animation (top-left by default)
-- @param r: Rotation in radians (optional, default 0)
-- @param sx, sy: Scale factors (optional, default 1)
-- @param ox, oy: Origin offset (optional, default 0, useful for rotation)
---
function Animation:draw(x, y, r, sx, sy, ox, oy)
    -- Ensure there is at least one frame
    if #self.frames == 0 then return end

    love.graphics.draw(
        self.spriteSheet,
        self.frames[self.currentFrame],
        x, y,
        r or 0,
        sx or 1, sy or 1,
        ox or 0, oy or 0
    )
end

-- CONTROL METHODS

---
-- Starts or resumes the animation
---
function Animation:play()
    self.playing = true
end

---
-- Pauses the animation
---
function Animation:pause()
    self.playing = false
end

---
-- Stops the animation and resets to first frame
---
function Animation:stop()
    self.playing = false
    self.currentFrame = 1
    self.timer = 0 -- Reset timer to prevent immediate frame jump on next play
end

---
-- Manually set the current frame
-- @param n: Frame number (1-based)
---
function Animation:setFrame(n)
    if n >= 1 and n <= #self.frames then
        self.currentFrame = n
        self.timer = 0 -- Reset timer to avoid immediate frame advance
    end
end

return Animation
