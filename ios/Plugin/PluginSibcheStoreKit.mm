#import "PluginSibcheStoreKit.h"

#include <CoronaRuntime.h>
#import <UIKit/UIKit.h>

#import <SibcheStoreKit/SibcheStoreKit.h>

const char* getCString(NSString* text);
// ----------------------------------------------------------------------------

class PluginSibcheStoreKit
{
	public:
		typedef PluginSibcheStoreKit Self;

	public:
		static const char kName[];
		static const char kEvent[];

	protected:
		PluginSibcheStoreKit();

	public:
		bool Initialize( CoronaLuaRef listener );

	public:
		static int Open( lua_State *L );

	protected:
		static int Finalizer( lua_State *L );

	public:
		static Self *ToLibrary( lua_State *L );

	public:
        static int init( lua_State *L );
        static int openUrl( lua_State *L );
        static int loginUser( lua_State *L );
        static int logoutUser( lua_State *L );
        static int fetchInAppPurchasePackages( lua_State *L );
        static int fetchInAppPurchasePackage( lua_State *L );
        static int fetchActiveInAppPurchasePackages( lua_State *L );
        static int purchasePackage( lua_State *L );
        static int consumePurchasePackage( lua_State *L );
        static int getCurrentUserData( lua_State *L );

	private:
		CoronaLuaRef fListener;
};

// ----------------------------------------------------------------------------

const char PluginSibcheStoreKit::kName[] = "plugin.SibcheStoreKit";

const char PluginSibcheStoreKit::kEvent[] = "SibcheStoreKitEvent";

PluginSibcheStoreKit::PluginSibcheStoreKit()
:	fListener( NULL )
{
}

bool
PluginSibcheStoreKit::Initialize( CoronaLuaRef listener )
{
	// Can only initialize listener once
	bool result = ( NULL == fListener );

	if ( result )
	{
		fListener = listener;
	}

	return result;
}

int
PluginSibcheStoreKit::Open( lua_State *L )
{
	// Register __gc callback
	const char kMetatableName[] = __FILE__; // Globally unique string to prevent collision
	CoronaLuaInitializeGCMetatable( L, kMetatableName, Finalizer );

	// Functions in library
	const luaL_Reg kVTable[] =
	{
		{ "init", init },
        { "openUrl", openUrl },
        { "loginUser", loginUser },
        { "logoutUser", logoutUser },
        { "fetchInAppPurchasePackages", fetchInAppPurchasePackages },
        { "fetchInAppPurchasePackage", fetchInAppPurchasePackage },
        { "fetchActiveInAppPurchasePackages", fetchActiveInAppPurchasePackages },
        { "purchasePackage", purchasePackage },
        { "consumePurchasePackage", consumePurchasePackage },
        { "getCurrentUserData", getCurrentUserData },

		{ NULL, NULL }
	};

	Self *library = new Self;
	CoronaLuaPushUserdata( L, library, kMetatableName );

	luaL_openlib( L, kName, kVTable, 1 ); // leave "library" on top of stack

	return 1;
}

int
PluginSibcheStoreKit::Finalizer( lua_State *L )
{
	return 0;
}

PluginSibcheStoreKit *
PluginSibcheStoreKit::ToLibrary( lua_State *L )
{
	// library is pushed as part of the closure
	Self *library = (Self *)CoronaLuaToUserdata( L, lua_upvalueindex( 1 ) );
	return library;
}

int
PluginSibcheStoreKit::init( lua_State *L )
{
    const char *apiKey = lua_tostring( L, 1 );
    const char *scheme = lua_tostring( L, 2 );
    if (!apiKey || !scheme) {
        NSLog(@"Parameters of api does not filled correctly (init)");
        return -1;
    }
    
    [SibcheStoreKit initWithApiKey:[NSString stringWithCString:apiKey encoding:NSASCIIStringEncoding] withScheme:[NSString stringWithCString:scheme encoding:NSASCIIStringEncoding] withStore:@"SDK-CORONA"];
    
    return 0;
}

int
PluginSibcheStoreKit::openUrl( lua_State *L )
{
    const char *url = lua_tostring( L, 1 );
    if (!url) {
        NSLog(@"Parameters of api does not filled correctly (openUrl)");
        return 0;
    }

    [SibcheStoreKit openUrl:[NSURL URLWithString:[NSString stringWithCString:url encoding:NSASCIIStringEncoding]] options:nil];
    
    return 0;
}

int
PluginSibcheStoreKit::loginUser( lua_State *L )
{
    int listenerIndex = 1;
    if ( CoronaLuaIsListener( L, listenerIndex, kEvent ) )
    {
        CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );

        [SibcheStoreKit loginUser:^(BOOL isSuccessful, SibcheError *error, NSString *userName, NSString *userId) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CoronaLuaNewEvent( L, "SibcheStoreKit.loginUser" );
                
                lua_pushboolean(L, isSuccessful);
                lua_setfield(L, -2, "isSuccessful");
                
                if (error) {
                    lua_pushnumber(L, [error.errorCode doubleValue]);
                    lua_setfield(L, -2, "errorCode");

                    lua_pushnumber(L, [error.statusCode doubleValue]);
                    lua_setfield(L, -2, "errorStatusCode");

                    lua_pushstring(L, getCString(error.message));
                    lua_setfield(L, -2, "errorMessage");
                }
                
                lua_pushstring(L, getCString(userName));
                lua_setfield(L, -2, "userName");

                lua_pushstring(L, getCString(userId));
                lua_setfield(L, -2, "userId");

                CoronaLuaDispatchEvent( L, listener, 0 );

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    CoronaLuaDeleteRef(L, listener);
                });
            });
        }];
    }
    
    return 0;
}

int
PluginSibcheStoreKit::logoutUser( lua_State *L )
{
    int listenerIndex = 1;
    if ( CoronaLuaIsListener( L, listenerIndex, kEvent ) )
    {
        CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
        
        [SibcheStoreKit logoutUser:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                CoronaLuaNewEvent( L, "SibcheStoreKit.logoutUser" );
                CoronaLuaDispatchEvent( L, listener, 0 );
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    CoronaLuaDeleteRef(L, listener);
                });
            });
        }];
    }
    
    return 0;
}

int
PluginSibcheStoreKit::fetchInAppPurchasePackages( lua_State *L )
{
    int listenerIndex = 1;
    if ( CoronaLuaIsListener( L, listenerIndex, kEvent ) )
    {
        CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
        
        [SibcheStoreKit fetchInAppPurchasePackages:^(BOOL isSuccessful, SibcheError *error, NSArray *packagesArray) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CoronaLuaNewEvent( L, "SibcheStoreKit.fetchInAppPurchasePackages" );
                
                lua_pushboolean(L, isSuccessful);
                lua_setfield(L, -2, "isSuccessful");
                
                if (error) {
                    lua_pushnumber(L, [error.errorCode doubleValue]);
                    lua_setfield(L, -2, "errorCode");
                    
                    lua_pushnumber(L, [error.statusCode doubleValue]);
                    lua_setfield(L, -2, "errorStatusCode");
                    
                    lua_pushstring(L, getCString(error.message));
                    lua_setfield(L, -2, "errorMessage");
                }
                
                NSMutableString* jsonString = [[NSMutableString alloc] initWithString:@""];
                for (SibchePackage* item in packagesArray) {
                    [jsonString appendFormat:@"%@, ", [item toJson]];
                }
                jsonString = [NSMutableString stringWithFormat:@"[%@]", jsonString];

                lua_pushstring(L, getCString(jsonString));
                lua_setfield(L, -2, "packagesArray");

                CoronaLuaDispatchEvent( L, listener, 0 );
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    CoronaLuaDeleteRef(L, listener);
                });
            });
        }];
    }
    
    return 0;
}

int
PluginSibcheStoreKit::fetchInAppPurchasePackage( lua_State *L )
{
    int listenerIndex = 2;

    if ( CoronaLuaIsListener( L, listenerIndex, kEvent ) )
    {
        CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );

        const char *packageId = lua_tostring( L, 1 );
        if (!packageId)
        {
            NSLog(@"Parameters of api does not filled correctly (fetchInAppPurchasePackage)");
            return 0;
        }

        [SibcheStoreKit fetchInAppPurchasePackage:[NSString stringWithCString:packageId encoding:NSASCIIStringEncoding] withPackagesCallback:^(BOOL isSuccessful, SibcheError *error, SibchePackage *package) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CoronaLuaNewEvent( L, "SibcheStoreKit.fetchInAppPurchasePackage" );
                
                lua_pushboolean(L, isSuccessful);
                lua_setfield(L, -2, "isSuccessful");
                
                if (error) {
                    lua_pushnumber(L, [error.errorCode doubleValue]);
                    lua_setfield(L, -2, "errorCode");
                    
                    lua_pushnumber(L, [error.statusCode doubleValue]);
                    lua_setfield(L, -2, "errorStatusCode");
                    
                    lua_pushstring(L, getCString(error.message));
                    lua_setfield(L, -2, "errorMessage");
                }
                
                lua_pushstring(L, getCString([package toJson]));
                lua_setfield(L, -2, "package");
                
                CoronaLuaDispatchEvent( L, listener, 0 );
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    CoronaLuaDeleteRef(L, listener);
                });
            });
        }];
    }
    
    return 0;
}

int
PluginSibcheStoreKit::fetchActiveInAppPurchasePackages( lua_State *L )
{
    int listenerIndex = 1;
    if ( CoronaLuaIsListener( L, listenerIndex, kEvent ) )
    {
        CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
        
        [SibcheStoreKit fetchActiveInAppPurchasePackages:^(BOOL isSuccessful, SibcheError *error, NSArray *purchasePackagesArray) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CoronaLuaNewEvent( L, "SibcheStoreKit.fetchActiveInAppPurchasePackages" );
                
                lua_pushboolean(L, isSuccessful);
                lua_setfield(L, -2, "isSuccessful");
                
                if (error) {
                    lua_pushnumber(L, [error.errorCode doubleValue]);
                    lua_setfield(L, -2, "errorCode");
                    
                    lua_pushnumber(L, [error.statusCode doubleValue]);
                    lua_setfield(L, -2, "errorStatusCode");
                    
                    lua_pushstring(L, getCString(error.message));
                    lua_setfield(L, -2, "errorMessage");
                }
                
                NSMutableString* jsonString = [[NSMutableString alloc] initWithString:@""];
                for (SibchePurchasePackage* item in purchasePackagesArray) {
                    [jsonString appendFormat:@"%@, ", [item toJson]];
                }
                jsonString = [NSMutableString stringWithFormat:@"[%@]", jsonString];
                
                lua_pushstring(L, getCString(jsonString));
                lua_setfield(L, -2, "purchasePackagesArray");
                
                CoronaLuaDispatchEvent( L, listener, 0 );
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    CoronaLuaDeleteRef(L, listener);
                });
            });
        }];
    }
    
    return 0;
}

int
PluginSibcheStoreKit::purchasePackage( lua_State *L )
{
    int listenerIndex = 2;
    if ( CoronaLuaIsListener( L, listenerIndex, kEvent ) )
    {
        CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
        
        const char *packageId = lua_tostring( L, 1 );
        if (!packageId)
        {
            NSLog(@"Parameters of api does not filled correctly (purchasePackage)");
            return 0;
        }

        [SibcheStoreKit purchasePackage:[NSString stringWithCString:packageId encoding:NSASCIIStringEncoding] withCallback:^(BOOL isSuccessful, SibcheError *error, SibchePurchasePackage *purchasePackage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CoronaLuaNewEvent( L, "SibcheStoreKit.purchasePackage" );
                
                lua_pushboolean(L, isSuccessful);
                lua_setfield(L, -2, "isSuccessful");
                
                if (error) {
                    lua_pushnumber(L, [error.errorCode doubleValue]);
                    lua_setfield(L, -2, "errorCode");
                    
                    lua_pushnumber(L, [error.statusCode doubleValue]);
                    lua_setfield(L, -2, "errorStatusCode");
                    
                    lua_pushstring(L, getCString(error.message));
                    lua_setfield(L, -2, "errorMessage");
                }
                
                lua_pushstring(L, getCString([purchasePackage toJson]));
                lua_setfield(L, -2, "purchasePackage");
                
                CoronaLuaDispatchEvent( L, listener, 0 );
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    CoronaLuaDeleteRef(L, listener);
                });
            });
        }];
    }
    
    return 0;
}

int
PluginSibcheStoreKit::consumePurchasePackage( lua_State *L )
{
    int listenerIndex = 2;
    if ( CoronaLuaIsListener( L, listenerIndex, kEvent ) )
    {
        CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
        
        const char *purchasePackageId = lua_tostring( L, 1 );
        if (!purchasePackageId)
        {
            NSLog(@"Parameters of api does not filled correctly (consumePurchasePackage)");
            return 0;
        }
        
        [SibcheStoreKit consumePurchasePackage:[NSString stringWithCString:purchasePackageId encoding:NSASCIIStringEncoding] withCallback:^(BOOL isSuccessful, SibcheError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CoronaLuaNewEvent( L, "SibcheStoreKit.consumePurchasePackage" );
                
                lua_pushboolean(L, isSuccessful);
                lua_setfield(L, -2, "isSuccessful");
                
                if (error) {
                    lua_pushnumber(L, [error.errorCode doubleValue]);
                    lua_setfield(L, -2, "errorCode");
                    
                    lua_pushnumber(L, [error.statusCode doubleValue]);
                    lua_setfield(L, -2, "errorStatusCode");
                    
                    lua_pushstring(L, getCString(error.message));
                    lua_setfield(L, -2, "errorMessage");
                }

                CoronaLuaDispatchEvent( L, listener, 0 );
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    CoronaLuaDeleteRef(L, listener);
                });
            });
        }];
    }
    
    return 0;
}

int
PluginSibcheStoreKit::getCurrentUserData( lua_State *L )
{
    int listenerIndex = 1;
    if ( CoronaLuaIsListener( L, listenerIndex, kEvent ) )
    {
        CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
        
        [SibcheStoreKit getCurrentUserData:^(BOOL isSuccessful, SibcheError *error, LoginStatusType loginStatus, NSString *userCellphoneNumber, NSString *userId) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CoronaLuaNewEvent( L, "SibcheStoreKit.getCurrentUserData" );
                
                lua_pushboolean(L, isSuccessful);
                lua_setfield(L, -2, "isSuccessful");
                
                if (error) {
                    lua_pushnumber(L, [error.errorCode doubleValue]);
                    lua_setfield(L, -2, "errorCode");
                    
                    lua_pushnumber(L, [error.statusCode doubleValue]);
                    lua_setfield(L, -2, "errorStatusCode");
                    
                    lua_pushstring(L, getCString(error.message));
                    lua_setfield(L, -2, "errorMessage");
                }

                lua_pushnumber(L, loginStatus);
                lua_setfield(L, -2, "loginStatus");

                lua_pushstring(L, getCString(userCellphoneNumber));
                lua_setfield(L, -2, "userCellphoneNumber");

                lua_pushstring(L, getCString(userId));
                lua_setfield(L, -2, "userId");

                CoronaLuaDispatchEvent( L, listener, 0 );
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    CoronaLuaDeleteRef(L, listener);
                });
            });
        }];
    }
    
    return 0;
}

// ----------------------------------------------------------------------------

const char* getCString(NSString* text){
    if(!text)
        text = @"";
    return [text cStringUsingEncoding:NSUTF8StringEncoding];
}

CORONA_EXPORT int luaopen_plugin_SibcheStoreKit( lua_State *L )
{
	return PluginSibcheStoreKit::Open( L );
}
