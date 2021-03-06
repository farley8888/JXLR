//
//  AssigneeDebtViewController.m
//  SP2P_6.1
//
//  Created by Jerry on 14-8-1.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//
//  账户中心 -> 理财子账户 -> 债权管理(受让债权管理)

#import "AssigneeDebtViewController.h"
#import "ColorTools.h"
#import "DebtManagement.h"
#import "DebtManagementCell.h"
#import "AssigneeSuccessedViewController.h"
#import "AssigneeingDebtViewController.h"
#import "DirectionalTransferViewController.h"
#import "AssigneeDebtFailureViewController.h"
#import "ConfirmedViewController.h"

#import "NSString+Date.h"

@interface AssigneeDebtViewController ()<UITableViewDelegate,UITableViewDataSource, HTTPClientDelegate> {
    NSMutableArray *_collectionArrays;// 数据
    
    NSInteger _total;// 总的数据
    
    NSInteger _currPage;// 查询的页数
    
    BOOL _isLoading;
    
}

@property(nonatomic ,strong) NetWorkClient *requestClient;

@property (nonatomic,strong) UITableView *listView;

@end

@implementation AssigneeDebtViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    
    // 初始化视图
    [self initView];
}




/**
 * 初始化数据
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
    _listView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 104) style:UITableViewStyleGrouped];
    _listView.delegate = self;
    _listView.dataSource = self;
    
    [self.view addSubview:_listView];
    
    
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    MJRefreshGifHeader *gifHeader = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
    
    UIImage *image1 = [UIImage imageNamed:@"listview_pull_refresh01"];
    UIImage *image2 = [UIImage imageNamed:@"listview_pull_refresh02"];
    NSArray *refreshImages = [NSArray arrayWithObjects:image1,image2, nil];
    // Hide the time
    gifHeader.lastUpdatedTimeLabel.hidden = YES;
    // Hide the status
    gifHeader.stateLabel.hidden = YES;
    // 设置普通状态的动画图片
    [gifHeader setImages:refreshImages forState:MJRefreshStateIdle];
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    [gifHeader setImages:refreshImages forState:MJRefreshStatePulling];
    // 设置正在刷新状态的动画图片
    [gifHeader setImages:refreshImages forState:MJRefreshStateRefreshing];
    _listView.mj_header = gifHeader;
    
    // 自动刷新(一进入程序就下拉刷新)
    [_listView.mj_header beginRefreshing];
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    MJRefreshBackGifFooter *gifFooter = [MJRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRereshing)];
    // Hide the status
    gifFooter.stateLabel.hidden = YES;
    // 设置普通状态的动画图片
    [gifFooter setImages:refreshImages forState:MJRefreshStateIdle];
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    [gifFooter setImages:refreshImages forState:MJRefreshStatePulling];
    // 设置正在刷新状态的动画图片
    [gifFooter setImages:refreshImages forState:MJRefreshStateRefreshing];
    _listView.mj_footer = gifFooter;
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTable:) name:@"markupSuccess" object:nil];
}

-(void) updateTable:(id)obj
{
    [_listView.mj_header beginRefreshing];
}

#pragma mark UItableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _collectionArrays.count;
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
    return 60.0f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellid = @"cellid";
    DebtManagementCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell==nil) {
        cell = [[DebtManagementCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    DebtManagement *debtMag = _collectionArrays[indexPath.section];
    
    cell.titleLabel.text = debtMag.titleName;
    // -1失败
    // 0竞拍中
    // 1成功
    // 2待接受
    // 3待确认
    [cell setStateColor:(int)debtMag.status];
    switch (debtMag.status) {
        case -1:
            cell.stateLabel.text = @"失败";
            
            break;
        case 0:
            cell.stateLabel.text = @"竞拍中";
            
            break;
        case 1:
            cell.stateLabel.text = @"成功";
            
            break;
        case 2:
            cell.stateLabel.text = @"待接受";
            
            break;
        case 3:
            cell.stateLabel.text = @"待确认";
            
            break;
            
        default:
            break;
    }
    cell.timeLabel.text = debtMag.endTime;
    
    [cell typeLabelBack:(int)debtMag.type];
    if (debtMag.type == 0) {
        //        [cell.typeBtn setTitle:@"竞" forState:UIControlStateNormal];
    }else if (debtMag.type == 1){
        //        [cell.typeBtn setBackgroundImage:[UIImage imageNamed:@"state_set"] forState:UIControlStateNormal];
        cell.typeImg.image = [UIImage imageNamed:@"state_set"];
        
        //        [cell.typeBtn setTitle:@"定" forState:UIControlStateNormal];
    }else if (debtMag.type == 2){
        //        [cell.typeBtn setTitle:@"待" forState:UIControlStateNormal];
        //        [cell.typeBtn setBackgroundImage:[UIImage imageNamed:@"state_auction"] forState:UIControlStateNormal];
        cell.typeImg.image = [UIImage imageNamed:@"state_auction"];
        
    }
    
    cell.transferLabel.text = [NSString stringWithFormat:@"转让定价:%.2f", debtMag.transferPrice];
    cell.highestLabel.text = [NSString stringWithFormat:@"最高竞价:%.2f", debtMag.maxOfferPrice];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // -1失败
    // 0竞拍中
    // 1成功
    // 2待接受
    // 3待确认
    DebtManagement *item = _collectionArrays[indexPath.section];
    //DLOG(@"item.status -> %ld", (long)item.status);
    
    if (item.status == -1) {// -1失败
        
        AssigneeDebtFailureViewController *assginFailureView = [[AssigneeDebtFailureViewController alloc] init];
        assginFailureView.signId = item.signId;
        [self.navigationController pushViewController:assginFailureView animated:YES];
        
    }else if(item.status == 0){ // 0竞拍中
        
        AssigneeingDebtViewController *assigneeingDebtView = [[AssigneeingDebtViewController alloc] init];
        assigneeingDebtView.signId = item.signId;
        assigneeingDebtView.sign = item.sign;
        [self.navigationController pushViewController:assigneeingDebtView animated:YES];
        
    }else if(item.status == 1){ // 1成功
        
        AssigneeSuccessedViewController *assigneeSuccessedView = [[AssigneeSuccessedViewController alloc] init];
        assigneeSuccessedView.signId = item.signId;
        [self.navigationController pushViewController:assigneeSuccessedView animated:YES];
        
    }else if(item.status == 2){ // 2待接受
        
        DirectionalTransferViewController *directionalTransferView = [[DirectionalTransferViewController alloc] init];
        directionalTransferView.signId = item.signId;//查看详情传signId
        directionalTransferView.sign = item.sign; //接受或拒绝传sign
        directionalTransferView.bidName = item.bidName;
        directionalTransferView.receivedAmount = [NSString stringWithFormat:@"%.f", item.transferPrice];
        directionalTransferView.maxOfferPrice = [NSString stringWithFormat:@"%.f", item.maxOfferPrice];
        [self.navigationController pushViewController:directionalTransferView animated:YES];
        
    }else if(item.status == 3){// 3待确认
        
        if (item.type == 1) {//定向
            DirectionalTransferViewController *directionalTransferView = [[DirectionalTransferViewController alloc] init];
            directionalTransferView.signId = item.signId;//查看详情传signId
            directionalTransferView.sign = item.sign;//接受或拒绝传sign
            //DLOG(@"%@",directionalTransferView.signId);
            directionalTransferView.bidName = item.bidName;
            directionalTransferView.receivedAmount = [NSString stringWithFormat:@"%.f", item.transferPrice];
            directionalTransferView.maxOfferPrice = [NSString stringWithFormat:@"%.f", item.maxOfferPrice];
            [self.navigationController pushViewController:directionalTransferView animated:YES];
            
        }else{//竞价
        
        ConfirmedViewController *confirmedView = [[ConfirmedViewController alloc] init];
        confirmedView.signId = item.signId;//查看详情传signId
        confirmedView.sign = item.sign; //受让成交传sign
        confirmedView.bidName = item.bidName;
        confirmedView.receivedAmount = [NSString stringWithFormat:@"%.f", item.transferPrice];
        confirmedView.maxOfferPrice = [NSString stringWithFormat:@"%.f", item.maxOfferPrice];
        [self.navigationController pushViewController:confirmedView animated:YES];
        }
        
    }
}


/**
 加载数据
 */
- (void)requestData
{
    if (AppDelegateInstance.userInfo == nil) {
        [self hiddenRefreshView];
      [SVProgressHUD showErrorWithStatus:@"请登录!"];
        return;
    }else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        
        [parameters setObject:@"53" forKey:@"OPT"];
        [parameters setObject:@"" forKey:@"body"];
        [parameters setObject:AppDelegateInstance.userInfo.userId forKey:@"id"];
        [parameters setObject:[NSString stringWithFormat:@"%ld", (long)_currPage] forKey:@"currPage"];
        
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
    _isLoading = YES;
}

// 返回成功
-(void) httpResponseSuccess:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didSuccessWithObject:(id)obj
{
    [self hiddenRefreshView];
    NSDictionary *dics = obj;
    //DLOG(@"===%@=======", dics);
    
    //DLOG(@"msg  -> %@", [obj objectForKey:@"msg"]);
    
    // 清空全部数据
    if (_currPage == 1) {
        [_collectionArrays removeAllObjects];
    }
    
    if ([[NSString stringWithFormat:@"%@",[dics objectForKey:@"error"]] isEqualToString:@"-1"]) {
        
        _total = [[dics objectForKey:@"totalNum"] intValue];
        
        if (![[obj objectForKey:@"list"] isEqual:[NSNull null]]) {
            
            NSArray *collections = [dics objectForKey:@"list"];
            
            for (NSDictionary *item in collections) {
                DebtManagement *bean = [[DebtManagement alloc] init];
                
                if (![[item objectForKey:@"transaction_time"] isEqual:[NSNull null]]) {
                    bean.endTime = [NSString converDate:[[item objectForKey:@"transaction_time"] objectForKey:@"time"]  withFormat:@"MM-dd"];
                }
                
                bean.titleName = [item objectForKey:@"title"];
                // -1失败
                // 0竞拍中
                // 1成功
                // 2待接受
                bean.status = [[item objectForKey:@"status"] integerValue];
                bean.type = [[item objectForKey:@"type"] integerValue];
                bean.transferPrice = [[item objectForKey:@"transfer_price"] floatValue];
                bean.maxOfferPrice = [[item objectForKey:@"max_price"] floatValue];
                bean.signId = [item objectForKey:@"signId"];
                bean.sign = [item objectForKey:@"sign"];
                //bean.bidName = [item objectForKey:@"name"];
                bean.bidName = [item objectForKey:@"rname"];
                
                [_collectionArrays addObject:bean];
            }
            
            [_listView reloadData];

        }
    } else {
        //DLOG(@"返回失败  msg -> %@",[obj objectForKey:@"msg"]);
         [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", [obj objectForKey:@"msg"]]];
        [self pageCount:NO];// 页面计数失败
    }
    
    _isLoading = NO;
}

// 返回失败
-(void) httpResponseFailure:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didFailWithError:(NSError *)error
{
    _isLoading = NO;
    [self hiddenRefreshView];
    [self pageCount:NO];// 页面计数失败
    
    // 服务器返回数据异常
//    [SVProgressHUD showErrorWithStatus:@"网络异常"];
}

// 无可用的网络
-(void) networkError
{
    [self hiddenRefreshView];
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"无可用网络"]];
    _isLoading = NO;
    [self pageCount:NO];// 页面计数失败
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    _currPage = 1;
    _total = 0;
    
    [self requestData];
}

- (void)footerRereshing
{
    _currPage++;

    [self requestData];
    
}

#pragma Hidden View

// 隐藏刷新视图
-(void) hiddenRefreshView
{
    if (!_listView.mj_header.hidden) {
        [_listView.mj_header endRefreshing];
    }
    
    if (!_listView.mj_footer.hidden) {
        [_listView.mj_footer endRefreshing];
    }
}

#pragma 页面计数
/**
 页面计数，如果isCount == YES则应该计数
 
 否则，计数失败，当前页应该恢复原来数值
 */
-(void) pageCount:(BOOL)isCount
{
    if(isCount){
        // 计数成功，加载前已经+1了，不处理
    } else {
        // 加载失败，计数无效，当前页应该 -1 ，恢复原来数值
        if(_currPage > 1){
            _currPage --;
        }
    }
}


-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestClient != nil) {
        [_requestClient cancel];
    }
    
    if (_isLoading) {
        // 正在加载中退出，关闭下拉，上拉界面，计数恢复原值
        [self hiddenRefreshView];
        [self pageCount:NO];
    }
    
}


@end
