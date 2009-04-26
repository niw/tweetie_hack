#import <Cocoa/Cocoa.h>
#import <Growl/GrowlApplicationBridge.h>

@interface TwitterUser : NSObject {
}
- (NSString *)username;
- (NSURL *)profileImageURL;
@end

@interface TwitterStatus : NSObject {
}
- (TwitterUser *)fromUser;
- (NSString *)text;
- (NSString *)statusID;
- (BOOL)wasSeen;
- (void)setWasSeen:(BOOL)seen;
@end

@interface TwitterAccountStream : NSObject {
}
- (NSArray*)statuses;
- (TwitterStatus *)newestStatus;
@end

@interface TwitterAccount : NSObject {
}
@end

@interface TweetieHack : NSObject {
}
+ (void)load;
@end