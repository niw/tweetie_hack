#import "TweetieHack.h"
#import "MethodSwizzle.h"

#define MAX_NO_OF_NOTIFIED_STATUS 5

@implementation TwitterAccount(TweetieHack)
- (void)swizzled_somethingDidUpdate:(NSNotification*)something {
	if([[something name] isEqualToString:@"TwitterStreamDidUpdateNotification"]) {
		TwitterAccountStream* accountStream = [something object];
		NSString *notificationName = [[accountStream className] isEqualToString:@"TwitterRepliesStream"] ? @"Replies" : @"Timeline";
		NSArray *statuses = [accountStream statuses];
		NSUInteger newestIndex = [statuses indexOfObject:[accountStream newestStatus]];
		NSUInteger nNotified = 0, nUnSeen = 0;
		NSMutableArray *unSeenTweetsUserNames = [NSMutableArray arrayWithCapacity:10];
		for(NSUInteger i = newestIndex; i < [statuses count]; i++) {
			TwitterStatus *status = [statuses objectAtIndex:i];
			if([status statusID] && ![status wasSeen]) {
				if(nNotified < MAX_NO_OF_NOTIFIED_STATUS) {
					TwitterUser *fromUser = [status fromUser];
					NSData *iconData = nil;
					NSURL *url = [fromUser profileImageURL];
					if(url) {
						iconData = [[NSData alloc] initWithContentsOfURL:url];
					}
					[GrowlApplicationBridge notifyWithTitle:[fromUser username]
												description:[status text]
										   notificationName:notificationName
												   iconData:iconData
												   priority:0
												   isSticky:NO
											   clickContext:nil];
					nNotified++;
				} else {
					if(nUnSeen < 10) {
						[unSeenTweetsUserNames addObject:[[status fromUser] username]];
					}
					nUnSeen++;
				}
				[status setWasSeen:YES];
			}
		}
		if(nUnSeen) {
			[GrowlApplicationBridge notifyWithTitle:[NSString stringWithFormat:@"%d new tweets", nUnSeen]
										description:[unSeenTweetsUserNames componentsJoinedByString:@", "]
								   notificationName:notificationName
										   iconData:nil
										   priority:0
										   isSticky:NO
									   clickContext:nil];
		}
	}

	[self swizzled_somethingDidUpdate:something];
}
@end

@implementation NSApplication(TweetieHack)
- (NSDictionary *)registrationDictionaryForGrowl {
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