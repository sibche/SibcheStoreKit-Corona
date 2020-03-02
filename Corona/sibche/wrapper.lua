local sibche = require "plugin.SibcheStoreKit"
local json = require "json"

local SibcheStoreKit = {}

--[[
This function is for initiation of application. This method should be called in
your main.lua file's first place
Parameters:
  apiKey: Key got from sibche developer portal
  scheme: Url scheme set specific for your application in info.plist (like tutorials)
Example: SibcheStoreKit.init("wnl6qrLmgNadY3kK3MWz5QkAo7OEXe", "testapp")
--]]
SibcheStoreKit.init = sibche.init


--[[
This function tries to login user with Sibche account. After successful/failed login,
we will call your provided callback method for result of login
Parameters:
  callback: Callback for when login finished/failed. The callback has these parameters
    event.isSuccessful (bool): Result of request
    event.errorCode (number): Code of faced error (if exist)
    event.errorStatusCode (number): HTTP status code of faced error (if exist)
    event.errorMessage (string): Error code message (if exist)
    event.userName (string): Name of user in our system (if given by user)
    event.userId (string): Internal Id of user in Sibche when logged in successfully
Example:
local function loginCallback(event)
   print(inspect(event))
end
SibcheStoreKit.loginUser(loginCallback)
--]]
SibcheStoreKit.loginUser = sibche.loginUser


--[[
This function is loggin out of user from sdk. Don't use this api without good reason
Parameters:
  callback: Callback for when logout finished. The callback has no parameters
Example: SibcheStoreKit.logoutUser(logoutCallback);
--]]
SibcheStoreKit.logoutUser = sibche.logoutUser


--[[
This function is for fetching all available packages which user can purchase
Parameters:
  callback: Callback for when fetch finished. The callback has these parameters
    event.isSuccessful (bool): Result of request
    event.errorCode (number): Code of faced error (if exist)
    event.errorStatusCode (number): HTTP status code of faced error (if exist)
    event.errorMessage (string): Error code message (if exist)
    event.packagesArray (table): Array of SibchePackage items
Example: SibcheStoreKit.fetchInAppPurchasePackages(fetchInAppPurchasePackagesCallback)
--]]
local function fetchInAppPurchasePackages(callback)
    local function newCallback(event)
        event.packagesArray = json.decode(event.packagesArray);
        callback(event)
    end
    sibche.fetchInAppPurchasePackages(newCallback)
end
SibcheStoreKit.fetchInAppPurchasePackages = fetchInAppPurchasePackages


--[[
This function is for fetching specific package with package id/code which user can purchase
Parameters:
  packageId: id/code of package which you want to get details of it
  callback: Callback for when fetch finished. The callback has these parameters
    event.isSuccessful (bool): Result of request
    event.errorCode (number): Code of faced error (if exist)
    event.errorStatusCode (number): HTTP status code of faced error (if exist)
    event.errorMessage (string): Error code message (if exist)
    event.package (table): Specific SibchePackage item which requested
Example: SibcheStoreKit.fetchInAppPurchasePackage("id", fetchInAppPurchasePackagesCallback)
--]]
local function fetchInAppPurchasePackage(packageId, callback)
    local function newCallback(event)
        event.package = json.decode(event.package);
        callback(event)
    end
    sibche.fetchInAppPurchasePackage(packageId, newCallback)
end
SibcheStoreKit.fetchInAppPurchasePackage = fetchInAppPurchasePackage


--[[
This function is for fetching active packages (SibchePurchasePackages) which user
purchased and active right now
Parameters:
  callback: Callback for when fetch finished. The callback has these parameters
    event.isSuccessful (bool): Result of request
    event.errorCode (number): Code of faced error (if exist)
    event.errorStatusCode (number): HTTP status code of faced error (if exist)
    event.errorMessage (string): Error code message (if exist)
    event.purchasePackagesArray (table): Array of SibchePurchasePackage items (active items)
Example: SibcheStoreKit.fetchActiveInAppPurchasePackages(fetchActiveInAppPurchasePackagesCallback)
--]]
local function fetchActiveInAppPurchasePackages(callback)
    local function newCallback(event)
        purchasePackagesArray = json.decode(event.purchasePackagesArray);
        for key, value in pairs(purchasePackagesArray) do
            value.package=json.decode(value.package)
        end
        event.purchasePackagesArray = purchasePackagesArray
        callback(event)
    end
    sibche.fetchActiveInAppPurchasePackages(newCallback)
end
SibcheStoreKit.fetchActiveInAppPurchasePackages = fetchActiveInAppPurchasePackages


--[[
This function is for request of purchase of packages
Parameters:
  packageId: id/code of package which you want to purchase
  callback: Callback for when fetch finished. The callback has these parameters
    event.isSuccessful (bool): Result of request
    event.errorCode (number): Code of faced error (if exist)
    event.errorStatusCode (number): HTTP status code of faced error (if exist)
    event.errorMessage (string): Error code message (if exist)
    event.purchasePackagesArray (table): Array of SibchePurchasePackage items (active items)
Example: SibcheStoreKit.purchasePackage("1", purchasePackageCallback)
--]]
local function purchasePackage(packageId, callback)
    local function newCallback(event)
        purchasePackage = json.decode(event.purchasePackage);
        purchasePackage.package=json.decode(purchasePackage.package)
        event.purchasePackage = purchasePackage
        callback(event)
    end
    sibche.purchasePackage(packageId, newCallback)
end
SibcheStoreKit.purchasePackage = purchasePackage


--[[
This function is for request of consuming of purchased packages
Parameters:
  purchasePackageId: id of purchased package (SibchePurchasePackage) which you want to consume
  callback: Callback for when fetch finished. The callback has these parameters
    event.isSuccessful (bool): Result of request
    event.errorCode (number): Code of faced error (if exist)
    event.errorStatusCode (number): HTTP status code of faced error (if exist)
    event.errorMessage (string): Error code message (if exist)
Example: SibcheStoreKit.consumePurchasePackage(event.purchasePackage.purchasePackageId, consumePurchasePackageCallback)
--]]
SibcheStoreKit.consumePurchasePackage = sibche.consumePurchasePackage


--[[
This function is for request of information for current user
Parameters:
  callback: Callback for when fetch finished. The callback has these parameters
    event.isSuccessful (bool): Result of request
    event.errorCode (number): Code of faced error (if exist)
    event.errorStatusCode (number): HTTP status code of faced error (if exist)
    event.errorMessage (string): Error code message (if exist)
    event.loginStatus (number): Status of user for login
    event.userCellphoneNumber (string): Cellphone of current user
    event.userId (string): Id of current user in Sibche system
Example: SibcheStoreKit.getCurrentUserData(getCurrentUserCallback)
--]]
SibcheStoreKit.getCurrentUserData = sibche.getCurrentUserData

local onSystemEvent = function(event)
    if(event.url) then
        sibche.openUrl(event.url)
    end
end
 
Runtime:addEventListener("system", onSystemEvent)

return SibcheStoreKit