//
//  TransferloanStandardDetailsViewController.m
//  SP2P_6.1
//
//  Created by Jerry on 14-8-4.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//
//  账户中心 -> 理财子账户 -> 债权管理(转让债权管理) -> 已成功 -> 转让的借款标详情 [成功,转让中,审核中,不通过,失败](opt=49)

#import "TransferloanStandardDetailsViewController.h"
#import "ColorTools.h"
#import "TransferloanStandardDetails.h"

#import "NSString+Date.h"

@interface TransferloanStandardDetailsViewController ()<HTTPClientDelegate>
{
    NSArray *titleArr;
    NSMutableArray *dataArr;
}

@property (nonatomic, strong) UILabel *borrowid;        // 借款标编号
@property (nonatomic, strong) UILabel *borrowerName;    // 借款人名称
@property (nonatomic, strong) UILabel *borrowType;      // 借款标类型
@property (nonatomic, strong) UILabel *borrowTitle;     // 借款标标题
@property (nonatomic, strong) UILabel *bidCapital;      // 投标本金
@property (nonatomic, strong) UILabel *annualRate;      // 年利率
@property (nonatomic, strong) UILabel *interestSum;     // 本息合计应收金额
@property (nonatomic, strong) UILabel *receivedAmount;  // 已收金额
@property (nonatomic, strong) UILabel *remainAmount;    // 剩余应收款
@property (nonatomic, strong) UILabel *expiryDate;      // 还款日期
@property (nonatomic, strong) UILabel *collectCapital;  // 待收本金

@property(nonatomic ,strong) NetWorkClient *requestClient;

@end

@implementation TransferloanStandardDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 初始化数据
    [self initData];
    
    // 初始化视图
    [self initView];
    
    [self requestData];
}

/**
 * 初始化数据
 */
- (void)initData
{
    titleArr = @[@"借款标编号:",@"借款人:",@"借款标类型:",@"借款标标题:",@"投标本金:",@"年利率:",@"本息合计应收金额:",@"已收金额:",@"剩余应收款:",@"还款日期:",@"待收本金:"];
    dataArr = [[NSMutableArray alloc] init];
}

/**
 初始化数据
 */
- (void)initView
{
    
    [self initNavigationBar];
    self.view.backgroundColor = [UIColor whiteColor];
    
    for (int i = 0; i<[titleArr count]; i++) {
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = [titleArr objectAtIndex:i];
        titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        
        if (i == 0) {
            titleLabel.frame = CGRectMake(10, 90, 90, 30);
        }else if (i == 1) {
            titleLabel.frame = CGRectMake(10, 125, 60, 30);
        }else if (i == 2) {
            titleLabel.frame = CGRectMake(10, 160, 90, 30);
        }else if (i == 3) {
            titleLabel.frame = CGRectMake(10, 195, 90, 30);
        }else if (i == 4) {
            titleLabel.frame = CGRectMake(10, 230, 75, 30);
        }else if (i == 5) {
            titleLabel.frame = CGRectMake(10, 265, 60, 30);
        }else if (i == 6) {
            titleLabel.frame = CGRectMake(10, 300, 135, 30);
        }else if (i == 7) {
            titleLabel.frame = CGRectMake(10, 335, 75, 30);
        }else if (i == 8) {
            titleLabel.frame = CGRectMake(10, 370, 90, 30);
        }else if (i == 9) {
            titleLabel.frame = CGRectMake(10, 405, 75, 30);
        }else if (i == 10) {
            titleLabel.frame = CGRectMake(10, 440, 75, 30);
        }
        
        [self.view addSubview:titleLabel];
    }
    
    _borrowid = [[UILabel alloc] init];
    _borrowid.frame = CGRectMake(100, 90, 160, 30);
    _borrowid.text = @"";
    _borrowid.font = [UIFont boldSystemFontOfSize:15.0f];
    _borrowid.textColor = [UIColor redColor];
    [self.view addSubview:_borrowid];
    
    _borrowerName = [[UILabel alloc] init];
    _borrowerName.frame = CGRectMake(70, 125, 160, 30);
    _borrowerName.text = @"";
    _borrowerName.font = [UIFont boldSystemFontOfSize:15.0f];
    _borrowerName.textColor = [UIColor redColor];
    [self.view addSubview:_borrowerName];
    
    _borrowType = [[UILabel alloc] init];
    _borrowType.frame = CGRectMake(100, 160, 160, 30);
    _borrowType.text = @"";
    _borrowType.font = [UIFont boldSystemFontOfSize:15.0f];
    _borrowType.textColor = [UIColor redColor];
    [self.view addSubview:_borrowType];
    
    _borrowTitle = [[UILabel alloc] init];
    _borrowTitle.frame = CGRectMake(100, 195, 200, 30);
    _borrowTitle.text = @"";
    _borrowTitle.font = [UIFont boldSystemFontOfSize:15.0f];
    _borrowTitle.textColor = [UIColor redColor];
    [self.view addSubview:_borrowTitle];
    
    // 投标本金
    _bidCapital = [[UILabel alloc] init];
    _bidCapital.frame = CGRectMake(85, 230, 160, 30);
    _bidCapital.text = @"";
    _bidCapital.font = [UIFont boldSystemFontOfSize:15.0f];
    _bidCapital.textColor = [UIColor redColor];
    [self.view addSubview:_bidCapital];
    
    // 年利率
    _annualRate = [[UILabel alloc] init];
    _annualRate.frame = CGRectMake(70, 265, 160, 30);
    _annualRate.text = @"";
    _annualRate.font = [UIFont boldSystemFontOfSize:15.0f];
    _annualRate.textColor = [UIColor redColor];
    [self.view addSubview:_annualRate];
    
    // 本息金额
    _interestSum = [[UILabel alloc] init];
    _interestSum.frame = CGRectMake(145, 300, 160, 30);
    _interestSum.text = @"";
    _interestSum.font = [UIFont boldSystemFontOfSize:15.0f];
    _interestSum.textColor = [UIColor redColor];
    [self.view addSubview:_interestSum];
    
    // 应收金额
    _receivedAmount = [[UILabel alloc] init];
    _receivedAmount.frame = CGRectMake(85, 335, 160, 30);
    _receivedAmount.text = @"";
    _receivedAmount.font = [UIFont boldSystemFontOfSize:15.0f];
    _receivedAmount.textColor = [UIColor redColor];
    [self.view addSubview:_receivedAmount];
    
    // 剩余金额
    _remainAmount = [[UILabel alloc] init];
    _remainAmount.frame = CGRectMake(100, 370, 160, 30);
    _remainAmount.text = @"";
    _remainAmount.font = [UIFont boldSystemFontOfSize:15.0f];
    _remainAmount.textColor = [UIColor redColor];
    [self.view addSubview:_remainAmount];
    
    // 还款时间
    _expiryDate = [[UILabel alloc] init];
    _expiryDate.frame = CGRectMake(85, 405, 160, 30);
    _expiryDate.text = @"";
    _expiryDate.font = [UIFont boldSystemFontOfSize:15.0f];
    _expiryDate.textColor = [UIColor redColor];
    [self.view addSubview:_expiryDate];
    
    // 待收金额
    _collectCapital = [[UILabel alloc] init];
    _collectCapital.frame = CGRectMake(85, 440, 160, 30);
    _collectCapital.text = @"";
    _collectCapital.font = [UIFont boldSystemFontOfSize:15.0f];
    _collectCapital.textColor = [UIColor redColor];
    [self.view addSubview:_collectCapital];
}
/**
 * 初始化导航条
 */
- (void)initNavigationBar
{
    self.title = @"详情";
    [self.navigationController.navigationBar setBarTintColor:ColorWhite];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      ColorNavTitle, NSForegroundColorAttributeName,
                                                                      FontNavTitle, NSFontAttributeName, nil]];
    
    
    // 导航条返回按钮
BarButtonItem *barButtonLeft=[BarButtonItem barItemWithTitle:@"返回" widthImage:[UIImage imageNamed:@"bar_left"] withIsImageLeft:YES target:self action:@selector(backClick)];
    [self.navigationItem setLeftBarButtonItem:barButtonLeft];
}

#pragma 返回按钮触发方法
- (void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)setView {
    
    TransferloanStandardDetails *tfLoan = dataArr[0];
    
    _borrowid.text = tfLoan.borrowid;
    _borrowerName.text = tfLoan.borrowerName;
    _borrowType.text = tfLoan.borrowType;
    _borrowTitle.text = tfLoan.borrowTitle;
    _expiryDate.text = tfLoan.expiryDate;
//    _bidCapital.text = tfLoan.bidCapital;
//    _interestSum.text = tfLoan.interestSum;
//    _receivedAmount.text = tfLoan.receivedAmount;
//    _remainAmount.text = tfLoan.remainAmount;
    _collectCapital.text = tfLoan.collectCapital;
}

/**
 加载数据
 */
- (void)requestData
{
    if (AppDelegateInstance.userInfo == nil) {
        [SVProgressHUD showErrorWithStatus:@"请登录!"];
        
        return;
    }else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        
        [parameters setObject:@"50" forKey:@"OPT"];
        [parameters setObject:@"" forKey:@"body"];
        [parameters setObject:_sign forKey:@"sign"];
        
        if (_requestClient == nil) {
            _requestClient = [[NetWorkClient alloc] init];
            _requestClient.delegate = self;
        }
        [_requestClient requestGet:@"app/services" withParameters:parameters];
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
        
        TransferloanStandardDetails *tfLoan = [[TransferloanStandardDetails alloc] init];
        
        if (![[obj objectForKey:@"borrowid"] isEqual:[NSNull null]]) {
            tfLoan.borrowid = [NSString stringWithFormat:@"%@", [obj objectForKey:@"borrowid"]];
        }
        if (![[obj objectForKey:@"borrowerName"] isEqual:[NSNull null]]) {
            tfLoan.borrowerName = [NSString stringWithFormat:@"%@",[obj objectForKey:@"borrowerName"]];
        }
        if (![[obj objectForKey:@"borrowType"] isEqual:[NSNull null]]) {
            tfLoan.borrowType = [NSString stringWithFormat:@"%@",[obj objectForKey:@"borrowType"]];
        }
        if (![[obj objectForKey:@"borrowTitle"] isEqual:[NSNull null]]) {
            tfLoan.borrowTitle = [NSString stringWithFormat:@"%@",[obj objectForKey:@"borrowTitle"]];
        }
        if (![[obj objectForKey:@"expiryDate"] isEqual:[NSNull null]]) {
            tfLoan.expiryDate = [NSString stringWithFormat:@"%@",[obj objectForKey:@"expiryDate"]];
        }
        if (![[obj objectForKey:@"collectCapital"] isEqual:[NSNull null]]) {
            tfLoan.collectCapital = [NSString stringWithFormat:@"%.2f", [[obj objectForKey:@"collectCapital"] floatValue]];
        }else {
            tfLoan.collectCapital = @"0";
        }
        
        //DLOG(@"=========%@==========%@===",tfLoan.interestSum, tfLoan.receivedAmount);
        if (![[obj objectForKey:@"interestSum"] isEqual:[NSNull null]]) {
            _interestSum.text = [NSString stringWithFormat:@"%.2f", [[obj objectForKey:@"interestSum"] floatValue]];
        }else {
            _interestSum.text = @"0";
        }
        if (![[obj objectForKey:@"receivedAmount"] isEqual:[NSNull null]]) {
            _receivedAmount.text = [NSString stringWithFormat:@"%.2f", [[obj objectForKey:@"receivedAmount"] floatValue]];
        }else {
            _receivedAmount.text = @"0";
        }
        
        _remainAmount.text = [NSString stringWithFormat:@"%.2f", [_interestSum.text floatValue] - [_receivedAmount.text floatValue]];
        
        if (![[obj objectForKey:@"bidCapital"] isEqual:[NSNull null]]) {
            _bidCapital.text = [NSString stringWithFormat:@"%.2f", [[obj objectForKey:@"bidCapital"] floatValue]];
        }else {
            _bidCapital.text = @"0";
        }
        
        //DLOG(@"annualRate -> %@", [obj objectForKey:@"annualRate"]);
        if (![[obj objectForKey:@"annualRate"] isEqual:[NSNull null]]) {
            _annualRate.text = [NSString stringWithFormat:@"%@%%", [obj objectForKey:@"annualRate"]];
        }else {
            _annualRate.text = @"0";
        }
        [dataArr addObject:tfLoan];
        
        [self setView];
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