--[[ 
    Animation.lua - Optimized single-file sprite animation library for Love2D
    Author: Fathir-a11y
    Features:
        - Single file, easy to include in any project
        - Handles looping and single-pass (non-looping) animations
        - Optimized for large numbers of sprites
        - Automatic culling: skips update/draw when sprite is outside screen
        - Simple control methods: play, pause, stop, setFrame
--]]

local Animation = {}
Animation.__index = Animation

--- Constructor: Creates a new animation object
-- @param imagePath: Path to the spritesheet image
-- @param frameWidth: Width of each individual frame in pixels
-- @param frameHeight: Height of each individual frame in pixels
-- @param frameDuration: Time (seconds) to display each frame (default 0.1)
-- @param doLoop: Boolean indicating if animation should loop (default true)
function Animation.new(imagePath, frameWidth, frameHeight, frameDuration, doLoop)
    -- Create the animation object
    local self = setmetatable({}, Animation)

    -- Load the sprite sheet from file
    self.spriteSheet = love.graphics.newImage(imagePath)

    -- Store frame dimensions
    self.frameWidth = frameWidth
    self.frameHeight = frameHeight

    -- Time per frame; default to 0.1 seconds
    self.frameDuration = frameDuration or 0.1

    -- Timer to track frame progression
    self.timer = 0

    -- Index of the current frame being displayed
    self.currentFrame = 1

    -- Flag indicating if animation is currently playing
    self.playing = true

    -- Loop flag (true by default)
    self.doLoop = doLoop ~= false

    --[[ 
        Slice the sprite sheet into frames using Quads.
        Love2D Quads allow drawing specific regions of an image efficiently.
        Frames are stored in a table for quick access during draw/update.
    --]]
    local imageWidth, imageHeight = self.spriteSheet:getWidth(), self.spriteSheet:getHeight()
    self.frames = {}
    for y = 0, (imageHeight / frameHeight) - 1 do
        for x = 0, (imageWidth / frameWidth) - 1 do
            local quad = love.graphics.newQuad(
                x * frameWidth, y * frameHeight, -- top-left corner of the frame
                frameWidth, frameHeight,         -- size of the frame
                imageWidth, imageHeight          -- total size of sprite sheet
            )
            table.insert(self.frames, quad)
        end
    end

    -- Optional: track last drawn position for culling optimization
    self.lastScreenX = nil
    self.lastScreenY = nil

    return self
end

--- Updates the animation logic. Call this in love.update(dt)
-- @param dt: Delta time since last frame
-- @param x, y: Optional current screen position for culling
function Animation:update(dt, x, y)
    -- Skip update if animation is paused
    if not self.playing then return end

    --[[ 
        Culling optimization:
        If x and y are provided, skip updating the animation
        if the sprite is completely outside the screen boundaries.
        This reduces CPU usage when there are many off-screen sprites.
    --]]
    if x and y then
        local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
        if x + self.frameWidth < 0 or x > screenW or y + self.frameHeight < 0 or y > screenH then
            return -- skip update
        end
    end

    -- Advance timer by delta time
    self.timer = self.timer + dt

    -- Check if it's time to move to the next frame
    if self.timer >= self.frameDuration then
        self.timer = self.timer - self.frameDuration
        self.currentFrame = self.currentFrame + 1

        -- Handle looping and stopping at the last frame
        if self.currentFrame > #self.frames then
            if self.doLoop then
                self.currentFrame = 1 -- loop back to first frame
            else
                self.currentFrame = #self.frames -- stop at last frame
                self.playing = false
            end
        end
    end
end

--- Draws the current frame to the screen. Call this in love.draw()
-- @param x, y: Position to draw the sprite
-- @param r: Optional rotation (default 0)
-- @param sx, sy: Optional scale factors (default 1)
function Animation:draw(x, y, r, sx, sy)
    -- Default scale to 1 if not provided
    sx, sy = sx or 1, sy or 1

    -- Culling optimization:
    -- Skip drawing if the sprite is completely off-screen
    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
    if x + self.frameWidth * sx < 0 or x > screenW or y + self.frameHeight * sy < 0 or y > screenH then
        return
    end

    -- Draw the current frame
    love.graphics.draw(
        self.spriteSheet,
        self.frames[self.currentFrame],
        x, y,
        r or 0,
        sx, sy
    )
end

--[[ Control Methods ]]--

--- Resume animation playback
function Animation:play()
    self.playing = true
end

--- Pause animation playback
function Animation:pause()
    self.playing = false
end

--- Stop animation and reset to first frame
function Animation:stop()
    self.playing = false
    self.currentFrame = 1
end

--- Manually set current animation frame
-- @param n: Frame index (1-based)
function Animation:setFrame(n)
    if n >= 1 and n <= #self.frames then
        self.currentFrame = n
        self.timer = 0 -- reset timer to avoid instant frame skip
    end
end

return Animation
