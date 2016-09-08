//
//  YFContactManager.m
//  ContactTest
//
//  Created by 陌南城 on 16/9/6.
//  Copyright © 2016年 陌南城. All rights reserved.
//

#import "YFContactManager.h"
#import <AddressBookUI/AddressBookUI.h>

NSString *const YFContactAccessAllowedNotification = @"YFContactAccessAllowedNotification";//同意授权
NSString *const YFContactAccessDeniedNotification = @"YFContactAccessDeniedNotification";//拒绝授权
NSString *const YFContactAccessFailedNotification = @"YFContactAccessFailedNotification";//获取授权出错

@interface YFContactManager()
@property (nonatomic, strong) NSMutableArray *people;
@end
@implementation YFContactManager
+(instancetype)manager
{
    static YFContactManager *manager;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        manager = [[YFContactManager alloc]init];
        [manager loadAllPeople];
    });
    return manager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _people = [[NSMutableArray alloc]init];
    }
    return self;
}
- (void)loadAllPeople
{
    NSArray *statuses = @[@"kABAuthorizationStatusNotDetermined",@"kABAuthorizationStatusRestricted",@"kABAuthorizationStatusDenied",@"kABAuthorizationStatusAuthorized"];
    ABAuthorizationStatus status =ABAddressBookGetAuthorizationStatus();//启动时询问授权
    NSLog(@"ABAddressBookGetAuthorizationStatus = %@",statuses[status]);
    //打印当前授权情况
    if (status == kABAuthorizationStatusAuthorized){
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        [self copyAddressBook:addressBook];
        CFRelease(addressBook);
    } else if (status == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error){
            NSLog(@"granted:%d",granted);//granted表示当前授权情况
            if (granted) {
                CFErrorRef *error1 = NULL;
                ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error1);
                [self copyAddressBook:addressBook];
                CFRelease(addressBook);
                [YFContactManager postMainThreadNotification:YFContactAccessAllowedNotification];
            } else {
                [YFContactManager postMainThreadNotification:YFContactAccessDeniedNotification];
            }
        });
    }
    else {
        //        Restricted OR Denied
        [YFContactManager postMainThreadNotification:YFContactAccessFailedNotification];
    }
}

    


- (void)copyAddressBook:(ABAddressBookRef)addressBook
{
    [self.people removeAllObjects];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    for ( int i = 0; i < numberOfPeople; i++){
        //获取当前个人
        ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        //创建新模型
        YFContactModel *contact = [YFContactModel new];
        //中文名
        NSString *firstName = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        contact.firstName = firstName;
        //middleName
        NSString *middlename = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonMiddleNameProperty));
        contact.middleName = middlename;
        //中文姓氏
        NSString *lastName = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        contact.lastName = lastName;
        
        NSMutableArray *phones = [NSMutableArray array];
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (int k = 0; k<ABMultiValueGetCount(phone); k++)
        {
            NSString * personPhone = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(phone, k));
            [phones addObject:personPhone];
        }
        contact.phoneNumbers = phones.copy;
        CFRelease(phone);
        
        [self.people addObject:contact];
        
    }
    CFRelease(people);
#pragma clang diagnostic pop
}
+ (void)postMainThreadNotification:(NSString *)notificationName
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if ([NSThread isMainThread]) {
        [center postNotificationName:notificationName object:[self manager] userInfo:nil];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [center postNotificationName:notificationName object:[self manager] userInfo:nil];
        });
    }
}
#pragma mark - 重写getter方法
- (NSArray *)allPeople {
    return self.people;
}
@end



@interface YFContactModel()

@end

@implementation YFContactModel
- (NSString *)description {
    NSMutableString *phoneNumbers = [[NSMutableString alloc] init];
    for (NSString *phoneNum in self.phoneNumbers) {
        [phoneNumbers appendString:phoneNum];
        [phoneNumbers appendString:@" || "];
    }
    NSRange range = {phoneNumbers.length-3,3};
    [phoneNumbers deleteCharactersInRange:range];
    if (self.middleName ==nil) {
        self.middleName =@".";
    }
    if (self.firstName ==nil) {
        self.firstName =@"";
    }
    return [NSString stringWithFormat:@"姓名:%@%@%@\n电话号码：%@",self.lastName,self.middleName,self.firstName,[phoneNumbers copy]];
}


@end