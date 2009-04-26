#import "TweetieHack.h"
#import "MethodSwizzle.h"

#define MAX_NO_OF_NOTIFIED_STATUS 5

@implementation TwitterAccount(TweetieHack)
- (void)swizzled_somethingDidUpdate:(NSNotification*)something {
	NSLog(@"somethingDidUpdate:%@", something);
	if([[something name] isEqualToString:@"TwitterStreamDidUpdateNotification"]) {
		TwitterAccountStream* accountStream = [something object];
		NSArray *statuses = [accountStream statuses];
		NSUInteger newestIndex = [statuses indexOfObject:[accountStream newestStatus]];
		for(NSUInteger i=newestIndex; i<MAX_NO_OF_NOTIFIED_STATUS && i<[statuses count]; i++) {
			TwitterStatus *status = [statuses objectAtIndex:i];
			if([status statusID] && ![status wasSeen]) {
				TwitterUser *fromUser = [status fromUser];
				NSData *iconData = nil;
				NSURL *url = [fromUser profileImageURL];
				if(url) {
					iconData = [[NSData alloc] initWithContentsOfURL:url];
				}
				[GrowlApplicationBridge notifyWithTitle:[fromUser username]
											description:[status text]
									   notificationName:[[accountStream className] isEqualToString:@"TwitterRepliesStream"] ? @"Replies" : @"Timeline"
											   iconData:iconData
											   priority:0
											   isSticky:NO
										   clickContext:nil];
				[status setWasSeen:YES];
			}
		}
	}

	[self swizzled_somethingDidUpdate:something];
}
@end

@implementation NSApplication(TweetieHack)
- (NSDictionary *)registrationDictionaryForGrowl {
	NSLog(@"registrationDictionaryForGrowl");
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSArray arrayWithObjects:@"Timeline", @"Replies", nil], GROWL_NOTIFICATIONS_ALL,
			[NSArray arrayWithObjects:@"Timeline", @"Replies", nil], GROWL_NOTIFICATIONS_DEFAULT, nil];
}
@end

@implementation TweetieHack
+ (void)load {
	NSApplication *app = [NSApplication sharedApplication];
	NSBundle *appBundle = [NSBundle bundleForClass:[app class]];
	NSString *growlPath = [[appBundle privateFrameworksPath] stringByAppendingPathComponent:@"Growl.framework"];
	NSBundle *growlBundle = [NSBundle bundleWithPath:growlPath];
	if (growlBundle && [growlBundle load]) {
		objc_msgSend([GrowlApplicationBridge class], @selector(setGrowlDelegate:), app);
	} else {
		NSLog(@"Could not load Growl.framework");
	}

	if(MethodSwizzle(NSClassFromString(@"TwitterAccount"), @selector(somethingDidUpdate:), @selector(swizzled_somethingDidUpdate:))) {
		NSLog(@"TweetieHack installed");
	}
}
@end