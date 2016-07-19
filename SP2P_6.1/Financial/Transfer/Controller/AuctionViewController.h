//
//  AuctionViewController.h
//  SP2P_6.1
//
//  Created by Jerry on 14-7-28.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuctionViewController : ViewControllerBasicNotNetwork

@property (nonatomic, strong) NSString *debtTitle;
@property (nonatomic, strong) NSString *debterName;
@property (nonatomic, strong) NSString *creditorId;
@property (nonatomic, copy) NSString *debtNo;   // 编号

@end