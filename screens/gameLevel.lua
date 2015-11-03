--screens.gameLevel

local composer = require ("composer")       -- Include the Composer library. Please refer to -> http://docs.coronalabs.com/api/library/composer/index.html
local scene = composer.newScene()           -- Created a new scene

local mainGroup         -- Our main display group. We will add display elements to this group so Composer will handle these elements for us.
-- For more information about groups, please refer to this guide -> http://docs.coronalabs.com/guide/graphics/group.html
local tank1
local isTank1Moving = false
local tank1Direction = ""
local tank1Rotation = 0
local speed = 4
local pretty = require("pl.pretty")


-- when dusk image object created
function onImageObjectCreate (object, objectData)
    if objectData.transfer._type == "wall" or objectData.transfer._type == "enemy" then
        physics.addBody(object, "static")
    end
end

local dusk = require("Dusk.Dusk")
dusk.setPreference("scaleCameraBoundsToScreen", true)
dusk.setPreference("styleImageObject", onImageObjectCreate )

local physics = require("physics")
physics.start()
physics.setGravity(0, 0)

local variableText = composer.getVariable( "variableString" )		-- Get the variable "variableString" defined in main.lua
local fontSize = composer.getVariable( "fontSize" )		-- Get the variable "fontSize" defined in main.lua


local nameDev		-- Forward reference to nameDev
local loopCount	= 0		-- Initialize loopCount



local function changeText()
	if ( loopCount == 120 ) then
		nameDev.text = "Corona SDK"		-- Access the text of nameDev object and change it.
	elseif ( loopCount == 240 ) then
		nameDev.text = "Empty Project Template"		-- Access the text of nameDev object and change it.
	elseif ( loopCount == 360 ) then
		nameDev.text = "By Serkan Aksit"		-- Access the text of nameDev object and change it.
		loopCount = 0
	end

	loopCount = loopCount + 1 		-- Increment the loop count
end


local function changeScene(event)
	if ( event.phase == "began" ) then
		print "event began"
	elseif ( event.phase == "moved" ) then
		print "event moved"
    elseif ( event.phase == "ended" or event.phase == "cancelled" ) then 		-- Check if the tap ended or cancelled
    	print "event ended"
    	

    	-- Define a variable <varName> to nameDev object for further access to transition. You can name it anything.
    	-- This function will cause nameDev to change its X position and its alpha value in 1500 ms. 
    	-- After it's done, onComplete will be called and it will change scene.
    	-- For more information about transitions, please refer to the following documents
    	-- http://docs.coronalabs.com/api/library/transition/index.html
    	-- http://docs.coronalabs.com/guide/media/transitionLib/index.html 
    	nameDev.trans = transition.to( nameDev, {time = 1500, alpha = 0, x = 0, onComplete = function ()
    			composer.gotoScene( "screens.mainMenu", "crossFade", 1000 )
    		end} )
    end
    return true 		-- To prevent more than one click

    -- For more information about events, please refer to the following documents
    -- http://docs.coronalabs.com/api/event/index.html
    -- http://docs.coronalabs.com/guide/index.html#events-and-listeners
end

local function cleanUp()
	-- Remove the Runtime event listener manually. Corona SDK doesn't handle Runtime listeners automatically.
	-- If not handled, it will probably throw out an error or show some unexpected behavior
	Runtime:removeEventListener(changeText)

	-- Corona SDK will remove the listeners that are attached to objects if the object is destroyed.

	-- Remove the transition manually.
	-- if ( nameDev.trans ) then
	transition.cancel( nameDev.trans )
	nameDev.trans = nil
	-- end
	-- If you are not sure if the nameDev.trans exists or want to take a defensive approach, you can check it with if clause
end

-- Collision listener
function onCollision (event)
    if event.phase == "began" then
        print("hit")
    elseif event.phase == "ended" then
        print("left")
    end

    print(event.object1._type)
    print(event.object2._type)

    if event.object1._type == "enemy" then
        display.remove(event.object1)
    elseif event.object2._type == "enemy" then
        display.remove(event.object2)
    end
end

-- Key listener
function onKeyEvent( event )
    local phase = event.phase
    local keyName = event.keyName
    print("("..phase.." , " .. keyName ..")")
    if keyName == "up" or keyName == "down" or keyName == "left" or keyName == "right" then
        if phase == "up" then
            isTank1Moving = false
        elseif phase == "down" then
            print(keyName)
            isTank1Moving = true
            tank1Direction = keyName
            if keyName == "up" then
                tank1Rotation = 180
            elseif keyName == "down" then
                tank1Rotation = 0
            elseif keyName == "right" then
                tank1Rotation = 270
            elseif keyName == "left" then
                tank1Rotation = 90
            end
            tank1.rotation = tank1Rotation
        end
    end

    return true
 end

function onFrameEnter( event )
    if isTank1Moving then
        if tank1Direction == "up" then
            if tank1.y > 0 + (tank1.height * 0.5) then
                tank1.y = tank1.y - speed
            end
        elseif tank1Direction == "down" then
            if tank1.y < map.data.height - (tank1.height * 0.5) then
                tank1.y = tank1.y + speed
            end
        elseif tank1Direction == "right" then
            if tank1.x < map.data.width - (tank1.width * 0.5) then
                tank1.x = tank1.x + speed
            end
        elseif tank1Direction == "left" then
            if tank1.x > 0 + (tank1.width * 0.5) then
                tank1.x = tank1.x - speed
            end
        end
    end

    map.updateView()
end



function scene:create( event )
    local mainGroup = self.view         -- We've initialized our mainGroup. This is a MUST for Composer library.

    tank1 = display.newImage( "assets/tank1.png")       -- Create a new image, logo.png (900px x 285px) from the assets folder. Default anchor point is center.
    tank1.x = display.contentCenterX       -- Assign the x value of the image to the center of the X axis.
    tank1.y = display.contentCenterY      -- Assign the y value of the image.

    map = dusk.buildMap("level_tilesets/levels.json")
    map.x = 0
    map.y = 0
    map.setCameraBounds( {  xMin = 0 + (display.contentWidth * 0.5), 
                            xMax = map.data.width - (display.contentWidth * 0.5), 
                            yMin = 0+ (display.contentHeight * 0.5), 
                            yMax = map.data.height - (display.contentHeight * 0.5) } )
    -- map.x = display.contentCenterX - (display.actualContentWidth/2)
    -- map.y = display.contentCenterY  - (display.actualContentHeight/2)
    map:scale(1, 1)
    map.updateView()
    -- print(pretty.write(object_layer.visible))
    local object_layer = map.layer["objects"]
    local tile_layer = map.layer["level1"]





    object_layer:insert(tank1)


    physics.addBody(tank1, "dynamic")

    -- Set up map camera
    map.setCameraFocus(tank1)
    map.setTrackingLevel(0.05)

    
end


function scene:show( event )
    local phase = event.phase

    if ( phase == "will" ) then         -- Scene is not shown entirely

    elseif ( phase == "did" ) then      -- Scene is fully shown on the screen
    	    -- Add the key callback
        Runtime:addEventListener( "key", onKeyEvent );
        Runtime:addEventListener( "enterFrame", onFrameEnter )
        Runtime:addEventListener( "collision", onCollision )
    end
end


function scene:hide( event )
    local phase = event.phase

    if ( phase == "will" ) then         -- Scene is not off the screen entirely

        cleanUp()       -- Clean up the scene from timers, transitions, listeners

    elseif ( phase == "did" ) then      -- Scene is off the screen

    end
end

function scene:destroy( event )
    -- Called before the scene is removed
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene

-- You can refer to the official Composer template for more -> http://docs.coronalabs.com/api/library/composer/index.html#template