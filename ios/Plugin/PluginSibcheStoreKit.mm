#import "PluginSibcheStoreKit.h"

#include <CoronaRuntime.h>
#import <UIKit/UIKit.h>
//#import <SibcheStoreKit/SibcheStoreKit.h>

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
		CoronaLuaRef GetListener() const { return fListener; }

	public:
		static int Open( lua_State *L );

	protected:
		static int Finalizer( lua_State *L );

	public:
		static Self *ToLibrary( lua_State *L );

	public:
		static int init( lua_State *L );
		static int show( lua_State *L );

	private:
		CoronaLuaRef fListener;
};

// ----------------------------------------------------------------------------

// This corresponds to the name of the library, e.g. [Lua] require "plugin.library"
const char PluginSibcheStoreKit::kName[] = "plugin.SibcheStoreKit";

// This corresponds to the event name, e.g. [Lua] event.name
const char PluginSibcheStoreKit::kEvent[] = "SibcheStoreKitEvent";

PluginSibcheStoreKit::PluginSibcheStoreKit()
:    fListener( NULL )
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
        { "show", show },

        { NULL, NULL }
    };

    // Set library as upvalue for each library function
    Self *library = new Self;
    CoronaLuaPushUserdata( L, library, kMetatableName );

    luaL_openlib( L, kName, kVTable, 1 ); // leave "library" on top of stack

    return 1;
}

int
PluginSibcheStoreKit::Finalizer( lua_State *L )
{
    Self *library = (Self *)CoronaLuaToUserdata( L, 1 );

    CoronaLuaDeleteRef( L, library->GetListener() );

    delete library;

    return 0;
}

PluginSibcheStoreKit *
PluginSibcheStoreKit::ToLibrary( lua_State *L )
{
    // library is pushed as part of the closure
    Self *library = (Self *)CoronaLuaToUserdata( L, lua_upvalueindex( 1 ) );
    return library;
}

// [Lua] library.init( listener )

int
PluginSibcheStoreKit::init( lua_State *L )
{
    const char *apiKey = lua_tostring( L, 1 );
    const char *scheme = lua_tostring( L, 2 );
    if (!apiKey || !scheme) {
        return -1;
    }

//    [SibcheStoreKit initWithApiKey:[NSString stringWithCString:apiKey encoding:NSASCIIStringEncoding] withScheme:[NSString stringWithCString:scheme encoding:NSASCIIStringEncoding]];
	return 0;
}

int
PluginSibcheStoreKit::show( lua_State *L )
{
//    id<CoronaRuntime> runtime = (id<CoronaRuntime>)CoronaLuaGetContext( L );
//    // Present the controller modally.
//    [runtime.appViewController presentViewController:controller animated:YES completion:nil];

//        const char *word = lua_tostring( L, 1 );
//        if ( ! word )
//        {
//            word = kDefaultWord;
//        }
//
//        UIReferenceLibraryViewController *controller = [[[UIReferenceLibraryViewController alloc] initWithTerm:[NSString stringWithUTF8String:word]] autorelease];
//
//
//        message = @"Success. Displaying UIReferenceLibraryViewController for 'corona'.";
//    }
//
//    Self *library = ToLibrary( L );
//
//    // Create event and add message to it
//    CoronaLuaNewEvent( L, kEvent );
//    lua_pushstring( L, [message UTF8String] );
//    lua_setfield( L, -2, "message" );
//
//    // Dispatch event to library's listener
//    CoronaLuaDispatchEvent( L, library->GetListener(), 0 );

	return 0;
}

// ----------------------------------------------------------------------------

CORONA_EXPORT int luaopen_plugin_SibcheStoreKit( lua_State *L )
{
	return PluginSibcheStoreKit::Open( L );
}
