//
//  AccuontSafeViewController.m
//  SP2P_6.1
//
//  Created by Jerry on 14-6-19.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//
//账户中心--》账户管理--》账户安全
#import "AccuontSafeViewController.h"
#import "FindDealPasssWordViewController.h"
#import "ChangeLoginPasswordViewController.h"
#import "SetSafeQuestionViewController.h"
#import "SetSafeQuestionViewTwoController.h"
#import "SetSafeEMailViewController.h"
#import "SetSafePhoneNumViewController.h"
#import "GestureManagerController.h"

#import "SetNewDealPassWordViewController.h"

#import "ColorTools.h"

@interface AccuontSafeViewController ()<UITableViewDataSource,UITableViewDelegate, HTTPClientDelegate>
{
    NSMutableArray *titleArr;

    BOOL _isPayPasswordStatus;      // 交易密码状态
    BOOL _isSecretStatus;           // 安全问题状态
    BOOL _isTeleStatus;             // 手机绑定状态
    BOOL _isLoading;

}

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArr;
@property(nonatomic ,strong) NetWorkClient *requestClient;
@end

@implementation AccuontSafeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 初始化数据
    [self initData];
  
    [self requestData];
    
    // 初始化视图
    [self initView];
}

/**
 * 初始化数据
 */
- (void)initData
{
    //通知检测对象
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(updatelist:) name:@"updatelist" object:nil];
    
    _isSecretStatus = NO;
    
    titleArr = [[NSMutableArray alloc] init];
    //_dataArr = [[NSMutableArray alloc] initWithArray:@[@"修改登录密码",@"设置安全问题",@"设置安全手机"]];
    
    //Jaqen-start:增加安全项－手势密码
    
    _dataArr = [[NSMutableArray alloc] initWithArray:@[@"修改登录密码",@"设置安全问题",@"设置安全手机",@"设置手势密码"]];
    
    //Jaqen-end
}

/**
 初始化数据
 */
- (void)initView
{
    self.title = @"账户安全";
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

#pragma mark UItableview代理方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

   return [_dataArr count];

}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 1;

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 4.0f;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return 4.0f;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 50.0f;

}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellid = @"cellid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    
    cell.textLabel.text = [_dataArr objectAtIndex:indexPath.section];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14.5f];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
            {
                ChangeLoginPasswordViewController *changeLoginPasswordView = [[ChangeLoginPasswordViewController alloc] init];
                [self.navigationController pushViewController:changeLoginPasswordView animated:YES];
            }
            break;
        case 1:
            {
                if (!_isLoading) {
                    // 不在请求数据
                    if (AppDelegateInstance.userInfo.isSecretStatus) {
                        // 有安全问题
                        SetSafeQuestionViewTwoController *setSafeQuestionViewTwo = [[SetSafeQuestionViewTwoController alloc] init];
                        [self.navigationController pushViewController:setSafeQuestionViewTwo animated:YES];
                        
                    }else {
                        // 未设置安全问题
                        SetSafeQuestionViewController *setSafeQuestionView = [[SetSafeQuestionViewController alloc] init];
                        [self.navigationController pushViewController:setSafeQuestionView animated:YES];
                    }
                }
            }
            break;
        case 2:
            {
                if (AppDelegateInstance.userInfo.isSecretStatus) {
                    SetSafePhoneNumViewController *setSafePhoneNumView = [[SetSafePhoneNumViewController alloc] init];
                    setSafePhoneNumView.isTeleStatus = _isTeleStatus;
                    [self.navigationController pushViewController:setSafePhoneNumView animated:YES];
                }else {
                    [SVProgressHUD showErrorWithStatus:@"亲，请先设置安全问题"];
                }
                
            }
            break;
        case 3:
        {
            GestureManagerController *gestureManagerController = [[GestureManagerController alloc] init];
            [self.navigationController pushViewController:gestureManagerController animated:YES];
        }
            break;
    }
}

#pragma 请求数据
-(void) requestData
{
    if (AppDelegateInstance.userInfo == nil) {
        [SVProgressHUD showErrorWithStatus:@"请登录!"];
        return;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"138" forKey:@"OPT"];// 客户端安全问题是否设置接口
    [parameters setObject:@"" forKey:@"body"];
    [parameters setObject:AppDelegateInstance.userInfo.userId forKey:@"user_id"];
    
    if (_requestClient == nil) {
        _requestClient = [[NetWorkClient alloc] init];
        _requestClient.delegate = self;
       
    }
    [_requestClient requestGet:@"app/services" withParameters:parameters];
}

#pragma HTTPClientDelegate 网络数据回调代理
-(void) startRequest
{
    _isLoading = YES;
}

// 返回成功
-(void) httpResponseSuccess:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didSuccessWithObject:(id)obj
{
    NSDictionary *dics = obj;
    
    if ([[NSString stringWithFormat:@"%@",[dics objectForKey:@"error"]] isEqualToString:@"-1"]) {
        
        _isPayPasswordStatus = [[dics objectForKey:@"payPasswordStatus"] boolValue];
        _isTeleStatus = [[dics objectForKey:@"teleStatus"] boolValue];
        _isSecretStatus = [[dics objectForKey:@"SecretStatus"] boolValue];
        
        [self setView];
    } else {
        // 服务器返回数据异常
       [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", [obj objectForKey:@"msg"]]];
    }
    _isLoading = NO;
}

// 返回失败
-(void) httpResponseFailure:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didFailWithError:(NSError *)error
{
    _isLoading = NO;
    // 服务器返回数据异常
//    [SVProgressHUD showErrorWithStatus:@"网络异常"];
}

// 无可用的网络
-(void) networkError
{
     _isLoading = NO;
    // 服务器返回数据异常
    [SVProgressHUD showErrorWithStatus:@"无可用网络"];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestClient != nil) {
        [_requestClient cancel];
    }
}

#pragma mark - 根据服务器信息，更新tableView数据
- (void)setView {
    
    if (_isSecretStatus) {
        [_dataArr replaceObjectAtIndex:1 withObject:@"修改安全问题"];
    }else {
        [_dataArr replaceObjectAtIndex:1 withObject:@"设置安全问题"];
    }
    
    if (_isTeleStatus) {
        [_dataArr replaceObjectAtIndex:2 withObject:@"修改安全手机"];
    }else {
        [_dataArr replaceObjectAtIndex:2 withObject:@"设置安全手机"];
    }
    
    // 储存是否设置安全手机 (0、 未设置  1、设置)
    AppDelegateInstance.userInfo.isTeleStatus = _isTeleStatus;
    // 储存是否设置交易密码 (0、 未设置  1、设置)
    AppDelegateInstance.userInfo.isPayPasswordStatus = _isPayPasswordStatus;
    // 储存是否设置安全问题 (0、 未设置  1、设置)
    AppDelegateInstance.userInfo.isSecretStatus = _isSecretStatus;
    [_tableView reloadData];
}

//通知中心触发方法
-(void)updatelist:(NSNotification *)notification
{
    NSString *str = (NSString *)[notification object];
    //DLOG(@"通知中心触发方法==============%@===========", AppDelegateInstance.userInfo.userImg);
    
    [self requestData];
    
    if ([str isEqualToString:@"1"]) {
        [_dataArr replaceObjectAtIndex:3 withObject:@"修改安全问题"];
        AppDelegateInstance.userInfo.isSecretStatus = YES;
    }
    if ([str isEqualToString:@"2"]) {
        [_dataArr replaceObjectAtIndex:4 withObject:@"修改安全手机"];
        AppDelegateInstance.userInfo.isTeleStatus = YES;
    }
    
    [_tableView reloadData];
}

@end