//
//  HistoricalRecordViewController.h
//  SP2P_6.1
//
//  Created by Jerry on 14-7-2.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>
#define HeightHistoricalView 210
@interface HistoricalRecordViewController : UIViewController
@property (nonatomic,copy)NSString *timeString;
@property (nonatomic,copy)NSString *successfulnumString;
@property (nonatomic,copy)NSString *normalnumString;
@property (nonatomic,copy)NSString *limitnumString;
@property (nonatomic,copy)NSString *repaymentString;
@property (nonatomic,copy)NSString *borrowString;
@property (nonatomic,copy)NSString *tendernumString;
@property (nonatomic,copy)NSString *receiptString;
@end