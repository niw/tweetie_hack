#import "TweetieHack.h"
#import "MethodSwizzle.h"

#define MAX_NO_OF_NOTIFIED_STATUS 5
#define MAX_NO_OF_UNNOTIFIED_NAMES 10

#pragma mark -

@implementation TweetieAppDelegate(TweetieHack)
- (void)notifyGrowlWithStatuses:(NSArray *)statuses title:(NSString *)title notificationName:(NSString *)notificationName {
	// Disable default Growl notifications for Timeline and Mentions
}

- (void)swizzled_notifyOfNewTimelineStatuses:(NSNotification *)notification {
	NSLog(@"timeline:%@", notification);
	[TweetieHack growl:[notification object]
	   messageSelector:@selector(text)
		  userSelector:@selector(fromUser)
			moreFormat:@"%d more tweets"
	  notificationName:@"Timeline"];
	[self swizzled_notifyOfNewTimelineStatuses:notification];
}

- (void)swizzled_notifyOfNewMentionStatuses:(NSNotification *)notification {
	NSLog(@"mention:%@", notification);
	[TweetieHack growl:[notification object]
	   messageSelector:@selector(text)
		  userSelector:@selector(fromUser)
			moreFormat:@"%d more mentions"
	  notificationName:@"Mentions"];
	[self swizzled_notifyOfNewMentionStatuses:notification];
}

- (void)swizzled_notifyOfNewMessages:(NSNotification *)notification {
	NSLog(@"message:%@", notification);
	[TweetieHack growl:[notification object]
	   messageSelector:@selector(text)
		  userSelector:@selector(sender)
			moreFormat:@"%d more direct messages"
	  notificationName:@"Direct Message"];
	// Disable default Growl notification for direct messages
	//[self swizzled_notifyOfNewMessages:notification];
}
@end

#pragma mark -

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
	if(MethodSwizzle(NSClassFromString(@"TweetieAppDelegate"), @selector(notifyOfNewTimelineStatuses:), @selector(swizzled_notifyOfNewTimelineStatuses:))
	   && MethodSwizzle(NSClassFromString(@"TweetieAppDelegate"), @selector(notifyOfNewMentionStatuses:), @selector(swizzled_notifyOfNewMentionStatuses:))
	   && MethodSwizzle(NSClassFromString(@"TweetieAppDelegate"), @selector(notifyOfNewMessages:), @selector(swizzled_notifyOfNewMessages:))) {
		NSLog(@"TweetieHack installed");
	}
}
@end