//
//  JXNotificationCenter.m
//  JXToolKit
//
//  Created by admin on 16/7/12.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "JXNotificationCenter.h"
#import <objc/runtime.h>

#if !__has_feature(objc_arc) || !__has_feature(objc_arc_weak)
#error This class requires automatic reference counting and weak references
#endif


typedef void (^JXNotificationBlock)(NSNotification *note, id observer);


static NSMutableArray *JXNotificationsGetObservers(id object, BOOL create)
{
    @synchronized(object)
    {
        static void *key = &key;
        NSMutableArray *wrappers = objc_getAssociatedObject(object, key);
        if (!wrappers && create)
        {
            wrappers = [NSMutableArray array];
            objc_setAssociatedObject(object, key, wrappers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        return wrappers;
    }
}

@interface JXNotificationObserver : NSObject

@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, weak) NSObject *object;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) JXNotificationBlock block;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, weak) NSNotificationCenter *center;

- (void)action:(NSNotification *)note;

@end


@implementation JXNotificationObserver

- (void)action:(NSNotification *)note
{
    __strong id strongObserver = self.observer;
    if (self.block && strongObserver)
    {
        if (!self.queue || [NSOperationQueue currentQueue] == self.queue)
        {
            self.block(note, strongObserver);
        }
        else
        {
            [self.queue addOperationWithBlock:^{
                self.block(note, strongObserver);
            }];
        }
    }
}

- (void)dealloc
{
    __strong NSNotificationCenter *strongCenter = _center;
    [strongCenter removeObserver:self];
}

@end

@implementation JXNotificationCenter

+ (JXNotificationCenter *)defaultCenter {
    static dispatch_once_t onceToken;
    static JXNotificationCenter * storeManagerSharedInstance;
    
    dispatch_once(&onceToken, ^{
        storeManagerSharedInstance = [[JXNotificationCenter alloc] init];
    });
    return storeManagerSharedInstance;
}

- (id)addObserver:(id)observer
          forName:(nullable NSString *)name
           object:(nullable id)object
            queue:(nullable NSOperationQueue *)queue
       usingBlock:(void (^)(NSNotification *note, id observer))block {
    
    JXNotificationObserver *container = [[JXNotificationObserver alloc] init];
    container.observer = observer;
    container.object = object;
    container.name = name;
    container.block = block;
    container.queue = queue;
    container.center = [NSNotificationCenter defaultCenter];
    
    JXNotificationsGetObservers(observer, YES);
    
    if (![self isExistObserver:observer name:name]) {
        [JXNotificationsGetObservers(observer, NO) addObject:container];
        [[NSNotificationCenter defaultCenter] addObserver:container selector:@selector(action:) name:name object:object];
    }
  
    return container;
}

- (void)postNotificationName:(nonnull NSString *)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:aName object:anObject userInfo:aUserInfo];
}

- (void)removeObserver:(nonnull id)observer {
    for (JXNotificationObserver *container in [JXNotificationsGetObservers(observer, NO) reverseObjectEnumerator])
    {
       [JXNotificationsGetObservers(observer, NO) removeObject:container];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

- (void)removeObserver:(nonnull id)observer name:(nullable NSString *)aName object:(nullable id)anObject {
    
    for (JXNotificationObserver *container in [JXNotificationsGetObservers(observer, NO) reverseObjectEnumerator])
    {
        __strong id strongObject = container.object;
        if ((!container.name || !aName || [container.name isEqualToString:aName]) &&
            (!strongObject || !anObject || strongObject == anObject))
        {
            [JXNotificationsGetObservers(observer, NO) removeObject:container];
        }
    }
    
    if (object_getClass(observer) == [JXNotificationObserver class])
    {
        JXNotificationObserver *container = observer;
        __strong NSObject *strongObserver = container.observer;
        [JXNotificationsGetObservers(strongObserver, NO) removeObject:container];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:aName object:anObject];
}

- (BOOL)isExistObserver:(id)observer  name:(NSString*)name {
    NSMutableArray * arry = JXNotificationsGetObservers(observer, NO);
    for (JXNotificationObserver *container in arry)
    {
        if ([container.observer isEqual:observer]&&[container.name isEqualToString:name]) {
            return YES;
        }
    }
    return NO;
}

@end
