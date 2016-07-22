//
//  JXNotificationCenter.h
//  JXToolKit
//
//  Created by admin on 16/7/12.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JXNotificationCenter : NSObject

+ (nonnull JXNotificationCenter *)defaultCenter;

- (nonnull id)addObserver:(nonnull id)observer
          forName:(nullable NSString *)name
           object:(nullable id)object
            queue:(nullable NSOperationQueue *)queue
       usingBlock:(nullable void (^)( NSNotification *note,  id observer))block;

- (void)postNotificationName:(nonnull NSString *)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo;

- (void)removeObserver:(nonnull id)observer;

- (void)removeObserver:(nonnull id)observer name:(nullable NSString *)aName object:(nullable id)anObject;

@end
