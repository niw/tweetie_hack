#import "TweetieHack.h"
#import "MethodSwizzle.h"

#define MAX_NO_OF_NOTIFIED_STATUS 5
#define MAX_NO_OF_UNNOTIFIED_NAMES 10

@implementation TwitterConcreteStatusesStream(TweetieHack)
- (void)swizzled_addStatuses:(NSArray *)statuses {
	NSString *notificationName = [[self className] isEqualToString:@"TwitterRepliesStream"] ? @"Replies" : @"Timeline";
	NSUInteger nNotified = 0, nUnNotified = 0;
	NSMutableArray *unNotifiedTweetsUserNames = [NSMutableArray arrayWithCapacity:MAX_NO_OF_UNNOTIFIED_NAMES];
	for(NSUInteger i = 0; i < [statuses count]; i++) {
		TwitterStatus *status = [statuses objectAtIndex:i];
		if(nNotified < MAX_NO_OF_NOTIFIED_STATUS) {
			[TweetieHack growl:[status text] From:[status fromUser] notificationName:notificationName];
			nNotified++;
		} else {
			if(nUnNotified < MAX_NO_OF_UNNOTIFIED_NAMES) {
				[unNotifiedTweetsUserNames addObject:[[status fromUser] username]];
			}
			nUnNotified++;
		}
	}
	if(nUnNotified) {
		NSString *format = @"%d new tweets";
		if(nUnNotified == 1) {
			format = @"%d new tweet";
		}
		[GrowlApplicationBridge notifyWithTitle:[NSString stringWithFormat:format, nUnNotified]
									description:[unNotifiedTweetsUserNames componentsJoinedByString:@", "]
							   notificationName:notificationName
									   iconData:nil
									   priority:0
									   isSticky:NO
								   clickContext:nil];
	}

	return [self swizzled_addStatuses:statuses];
}
@end

@implementation TwitterDirectMessagesStream(TweetieHack)
- (void)swizzled_addMessages:(NSArray *)messages {
	NSString *notificationName = @"Direct Message";
	NSUInteger nNotified = 0, nUnNotified = 0;
	NSMutableArray *unNotifiedTweetsUserNames = [NSMutableArray arrayWithCapacity:MAX_NO_OF_UNNOTIFIED_NAMES];
	for(NSUInteger i = 0; i < [messages count]; i++) {
		TwitterDirectMessage *message = [messages objectAtIndex:i];
		if(nNotified < MAX_NO_OF_NOTIFIED_STATUS) {
			[TweetieHack growl:[message text] From:[message sender] notificationName:notificationName];
			nNotified++;
		} else {
			if(nUnNotified < MAX_NO_OF_UNNOTIFIED_NAMES) {
				[unNotifiedTweetsUserNames addObject:[[message sender] username]];
			}
			nUnNotified++;
		}
	}
	if(nUnNotified) {
		NSString *format = @"%d new direct messages";
		if(nUnNotified == 1) {
			format = @"%d new direct message";
		}
		[GrowlApplicationBridge notifyWithTitle:[NSString stringWithFormat:format, nUnNotified]
									description:[unNotifiedTweetsUserNames componentsJoinedByString:@", "]
							   notificationName:notificationName
									   iconData:nil
									   priority:0
									   isSticky:NO
								   clickContext:nil];
	}

	return [self swizzled_addMessages:messages];
}
@end

@implementation NSApplication(TweetieHack)
- (NSDictionary *)registrationDictionaryForGrowl {
	return [NSDictionary dictionaryWithObjectsAndKeys:
		[NSArray arrayWithObjects:@"Timeline", @"Replies", @"Direct Message", nil], GROWL_NOTIFICATIONS_ALL,
		[NSArray arrayWithObjects:@"Timeline", @"Replies", @"Direct Message", nil], GROWL_NOTIFICATIONS_DEFAULT, nil];
}
@end

@implementation TweetieHack
+ (void)growl:(NSString *)message From:(TwitterUser *)user notificationName:(NSString *)notificationName {
	NSData *iconData = nil;
	NSURL *url = [user profileImageURL];
	if(url) {
		iconData = [NSData dataWithContentsOfURL:url];
	}
	[GrowlApplicationBridge notifyWithTitle:[user username]
								description:message
						   notificationName:notificationName
								   iconData:iconData
								   priority:0
								   isSticky:NO
							   clickContext:nil];
}

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

	if(MethodSwizzle(NSClassFromString(@"TwitterTimelineStream"), @selector(addStatuses:), @selector(swizzled_addStatuses:)) &&
	   MethodSwizzle(NSClassFromString(@"TwitterRepliesStream"), @selector(addStatuses:), @selector(swizzled_addStatuses:)) &&
	   MethodSwizzle(NSClassFromString(@"TwitterReceivedDirectMessagesStream"), @selector(addMessages:), @selector(swizzled_addMessages:))) {
		NSLog(@"TweetieHack installed");
	}
}
@end