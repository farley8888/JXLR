//
//  NormalIntegralReimbursementDetailViewController.m
//  SP2P_6.1
//
//  Created by Jerry on 14-6-30.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//
//正常还款积分明细
#import "NormalIntegralReimbursementDetailViewController.h"
#import "IntegralSubsidiaryCell.h"
#import "ColorTools.h"

#import "NormalIntegralDetail.h"

@interface NormalIntegralReimbursementDetailViewController ()<UITableViewDataSource,UITableViewDelegate, HTTPClientDelegate>
{
    NSMutableArray *_dataArrays;
    
    NSInteger _total;// 总的数据
    
    NSInteger _currPage;// 查询的页数
}

@property (nonatomic,strong) UITableView *tableView;

@property(nonatomic ,strong) NetWorkClient *requestClient;

@end

@implementation NormalIntegralReimbursementDetailViewController

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
    
}

/**
 * 初始化数据
 */
- (void)initData
{
    _dataArrays = [[NSMutableArray alloc] init];
    
}

/**
 初始化数据
 */
- (void)initView
{
    
    [self initNavigationBar];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-HeightNavigationAndStateBar) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [_tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    // 自动刷新(一进入程序就下拉刷新)
    [_tableView headerBeginRefreshing];
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [_tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}


/**
 * 初始化导航条
 */
- (void)initNavigationBar
{
    self.title = @"正常还款积分明细";
}

#pragma mark UItableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return _dataArrays.count;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2.0f;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return 2.0f;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0f;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellid = @"cellid";
    IntegralSubsidiaryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell==nil) {
        cell = [[IntegralSubsidiaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NormalIntegralDetail *bean = _dataArrays[indexPath.section];
    
    cell.typeRow = 1;
    [cell fillCellWithObject:bean];
    return cell;
}
#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    _currPage = 1;
    
    [self requestData];
}


- (void)footerRereshing
{
    
    _currPage++;
    
    [self requestData];
    
}


#pragma 请求数据
-(void) requestData
{
    if (AppDelegateInstance.userInfo == nil) {
        [self hiddenRefreshView];
       [SVProgressHUD showErrorWithStatus:@"请登录!"];
        return;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"116" forKey:@"OPT"];
    [parameters setObject:@"" forKey:@"body"];
    
    [parameters setObject:[NSString stringWithFormat:@"%ld", (long)_currPage] forKey:@"currPage"];
    [parameters setObject:AppDelegateInstance.userInfo.userId forKey:@"id"];
    
    if (_requestClient == nil) {
        _requestClient = [[NetWorkClient alloc] init];
        _requestClient.delegate = self;
        
    }
    [_requestClient requestGet:@"app/services" withParameters:parameters];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        // 刷新表格
//        [_tableView reloadData];
//        
//        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
//        [self hiddenRefreshView];
//    });
    
}

#pragma HTTPClientDelegate 网络数据回调代理
-(void) startRequest
{
    
}

// 返回成功
-(void) httpResponseSuccess:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didSuccessWithObject:(id)obj
{
    [self hiddenRefreshView];
    
    NSDictionary *dics = obj;
    //DLOG(@"===%@=======", dics);
    //DLOG(@"msg  -> %@", [obj objectForKey:@"msg"]);
    
    if ([[NSString stringWithFormat:@"%@",[dics objectForKey:@"error"]] isEqualToString:@"-1"]) {
        if(_currPage == 1)
        {
            
         [_dataArrays removeAllObjects];// 清空全部数据
            
        }
        _total = [[[dics objectForKey:@"list"] objectForKey:@"totalCount" ] intValue];// 总共多少条
        
        NSArray *dataArr = [[dics objectForKey:@"list"] objectForKey:@"page"];
        
        for (NSDictionary *item in dataArr) {
            
            NormalIntegralDetail *bean = [[NormalIntegralDetail alloc] init];
            
            bean.title = [item objectForKey:@"title"];// 借款标名称
            if (![[item objectForKey:@"audit_time"] isEqual:[NSNull null]]) {
                NSDate *date = [NSDate dateWithTimeIntervalSince1970: [[[item objectForKey:@"audit_time"] objectForKey:@"time"] doubleValue]/1000];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyy-MM-dd"];
                bean.auditTime  = [dateFormat stringFromDate: date];
            }
            bean.score = [[item objectForKey:@"score"] intValue];// 信用积分
            bean.bidNo = [item objectForKey:@"bid_no"] ; // 借款标编号
            bean.period = [item objectForKey:@"period"] ; // 期数(比例)
            
            [_dataArrays addObject:bean];
        }
        // 刷新表格
        [_tableView reloadData];
    
    }else {
    // 服务器返回数据异常
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", [obj objectForKey:@"msg"]]];
    }
    
}

// 返回失败
-(void) httpResponseFailure:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didFailWithError:(NSError *)error
{
    [self hiddenRefreshView];
    
    // 服务器返回数据异常
//    [SVProgressHUD showErrorWithStatus:@"网络异常"];
}

// 无可用的网络
-(void) networkError
{
    [self hiddenRefreshView];
    
    // 服务器返回数据异常
    [SVProgressHUD showErrorWithStatus:@"无可用网络"];
}


#pragma Hidden View

// 隐藏刷新视图
-(void) hiddenRefreshView
{
    if (!self.tableView.isHeaderHidden) {
        [self.tableView headerEndRefreshing];
    }
    
    if (!self.tableView.isFooterHidden) {
        [self.tableView footerEndRefreshing];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestClient != nil) {
        [_requestClient cancel];
    }
}

@end