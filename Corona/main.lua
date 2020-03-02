-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- 

local json = require "json"
local inspect = require "inspect"
local SibcheStoreKit = require "sibche.wrapper"

SibcheStoreKit.init("wnl6qrLmgNadY3kK3MWz5QkAo7OEXe", "testapp")

local function loginCallback( event )
    print(inspect(event))
end

local function logoutCallback( event )
    print(inspect(event))
end

local function fetchInAppPurchasePackagesCallback( event )
    print(inspect(event))
end

local function fetchInAppPurchasePackageCallback( event )
    print(inspect(event))
end

local function fetchActiveInAppPurchasePackagesCallback( event )
    print(inspect(event))
end

local function consumePurchasePackageCallback( event )
    print(inspect(event))
end

local function purchasePackageCallback( event )
    print(inspect(event))
    if(event.isSuccessful and event.purchasePackage) then
        if(event.purchasePackage.package.type == "ConsumableInAppPackage") then
            SibcheStoreKit.consumePurchasePackage(event.purchasePackage.purchasePackageId, consumePurchasePackageCallback)
        end
    end
end

local function getCurrentUserCallback( event )
    print(inspect(event))
end

-- timer.performWithDelay( 100, function()
--     SibcheStoreKit.logoutUser(logoutCallback);
-- end )

-- timer.performWithDelay( 1000, function()
--     SibcheStoreKit.loginUser(loginCallback);
-- end )

-- timer.performWithDelay( 1000, function()
--     SibcheStoreKit.fetchInAppPurchasePackages(fetchInAppPurchasePackagesCallback)
-- end )

-- timer.performWithDelay( 2000, function()
--     SibcheStoreKit.fetchInAppPurchasePackage("1", fetchInAppPurchasePackageCallback)
-- end )


-- timer.performWithDelay( 3000, function()
--     SibcheStoreKit.fetchActiveInAppPurchasePackages(fetchActiveInAppPurchasePackagesCallback)
-- end )

timer.performWithDelay( 3000, function()
    SibcheStoreKit.purchasePackage("1", purchasePackageCallback)
end )

timer.performWithDelay( 1000, function()
    SibcheStoreKit.getCurrentUserData(getCurrentUserCallback)
end )

local tapCount = 0

display.setStatusBar( display.HiddenStatusBar )

local background = display.newImageRect( "background.png", 360, 570 )
background.x = display.contentCenterX
background.y = display.contentCenterY

local tapText = display.newText( tapCount, display.contentCenterX, 20, native.systemFont, 40 )
tapText:setFillColor( 0, 0, 0 )

local platform = display.newImageRect( "platform.png", 300, 50 )
platform.x = display.contentCenterX
platform.y = display.contentHeight-25

local balloon = display.newImageRect( "balloon.png", 112, 112 )
balloon.x = display.contentCenterX
balloon.y = display.contentCenterY
balloon.alpha = 0.8

local physics = require( "physics" )
physics.start()
physics.addBody( platform, "static" )
physics.addBody( balloon, "dynamic", { radius=50, bounce=0.3 } )

local function pushBalloon()
    balloon:applyLinearImpulse( 0, -0.75, balloon.x, balloon.y )
    tapCount = tapCount + 1
    tapText.text = tapCount
end

balloon:addEventListener( "tap", pushBalloon )
