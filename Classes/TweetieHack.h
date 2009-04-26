#import <Cocoa/Cocoa.h>
#import <Growl/GrowlApplicationBridge.h>

@interface TwitterUser : NSObject {
}
- (NSString *)username;
- (NSURL *)profileImageURL;
@end

@interface TwitterDirectMessage : NSObject {
}
- (TwitterUser *)sender;
- (NSString *)text;
@end

@interface TwitterStatus : NSObject {
}
- (TwitterUser *)fromUser;
- (NSString *)text;
@end

@interface TwitterConcreteStatusesStream : NSObject {
}
@end

@interface TwitterDirectMessagesStream : NSObject {
}
@end

@interface TweetieHack : NSObject {
}
+ (void)growl:(NSString *)message From:(TwitterUser *)user notificationName:(NSString *)notificationName;
+ (void)load;
@end