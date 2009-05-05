#import <Cocoa/Cocoa.h>
#import <Growl/GrowlApplicationBridge.h>

@interface TwitterUser : NSObject {
}
- (NSString *)username;
- (NSURL *)profileImageURL;
@end

@interface TweetieAppDelegate : NSObject {
}
@end

#pragma mark -

@interface TweetieHack : NSObject {
}
+ (void)growl:(NSString *)message From:(TwitterUser *)user notificationName:(NSString *)notificationName;
+ (void)growl:(NSArray *)tweets messageSelector:(SEL)msgsel userSelector:(SEL)usersel moreFormat:(NSString *)moreFormat notificationName:(NSString *)notificationName;
+ (void)load;
@end