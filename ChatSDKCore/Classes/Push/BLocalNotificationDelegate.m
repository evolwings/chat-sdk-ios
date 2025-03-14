//
//  BLocalNotificationDelegate.m
//  ChatSDKSwift
//
//  Created by Ben on 4/19/18.
//  Copyright © 2018 deluge. All rights reserved.
//

#import "BLocalNotificationDelegate.h"

#import <ChatSDK/Core.h>

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

@implementation BLocalNotificationDelegate

// The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    
    BOOL showLocalNotification = BChatSDK.config.showLocalNotifications;
    
    NSDictionary * userInfo = notification.request.content.userInfo;
    NSString * threadEntityID = userInfo[bPushThreadEntityID];
    if (threadEntityID) {
        id<PThread> thread = [BChatSDK.db fetchEntityWithID:threadEntityID withType:bThreadEntity];
        if (thread) {
            showLocalNotification = [BChatSDK.ui showLocalNotification:thread];

            // Check if we show notifications for public threads
            if (thread.type.intValue & bThreadFilterPublic) {
                showLocalNotification = showLocalNotification && BChatSDK.config.showLocalNotificationsForPublicChats;
            }
            
            // Check if the thread is muted
            showLocalNotification = showLocalNotification && !thread.meta[bMute];
        } else {
            showLocalNotification = NO;
        }
        
    }
    
    NSLog(@"showLocalNotification = %d", showLocalNotification);
    if (showLocalNotification) {
        completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
    }
}

// The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler  {
    NSDictionary * userInfo = [NSMutableDictionary dictionaryWithDictionary:response.notification.request.content.userInfo];

    if ([response.actionIdentifier isEqualToString:bChatSDKReplyAction]) {
        if ([response isKindOfClass:[UNTextInputNotificationResponse class]]) {
            UNTextInputNotificationResponse * inputResponse = (UNTextInputNotificationResponse *) response;
            NSString * text = inputResponse.userText;
            NSString * threadEntityID = userInfo[bPushThreadEntityID];
            
            if (threadEntityID && text) {

                UIBackgroundTaskIdentifier taskIndentifier = UIBackgroundTaskInvalid;
                taskIndentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                    [[UIApplication sharedApplication] endBackgroundTask:taskIndentifier];
                }];
                [BChatSDK.thread sendMessageWithText:text withThreadEntityID:threadEntityID].then(^id(id result) {
                    [[UIApplication sharedApplication] endBackgroundTask:taskIndentifier];
                    return Nil;
                }, ^id(NSError * error) {
                    [[UIApplication sharedApplication] endBackgroundTask:taskIndentifier];
                    return Nil;
                });
            }
        }
    }
//    else {
//        [BChatSDK application:[UIApplication sharedApplication] didReceiveRemoteNotification:userInfo];
//    }

    completionHandler();
}

@end

#endif
