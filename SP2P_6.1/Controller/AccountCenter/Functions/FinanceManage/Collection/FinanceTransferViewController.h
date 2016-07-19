//
//  FinanceTransferViewController.h
//  SP2P_6.1
//
//  Created by Jerry on 14-8-1.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FinanceTransferViewController : ViewControllerBasicNotNetwork

@property (nonatomic) int investId;
@property (nonatomic,copy)NSString *borrowID;

@property (nonatomic,copy)NSString *bidAmount; // 金额

@end
