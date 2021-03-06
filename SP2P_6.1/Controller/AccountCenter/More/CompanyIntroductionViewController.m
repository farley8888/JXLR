//
//  CompanyIntroductionViewController.m
//  SP2P_6.1
//
//  Created by kiu on 14-6-13.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//

#import "CompanyIntroductionViewController.h"

#import "ColorTools.h"

@interface CompanyIntroductionViewController ()<HTTPClientDelegate>

@property (nonatomic, strong) UIWebView *webView;

@property(nonatomic ,strong) NetWorkClient *requestClient;

@end

@implementation CompanyIntroductionViewController

// 加载页面之前 加载数据
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    [parameters setObject:@"77" forKey:@"OPT"];
    [parameters setObject:@"" forKey:@"body"];
    
    if (_requestClient == nil) {
        _requestClient = [[NetWorkClient alloc] init];
        _requestClient.delegate = self;
        
    }
    [_requestClient requestGet:@"app/services" withParameters:parameters];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
}

/**
 初始化数据
 */
- (void)initView
{
    self.title = @"公司简介";
    
    [self initContent];
}

/**
 * 初始化内容
 */
- (void)initContent
{
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, WidthScreen, HeightScreen-HeightNavigationAndStateBar)];
    _webView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_webView];
}
#pragma HTTPClientDelegate 网络数据回调代理
-(void) startRequest
{
   
}

// 返回成功
-(void) httpResponseSuccess:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didSuccessWithObject:(id)obj
{
    
    NSDictionary *dics = obj;
    
    if ([[NSString stringWithFormat:@"%@",[dics objectForKey:@"error"]] isEqualToString:@"-1"]) {
        
        //DLOG(@"返回成功  msg -> %@",[obj objectForKey:@"msg"]);
        
        NSString *content = nil;
        
        id object = [obj objectForKey:@"content"];
        
        if ([object isKindOfClass:[NSArray class]]) {
            
            if ([object count] != 0) {
                
                content = object[0];
            }
        }else{
            
            content = object;
        }
        
        if (![object isEqual:[NSNull null]] && content != nil) {
            
            content = [content stringByReplacingOccurrencesOfString:@"alt=\"\" " withString:@""];
            
            content = [content stringByReplacingOccurrencesOfString:@"<img src=\"/" withString:[NSString stringWithFormat:@"<img style=\"width:%f\" src=\"%@/", self.view.frame.size.width - 20, Baseurl]]; //替换相对路径
            
            [_webView loadHTMLString:content baseURL:[NSURL URLWithString:Baseurl]];
        }
        
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
