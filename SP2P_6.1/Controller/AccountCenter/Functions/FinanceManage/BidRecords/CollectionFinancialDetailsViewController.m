//
//  CollectionFinancialDetailsViewController.m
//  SP2P_6.1
//
//  Created by Jerry on 14-8-1.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//
//  理财子账号 -> 投标记录 -> 借款详情

#import "CollectionFinancialDetailsViewController.h"
#import "LDProgressView.h"
#import "ColorTools.h"
#import "BorrowDetailsCell.h"
#import "TenderOnceViewController.h"
#import <QuartzCore/QuartzCore.h>


#import "UIFolderTableView.h"
#import "DetailsDescriptionViewController.h"
#import "MaterialAuditSubjectViewController.h"
#import "CBORiskControlSystemViewController.h"
#import "HistoricalRecordViewController.h"
#import "TenderAwardViewController.h"
#import "TenderRecordsViewController.h"
#import "AskBorrowerViewController.h"
#import "BorrowerInformationViewController.h"
#import "InterestcalculatorViewController.h"
#import "ReportViewController.h"
#import "SendMessageViewController.h"

@interface CollectionFinancialDetailsViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,HTTPClientDelegate>
{
    
    NSArray *titleArr;
    NSArray *tableArr;
    NSMutableArray *_collectionArrays;
    UIView *scrollPanel;
    int num;
    
}

@property (nonatomic, strong) UIFolderTableView *listView;
//  是否打开二级详情
@property (assign)BOOL isOpen;
@property (nonatomic,retain)NSIndexPath *selectIndex;

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)UIScrollView *ScrollView;
@property (nonatomic,strong)LDProgressView *progressView;
@property (nonatomic,strong)UILabel *progressLabel;

@property (nonatomic,strong)UILabel *usageLabel;
@property (nonatomic,strong)UIImageView * typeImg;
@property (nonatomic,strong)UILabel *wayLabel;
@property (nonatomic,strong)NSString *associatesStr;
@property (nonatomic,strong)NSString *CBOAuditStr;
@property (nonatomic,strong)UILabel *moneyLabel;
@property (nonatomic,strong)UILabel *rateLabel;
@property (nonatomic,strong)UILabel *deadlineLabel;
@property (nonatomic,strong)UILabel *dateLabel;
@property (nonatomic,strong)UILabel *dateLabel2;
@property (nonatomic,copy) NSString *borrowerId;
@property (nonatomic,copy)NSString   *borrowerheadImg;
@property (nonatomic,copy)NSString   *borrowername;
@property (nonatomic,copy)NSString   *borrowid;
@property (nonatomic,copy)NSString   *borrowId;
@property (nonatomic,copy)NSString   *creditRating;
@property (nonatomic,copy)NSArray   *list;    //审核数组  AuditSubjectName  auditStatus   imgpath
@property (nonatomic,strong)UILabel *organizationLabel;
@property (nonatomic,copy)NSString   *VipStr;
@property (nonatomic,copy)NSString   *BorrowsucceedStr;
@property (nonatomic,copy)NSString   *BorrowfailStr;
@property (nonatomic,copy)NSString   *repaymentnormalStr;
@property (nonatomic,copy)NSString   *repaymentabnormalStr;
@property (nonatomic,copy)NSString   *borrowDetails;
@property (nonatomic,copy)NSString   *registrationTime;
@property (nonatomic,copy)NSString   *reimbursementAmount;
@property (nonatomic,copy)NSString   *SuccessBorrowNum;
@property (nonatomic,copy)NSString   *NormalRepaymentNum;
@property (nonatomic,copy)NSString   *OverdueRepamentNum;
@property (nonatomic,copy)NSString   *BorrowingAmount;
@property (nonatomic,copy)NSString   *FinancialBidNum;
@property (nonatomic,copy)NSString   *paymentAmount;
@property (nonatomic,copy)NSString   *awardString;
@property (nonatomic,assign)NSInteger   statuNum;
@property (nonatomic,strong)NSMutableArray  *AuditdataArr;
@property (nonatomic,strong)NSMutableArray  *auditStatusArr;
@property (nonatomic,strong)NSMutableArray  *imgpathArr;
@property (nonatomic,copy)NSString  *bidIdSign;
@property (nonatomic,copy)NSString  *bidUserIdSign;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *organizationtextLabel;//合作机构
@property (nonatomic,strong)UIImageView  *stateImg;
@property(nonatomic ,strong) NetWorkClient *requestClient;

@end

@implementation CollectionFinancialDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 初始化数据
    self.isOpen = NO;
    
    //初始化网络数据
    [self initData];
    
    // 初始化视图
    [self initView];
    
}

/**
 * 初始化数据
 */
- (void)initData
{
    
    titleArr = @[@"借款金额:",@"年  利  率:",@"还款方式:",@"借款期限:",@"还款日期:"];
    tableArr = @[@"详情描述",@"必要材料审核科目",@"CBO风控体系审核",@"历史记录",@"投标奖励",@"投标记录",@"向借款人提问"];
    
    //展开行数组
    _collectionArrays =[[NSMutableArray alloc] init];
    _AuditdataArr = [[NSMutableArray alloc] init];
    _auditStatusArr = [[NSMutableArray alloc] init];
    _imgpathArr = [[NSMutableArray alloc] init];
    
    num = 1;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    //2.2借款详情接口[借款详情详细信息]
    [parameters setObject:@"11" forKey:@"OPT"];
    [parameters setObject:@"" forKey:@"body"];
    [parameters setObject:[NSString stringWithFormat:@"%@",_borrowID] forKey:@"borrowId"];
    
    
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
    self.view.backgroundColor = ColorBGGray;
    
    //滚动视图
    _ScrollView =[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 920)];
    _ScrollView.userInteractionEnabled = YES;
    _ScrollView.scrollEnabled = YES;
    _ScrollView.showsHorizontalScrollIndicator =NO;
    _ScrollView.showsVerticalScrollIndicator = NO;
    _ScrollView.delegate = self;
    _ScrollView.backgroundColor = ColorBGGray;
    _ScrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1160);
    [self.view addSubview:_ScrollView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 220, 35)];
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [_ScrollView addSubview:_titleLabel];
    
    UILabel *idtextLabel = [[UILabel alloc] initWithFrame:CGRectMake(225, 10, 80, 30)];
    idtextLabel.text = @"编号:";
    idtextLabel.textColor = [UIColor lightGrayColor];
    idtextLabel.font = [UIFont systemFontOfSize:12.0f];
    idtextLabel.textAlignment = NSTextAlignmentLeft;
    [_ScrollView addSubview:idtextLabel];
    
    UILabel *idLabel = [[UILabel alloc] initWithFrame:CGRectMake(255, 10, 100, 30)];
    idLabel.text = [NSString stringWithFormat:@"%@",_borrowID];
    idLabel.textColor = [UIColor lightGrayColor];
    idLabel.font = [UIFont systemFontOfSize:12.0f];
    idLabel.textAlignment = NSTextAlignmentLeft;
    [_ScrollView addSubview:idLabel];
    
    
    
    _stateImg = [[UIImageView alloc] initWithFrame:CGRectMake(18, 38, 40, 20)];
    [_ScrollView addSubview:_stateImg];
    
    
    
    _usageLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 38, 50, 17)];
    _usageLabel.textColor = [UIColor darkGrayColor];
    _usageLabel.textAlignment = NSTextAlignmentCenter;
    _usageLabel.backgroundColor = [UIColor whiteColor];
    _usageLabel.font = [UIFont boldSystemFontOfSize:10.0f];
    [_ScrollView addSubview:_usageLabel];
    
    
    _typeImg = [[UIImageView alloc] initWithFrame:CGRectMake(130, 36, 20, 20)];
    _typeImg.backgroundColor = [UIColor clearColor];
    [_ScrollView addSubview:_typeImg];
    
    
    UIButton *collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    collectBtn.frame = CGRectMake(160, 36, 20, 20);
    [collectBtn setImage:[UIImage imageNamed:@"collection"] forState:UIControlStateNormal];
    [collectBtn setImage:[UIImage imageNamed:@"collection"] forState:UIControlStateSelected];
    [collectBtn addTarget:self action:@selector(collectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_ScrollView addSubview:collectBtn];
    
    
    
    _progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(15, 70, 265, 4)];
    _progressView.color = GreenColor;
    _progressView.flat = @YES;// 是否扁平化
    _progressView.borderRadius = @0;
    _progressView.showBackgroundInnerShadow = @NO;
    _progressView.animate = @NO;
    _progressView.progressInset = @0;//内边的边距
    _progressView.showBackground = @YES;
    _progressView.outerStrokeWidth = @0;
    _progressView.showText = @NO;
    _progressView.showStroke = @NO;
    //    _progressView.progress = _progressnum;
    _progressView.background = [UIColor lightGrayColor];
    [_ScrollView addSubview:_progressView];
    
    
    UIImageView *roundimgView = [[UIImageView alloc] initWithFrame:CGRectMake(280, 55, 30, 30)];
    roundimgView.image = [UIImage imageNamed:@"round_back"];
    [_ScrollView addSubview:roundimgView];
    
    _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(283, 62, 30, 15)];
    _progressLabel.font = [UIFont systemFontOfSize:10];
    _progressLabel.textColor = [UIColor whiteColor];
    _progressLabel.adjustsFontSizeToFitWidth = YES;
    //    _progressLabel.text = [NSString stringWithFormat:@"%.0f%%",_progressnum*100];
    [_ScrollView addSubview:_progressLabel];
    
    
    
    for (int i = 0; i<[titleArr count]; i++){
        
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.text = [titleArr objectAtIndex:i];
        textLabel.font = [UIFont systemFontOfSize:12.0f];
        textLabel.textAlignment = NSTextAlignmentRight;
        if (i==3||i==4) {
            
            textLabel.frame = CGRectMake(155, 90+20*(i-3), 60, 20);
            
        }
        else
            textLabel.frame = CGRectMake(10, 90+20*i, 60, 20);
        [_ScrollView addSubview:textLabel];
        
    }
    
    
    _organizationtextLabel = [[UILabel alloc] init];
    _organizationtextLabel.font = [UIFont systemFontOfSize:12.0f];
    _organizationtextLabel.textAlignment = NSTextAlignmentRight;
    _organizationtextLabel.frame = CGRectMake(10, 90+20*3, 60, 20);
    [_ScrollView addSubview:_organizationtextLabel];
    
    
    _moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 90, 100, 20)];
    //    moneyLabel.text =[NSString stringWithFormat: @"￥%0.2f",_amount];
    _moneyLabel.textColor = PinkColor;
    _moneyLabel.font = [UIFont systemFontOfSize:12.0f];
    [_ScrollView addSubview:_moneyLabel];
    
    _rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 110, 100, 20)];
    _rateLabel.textColor = PinkColor;
    _rateLabel.font = [UIFont systemFontOfSize:12.0f];
    [_ScrollView addSubview:_rateLabel];
    
    _wayLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 130, 140, 20)];
    _wayLabel.textColor = [UIColor darkGrayColor];
    _wayLabel.font = [UIFont systemFontOfSize:12.0f];
    _wayLabel.adjustsFontSizeToFitWidth = YES;
    [_ScrollView addSubview:_wayLabel];
    
    _organizationLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 150, 100, 20)];
    _organizationLabel.textColor = [UIColor darkGrayColor];
    _organizationLabel.font = [UIFont systemFontOfSize:12.0f];
    [_ScrollView addSubview:_organizationLabel];
    
    
    _deadlineLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 90, 100, 20)];
    _deadlineLabel.textColor = [UIColor darkGrayColor];
    _deadlineLabel.font = [UIFont systemFontOfSize:12.0f];
    [_ScrollView addSubview:_deadlineLabel];
    
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 110, 80, 20)];
    _dateLabel.textColor = [UIColor darkGrayColor];
    _dateLabel.font = [UIFont systemFontOfSize:12.0f];
    [_ScrollView addSubview:_dateLabel];
    
    UIView *dateBackView = [[UIView alloc] initWithFrame:CGRectMake(10, 180, 110, 30)];
    dateBackView.backgroundColor = PinkColor;
    [_ScrollView addSubview:dateBackView];
    
    
    
    UILabel *dateLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(50, 180, 110, 30)];
    dateLabel1.text = @"剩余时间";
    dateLabel1.textColor = [UIColor whiteColor];
    dateLabel1.font = [UIFont boldSystemFontOfSize:14.0f];
    [_ScrollView addSubview:dateLabel1];
    
    UIImageView *clockImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 185, 22, 22)];
    clockImg.image = [UIImage imageNamed:@"clock_big"];
    clockImg.backgroundColor = [UIColor clearColor];
    [_ScrollView addSubview:clockImg];
    
    _dateLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(120, 180, 190, 30)];
    //    _dateLabel2.text = @"12天23小时34分54秒";
    _dateLabel2.textColor = PinkColor;
    _dateLabel2.backgroundColor = [UIColor whiteColor];
    _dateLabel2.textAlignment = NSTextAlignmentCenter;
    _dateLabel2.font = [UIFont boldSystemFontOfSize:14.0f];
    [_ScrollView addSubview:_dateLabel2];
    
    
    
    _listView = [[UIFolderTableView alloc] initWithFrame:CGRectMake(0, 215, self.view.frame.size.width, 800)  style:UITableViewStyleGrouped];
    _listView.delegate = self;
    _listView.dataSource = self;
    [_listView setBackgroundColor:ColorBGGray];
    [_ScrollView addSubview:_listView];
    
    
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:bottomView aboveSubview:_ScrollView];
    
    
    UIButton *tenderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tenderBtn.frame = CGRectMake(self.view.frame.size.width*0.5-50, 8,100, 25);
    tenderBtn.backgroundColor = GreenColor;
    [tenderBtn setTitle:@"查看账单" forState:UIControlStateNormal];
    [tenderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    tenderBtn.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:13.0];
    [tenderBtn.layer setMasksToBounds:YES];
    [tenderBtn.layer setCornerRadius:3.0];
    [tenderBtn addTarget:self action:@selector(tenderBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:tenderBtn];
    
}


/**
 * 初始化导航条
 */
- (void)initNavigationBar
{
    self.title = @"借款详情";
    [self.navigationController.navigationBar setBarTintColor:ColorWhite];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      ColorNavTitle, NSForegroundColorAttributeName,
                                                                      FontNavTitle, NSFontAttributeName, nil]];
    
    
    // 导航条返回按钮
BarButtonItem *barButtonLeft=[BarButtonItem barItemWithTitle:@"返回" widthImage:[UIImage imageNamed:@"bar_left"] withIsImageLeft:YES target:self action:@selector(backClick)];
    [self.navigationItem setLeftBarButtonItem:barButtonLeft];
    
    // 导航条分享按钮
    UIBarButtonItem *ShareItem=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_share"] style:UIBarButtonItemStyleDone target:self action:@selector(ShareClick)];
    ShareItem.tintColor = [UIColor whiteColor];
    [self.navigationItem setRightBarButtonItem:ShareItem];
    
    
    
}



#pragma HTTPClientDelegate 网络数据回调代理
-(void) startRequest
{
 
}




// 返回成功
-(void) httpResponseSuccess:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didSuccessWithObject:(id)obj
{
    
    //DLOG(@"==返回成功=======%@",obj);
    NSDictionary *dics = obj;
    
    if ([[NSString stringWithFormat:@"%@",[dics objectForKey:@"error"]] isEqualToString:@"-1"]) {
        if (num == 1) {
            
            _titleLabel.text  = [dics objectForKey:@"borrowTitle"];
            _usageLabel.text = [dics objectForKey:@"purpose"]; //用途 borrowAmount
            
            if ([dics objectForKey:@"borrowtype"]!= nil && ![[dics objectForKey:@"borrowtype"]isEqual:[NSNull null]])
            {
                if ([[dics objectForKey:@"borrowtype"] hasPrefix:@"http"]) {
                    
                    [_typeImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dics objectForKey:@"borrowtype"]]]];//借款标类型
                }else{
                    
                    [_typeImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",Baseurl,[dics objectForKey:@"borrowtype"]]]];//借款标类型
                }
            }
            //借款标状态
            _statuNum = [[dics objectForKey:@"borrowStatus"] integerValue];
            switch (_statuNum) {
                case 1:
                    [_stateImg setImage:[UIImage imageNamed:@"state_waiting_info"]];
                    break;
                case 2:
                    [_stateImg setImage:[UIImage imageNamed:@"state_borrowing"]];
                    break;
                case 3:
                    [_stateImg setImage:[UIImage imageNamed:@"state_borrowing"]];
                    break;
                case 4:
                    [_stateImg setImage:[UIImage imageNamed:@"state_borrowing"]];
                    break;
                    
                    
            }
            
            
            
            _progressLabel.text = [NSString stringWithFormat:@"%@%%",[dics objectForKey:@"schedules"]];
            _progressView.progress = [[dics objectForKey:@"schedules"] floatValue]/100;
            _wayLabel.text = [dics objectForKey:@"paymentMode"];//还款方式
            _bidIdSign = [dics objectForKey:@"bidIdSign"];//加密ID
            _moneyLabel.text = [NSString stringWithFormat:@"¥%0.1f",[[dics objectForKey:@"borrowAmount"] floatValue]];
            _rateLabel.text = [NSString stringWithFormat:@"%0.1f%%",[[dics objectForKey:@"annualRate"] floatValue]];
            _deadlineLabel.text = [dics objectForKey:@"deadline"]; // 期限
            if(![[dics objectForKey:@"paymentTime"] isEqual:[NSNull null]])
            {
                //                _dateLabel.text =[NSString stringWithFormat:@"%@",[dics objectForKey:@"paymentTime"]] ;
                NSString *dataStr = [dics objectForKey:@"paymentTime"];
                _dateLabel.text =   [dataStr   substringWithRange:NSMakeRange(0,10)];//截取字符串
            }
            else
            {
                
                _dateLabel.text =@"无数据";
                
            }
            
            
            //合作机构
            if( ![[dics objectForKey:@"associates"] isEqualToString:@""])
            {
                _organizationLabel.text = [dics objectForKey:@"associates"];
                _organizationtextLabel.text = @"合作机构:";
                
            }
            
            
            if( [dics objectForKey:@"remainTime"] != nil &&![[dics objectForKey:@"remainTime"] isEqual:[NSNull null]])
            {
                
                NSString *timeStr = [[NSString stringWithFormat:@"%@",[dics objectForKey:@"remainTime"]] substringWithRange:NSMakeRange(0, 19)];
                
                //剩余时间
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
                NSDate *senddate=[NSDate date];
                //结束时间
                NSDate *endDate = [dateFormatter dateFromString:timeStr];
                //当前时间
                NSDate *senderDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:senddate]];
                //得到相差秒数
                NSTimeInterval time=[endDate timeIntervalSinceDate:senderDate];
                int days = ((int)time)/(3600*24);
                int hours = ((int)time)%(3600*24)/3600;
                int minute = ((int)time)%(3600*24)/3600/60;
                
                if (days <= 0&&hours <= 0&&minute <= 0)
                    _dateLabel2.text =@"0天0时0分";
                else
                    _dateLabel2.text = [[NSString alloc] initWithFormat:@"%i天%i时%i分",days,hours,minute];
                
            }
            
            _VipStr = [NSString stringWithFormat:@"%@",[dics objectForKey:@"vipStatus"]];
            //借款详情描述
            _borrowDetails = [dics objectForKey:@"borrowDetails"];
            //CBO审核
            _CBOAuditStr =  [dics objectForKey:@"CBOAuditDetails"];
            _borrowerId = [NSString stringWithFormat:@"%@",[dics objectForKey:@"bidUserIdSign"]];
            _borrowId = [NSString stringWithFormat:@"%@",[dics objectForKey:@"borrowid"]];
            _borrowerheadImg = [dics objectForKey:@"borrowerheadImg"];
            if( [dics objectForKey:@"borrowername"] != nil &&![[dics objectForKey:@"borrowername"] isEqual:[NSNull null]])
            {
                _borrowername = [dics objectForKey:@"borrowername"];
                
            }
            _creditRating = [dics objectForKey:@"creditRating"];
            _BorrowsucceedStr = [dics objectForKey:@"borrowSuccessNum"];
            _BorrowfailStr = [dics objectForKey:@"borrowFailureNum"];
            _repaymentnormalStr= [dics objectForKey:@"repaymentNormalNum"];
            _repaymentabnormalStr = [dics objectForKey:@"repaymentOverdueNum"];
            
            //审核科目数组
            if( [dics objectForKey:@"list"] != nil && ![[dics objectForKey:@"list"] isEqual:[NSNull null]])
            {
                _list = [dics objectForKey:@"list"];
                for (NSDictionary* dic in _list) {
                    [_AuditdataArr addObject:[dic  objectForKey:@"AuditSubjectName"]];
                    [_auditStatusArr addObject:[dic  objectForKey:@"auditStatus"]];
                    [_imgpathArr addObject:[dic  objectForKey:@"imgpath"]];
                }
            }
            
            
            
            //历史纪录部分
            if( [dics objectForKey:@"registrationTime"] != nil &&![[dics objectForKey:@"registrationTime"] isEqual:[NSNull null]])
            {
                _registrationTime = [NSString stringWithFormat:@"%@",[dics objectForKey:@"registrationTime"]];
            }
            
            _SuccessBorrowNum = [NSString stringWithFormat:@"%@",[dics objectForKey:@"SuccessBorrowNum"]];
            _NormalRepaymentNum = [NSString stringWithFormat:@"%@",[dics objectForKey:@"NormalRepaymentNum"]];
            _OverdueRepamentNum = [NSString stringWithFormat:@"%@",[dics objectForKey:@"OverdueRepamentNum"]];
            _reimbursementAmount = [NSString stringWithFormat:@"%@",[dics objectForKey:@"reimbursementAmount"]];
            _BorrowingAmount = [NSString stringWithFormat:@"%@",[dics objectForKey:@"BorrowingAmount"]];
            _FinancialBidNum = [NSString stringWithFormat:@"%@",[dics objectForKey:@"FinancialBidNum"]];
            _paymentAmount = [NSString stringWithFormat:@"%@",[dics objectForKey:@"paymentAmount"]];
            
            //投标奖励
            _awardString = [NSString stringWithFormat:@"%@",[dics objectForKey:@"bonus"]] ;//奖励
            
            [_listView reloadData];
            
        }else if (num == 2 || num == 3)
        {
            
            //DLOG(@"收藏信息===========%@",[obj objectForKey:@"msg"]);
           [SVProgressHUD showSuccessWithStatus:[obj objectForKey:@"msg"]];
  
        }
        
        
        
    }
    else{
        
        //DLOG(@"返回失败===========%@",[obj objectForKey:@"msg"]);
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


#pragma mark UItableViewdelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [tableArr count]+1;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 5.0f;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 95.0f;
    }
    else
        return 35.0f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return 5.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        
        
        static  NSString *cellID = @"cellid";
        BorrowDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[BorrowDetailsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        if ([[NSString stringWithFormat:@"%@",_borrowerheadImg] hasPrefix:@"http"])
        {
            
             [cell.HeadimgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",_borrowerheadImg]]];
        }else
        {
          [cell.HeadimgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",Baseurl,_borrowerheadImg]]];
        }
        cell.NameLabel.text = _borrowername;
        cell.BorrowsucceedLabel.text = _BorrowsucceedStr;
        cell.BorrowfailLabel.text = _BorrowfailStr;
        cell.repaymentnormalLabel.text = _repaymentnormalStr;
        cell.repaymentabnormalLabel.text = _repaymentabnormalStr;
        
        if ([_creditRating hasPrefix:@"http"]) {
            
            [cell.LevelimgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",_creditRating]]];
        }else
        {
           [cell.LevelimgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",Baseurl,_creditRating]]];
        }
        [cell.attentionBtn addTarget:self action:@selector(attentionBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [cell.CalculateBtn setImage:[UIImage imageNamed:@"menu_calculator"] forState:UIControlStateNormal];
        [cell.CalculateBtn addTarget:self action:@selector(CalculateBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *expanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        expanBtn.frame = CGRectMake(self.view.frame.size.width-30, 35, 25, 20);
        [expanBtn setImage:[UIImage imageNamed:@"cell_more_btn"] forState:UIControlStateNormal];
        [expanBtn setTag:100];
        expanBtn.userInteractionEnabled = NO;
        [cell addSubview:expanBtn];
        return cell;
    }
    else{
        NSString *cellID2 = @"cellid2";
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID2];
        }
        cell.textLabel.text = [tableArr objectAtIndex:indexPath.section-1];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        
        
        UIButton *expanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        expanBtn.frame = CGRectMake(self.view.frame.size.width-30, 8, 25, 20);
        [expanBtn setImage:[UIImage imageNamed:@"expan_down_btn"] forState:UIControlStateNormal];
        [expanBtn setImage:[UIImage imageNamed:@"expand_up_btn"] forState:UIControlStateSelected];
        [expanBtn setTag:indexPath.section];
        expanBtn.userInteractionEnabled = NO;
        if (indexPath.section == 6||indexPath.section == 7) {
            
            [expanBtn setImage:[UIImage imageNamed:@"cell_more_btn"] forState:UIControlStateNormal];
        }
        [cell addSubview:expanBtn];
        
        return cell;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell1 = [_listView cellForRowAtIndexPath:indexPath];
    UIButton *btn = (UIButton *)[cell1 viewWithTag:indexPath.section];
    
    if (btn.selected==0) {
        btn.selected = 1;
    }
    
    
    UIFolderTableView *folderTableView = (UIFolderTableView *)tableView;
    switch (indexPath.section) {
        case 0:
        {
            BorrowerInformationViewController *BorrowerInformationView = [[BorrowerInformationViewController alloc] init];
            BorrowerInformationView.borrowerID = _borrowerId;
            BorrowerInformationView.borrowId = _borrowId;
            [self.navigationController pushViewController:BorrowerInformationView animated:NO];
        }
            break;
            
        case 1:
        {
            DetailsDescriptionViewController *DetailsDescriptionView = [[DetailsDescriptionViewController alloc] init];
            DetailsDescriptionView.textString = _borrowDetails;
            _listView.scrollEnabled = NO;
            [folderTableView openFolderAtIndexPath:indexPath WithContentView:DetailsDescriptionView.view
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
            break;
        case 2:
        {
            MaterialAuditSubjectViewController *MaterialAuditSubjectView = [[MaterialAuditSubjectViewController alloc] init];
            _listView.scrollEnabled = NO;
            MaterialAuditSubjectView.view.frame = CGRectMake(0, 0, 1000, [_AuditdataArr count]*30+25);
            
            for (int i = 0; i<[_AuditdataArr count]; i++) {
                
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5+35*i, 100, 30)];
                titleLabel.font = [UIFont systemFontOfSize:13.0f];
                titleLabel.textAlignment = NSTextAlignmentCenter;
                titleLabel.text = [_AuditdataArr objectAtIndex:i];
                [MaterialAuditSubjectView.view addSubview:titleLabel];
                
                UIButton *lookBtn = [UIButton  buttonWithType:UIButtonTypeRoundedRect];
                [lookBtn setTag:i+100];
                [lookBtn setFrame:CGRectMake(250, 5+35*i, 80, 30)];
                [lookBtn setTitle:@"查看" forState:UIControlStateNormal];
                [lookBtn setTintColor:[UIColor grayColor]];
                lookBtn.titleLabel.textColor = [UIColor grayColor];
                [lookBtn addTarget:self action:@selector(LookBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [MaterialAuditSubjectView.view addSubview:lookBtn];
                
                
                UIImageView *stateView = [[UIImageView alloc] initWithFrame:CGRectMake(130, 8+35*i, 25, 25)];
                [stateView setTag:i+100];
                
                
                UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(165, 0+35*i, 40, 40)];
                [stateLabel setTag:i+100];
                stateLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:13.0f];
                
                
                if ([[_auditStatusArr objectAtIndex:i] isEqualToString:@"通过审核"]) {
                    [stateView setImage:[UIImage imageNamed:@"loan_pass"]];
                    stateLabel.text = @"通过";
                    stateLabel.textColor = GreenColor;
                }
                else if ([[_auditStatusArr objectAtIndex:i] isEqualToString:@"审核中"])
                {
                    [stateView setImage:[UIImage imageNamed:@"loan_wait"]];
                    stateLabel.text = @"待审核";
                    stateLabel.textColor = [UIColor grayColor];
                    
                    
                }
                //                if([[_auditStatusArr objectAtIndex:i] isEqualToString:@"审核不通过"])
                else
                {
                    
                    [stateView setImage:[UIImage imageNamed:@"loan_nopass"]];
                    stateLabel.text = @"未通过";
                    stateLabel.textColor = [UIColor grayColor];
                    
                    
                }
                
                [MaterialAuditSubjectView.view addSubview:stateView];
                [MaterialAuditSubjectView.view addSubview:stateLabel];
                
                
            }
            
            [folderTableView openFolderAtIndexPath:indexPath WithContentView:MaterialAuditSubjectView.view
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
            
            //            for (int i=0; i<[MaterialAuditSubjectView.dataArr count]; i++) {
            //                UIButton *btn  = (UIButton *)[MaterialAuditSubjectView.view viewWithTag:100+i];
            //                [btn addTarget:self action:@selector(LookBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            //
            //            }
            
        }
            
            break;
        case 3:
        {
            
            CBORiskControlSystemViewController *CBORiskControlSystemView = [[CBORiskControlSystemViewController alloc] init];
            CBORiskControlSystemView.CBOtextString= _CBOAuditStr;
            _listView.scrollEnabled = NO;
            [folderTableView openFolderAtIndexPath:indexPath WithContentView:CBORiskControlSystemView.view
                                         openBlock:^(UIView *subClassView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction){
                                             // opening actions
                                             //[self CloseAndOpenACtion:indexPath];
                                             btn.selected = !btn.selected;
                                         }
                                        closeBlock:^(UIView *subClassView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction){
                                            // closing actions
                                            
                                        }
                                   completionBlock:^{
                                       // completed actions
                                       _listView.scrollEnabled = YES;
                                   }];
            
            
            
        }
            break;
        case 4:
        {
            HistoricalRecordViewController *HistoricalRecordView = [[HistoricalRecordViewController alloc] init];
            HistoricalRecordView.timeString = _registrationTime;
            HistoricalRecordView.successfulnumString = [NSString stringWithFormat:@"%@  次",_SuccessBorrowNum];
            HistoricalRecordView.normalnumString = [NSString stringWithFormat:@"%@  次",_NormalRepaymentNum];
            HistoricalRecordView.limitnumString = [NSString stringWithFormat:@"%@  次",_OverdueRepamentNum];
            HistoricalRecordView.repaymentString = [NSString stringWithFormat:@"%@  元",_reimbursementAmount];
            HistoricalRecordView.borrowString = [NSString stringWithFormat:@"%@  元",_BorrowingAmount];
            HistoricalRecordView.tendernumString = [NSString stringWithFormat:@"%@  次",_FinancialBidNum];
            HistoricalRecordView.receiptString = [NSString stringWithFormat:@"%@  元",_paymentAmount];
            
            
            _listView.scrollEnabled = NO;
            [folderTableView openFolderAtIndexPath:indexPath WithContentView:HistoricalRecordView.view
                                         openBlock:^(UIView *subClassView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction){
                                             // opening actions
                                             //[self CloseAndOpenACtion:indexPath];
                                             btn.selected = !btn.selected;
                                         }
                                        closeBlock:^(UIView *subClassView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction){
                                            // closing actions
                                            
                                        }
                                   completionBlock:^{
                                       // completed actions
                                       _listView.scrollEnabled = YES;
                                   }];
            
        }
            break;
            
            
        case 5:
        {
            TenderAwardViewController *TenderAwardView = [[TenderAwardViewController alloc] init];
            
            
            UILabel *textlabel1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 120, 30)];
            
            textlabel1.font = [UIFont boldSystemFontOfSize:13.0f];
            textlabel1.textColor = [UIColor grayColor];
            
            
            UILabel *textlabel3 = [[UILabel alloc] initWithFrame:CGRectMake(80, 20, 260, 30)];
            textlabel3.font = [UIFont systemFontOfSize:13.0f];
            textlabel3.textColor = [UIColor redColor];
            
            
            UILabel *textlabel2 = [[UILabel alloc] initWithFrame:CGRectMake(155, 20, 260, 30)];
            textlabel2.font = [UIFont boldSystemFontOfSize:13.0f];
            textlabel2.textColor = [UIColor grayColor];
            
            if([_awardString isEqualToString:@"0"])
            {
                
                textlabel2.text = @"不设置奖励";
                textlabel2.frame = CGRectMake(20, 20, 260, 30);
                
            }else{
                
                textlabel1.text = @"固定奖金";
                textlabel2.text = @"元，按投标比例分配。";
                textlabel3.text = _awardString;
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                UIFont *font = [UIFont boldSystemFontOfSize:13.0f];
                NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
                
                
                CGSize _label3Sz = [textlabel3.text boundingRectWithSize:CGSizeMake(999, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
                CGSize _label2Sz = [textlabel2.text boundingRectWithSize:CGSizeMake(999, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
                
                textlabel3.frame = CGRectMake(80, 20,  _label3Sz.width+5, 30);
                textlabel2.frame = CGRectMake(textlabel3.frame.origin.x + textlabel3.frame.size.width+10, 20, _label2Sz.width + 15, 30);
                
            }
            
            
            
            
            [TenderAwardView.view addSubview:textlabel1];
            [TenderAwardView.view addSubview:textlabel3];
            [TenderAwardView.view addSubview:textlabel2];
            
            
            _listView.scrollEnabled = NO;
            [folderTableView openFolderAtIndexPath:indexPath WithContentView:TenderAwardView.view
                                         openBlock:^(UIView *subClassView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction){
                                             // opening actions
                                             //[self CloseAndOpenACtion:indexPath];
                                             btn.selected = !btn.selected;
                                         }
                                        closeBlock:^(UIView *subClassView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction){
                                            
                                        }
                                   completionBlock:^{
                                       // completed actions
                                       _listView.scrollEnabled = YES;
                                   }];
            
        }
            break;
            
            
        case 6:
        {
            btn.selected = 0;
            TenderRecordsViewController *TenderRecordsView = [[TenderRecordsViewController alloc] init];
            TenderRecordsView.borrowID = _borrowId;
            [self.navigationController pushViewController:TenderRecordsView animated:NO];
            
        }
            break;
            
            
        case 7:
        {
            btn.selected = 0;
            AskBorrowerViewController *AskBorrowerView = [[AskBorrowerViewController alloc] init];
            AskBorrowerView.borrowId = _borrowId;
            AskBorrowerView.bidUserIdSign = _borrowerId;
            [self.navigationController pushViewController:AskBorrowerView animated:NO];
            
        }
            break;
            
            
    }
    
    
    
}


#pragma mark 查看按钮
- (void)LookBtnClick:(UIButton *)btn
{
    
    //DLOG(@"点击了查看按钮%ld", (long)btn.tag);
    
    if ([_imgpathArr objectAtIndex:btn.tag-100]) {
        scrollPanel = [[UIView alloc] initWithFrame:self.view.bounds];
        scrollPanel.backgroundColor = [UIColor lightGrayColor];
        scrollPanel.alpha = 0;
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 180, self.view.frame.size.width - 20, 200)];
       
        if ([[NSString stringWithFormat:@"%@",[_imgpathArr objectAtIndex:btn.tag-100]] hasPrefix:@"http"]) {
            
              [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[_imgpathArr objectAtIndex:btn.tag-100]]]];
        }else{
            
            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",Baseurl,[_imgpathArr objectAtIndex:btn.tag-100]]]];
        }
    
        [imageView addGestureRecognizer:tap];
        [imageView setUserInteractionEnabled:YES];
        [scrollPanel addSubview:imageView];
        
        [self.view bringSubviewToFront:scrollPanel];
        scrollPanel.alpha = 1.0;
        [self.view addSubview:scrollPanel];
        
        
    }
    
}

#pragma 退出证件查看
-(void)tapClick
{
    
    [scrollPanel removeFromSuperview];
    
}

#pragma mark 关注按钮
- (void)attentionBtnClick
{
    
    if (AppDelegateInstance.userInfo == nil) {
        
      [SVProgressHUD showErrorWithStatus:@"请登录!"];
    }
    else
    {
        
        //DLOG(@"关注按钮");
        
        num = 3;
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        //关注接口
        [parameters setObject:@"71" forKey:@"OPT"];
        [parameters setObject:@"" forKey:@"body"];
        [parameters setObject:[NSString stringWithFormat:@"%@",_borrowerId] forKey:@"bidUserIdSign"];
        [parameters setObject:[NSString stringWithFormat:@"%@",AppDelegateInstance.userInfo.userId] forKey:@"id"];
        
        if (_requestClient == nil) {
            _requestClient = [[NetWorkClient alloc] init];
            _requestClient.delegate = self;
            
        }
        [_requestClient requestGet:@"app/services" withParameters:parameters];
    }
    
}


#pragma mark 信件按钮
- (void)MailBtnClick
{
    if (AppDelegateInstance.userInfo == nil) {
        
        [SVProgressHUD showErrorWithStatus:@"请登录!"];
        
    }
    else
    {
        
        //DLOG(@"信件按钮");
        SendMessageViewController *SendMessageView = [[SendMessageViewController alloc] init];
        SendMessageView.borrowName = _borrowername;
        SendMessageView.borrowerid = _borrowerId;
        [self.navigationController pushViewController:SendMessageView animated:YES];
        
        
    }
}

#pragma mark 举报按钮
- (void)ReportBtnClick
{
    if (AppDelegateInstance.userInfo == nil) {
        
      [SVProgressHUD showErrorWithStatus:@"请登录!"];
        
    }else {
        
        //DLOG(@"举报按钮");
        ReportViewController *reportView = [[ReportViewController alloc] init];
        reportView.bidIdSign = _bidIdSign;
        reportView.borrowName = _borrowername;
        reportView.reportName = AppDelegateInstance.userInfo.userName;
        [self.navigationController pushViewController:reportView animated:YES];
    }
    
}



#pragma mark 计算器按钮
- (void)CalculateBtnClick
{
    //DLOG(@"计算器按钮");
    InterestcalculatorViewController *interestcalculatorView = [[InterestcalculatorViewController alloc] init];
    [self.navigationController pushViewController:interestcalculatorView animated:NO];
}

#pragma mark 收藏按钮
- (void)collectBtnClick:(UIButton *)btn
{
    //DLOG(@"收藏按钮");
    //btn.selected = !btn.selected;
    
    if (AppDelegateInstance.userInfo == nil) {
        
          [SVProgressHUD showErrorWithStatus:@"请登录!"];
        
    }
    else
    {
        
        num = 2;
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        //收藏借款标接口
        [parameters setObject:@"72" forKey:@"OPT"];
        [parameters setObject:@"" forKey:@"body"];
        [parameters setObject:[NSString stringWithFormat:@"%@",_bidIdSign] forKey:@"bidIdSign"];
        [parameters setObject:[NSString stringWithFormat:@"%@",AppDelegateInstance.userInfo.userId] forKey:@"id"];
        
        if (_requestClient == nil) {
            _requestClient = [[NetWorkClient alloc] init];
            _requestClient.delegate = self;
            
        }
        [_requestClient requestGet:@"app/services" withParameters:parameters];
        
    }
    
}

#pragma  分享按钮
- (void)ShareClick
{
    if (AppDelegateInstance.userInfo == nil) {
        
        [SVProgressHUD showErrorWithStatus:@"请登录!"];
        
    }else {
        //DLOG(@"分享按钮");
        
//        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"logo" ofType:@"png"];
        
        NSString *shareUrl = [NSString stringWithFormat:@"%@/front/invest/invest?bidId=%@", Baseurl, _borrowID];
        
        //构造分享内容
        id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"来融金服 理财子账户 投标记录 借款详情%@",shareUrl]
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


#pragma 返回按钮触发方法
- (void)backClick
{
    // //DLOG(@"返回按钮");
    [super setHidesBottomBarWhenPushed:NO];
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma 立即投标ann
- (void)tenderBtnClick
{
    //DLOG(@"查看账单");
    
//    if (AppDelegateInstance.userInfo == nil) {
//        
//        
//     [SVProgressHUD showErrorWithStatus:@"请登录!"];
//
//    }
//    else
//    {
//        
//        TenderOnceViewController *TenderOnceView = [[TenderOnceViewController alloc] init];
//        TenderOnceView.borrowId = _borrowId;
//        [self.navigationController pushViewController:TenderOnceView animated:NO];
//    }
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestClient != nil) {
        [_requestClient cancel];
    }
}

@end