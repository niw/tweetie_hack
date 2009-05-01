#import "TweetieHack.h"
#import "MethodSwizzle.h"

#define MAX_NO_OF_NOTIFIED_STATUS 5
#define MAX_NO_OF_UNNOTIFIED_NAMES 10

@implementation TwitterConcreteStatusesStream(TweetieHack)
- (void)swizzled_addStatuses:(NSArray *)statuses {
	[TweetieHack growl:statuses
	   messageSelector:@selector(text)
		  userSelector:@selector(fromUser)
			moreFormat:@"%d more tweets"
	  notificationName:[[self className] isEqualToString:@"TwitterRepliesStream"] ? @"Replies" : @"Timeline"];

	return [self swizzled_addStatuses:statuses];
}
@end

@implementation TwitterDirectMessagesStream(TweetieHack)
- (void)swizzled_addMessages:(NSArray *)messages {
	[TweetieHack growl:messages
	   messageSelector:@selector(text)
		  userSelector:@selector(sender)
			moreFormat:@"%d more direct messages"
	  notificationName:@"Direct Message"];

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

+ (void)growl:(NSArray *)tweets messageSelector:(SEL)msgsel userSelector:(SEL)usersel moreFormat:(NSString *)moreFormat notificationName:(NSString *)notificationName {
	NSUInteger nNotified = 0, nUnNotified = 0;
	id lastTweet = nil;

	NSMutableArray *unNotifiedTweetsUserNames = [NSMutableArray arrayWithCapacity:MAX_NO_OF_UNNOTIFIED_NAMES];
	for(NSUInteger i = 0; i < [tweets count]; i++) {
		id tweet = [tweets objectAtIndex:i];
		TwitterUser *user = objc_msgSend(tweet, usersel);

		if(nNotified < MAX_NO_OF_NOTIFIED_STATUS) {
			[TweetieHack growl:objc_msgSend(tweet, msgsel) From:user notificationName:notificationName];
			nNotified++;
		} else {
			if(nUnNotified < MAX_NO_OF_UNNOTIFIED_NAMES) {
				[unNotifiedTweetsUserNames addObject:[user username]];
			}
			lastTweet = tweet;
			nUnNotified++;
		}
	}
	if(nUnNotified) {
		if(nUnNotified < 2 && lastTweet) {
			[TweetieHack growl:objc_msgSend(lastTweet, msgsel) From:objc_msgSend(lastTweet, usersel) notificationName:notificationName];
		} else {
			[GrowlApplicationBridge notifyWithTitle:[NSString stringWithFormat:moreFormat, nUnNotified]
										description:[unNotifiedTweetsUserNames componentsJoinedByString:@", "]
								   notificationName:notificationName
										   iconData:nil
										   priority:0
										   isSticky:NO
									   clickContext:nil];
		}
	}
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