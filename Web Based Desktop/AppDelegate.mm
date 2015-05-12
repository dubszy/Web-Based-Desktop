#import "AppDelegate.h"
#import <Carbon/Carbon.h>
#import <WebKit/WebKit.h>

@interface AppDelegate ()

@property (nonatomic, strong) NSWindow *window;	// Main window for the application
@property (nonatomic, strong) WebView *webView;	// The webview where pages get loaded

@end

@implementation AppDelegate

// 'self' is not available in C, but 'self' is of type 'id', so we create a reference to it
// so we can call Objective-C methods from inside C code
id selfRef;
// A check to find out if the application is currently visible
static bool isShowing;

- (id)init
{
	self = [super init];
	selfRef = self;
	return self;
}

/**
 *	Listens for a hot-key combination to be pressed.
 *	When the correct hot-key combination has been pressed, this application is brought to the front.
 *
 *	@todo Add functionality to find all open windows, hide them properly, and unhide them when finished.
 */
OSStatus HotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
	if (!isShowing) {
		[[NSWorkspace sharedWorkspace] hideOtherApplications];
		isShowing = true;
	}
	else
		isShowing = false;
	
	return noErr;
}

/**
 *	Called when the application starts.
 */
- (void)awakeFromNib
{
	EventHotKeyRef globalHotKeyRef;
	EventHotKeyID  globalHotKeyID;
	EventTypeSpec  eventType;
	eventType.eventClass = kEventClassKeyboard;
	eventType.eventKind  = kEventHotKeyPressed;
	
	// Register the function HotKeyHandler as an event handler for the application
	InstallApplicationEventHandler(&HotKeyHandler, 1, &eventType, NULL, NULL);
	// Assign the hot-key ID a signiture and an ID
	globalHotKeyID.signature = 'htk1';
	globalHotKeyID.id = 1;
	// Register for the hot-key combination we want to listen for (Command+Option+Space).
	RegisterEventHotKey(kVK_Space, cmdKey+optionKey, globalHotKeyID, GetApplicationEventTarget(), 0, &globalHotKeyRef);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Get the primary screen
	NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
	// Set the window to the size of the screen minus 22 (for the menu bar), and to be a borderless window
	self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, screen.frame.size.width, screen.frame.size.height-22) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO screen:screen];
	[self.window setBackgroundColor:[NSColor clearColor]];	// Set the window to have a transparent background color
	[self.window makeKeyAndOrderFront:self.window];			// Order the window to the front and make it the key window
	[self.window setLevel:-1];								// Set the window to the lowest level possible (just above the desktop level)
	[self.window setOpaque:NO];		// Make sure the window is transparent
	
	// Initialize an URL request with a specified URL to download
	NSURL *url = [NSURL URLWithString:@"http://dubszy.local/wbd/index.php"];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	// Set the size of the web view to be the size of the window and to be at (0, 0)
	self.webView = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
	// Load the web request into the web view
	[self.webView.mainFrame loadRequest:request];
	/* Add the web view to the window.
	 *	Make sure this is done AFTER loading the web request,
	 *	so as to make sure the webpage is entirely loaded and
	 *	everything is laid out correctly
	 */
	[self.window.contentView addSubview:self.webView];
	// Set the webview to not draw its background, so the transparency of the window and web view are not covered by a white background
	[self.webView setDrawsBackground:NO];
}

@end
