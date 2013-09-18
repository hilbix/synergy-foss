/*
 * synergy -- mouse and keyboard sharing utility
 * Copyright (C) 2013 Bolton Software Ltd.
 *
 * This package is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * found in the file COPYING that should have accompanied this file.
 *
 * This package is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

#import "COSXDragSimulator.h"
#import "COSXDragView.h"
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Cocoa/Cocoa.h>

#if defined(MAC_OS_X_VERSION_10_7)

NSWindow* g_dragWindow = NULL;
COSXDragView* g_dragView = NULL;
NSApplication* g_app = NULL;

void
runCocoaApp()
{
	// HACK: sleep, carbon loop should start first.
	usleep(1000000);
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
    
	NSApplication* app = [[NSApplication alloc] init];
    g_app = app;
	
    NSWindow* window = [[NSWindow alloc]
						initWithContentRect: NSMakeRect(0, 0, 100, 4)
						styleMask: NSBorderlessWindowMask
						backing: NSBackingStoreBuffered
						defer: NO];
    [window setTitle: @""];
	[window setAlphaValue:0.1];
	[window makeKeyAndOrderFront:nil];
	
	COSXDragView* dragView = [[COSXDragView alloc] initWithFrame:NSMakeRect(0, 0, 100, 4)];
	
	g_dragWindow = window;
	g_dragView = dragView;
	[window setContentView: dragView];
	
	NSLog(@"starting cocoa loop");
	[app run];
	
	NSLog(@"cocoa: release");
	[pool release];
}

void
stopCocoaLoop()
{
	[g_app stop: g_dragWindow];
}

void
fakeDragging(const char* str, int length, int cursorX, int cursorY)
{
	dispatch_async(dispatch_get_main_queue(), ^{
	NSRect screen = [[NSScreen mainScreen] frame];
	NSLog ( @"screen size: witdh = %f height = %f", screen.size.width, screen.size.height);
	NSLog ( @"mouseLocation: %d %d", cursorX, cursorY);
		
	int newPosX = 0;
	int newPosY = 0;
	if (cursorX == 0) {
		newPosX = cursorX - 99;
	}
	else if (cursorX == screen.size.width - 1) {
		newPosX = cursorX - 1;
	}
	newPosY = screen.size.height - cursorY - 2;
	
	if (cursorY == 0) {
		newPosY = screen.size.height - 1;
		newPosX = cursorX - 50;
	}
	else if (cursorY == screen.size.height - 1) {
		newPosY = 1;
		newPosX = cursorX - 50;
	}
	
	NSRect rect = NSMakeRect(newPosX, newPosY, 100, 4);
	NSLog ( @"newPosX: %d", newPosX);
	NSLog ( @"newPosY: %d", newPosY);
		
	[g_dragWindow setFrame:rect display:NO];
	
	[g_dragWindow makeKeyAndOrderFront:nil];
		
	CGEventRef down = CGEventCreateMouseEvent(CGEventSourceCreate(kCGEventSourceStateHIDSystemState), kCGEventLeftMouseDown, CGPointMake(cursorX, cursorY), kCGMouseButtonLeft);
	CGEventPost(kCGHIDEventTap, down);
	});
}

CFStringRef
getCocoaDropTarget()
{
	return [g_dragView getDropTarget];
}

#endif
