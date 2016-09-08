//
//  ViewController.m
//  ContactTest
//
//  Created by 陌南城 on 16/9/6.
//  Copyright © 2016年 陌南城. All rights reserved.
//

#import "ViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "YFContactManager.h"
#define PATH @"/Users/monancheng/Desktop/tests.txt"

@interface ViewController ()
@property(nonatomic, strong) NSMutableArray *people;

@end

@implementation ViewController
- (NSMutableArray *)people {
    if (!_people) {
        _people = [NSMutableArray array];
    }
    return _people;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addNotifications];
    //创建导航按钮
    [self testContact];
    
}
#pragma mark====添加通知
- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(allowAccessContacts)
                                                 name:YFContactAccessAllowedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessDenied)
                                                 name:YFContactAccessDeniedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessFailed)
                                                 name:YFContactAccessFailedNotification
                                               object:nil];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - notification action
- (void)allowAccessContacts {
    NSLog(@"accessAllowed");
    [self.tableView reloadData];
}
- (void)accessDenied {
    NSLog(@"accessDenied");
}
- (void)accessFailed {
    NSLog(@"accessFailed");
}
#pragma mark=====创建导航按钮
- (void)testContact
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, 10, 60, 40);
    [button setTitle:@"Contact" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor yellowColor]];
    button.titleLabel.font =[UIFont systemFontOfSize:15];
    button.layer.cornerRadius=6;
    button.layer.masksToBounds= YES;
    [button addTarget:self action:@selector(testContactAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = item;
}
//写入本地
- (void)testContactAction
{
    YFContactManager *manager = [YFContactManager manager];
    for (YFContactModel *contact in manager.allPeople) {
        NSLog(@"%@", contact);
    }
    [self hangdleContactManagerToString:manager];
}
//解析为jscon字符串传回后台前准备
- (void)hangdleContactManagerToString:(YFContactManager *)manager
{
    NSString *testStr= [manager.allPeople componentsJoinedByString:@"\n"];
    NSFileHandle * fh = [NSFileHandle fileHandleForWritingAtPath:PATH];
    NSData * data = [testStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [fh seekToEndOfFile];
    
    [fh writeData:data];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setValue:testStr forKey:@"test"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", jsonString);
    
}

#pragma mark=====列表代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [YFContactManager manager].allPeople.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId =@"cellID";
    YFContactModel *contact = (YFContactModel *)([YFContactManager manager].allPeople[indexPath.row]);
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell ==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = contact.description;
    cell.textLabel.numberOfLines=0;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
