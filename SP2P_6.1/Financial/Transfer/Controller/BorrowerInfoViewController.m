//
//  BorrowerInfoViewController.m
//  SP2P_6.1
//
//  Created by Jerry on 14-9-28.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//

//  债权详情 -> 借款人信息
#import "BorrowerInfoViewController.h"
#import "ColorTools.h"
#import "AuctionViewController.h"

@interface BorrowerInfoViewController ()<HTTPClientDelegate>
{
    NSArray *infoArr;
}

@property(nonatomic ,strong) NetWorkClient *requestClient;
@property (nonatomic ,strong) NSMutableArray *dataArr;

@end

@implementation BorrowerInfoViewController


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
    _dataArr = [[NSMutableArray alloc] init];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    //借款人详情接口
    [parameters setObject:@"3" forKey:@"OPT"];
    [parameters setObject:@"" forKey:@"body"];
    [parameters setObject:[NSString stringWithFormat:@"%@",_borrowerID] forKey:@"id"];
    

    if (_requestClient == nil) {
        _requestClient = [[NetWorkClient alloc] init];
        _requestClient.delegate = self;
        
    }

    [_requestClient requestGet:@"app/services" withParameters:parameters];
}

/**
 初始化数据
 */
- (void)initView
{
    [self initNavigationBar];
    self.view.backgroundColor = [UIColor whiteColor];
    
    for (int i = 0; i<[infoArr count]; i++) {
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, SpaceMediumBig+35*i, 100, 30)];
        titleLabel.font = [UIFont systemFontOfSize:14.0f];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = [infoArr objectAtIndex:i];
        [self.view addSubview:titleLabel];
        
    }
    
    if (AppDelegateInstance.userInfo != nil) {
        
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
        bottomView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:bottomView];
        
        UIButton *tenderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        tenderBtn.frame = CGRectMake(SpaceBig, SpaceSmall,WidthScreen-SpaceBig*2, 44-SpaceSmall*2);
        tenderBtn.backgroundColor = GreenColor;
        [tenderBtn setTitle:@"我要竞拍" forState:UIControlStateNormal];
        [tenderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        tenderBtn.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:13.0];
        [tenderBtn.layer setMasksToBounds:YES];
        [tenderBtn.layer setCornerRadius:3.0];
        [tenderBtn addTarget:self action:@selector(tenderBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:tenderBtn];
        
    }
}

/**
 * 初始化导航条
 */
- (void)initNavigationBar
{
    self.title = @"借款人信息";
    // 导航条分享按钮
    BarButtonItem *shareItem=[BarButtonItem barItemWithTitle:@"分享" widthImage:[UIImage imageNamed:@"bar_right"] selectedImage:[UIImage imageNamed:@"bar_right_press"] withIsImageLeft:NO target:self action:@selector(ShareClick)];
    [self.navigationItem setRightBarButtonItem:shareItem];
}

// 返回成功
-(void) httpResponseSuccess:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didSuccessWithObject:(id)obj
{
    
    //DLOG(@"==返回成功=======%@",obj);
    NSDictionary *dics = obj;
    
    if ([[NSString stringWithFormat:@"%@",[dics objectForKey:@"error"]] isEqualToString:@"-1"]) {
        
        if(![[dics objectForKey:@"realName"]isEqual:[NSNull null]]&&[dics objectForKey:@"realName"]!=nil)
        {
            NSString *realName = [NSString stringWithFormat:@"真实姓名: %@***",[[dics objectForKey:@"realName"] substringWithRange:NSMakeRange(0, 1)]];
            [_dataArr addObject:realName];
        }
      
        NSString *sex = [NSString stringWithFormat:@"性别: %@",[dics objectForKey:@"sex"]] ;
        [_dataArr addObject:sex];
        
        
        NSString *year = [NSString stringWithFormat:@"年龄: %@",[dics objectForKey:@"age"]];
        [_dataArr addObject:year];
        
        // 截取局部 用 * 代替
        
        if(![[dics objectForKey:@"idNo"]isEqual:[NSNull null]]&&[dics objectForKey:@"idNo"]!=nil)
        {
            NSMutableString *idNo = [NSMutableString stringWithFormat:@"身份证号: %@",[dics objectForKey:@"idNo"]];
            [idNo replaceCharactersInRange:NSMakeRange(12, 8) withString:@"********"];
            [_dataArr addObject:idNo];
        }
        NSInteger registedPlaceProId = [[dics objectForKey:@"registedPlacePro"] intValue] ;
        NSInteger registedPlaceCityId = [[dics objectForKey:@"registedPlaceCity"] intValue] ;
        NSInteger higtestEduId = [[dics objectForKey:@"higtestEdu"] intValue] ;
        NSInteger maritalStatusId = [[dics objectForKey:@"maritalStatus"] intValue] ;
        NSInteger housrseStatusId = [[dics objectForKey:@"housrseStatus"] intValue] ;
        NSInteger CarStatusId = [[dics objectForKey:@"CarStatus"] intValue] ;
        
        
        //    infoArr = @[@"真实姓名:",@"性别:",@"年龄:",@"身份证号:",@"户口所在地:",@"文化程度:",@"婚姻情况:",@"购房情况:",@"购车情况:"];
        NSArray *provinceArr = [dics objectForKey:@"provinceList"];
        if (provinceArr.count) {
            
            for (NSDictionary *item  in provinceArr) {
                if ([[item objectForKey:@"id"] intValue] == registedPlaceProId ) {
                    
                    NSString *registedPlacePro = [NSString stringWithFormat:@"户口所在省份: %@",[item objectForKey:@"name"]];
                    [_dataArr addObject:registedPlacePro];
                    //DLOG(@"fdufhdfhsdfds %@",[item objectForKey:@"name"]);
                }
            }
        }
        NSArray *cityArr = [dics objectForKey:@"cityList"];
        if (cityArr.count) {
            for ( NSDictionary *item  in cityArr) {
                if ([[item objectForKey:@"id"] intValue] == registedPlaceCityId ) {
                    
                    NSString *registedPlaceCity = [NSString stringWithFormat:@"户口所在地: %@",[item objectForKey:@"name"]];
                    [_dataArr addObject:registedPlaceCity];
                    //DLOG(@"registedPlaceCity  %@",[item objectForKey:@"name"]);
                }
            }
        }
        
        NSArray *educationsArr = [dics objectForKey:@"educationsList"];
        if (educationsArr.count) {
            for (NSDictionary *item in educationsArr) {
                if ([[item objectForKey:@"id"] intValue] == higtestEduId ) {
                    
                    NSString *higtestEdu = [NSString stringWithFormat:@"最高学历: %@",[item objectForKey:@"name"]];
                    [_dataArr addObject:higtestEdu];
                    //DLOG(@"higtestEdu is  %@",[item objectForKey:@"name"]);
                }
                
            }
        }
        
        NSArray *maritalsArr = [dics objectForKey:@"maritalsList"];
        for (NSDictionary *item in maritalsArr) {
            
            if ([[item objectForKey:@"id"] intValue] == maritalStatusId ) {
                
                NSString *maritalStatus = [NSString stringWithFormat:@"婚姻情况: %@",[item objectForKey:@"name"]];
                [_dataArr addObject:maritalStatus];
                //DLOG(@"maritalStatus is  %@",[item objectForKey:@"name"]);
            }
        }
        
        
        NSArray *housesArr = [dics objectForKey:@"housesList"];
        for (NSDictionary *item in housesArr) {
            if ([[item objectForKey:@"id"] intValue] == housrseStatusId ) {
                
                NSString *housrseStatus =  [NSString stringWithFormat:@"购房情况: %@",[item objectForKey:@"name"]];
                [_dataArr addObject:housrseStatus];
                //DLOG(@"housrseStatus is  %@",[item objectForKey:@"name"]);
            }
        }
        
        
        
        NSArray *carArr = [dics objectForKey:@"carList"];
        for (NSDictionary *item in carArr) {
            if ([[item objectForKey:@"id"] intValue] == CarStatusId ) {
                
                NSString *CarStatus = [NSString stringWithFormat:@"购车情况: %@",[item objectForKey:@"name"]];
                [_dataArr addObject:CarStatus];
                //DLOG(@"CarStatus is  %@",[item objectForKey:@"name"]);
            }
        }
        
        for (int i = 0; i<[_dataArr count]; i++) {
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SpaceMediumSmall, SpaceMediumBig+35*i, WidthScreen-SpaceMediumSmall*2, 30)];
            titleLabel.font = FontTextContent;
            titleLabel.textColor=ColorTextContent;
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.text = [_dataArr objectAtIndex:i];
            [self.view addSubview:titleLabel];
        }
    }
    else{
        //DLOG(@"返回成功===========%@",[obj objectForKey:@"msg"]);
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
     [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"无可用网络"]];
}

#pragma  分享按钮
- (void)ShareClick
{
    if (AppDelegateInstance.userInfo == nil) {
        
        [SVProgressHUD showErrorWithStatus:@"请登录!"];
        
    }else {
        NSString *shareUrl = [NSString stringWithFormat:@"%@/front/invest/invest?bidId=1122", Baseurl];
        
        //构造分享内容
        id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"来融金服 我要投资 借款详情%@",shareUrl]
                                           defaultContent:@"默认分享内容，没内容时显示"
                                                    image:[ShareSDK pngImageWithImage:[UIImage imageNamed:@"logo"]]
                                                    title:@"借款详情"
                                                      url:shareUrl
                                              description:@"这是一条测试信息"
                                                mediaType:SSPublishContentMediaTypeNews];
        
        [ShareSDK showShareActionSheet:nil
                             shareList:nil
                               content:publishContent
                         statusBarTips:YES
                           authOptions:nil
                          shareOptions: nil
                                result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                    if (state == SSResponseStateSuccess)
                                    {
                                        //DLOG(@"分享成功");
                                    }
                                    else if (state == SSResponseStateFail)
                                    {
                                        //DLOG(@"分享失败,错误码:%ld,错误描述:%@", (long)[error errorCode], [error errorDescription]);
                                        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", [error errorDescription]]];
                                    }
                                }];
    }
}

#pragma 竞拍
- (void)tenderBtnClick
{
    
    if (AppDelegateInstance.userInfo == nil) {
        
     [SVProgressHUD showErrorWithStatus:@"请登录!"];
        
    }
    else
    {
        
        //DLOG(@"竞拍按钮！！！");
        AuctionViewController *AuctionView = [[AuctionViewController alloc] init];
        AuctionView.creditorId = _creditorId;
        [self.navigationController pushViewController:AuctionView animated:YES];
        
        
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
