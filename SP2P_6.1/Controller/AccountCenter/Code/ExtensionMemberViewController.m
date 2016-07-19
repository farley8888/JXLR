//
//  ExtensionMemberViewController.m
//  SP2P_6.1
//
//  Created by kiu on 14-6-19.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//
//  成功推广的会员

#import "ExtensionMemberViewController.h"

#import "ColorTools.h"
#import "Member.h"
#import "MemberTableViewCell.h"
#import "ExtensionDetailViewController.h"
#import "UIFolderTableView.h"

@interface ExtensionMemberViewController ()<UITableViewDataSource,UITableViewDelegate, HTTPClientDelegate>
{
    NSMutableArray *_collectionArrays;
}

@property (nonatomic, strong) UIFolderTableView *listView;
//  是否打开二级详情
@property (assign)BOOL isOpen;
@property (nonatomic,retain)NSIndexPath *selectIndex;

@property(nonatomic ,strong) NetWorkClient *requestClient;

@end

@implementation ExtensionMemberViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    if (AppDelegateInstance.userInfo == nil) {
        [SVProgressHUD showErrorWithStatus:@"请登录!"];
        
        return;
    }else {
    
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

        [parameters setObject:@"29" forKey:@"OPT"];
        [parameters setObject:@"" forKey:@"body"];
        [parameters setObject:AppDelegateInstance.userInfo.userId forKey:@"id"];

        if (_requestClient == nil) {
            _requestClient = [[NetWorkClient alloc] init];
            _requestClient.delegate = self;
        }
        [_requestClient requestGet:@"app/services" withParameters:parameters];
        
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isOpen = NO;
    // 初始化数据
    [self initData];
    
    // 初始化视图
    [self initView];
}

/**
 初始化数据
 */
- (void)initData
{
    _collectionArrays =[[NSMutableArray alloc] init];
}

/**
 初始化数据
 */
- (void)initView
{
    [self initNavigationBar];
    
    [self initContentView];
}

/**
 * 初始化导航条
 */
- (void)initNavigationBar
{
    self.title = @"成功推广的会员";
}

/**
 * 初始化内容详情
 */
- (void)initContentView
{
    _listView = [[UIFolderTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _listView.delegate = self;
    _listView.dataSource = self;
    [_listView setBackgroundColor:ColorBGGray];
    _listView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listView];
}

#pragma mark - UITableView 代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _collectionArrays.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *settingcell = @"settingCell";
    
    MemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:settingcell];
    
    if (cell == nil) {
        cell = [[MemberTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:settingcell];
    }
    
    [cell setSeparatorInset:UIEdgeInsetsZero];
    
     cell.more.userInteractionEnabled = NO;
    [cell.more setTag:indexPath.section + 11111];

    
    Member *_member = [_collectionArrays objectAtIndex:indexPath.section];
    
    [cell fillCellWithObject:_member];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Member *_member = [_collectionArrays objectAtIndex:indexPath.section];
    //DLOG(@"name - %@", _member.name);
    //DLOG(@"loan - %@", _member.loan);
    //DLOG(@"bonus - %@", _member.bonus);
    
    //DLOG(@"registrationDate - %@", _member.registrationDate);
    //DLOG(@"loan - %@", _member.loan);
    //DLOG(@"manage - %@", _member.manage);
    //DLOG(@"bonus - %@", _member.bonus);
    
    ExtensionDetailViewController *subVc = [[ExtensionDetailViewController alloc] init];
    
    subVc.registrationDate = _member.registrationDate;
    subVc.loan = _member.loan;
    subVc.manage = _member.manage;
    subVc.bonus = _member.bonus;
    
    UITableViewCell *cell1 = [_listView cellForRowAtIndexPath:indexPath];
    UIButton *btn = (UIButton *)[cell1 viewWithTag:indexPath.section + 11111];
    
    //DLOG(@"%d", btn.selected);
    if (btn.selected == 0) {
        btn.selected = 1;
    }
    
    _listView.scrollEnabled = NO;
    UIFolderTableView *folderTableView = (UIFolderTableView *)tableView;
    [folderTableView openFolderAtIndexPath:indexPath WithContentView:subVc.view
                                 openBlock:^(UIView *subClassView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction){
                                     // opening actions
                                     //[self CloseAndOpenACtion:indexPath];
                                     btn.selected = !btn.selected;
                                 }
                                closeBlock:^(UIView *subClassView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction){
                                    // closing actions
                                    //[self CloseAndOpenACtion:indexPath];
                                    //[cell changeArrowWithUp:NO];
                                }
                           completionBlock:^{
                               // completed actions
                               _listView.scrollEnabled = YES;
                           }];
}

-(void)CloseAndOpenACtion:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:self.selectIndex]) {
        self.isOpen = NO;
        [self didSelectCellRowFirstDo:NO nextDo:NO];
        self.selectIndex = nil;
    }
    else
    {
        if (!self.selectIndex) {
            self.selectIndex = indexPath;
            [self didSelectCellRowFirstDo:YES nextDo:NO];
            
        }
        else
        {
            [self didSelectCellRowFirstDo:NO nextDo:YES];
        }
    }
}
- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert
{
    self.isOpen = firstDoInsert;
    
    if (nextDoInsert) {
        self.isOpen = YES;
        self.selectIndex = [_listView indexPathForSelectedRow];
        [self didSelectCellRowFirstDo:YES nextDo:NO];
    }
}

#pragma mark HTTPClientDelegate 网络数据回调代理
-(void) startRequest
{

}

// 返回成功
-(void) httpResponseSuccess:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didSuccessWithObject:(id)obj
{
    NSDictionary *dics = obj;
    
    if ([[NSString stringWithFormat:@"%@",[dics objectForKey:@"error"]] isEqualToString:@"-1"]) {
        
        //DLOG(@"返回成功  msg -> %@",[obj objectForKey:@"msg"]);
        
        //DLOG(@"加载数据中.....");
        _collectionArrays =[[NSMutableArray alloc] init];

        NSArray *collections = [[obj objectForKey:@"page"] objectForKey:@"page"];
        for (NSDictionary *item in collections) {
            Member *bean = [[Member alloc] init];
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[[item objectForKey:@"time"] objectForKey:@"time"] doubleValue]/1000];
            NSDateFormatter *dataFormat = [[NSDateFormatter alloc] init];
            NSDateFormatter *dataFormat1 = [[NSDateFormatter alloc] init];
            [dataFormat setDateFormat:@"yyyy-MM-dd"];
            [dataFormat1 setDateFormat:@"MM-dd"];
            
            bean.registrationDate = [dataFormat stringFromDate: date];
            
            bean.name = [item objectForKey:@"name"];
            bean.dateTime = [dataFormat1 stringFromDate: date];
            bean.isActive = [[item objectForKey:@"is_active"] boolValue];
            bean.loan = [item objectForKey:@"bid_amount"];
            bean.manage = [item objectForKey:@"invest_amount"];
            bean.bonus = [item objectForKey:@"cps_award"];
            
            [_collectionArrays addObject:bean];
        }
        
        [_listView reloadData];
        
    }else {
        //DLOG(@"返回失败  msg -> %@",[obj objectForKey:@"msg"]);
        
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", [obj objectForKey:@"msg"]]];
    }
}

// 返回失败
-(void) httpResponseFailure:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didFailWithError:(NSError *)error
{
    // 服务器返回数据异常
//    [SVProgressHUD showErrorWithStatus:@"网络异常"];

}

// 无可用的网络
-(void) networkError
{
    [SVProgressHUD showErrorWithStatus:@"无可用网络"];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestClient != nil) {
        [_requestClient cancel];
    }
}

@end