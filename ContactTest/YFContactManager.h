//
//  YFContactManager.h
//  ContactTest
//
//  Created by 陌南城 on 16/9/6.
//  Copyright © 2016年 陌南城. All rights reserved.

/*********/

#import <Foundation/Foundation.h>
extern NSString *const YFContactAccessAllowedNotification;//only received when asked for the first time and chose YES
extern NSString *const YFContactAccessDeniedNotification;//only received when asked for the first time and chose NO
extern NSString *const YFContactAccessFailedNotification;//only received when denied or restricted (not for the first time)

@interface YFContactManager : NSObject
+ (instancetype) manager;
@property (nonatomic, strong, readonly) NSArray *allPeople;

@end

@interface YFContactModel : NSObject
//只取了其中几个重要的参数
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *middleName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSArray *phoneNumbers;//NSString Collection

@end
