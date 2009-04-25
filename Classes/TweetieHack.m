#import "TweetieHack.h"
#import "MethodSwizzle.h"

@implementation TweetieAppDelegate(TweetieHack)
- (void)swizzledNewTweetFromAccount:(id)account inReplyToStatus:(id)status defaultText:(id)text replyPointHint:(struct CGPoint *)hint {
	NSLog(@"newTweetFromAccount: %@ %@ %@", account, status, text);
	[self swizzledNewTweetFromAccount:account inReplyToStatus:status defaultText:text replyPointHint:hint];
}
@end

@implementation TweetieHack
+(void) load {
	if(MethodSwizzle(NSClassFromString(@"TweetieAppDelegate"),
					 @selector(newTweetFromAccount:inReplyToStatus:defaultText:replyPointHint:),
					 @selector(swizzledNewTweetFromAccount:inReplyToStatus:defaultText:replyPointHint:))) {
		NSLog(@"TweetieHack installed");
	}
}
@end