//
//  ScreenViewOneController.m
//  SP2P_6.1
//
//  Created by Jerry on 14-7-9.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//

#import "ScreenViewOneController.h"
#import "ColorTools.h"
#import "SKSTableView.h"
#import "SKSTableViewCell.h"
#import "QCheckBox.h"
#import "ScreenModel.h"

@interface ScreenViewOneController ()<UITableViewDataSource,UITableViewDelegate,SKSTableViewDelegate>
{
    NSMutableArray *ScreenArr;
    NSMutableArray *screenDataArr;
    NSInteger _emptyNum;
    NSInteger _sureNum;
    NSInteger _selectNum;
}

@property (nonatomic,strong) NSArray *contents;
@property (nonatomic,strong) QCheckBox *check;
@property (nonatomic,strong) SKSTableView *tableView;
@property (nonatomic,strong) UIDatePicker *datePicker;
@property (nonatomic,strong)UIView *backView; //时间选择器背景
@property (nonatomic,strong)UIButton *emptyBtn;
@property (nonatomic,strong)UIButton *SureBtn;
@property (nonatomic, strong) NSString *timeStr;


@end

@implementation ScreenViewOneController

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
    [self contents];
    _emptyNum = 0;
    _sureNum = 0;
    _selectNum  = 0;
    _timeStr = [[NSString alloc] init];
    ScreenArr = [[NSMutableArray alloc] init];
    screenDataArr = [[NSMutableArray alloc] init];
    
}

/**
 初始化数据
 */
- (void)initView
{
    
    [self initNavigationBar];
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = ColorBGGray;
    
    //列表初始化
    _tableView = [[SKSTableView alloc] initWithFrame:CGRectMake(self.leftMargin, 0, self.view.frame.size.width - self.leftMargin, self.view.frame.size.height-44) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    self.tableView.SKSTableViewDelegate = self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:bottomView aboveSubview:_tableView];
    UIView *viewLine=[[UIView alloc] initWithFrame:CGRectMake(0, 0, WidthScreen, HeightLine)];
    viewLine.backgroundColor=ColorLine;
    [bottomView addSubview:viewLine];
    
    _emptyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _emptyBtn.frame = CGRectMake(85, SpaceSmall,95, 44-SpaceSmall*2);
    [_emptyBtn setBackgroundImage:[ImageTools imageWithColor:[UIColor grayColor] withAlpha:1.0] forState:UIControlStateNormal];
    [_emptyBtn setBackgroundImage:[ImageTools imageWithColor:[UIColor grayColor] withAlpha:0.6] forState:UIControlStateHighlighted];
    [_emptyBtn setTitle:@"清空" forState:UIControlStateNormal];
    _emptyBtn.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:13.0];
    [_emptyBtn.layer setMasksToBounds:YES];
    [_emptyBtn.layer setCornerRadius:3.0];
    [_emptyBtn addTarget:self action:@selector(emptyBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_emptyBtn];
    
    _SureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _SureBtn.frame = CGRectMake(205, SpaceSmall,95, 44-SpaceSmall*2);
    [_SureBtn setBackgroundImage:[ImageTools imageWithColor:ColorRedMain withAlpha:1.0] forState:UIControlStateNormal];
    [_SureBtn setBackgroundImage:[ImageTools imageWithColor:ColorRedMain withAlpha:0.6] forState:UIControlStateHighlighted];
    [_SureBtn setTitle:@"确定" forState:UIControlStateNormal];
    _SureBtn.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:13.0];
    [_SureBtn.layer setMasksToBounds:YES];
    [_SureBtn.layer setCornerRadius:3.0];
    [_SureBtn addTarget:self action:@selector(SureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_SureBtn];
    
    _backView = [[UIView alloc] initWithFrame:CGRectMake(60,self.view.frame.size.height - 44-162, WidthScreen, 162)];
    _backView.backgroundColor = [UIColor whiteColor];
    
    
    //时间选择器
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
    
    NSDate *currentTime  = [NSDate date];
    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, WidthScreen, 162)];
    // [datePicker   setTimeZone:[NSTimeZone defaultTimeZone]];
    [_datePicker setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];
    // 设置当前显示
    [_datePicker setDate:currentTime animated:YES];
    // 设置显示最大时间（
    //[datePicker setMaximumDate:currentTime];
    // 显示模式
    [_datePicker setDatePickerMode:UIDatePickerModeDate];
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中
    _datePicker.locale = locale;
    
    _datePicker.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    _datePicker.frame = CGRectMake(0, 0,250, 50);
    // 回调的方法由于UIDatePicker 是UIControl的子类 ,可以在UIControl类的通知结构中挂接一个委托
    [_datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_backView addSubview:_datePicker];
}

//初始化
- (NSArray *)contents
{
    if (!_contents) {
        
        _contents = @[@[@[@"利率",@"10%以下",@"10%-12%",@"12%-15%",@"15%以上"]],
                      @[@[@"金额",@"10万以下",@"10-30万",@"30-50万",@"50-100万",@"100万以上"]],
                      @[@[@"认购进度",@"50%以下",@"50%-80%",@"80%以上",@"满标"]]];
    }
    return _contents;
}

/**
 * 初始化导航条
 */
- (void)initNavigationBar
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    titleLabel.textColor = ColorTextContent;
    titleLabel.textAlignment = NSTextAlignmentRight;
    titleLabel.font = FontTextContent;
    titleLabel.text = @"筛选条件";
    self.navigationItem.titleView =  titleLabel;
    [self.navigationController.navigationBar setBarTintColor:ColorWhite];
}

#pragma mark - UITableView代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.contents count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return 42.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.contents[section] count];
}

-(NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.contents[indexPath.section][indexPath.row] count] - 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellid = [NSString stringWithFormat:@"cellid%ld",(long)indexPath.section];
    SKSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[SKSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        UIImageView *imageViewLine=[[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(cell.frame)-HeightLine, CGRectGetWidth(cell.frame), HeightLine)];
        [imageViewLine setImage:[ImageTools imageWithColor:ColorLine]];
        [cell addSubview:imageViewLine];
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WidthScreen, cell.frame.size.height)];
        imageView.image=[ImageTools imageWithColor:ColorBtnWhiteHighlight];
        cell.selectedBackgroundView=imageView;
    }
    cell.textLabel.text = self.contents[indexPath.section][indexPath.row][0];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    cell.textLabel.textColor=ColorTextContent;
    cell.expandable = YES;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld%ld", (long)indexPath.section, (long)indexPath.row,(long)indexPath.subRow];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setTag:[[NSString stringWithFormat:@"%ld%ld%ld", (long)indexPath.section, (long)indexPath.row,(long)indexPath.subRow] intValue]];
    if (indexPath.section < 5 && indexPath.section != 4)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@",self.contents[indexPath.section][indexPath.row][indexPath.subRow]];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        
        //单选按钮
        _check = [[QCheckBox alloc] initWithDelegate:self];
        _check.frame = CGRectMake(self.view.frame.size.width-90, 5, 40, 40);
        [_check setTag:[[NSString stringWithFormat:@"%ld%ld%ld", (long)indexPath.section, (long)indexPath.row,(long)indexPath.subRow] intValue]];
        for (int i=0; i<[ScreenArr count]; i++) {
            ScreenModel *model = [ScreenArr objectAtIndex:i];
            if (_check.tag==model.Tag) {
                model.name=cell.textLabel.text;
                DLOG(@"%@",model.name);
                [_check setImage:[UIImage imageNamed:@"checkbox1_unchecked"] forState:UIControlStateNormal];
                cell.textLabel.textColor = PinkColor;
                _check.selected=YES;
            }
        }
        [_check setImage:[UIImage imageNamed:@"checkbox1_unchecked"] forState:UIControlStateNormal];
        [_check setImage:[UIImage imageNamed:@"screen_btn"] forState:UIControlStateSelected];
        [_check setTitle:nil forState:UIControlStateNormal];
        [_check setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_check.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
        
        [cell.contentView addSubview:_check];
    }
    if (indexPath.section == 4) {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLOG(@"indexPath is %ld",(long)indexPath.section);
//     UITableViewCell *cell1 = (UITableViewCell *)[_tableView viewWithTag:401];
    if (indexPath.section == 4) {
        if (_selectNum==0) {
            
            _sureNum = 1;
            _emptyNum = 1;
            _selectNum = 1;
            [_emptyBtn setTitle:@"取消时间选择" forState:UIControlStateNormal];
            [_SureBtn setTitle:@"确定时间" forState:UIControlStateNormal];
            [self.view insertSubview:_backView aboveSubview:_tableView];
            _tableView.frame =  CGRectMake(self.leftMargin, 0, self.view.frame.size.width - self.leftMargin, self.view.frame.size.height-44-162);
        }else{
        
            _sureNum = 0;
            _emptyNum = 0;
            _selectNum = 0;
            _tableView.frame =  CGRectMake(self.leftMargin, 0, self.view.frame.size.width - self.leftMargin, self.view.frame.size.height-44);
            [_emptyBtn setTitle:@"清空" forState:UIControlStateNormal];
            [_SureBtn setTitle:@"确定" forState:UIControlStateNormal];
            [_backView removeFromSuperview];
        
        
        }
    }
}


-(void)datePickerValueChanged:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
    NSDate *selectDate = [_datePicker date];
    NSDate *nowDate = [NSDate date];
    NSString *nowString = [dateFormatter stringFromDate:nowDate];
    NSString *selectString = [dateFormatter stringFromDate:selectDate];
    NSDate *nowStrDate = [dateFormatter dateFromString:nowString];
    if (NSOrderedAscending == [selectDate compare:nowStrDate]) {//选择的时间与当前系统时间做比较
        
        //        DLOG(@"不合法");
        [SVProgressHUD showErrorWithStatus:@"请选择正确时间!"];
        //        _timeStr = @"";
    }
    else
    {
        _timeStr = selectString;
        DLOG(@"选择的时间为:%@",_timeStr);
    }
}


#pragma 单选框选中触发方法
- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked
{
    DLOG(@"did tap on CheckBox:%ld checked:%d", (long)checkbox.tag, checked);
    UITableViewCell *cell = (UITableViewCell *)[_tableView viewWithTag:checkbox.tag];
    UITableViewCell *cell11 = (UITableViewCell *)[_tableView viewWithTag:1];
    UITableViewCell *cell12 = (UITableViewCell *)[_tableView viewWithTag:2];
    UITableViewCell *cell13 = (UITableViewCell *)[_tableView viewWithTag:3];
    UITableViewCell *cell14 = (UITableViewCell *)[_tableView viewWithTag:4];
    
    UITableViewCell *cell21 = (UITableViewCell *)[_tableView viewWithTag:101];
    UITableViewCell *cell22 = (UITableViewCell *)[_tableView viewWithTag:102];
    UITableViewCell *cell23 = (UITableViewCell *)[_tableView viewWithTag:103];
    UITableViewCell *cell24 = (UITableViewCell *)[_tableView viewWithTag:104];
    UITableViewCell *cell25 = (UITableViewCell *)[_tableView viewWithTag:105];
    
    UITableViewCell *cell31 = (UITableViewCell *)[_tableView viewWithTag:201];
    UITableViewCell *cell32 = (UITableViewCell *)[_tableView viewWithTag:202];
    UITableViewCell *cell33 = (UITableViewCell *)[_tableView viewWithTag:203];
    UITableViewCell *cell34 = (UITableViewCell *)[_tableView viewWithTag:204];
    
//    UITableViewCell *cell41 = (UITableViewCell *)[_tableView viewWithTag:301];
//    UITableViewCell *cell42 = (UITableViewCell *)[_tableView viewWithTag:302];
//    UITableViewCell *cell43 = (UITableViewCell *)[_tableView viewWithTag:303];
//    UITableViewCell *cell44 = (UITableViewCell *)[_tableView viewWithTag:304];
//    UITableViewCell *cell45 = (UITableViewCell *)[_tableView viewWithTag:305];
    
    
    QCheckBox *checkbox11  = (QCheckBox *)[cell11.contentView viewWithTag:1];
    QCheckBox *checkbox12  = (QCheckBox *)[cell12.contentView viewWithTag:2];
    QCheckBox *checkbox13  = (QCheckBox *)[cell13.contentView viewWithTag:3];
    QCheckBox *checkbox14  = (QCheckBox *)[cell14.contentView viewWithTag:4];
    
    QCheckBox *checkbox21  = (QCheckBox *)[cell21.contentView viewWithTag:101];
    QCheckBox *checkbox22  = (QCheckBox *)[cell22.contentView viewWithTag:102];
    QCheckBox *checkbox23  = (QCheckBox *)[cell23.contentView viewWithTag:103];
    QCheckBox *checkbox24  = (QCheckBox *)[cell24.contentView viewWithTag:104];
    QCheckBox *checkbox25  = (QCheckBox *)[cell25.contentView viewWithTag:105];
    
    QCheckBox *checkbox31  = (QCheckBox *)[cell31.contentView viewWithTag:201];
    QCheckBox *checkbox32  = (QCheckBox *)[cell32.contentView viewWithTag:202];
    QCheckBox *checkbox33  = (QCheckBox *)[cell33.contentView viewWithTag:203];
    QCheckBox *checkbox34  = (QCheckBox *)[cell34.contentView viewWithTag:204];
    
    
//    QCheckBox *checkbox41  = (QCheckBox *)[cell41.contentView viewWithTag:301];
//    QCheckBox *checkbox42  = (QCheckBox *)[cell42.contentView viewWithTag:302];
//    QCheckBox *checkbox43  = (QCheckBox *)[cell43.contentView viewWithTag:303];
//    QCheckBox *checkbox44  = (QCheckBox *)[cell44.contentView viewWithTag:304];
//    QCheckBox *checkbox45  = (QCheckBox *)[cell45.contentView viewWithTag:305];
    
    
    //先判断是否选中状态
    if (checkbox.checked) {
        ScreenModel *model1 = [[ScreenModel alloc] init];
        model1.Tag = checkbox.tag;
        model1.Checked = checkbox.checked;
        [ScreenArr addObject:model1];
        cell.textLabel.textColor = PinkColor;
        
        switch (checkbox.tag) {
            case 1:
            {
                checkbox13.checked = 0;
                checkbox12.checked = 0;
                checkbox14.checked = 0;
                for (int i = 0; i<[ScreenArr count]; i++) {
                    ScreenModel *model = [ScreenArr objectAtIndex:i];
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    if (model.Tag == 2 || model.Tag ==3 ||model.Tag ==4) {
                        if (model.Tag != checkbox.tag)
                        {
                            [ScreenArr removeObject:model];
                            
                        }
                    }
                    
                }
            }
                break;
            case 2:
            {
                checkbox13.checked = 0;
                checkbox11.checked = 0;
                checkbox14.checked = 0;
                for (int i = 0; i<[ScreenArr count]; i++) {
                    ScreenModel *model = [ScreenArr objectAtIndex:i];
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    if (model.Tag == 1 || model.Tag ==3 ||model.Tag ==4) {
                        if (model.Tag != checkbox.tag)
                        {
                            [ScreenArr removeObject:model];
                            
                        }
                    }
                    
                }
                
            }
                break;
            case 3:
            {
                checkbox11.checked = 0;
                checkbox12.checked = 0;
                checkbox14.checked = 0;
                for (int i = 0; i<[ScreenArr count]; i++) {
                    ScreenModel *model = [ScreenArr objectAtIndex:i];
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    if (model.Tag == 1 || model.Tag ==2 ||model.Tag ==4) {
                        if (model.Tag != checkbox.tag)
                        {
                            [ScreenArr removeObject:model];
                            
                        }
                    }
                }
            }
                break;
            case 4:
            {
                checkbox13.checked = 0;
                checkbox12.checked = 0;
                checkbox11.checked = 0;
                for (int i = 0; i<[ScreenArr count]; i++) {
                    ScreenModel *model = [ScreenArr objectAtIndex:i];
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    if (model.Tag == 1 || model.Tag ==3 ||model.Tag ==2) {
                        if (model.Tag != checkbox.tag)
                        {
                            [ScreenArr removeObject:model];
                            
                        }
                    }
                    
                }
            }
                break;
            case 101:
            {
                checkbox23.checked = 0;
                checkbox22.checked = 0;
                checkbox24.checked = 0;
                checkbox25.checked = 0;
                for (int i = 0; i<[ScreenArr count]; i++) {
                    ScreenModel *model = [ScreenArr objectAtIndex:i];
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    if (model.Tag == 102 || model.Tag ==103 || model.Tag ==104 || model.Tag ==105) {
                        if (model.Tag != checkbox.tag)
                        {
                            [ScreenArr removeObject:model];
                            
                        }
                    }
                    
                }
            }
                break;
            case 102:
            {
                checkbox23.checked = 0;
                checkbox21.checked = 0;
                checkbox24.checked = 0;
                checkbox25.checked = 0;
                for (int i = 0; i<[ScreenArr count]; i++) {
                    ScreenModel *model = [ScreenArr objectAtIndex:i];
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    if (model.Tag == 101 || model.Tag ==103 || model.Tag ==104 || model.Tag ==105) {
                        if (model.Tag != checkbox.tag)
                        {
                            [ScreenArr removeObject:model];
                            
                        }
                    }
                    
                }
            }
                break;
            case 103:
            {
                checkbox21.checked = 0;
                checkbox22.checked = 0;
                checkbox24.checked = 0;
                checkbox25.checked = 0;
                for (int i = 0; i<[ScreenArr count]; i++) {
                    ScreenModel *model = [ScreenArr objectAtIndex:i];
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    if (model.Tag == 102 || model.Tag ==101 || model.Tag ==104 || model.Tag ==105) {
                        if (model.Tag != checkbox.tag)
                        {
                            [ScreenArr removeObject:model];
                            
                        }
                    }
                    
                }
            }
                break;
            case 104:
            {
                checkbox23.checked = 0;
                checkbox22.checked = 0;
                checkbox21.checked = 0;
                checkbox25.checked = 0;
                for (int i = 0; i<[ScreenArr count]; i++) {
                    ScreenModel *model = [ScreenArr objectAtIndex:i];
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    if (model.Tag == 102 || model.Tag ==103 || model.Tag ==101 || model.Tag ==105) {
                        if (model.Tag != checkbox.tag)
                        {
                            [ScreenArr removeObject:model];
                            
                        }
                    }
                    
                }
            }
                break;
            case 105:
            {
                checkbox23.checked = 0;
                checkbox22.checked = 0;
                checkbox21.checked = 0;
                checkbox24.checked = 0;
                for (int i = 0; i<[ScreenArr count]; i++) {
                    ScreenModel *model = [ScreenArr objectAtIndex:i];
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    if (model.Tag == 102 || model.Tag ==103 || model.Tag ==104 || model.Tag ==101) {
                        if (model.Tag != checkbox.tag)
                        {
                            [ScreenArr removeObject:model];
                            
                        }
                    }
                    
                }
            }
                break;
            case 201:
            {
                checkbox33.checked = 0;
                checkbox32.checked = 0;
                checkbox34.checked = 0;
                for (int i = 0; i<[ScreenArr count]; i++) {
                    ScreenModel *model = [ScreenArr objectAtIndex:i];
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    if (model.Tag == 202 || model.Tag ==203 || model.Tag ==204) {
                        if (model.Tag != checkbox.tag)
                        {
                            [ScreenArr removeObject:model];
                            
                        }
                    }
                    
                }
            }
                break;
            case 202:
            {
                checkbox33.checked = 0;
                checkbox31.checked = 0;
                checkbox34.checked = 0;
                for (int i = 0; i<[ScreenArr count]; i++) {
                    ScreenModel *model = [ScreenArr objectAtIndex:i];
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    if (model.Tag == 201 || model.Tag ==203 || model.Tag == 204) {
                        if (model.Tag != checkbox.tag)
                        {
                            [ScreenArr removeObject:model];
                            
                        }
                    }
                    
                }
            }
                break;
            case 203:
            {
                checkbox32.checked = 0;
                checkbox31.checked = 0;
                checkbox34.checked = 0;
                for (int i = 0; i<[ScreenArr count]; i++) {
                    ScreenModel *model = [ScreenArr objectAtIndex:i];
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    if (model.Tag == 202 || model.Tag ==201 || model.Tag ==204) {
                        if (model.Tag != checkbox.tag)
                        {
                            [ScreenArr removeObject:model];
                            
                        }
                    }
                    
                }
            }
                break;
            case 204:
            {
                checkbox33.checked = 0;
                checkbox32.checked = 0;
                checkbox31.checked = 0;
                for (int i = 0; i<[ScreenArr count]; i++) {
                    ScreenModel *model = [ScreenArr objectAtIndex:i];
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    if (model.Tag == 202 || model.Tag ==203 || model.Tag == 201) {
                        if (model.Tag != checkbox.tag)
                        {
                            [ScreenArr removeObject:model];
                            
                        }
                    }
                    
                }
            }
                break;
                
//            case 301:
//            {
//                checkbox43.checked = 0;
//                checkbox42.checked = 0;
//                checkbox44.checked = 0;
//                checkbox45.checked = 0;
//                for (int i = 0; i<[ScreenArr count]; i++) {
//                    ScreenModel *model = [ScreenArr objectAtIndex:i];
//                    cell.textLabel.textColor = [UIColor lightGrayColor];
//                    if (model.Tag == 302 || model.Tag ==303 || model.Tag ==304 || model.Tag ==305) {
//                        if (model.Tag != checkbox.tag)
//                        {
//                            [ScreenArr removeObject:model];
//                            
//                        }
//                    }
//                    
//                }
//            }
//                break;
//            case 302:
//            {
//                checkbox43.checked = 0;
//                checkbox41.checked = 0;
//                checkbox44.checked = 0;
//                checkbox45.checked = 0;
//                for (int i = 0; i<[ScreenArr count]; i++) {
//                    ScreenModel *model = [ScreenArr objectAtIndex:i];
//                    cell.textLabel.textColor = [UIColor lightGrayColor];
//                    if (model.Tag == 301 || model.Tag == 303 || model.Tag == 304 || model.Tag == 305) {
//                        if (model.Tag != checkbox.tag)
//                        {
//                            [ScreenArr removeObject:model];
//                            
//                        }
//                    }
//                    
//                }
//            }
//                break;
//            case 303:
//            {
//                checkbox41.checked = 0;
//                checkbox42.checked = 0;
//                checkbox44.checked = 0;
//                checkbox45.checked = 0;
//                for (int i = 0; i<[ScreenArr count]; i++) {
//                    ScreenModel *model = [ScreenArr objectAtIndex:i];
//                    cell.textLabel.textColor = [UIColor lightGrayColor];
//                    if (model.Tag == 302 || model.Tag == 301 || model.Tag == 304 || model.Tag == 305) {
//                        if (model.Tag != checkbox.tag)
//                        {
//                            [ScreenArr removeObject:model];
//                            
//                        }
//                    }
//                    
//                }
//            }
//                break;
//            case 304:
//            {
//                checkbox43.checked = 0;
//                checkbox42.checked = 0;
//                checkbox41.checked = 0;
//                checkbox45.checked = 0;
//                for (int i = 0; i<[ScreenArr count]; i++) {
//                    ScreenModel *model = [ScreenArr objectAtIndex:i];
//                    cell.textLabel.textColor = [UIColor lightGrayColor];
//                    if (model.Tag == 302 || model.Tag == 303 || model.Tag == 301 || model.Tag == 305) {
//                        if (model.Tag != checkbox.tag)
//                        {
//                            [ScreenArr removeObject:model];
//                            
//                        }
//                    }
//                    
//                }
//            }
//                break;
//            case 305:
//            {
//                checkbox43.checked = 0;
//                checkbox42.checked = 0;
//                checkbox41.checked = 0;
//                checkbox44.checked = 0;
//                for (int i = 0; i<[ScreenArr count]; i++) {
//                    ScreenModel *model = [ScreenArr objectAtIndex:i];
//                    cell.textLabel.textColor = [UIColor lightGrayColor];
//                    if (model.Tag == 302 || model.Tag ==303 || model.Tag == 304 || model.Tag ==301) {
//                        if (model.Tag != checkbox.tag)
//                        {
//                            [ScreenArr removeObject:model];
//                            
//                        }
//                    }
//                    
//                }
//            }
//                break;
        }
    }
    else
    {
        for (int i = 0; i<[ScreenArr count]; i++) {
            ScreenModel *model = [ScreenArr objectAtIndex:i];
            cell.textLabel.textColor = [UIColor lightGrayColor];
            if (model.Tag == checkbox.tag)
            {
                [ScreenArr removeObject:model];
            }
        }
    }
    DLOG(@"筛选选中的数组 ====== %@",ScreenArr);
    //刷新列表
    [_tableView reloadData];
}


#pragma mark 确定按钮
- (void)SureBtnClick
{
    DLOG(@"确定按钮");
    if (_sureNum) {
        [_backView removeFromSuperview];
        [_emptyBtn setTitle:@"清空" forState:UIControlStateNormal];
        [_SureBtn setTitle:@"确定" forState:UIControlStateNormal];
    }else{
    
    NSInteger num1 = 0,num2 = 0,num3 = 0;
    DLOG(@"确定按钮");
    for (int i = 0; i<[ScreenArr count]; i++) {
        ScreenModel *model = [ScreenArr objectAtIndex:i];
        if (model.Tag >=1 && model.Tag <=4) {
            num1 = model.Tag;
        }
        else  if (model.Tag>=101 && model.Tag <=105) {
            
            num2 = model.Tag - 100;
        }
        else   if (model.Tag>=201 && model.Tag <=204) {
            
            num3 = model.Tag - 200;
            
        }
//        else  if (model.Tag>=301 && model.Tag <=305) {
//            
//            num4 = model.Tag - 300;
//        }
    }
    [screenDataArr removeAllObjects]; //Jaqen-start:先清空原先搜索条件
        
    [screenDataArr addObject:[NSString stringWithFormat:@"%ld",(long)num1]];
    [screenDataArr addObject:[NSString stringWithFormat:@"%ld",(long)num2]];
    [screenDataArr addObject:[NSString stringWithFormat:@"%ld",(long)num3]];
//    [screenDataArr addObject:[NSString stringWithFormat:@"%ld",(long)num4]];
//    [screenDataArr addObject:_timeStr];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"screen1" object:screenDataArr];
    [self.sideMenuViewController hideMenuViewController];
   }
    _tableView.frame =  CGRectMake(self.leftMargin, 0, self.view.frame.size.width - self.leftMargin, self.view.frame.size.height-44);
    _emptyNum = 0;
    _sureNum = 0;
    _selectNum = 0;
}

#pragma mark 清空筛选条件
- (void)emptyBtnClick
{
    if (_emptyNum) {
        
        _timeStr = @"";
        [_backView removeFromSuperview];
        [_emptyBtn setTitle:@"清空" forState:UIControlStateNormal];
        [_SureBtn setTitle:@"确定" forState:UIControlStateNormal];
        
    }else{
        DLOG(@"清空条件");
        [ScreenArr removeAllObjects];
        [_tableView reloadData];
    }
     _tableView.frame =  CGRectMake(self.leftMargin, 0, self.view.frame.size.width - self.leftMargin, self.view.frame.size.height-44);
    _emptyNum = 0;
    _sureNum = 0;
     _selectNum = 0;
}

@end
