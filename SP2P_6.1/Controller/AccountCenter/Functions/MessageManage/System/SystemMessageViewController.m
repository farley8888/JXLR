//
//  SystemMessageViewController.m
//  SP2P_6.1
//
//  Created by Jerry on 14-6-18.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//
//  系统消息

#import "SystemMessageViewController.h"
#import "MessageBoxCell.h"
#import "MessageBox.h"
#import "ColorTools.h"
#import "SMDetailViewController.h"

@interface SystemMessageViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate, HTTPClientDelegate>
{
    
    UITableViewCellEditingStyle selectEditingStyle;
    
    NSMutableArray *_dataArrays;        // 数据
    
    NSInteger _total;                   // 总的数据
    
    NSInteger _currPage;                // 查询的页数
    
    BOOL editStatus;                    // 是否编辑状态（决定点击是否进入内页）
    
    NSInteger _isDelete;                // 删除状态（解析不同数据）
    NSInteger _editNum;
    NSInteger _selectNum;
    NSInteger _deleteNum;
    
    NSInteger readStatus;
}

@property (nonatomic, strong) UITableView *listView;
@property (nonatomic,strong)UIView *bottomView;
@property (nonatomic,strong)BarButtonItem *editBarButtonItem;
@property (nonatomic,strong)UIView *aboveView;
@property (nonatomic,strong)UIButton *selectBtn;
@property (nonatomic,strong)UIButton *markBtn;  // 标记
@property (nonatomic,strong)UIButton *deleteBtn;  // 删除
@property(nonatomic ,strong) NetWorkClient *requestClient;

@end

@implementation SystemMessageViewController

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
    _editNum = 0;
    editStatus = NO;
    _isDelete = 0;
    _selectNum = 0;
    _deleteNum = 0;
    readStatus = 0;
}

/**
 初始化数据
 */
- (void)initView
{
    [self initNavigationBar];
    
    //列表视图
    _listView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    _listView.delegate = self;
    _listView.dataSource = self;
    _listView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _listView.backgroundColor=[UIColor clearColor];
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
    [gifHeader setImages:refreshImages forState:MJRefreshStateRefreshing];    _listView.mj_header = gifHeader;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTable:) name:@"SystemMegSuccess" object:nil];
    
    //  底部模块及一些按钮功能
    _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
    _bottomView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 40);
    _bottomView.backgroundColor = ColorWhite;
    
    //选中全部
    _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectBtn.frame = CGRectMake(8 ,8, 25, 25);
    [_selectBtn setBackgroundImage:[UIImage imageNamed:@"checkbox2_unchecked"] forState:UIControlStateNormal];
    _selectBtn.tag = 0;
    [_selectBtn addTarget:self action:@selector(selectClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_selectBtn];
    
    //标记按钮
    _markBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _markBtn.frame = CGRectMake(self.view.frame.size.width - 90, 4, 28, 28);
    [_markBtn setBackgroundImage:[UIImage imageNamed:@"mark_img"] forState:UIControlStateNormal];
    _markBtn.tag = 1;
    [_markBtn addTarget:self action:@selector(markClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_markBtn];
    
    //删除按钮
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteBtn.frame = CGRectMake(self.view.frame.size.width - 45, 4, 28, 28);
    [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete_img"] forState:UIControlStateNormal];
    _deleteBtn.tag = 2;
    [_deleteBtn addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_deleteBtn];
    
}

// 调用通知，刷新数据。
-(void) updateTable:(id)obj
{
    [self headerRereshing];
}

/**
 * 初始化导航条
 */
- (void)initNavigationBar
{
    self.title = @"系统消息";
    
    // 导航条编辑按钮
    _editBarButtonItem=[BarButtonItem barItemRightDefaultWithTitle:@"编辑" target:self action:@selector(editButtonClicked:)];
    [self.navigationItem setRightBarButtonItem:_editBarButtonItem];
}

#pragma 返回按钮触发方法
- (void)back
{
    if (editStatus) {
        
        _isDelete = 0;
        _deleteNum = 0;
        editStatus = NO;
        readStatus = 0;
        _editBarButtonItem.title = @"编辑";
        [_listView setEditing:NO animated:YES];
        _listView.allowsMultipleSelectionDuringEditing = NO;
        
        [_markBtn setBackgroundImage:[UIImage imageNamed:@"mark_img"] forState:UIControlStateNormal];
        [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete_img"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:.3 animations:^{
            _listView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            _bottomView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 40);
        } completion:^(BOOL finished) {
            [_bottomView removeFromSuperview];
        }];
        
        _editNum = 0;
        _selectNum = 0;
        [_selectBtn setBackgroundImage:[UIImage imageNamed:@"checkbox2_unchecked"] forState:UIControlStateNormal];
        
        for (int temp = 0; temp < _dataArrays.count; temp ++) {
            MessageBox *box = _dataArrays[temp];
            box.selectall = @"0";
        }
        [_listView reloadData];
    }
    [super back];
}

#pragma mark - Table view delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArrays.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageBox *meg = _dataArrays[indexPath.row];
    
    if (meg.contentHeight < 30) {
        return 70;
    }else{
        return 40 + meg.contentHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *settingcell = @"settingCell";
    
    MessageBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:settingcell];
    
    if (cell == nil) {
        cell = [[MessageBoxCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:settingcell];
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WidthScreen, cell.frame.size.height)];
        imageView.image=[ImageTools imageWithColor:ColorBtnWhiteHighlight];
        cell.selectedBackgroundView=imageView;
    }
    MessageBox *meg = _dataArrays[indexPath.row];
    [cell fillCellWithObject:meg];
    return cell;
}

// 选中行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editStatus) {
        //DLOG(@"您点击了第%ld分区第%ld行",(long)indexPath.section, (long)indexPath.row);
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        [_markBtn setBackgroundImage:[UIImage imageNamed:@"mark_img_selete"] forState:UIControlStateNormal];
        [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete_img_selete"] forState:UIControlStateNormal];
        
    }else {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        SMDetailViewController *message = [[SMDetailViewController alloc] init];
        message.index = (int)indexPath.row + 1;
        [self.navigationController pushViewController:message animated:YES];
        
        MessageBox *model =  [_dataArrays objectAtIndex:indexPath.row];
        model.status = @"已读";
        [self.listView reloadData];
        
        // 标记为已读，发送请求给服务器
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:@"85" forKey:@"OPT"];
        [parameters setObject:@"" forKey:@"body"];
        [parameters setObject:AppDelegateInstance.userInfo.userId forKey:@"id"];
        [parameters setObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forKey:@"ids"];
        
        if (_requestClient == nil) {
            _requestClient = [[NetWorkClient alloc] init];
            _requestClient.delegate = self;
        }
        [_requestClient requestGet:@"app/services" withParameters:parameters];
    }
}
#pragma mark - 编辑
// 设置删除按钮标题
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
// 是否可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return YES;
}
// 编辑模式
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return selectEditingStyle;
    
}

#pragma mark 删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 删除模式
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        
        // 从数据源中删除
        [_dataArrays removeObjectAtIndex:indexPath.row];
        // 删除行
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}


// 点击编辑按钮
- (void)editButtonClicked:(id)sender {
    
    _listView.userInteractionEnabled = YES;
    
    
    if (_editNum == 0) {
        editStatus = YES;
        _isDelete = 0;
        _editBarButtonItem.title = @"取消";
        _deleteNum = 0;
        
        [UIView animateWithDuration:.3 animations:^{
            _listView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 40);
            _bottomView.frame = CGRectMake(0, self.view.frame.size.height - 40, self.view.frame.size.width, 40);
        }];
        
        [_selectBtn setBackgroundImage:[UIImage imageNamed:@"checkbox2_unchecked"] forState:UIControlStateNormal];
        selectEditingStyle = UITableViewCellEditingStyleDelete;
        _listView.allowsMultipleSelectionDuringEditing = YES;
        [_listView setEditing:YES animated:YES];
        
        [self.view insertSubview:_bottomView aboveSubview:self.view];
        _editNum = 1;
    }else{
        
        _isDelete = 0;
        _deleteNum = 0;
        editStatus = NO;
        readStatus = 0;
        _editBarButtonItem.title = @"编辑";
        [_listView setEditing:NO animated:YES];
        _listView.allowsMultipleSelectionDuringEditing = NO;
        
        [_markBtn setBackgroundImage:[UIImage imageNamed:@"mark_img"] forState:UIControlStateNormal];
        [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete_img"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:.3 animations:^{
            _listView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            _bottomView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 40);
        } completion:^(BOOL finished) {
            [_bottomView removeFromSuperview];
        }];
        
        _editNum = 0;
        _selectNum = 0;
        [_selectBtn setBackgroundImage:[UIImage imageNamed:@"checkbox2_unchecked"] forState:UIControlStateNormal];
        
        for (int temp = 0; temp < _dataArrays.count; temp ++) {
            MessageBox *box = _dataArrays[temp];
            box.selectall = @"0";
        }
        [_listView reloadData];
        
    }
    
}


//选中全部cell
-(void)selectClick
{
    
    //DLOG(@"点击选择按钮!!!!");
    if (_selectNum == 0) {
        _selectNum = 1;
        _deleteNum = 1;
        _listView.userInteractionEnabled = NO;
        _listView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40);
        [_selectBtn setBackgroundImage:[UIImage imageNamed:@"checkbox2_checked"] forState:UIControlStateNormal];
        [_markBtn setBackgroundImage:[UIImage imageNamed:@"mark_img_selete"] forState:UIControlStateNormal];
        [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete_img_selete"] forState:UIControlStateNormal];
        
        for (int temp = 0; temp < _dataArrays.count; temp ++) {
            MessageBox *box = _dataArrays[temp];
            box.selectall = @"1";
        }
        [_listView reloadData];
    }else{
        _selectNum = 0;
        _deleteNum = 0;
        _listView.userInteractionEnabled = YES;
        _listView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40);
        [_selectBtn setBackgroundImage:[UIImage imageNamed:@"checkbox2_unchecked"] forState:UIControlStateNormal];
        [_markBtn setBackgroundImage:[UIImage imageNamed:@"mark_img"] forState:UIControlStateNormal];
        [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete_img"] forState:UIControlStateNormal];
        
        for (int temp = 0; temp < _dataArrays.count; temp ++) {
            MessageBox *box = _dataArrays[temp];
            box.selectall = @"0";
        }
        [_listView reloadData];
    }
    
}

//删除按钮
-(void)deleteClick
{
    NSArray *selectedRows = [_listView indexPathsForSelectedRows];
    if (selectedRows.count) {
        NSString *infoStr = [NSString stringWithFormat:@"确定要删除%lu信息吗？", (unsigned long)selectedRows.count];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"删除" message:infoStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        
        [alertView show];
    }else if (_selectNum == 1) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"删除" message:@"确定要删除全部信息吗？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        
        [alertView show];
    }else {
        [SVProgressHUD showErrorWithStatus:@"请选择删除信息"];
    }
}

#pragma mark UIAlertDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //DLOG(@"buttonIndex: %ld", (long)buttonIndex);
    switch (buttonIndex) {
        case 0:
        {
            _listView.userInteractionEnabled = YES;
            //DLOG(@"点击删除按钮!!!!");
            _isDelete = 1;
            // 选中的行
            NSArray *selectedRows = [_listView indexPathsForSelectedRows];
            NSMutableString *ids = [[NSMutableString alloc] init];
            // 是否删除特定的行
            BOOL deleteSpecificRows = selectedRows.count > 0;
            // 删除特定的行
            if (deleteSpecificRows&& _deleteNum == 0)
            {
                // 将所选的行的索引值放在一个集合中进行批量删除
                NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
                
                for (NSIndexPath *selectionIndex in selectedRows)
                {
                    [indicesOfItemsToDelete addIndex:selectionIndex.row];
                    
                    // 取出ID串，发送给服务器
                    MessageBox *box = _dataArrays[selectionIndex.row];
                    [ids appendString:[NSString stringWithFormat:@"%ld", (long)box.messageId]];
                    if (_dataArrays.count) {
                        [ids appendString:@","];
                    }
                }
                [ids deleteCharactersInRange:NSMakeRange(ids.length-1,1)];
                //DLOG(@"ids -> %@", ids);
                
                NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                
                [parameters setObject:@"82" forKey:@"OPT"];
                [parameters setObject:@"" forKey:@"body"];
                [parameters setObject:AppDelegateInstance.userInfo.userId forKey:@"id"];
                [parameters setObject:ids forKey:@"ids"];
                
                if (_requestClient == nil) {
                    _requestClient = [[NetWorkClient alloc] init];
                    _requestClient.delegate = self;
                }
                [_requestClient requestGet:@"app/services" withParameters:parameters];
                
                // 从数据源中删除所选行对应的值
                [_dataArrays removeObjectsAtIndexes:indicesOfItemsToDelete];
                
                //删除所选的行
                [_listView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            if(_deleteNum == 1)
            {
                for (int temp = 0; temp < _dataArrays.count; temp ++) {
                    // 取出ID串，发送给服务器
                    MessageBox *box = _dataArrays[temp];
                    [ids appendString:[NSString stringWithFormat:@"%ld", (long)box.messageId]];
                    if (_dataArrays.count) {
                        [ids appendString:@","];
                    }
                }
                [ids deleteCharactersInRange:NSMakeRange(ids.length-1,1)];
                //DLOG(@"ids -> %@", ids);
                NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                
                [parameters setObject:@"82" forKey:@"OPT"];
                [parameters setObject:@"" forKey:@"body"];
                [parameters setObject:AppDelegateInstance.userInfo.userId forKey:@"id"];
                [parameters setObject:ids forKey:@"ids"];
                
                if (_requestClient == nil) {
                    _requestClient = [[NetWorkClient alloc] init];
                    _requestClient.delegate = self;
                }
                [_requestClient requestGet:@"app/services" withParameters:parameters];
                
                // 删除全部
                [_dataArrays removeAllObjects];
                
                [_listView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            [_listView setEditing:NO animated:YES];
            
            _listView.allowsMultipleSelectionDuringEditing = NO;
        }
            
            break;
        case 1:
            
            break;
    }
}

//标记按钮
-(void)markClick
{
    
    //DLOG(@"标记按钮!!!!");
    _listView.userInteractionEnabled = YES;
    UIActionSheet *SheetView = [[UIActionSheet alloc]
                                initWithTitle:nil
                                delegate:self
                                cancelButtonTitle:@"取消"
                                destructiveButtonTitle:@"标记为已读"
                                otherButtonTitles:@"标记为未读", nil];
    [SheetView showInView:self.view];
    
    
}
#pragma UIActionSheet代理方法
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    _isDelete = 1;
    NSArray *selectedRows = [_listView indexPathsForSelectedRows];
    
    // 是否特定的行
    BOOL deleteSpecificRows = selectedRows.count > 0;
    // 将所选的行的索引值放在一个集合中进
    NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
    NSMutableString *ids = [[NSMutableString alloc] init];
    // 特定的行
    if (deleteSpecificRows && _deleteNum == 0)
    {
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            [indicesOfItemsToDelete addIndex:selectionIndex.row];
            
            // 取出ID串，发送给服务器
            MessageBox *box = _dataArrays[selectionIndex.row];
            [ids appendString:[NSString stringWithFormat:@"%ld", (long)box.messageId]];
            if (_dataArrays.count) {
                [ids appendString:@","];
            }
        }
        [ids deleteCharactersInRange:NSMakeRange(ids.length-1,1)];
        //DLOG(@"ids -> %@", ids);
        
    }
    
    if(_deleteNum == 1)
    {
        // 发送请求，响应服务
        for (int temp = 0; temp < _dataArrays.count; temp ++) {
            // 取出ID串，发送给服务器
            MessageBox *box = _dataArrays[temp];
            [ids appendString:[NSString stringWithFormat:@"%ld", (long)box.messageId]];
            if (_dataArrays.count) {
                [ids appendString:@","];
            }
        }
        [ids deleteCharactersInRange:NSMakeRange(ids.length-1,1)];
        //DLOG(@"ids -> %@", ids);
    }
    
    //DLOG(@"选择选项为%ld",(long)buttonIndex);
    if (ids!=nil && buttonIndex != 2) {
        
        if(buttonIndex){
            readStatus = 3;
            // 标记为未读，发送请求给服务器
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setObject:@"86" forKey:@"OPT"];
            [parameters setObject:@"" forKey:@"body"];
            [parameters setObject:AppDelegateInstance.userInfo.userId forKey:@"id"];
            [parameters setObject:ids forKey:@"ids"];
            
            if (_requestClient == nil) {
                _requestClient = [[NetWorkClient alloc] init];
                _requestClient.delegate = self;
            }
            [_requestClient requestGet:@"app/services" withParameters:parameters];
            
            [_listView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }else if(buttonIndex == 0){
            readStatus = 3;
            
            // 标记为已读，发送请求给服务器
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setObject:@"85" forKey:@"OPT"];
            [parameters setObject:@"" forKey:@"body"];
            [parameters setObject:AppDelegateInstance.userInfo.userId forKey:@"id"];
            [parameters setObject:ids forKey:@"ids"];
            
            if (_requestClient == nil) {
                _requestClient = [[NetWorkClient alloc] init];
                _requestClient.delegate = self;
            }
            [_requestClient requestGet:@"app/services" withParameters:parameters];
            
        }
        
        
        // 2.2秒后刷新表格UI
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _isDelete = 0;
            _currPage = 1;
            _total = 1;
            
            [self requestData];// 刷新表格
            // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
            [self hiddenRefreshView];
        });
        
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
        
        [parameters setObject:@"81" forKey:@"OPT"];
        [parameters setObject:@"" forKey:@"body"];
        [parameters setObject:AppDelegateInstance.userInfo.userId forKey:@"id"];
        [parameters setObject:[NSString stringWithFormat:@"%ld",(long)_currPage] forKey:@"currPage"];
        
        if (_requestClient == nil) {
            _requestClient = [[NetWorkClient alloc] init];
            _requestClient.delegate = self;
        }
        [_requestClient requestGet:@"app/services" withParameters:parameters];
        
        
    }
}

#pragma mark - HTTPClientDelegate 网络数据回调代理
-(void) startRequest
{
}

// 返回成功
-(void) httpResponseSuccess:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didSuccessWithObject:(id)obj
{
    [self hiddenRefreshView];
    NSDictionary *dics = obj;
    _listView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    if ([[NSString stringWithFormat:@"%@",[dics objectForKey:@"error"]] isEqualToString:@"-1"]) {
        //退出编辑模式
        editStatus = NO;
        _editBarButtonItem.title = @"编辑";
        [_listView setEditing:NO animated:NO];
        _listView.allowsMultipleSelectionDuringEditing = NO;
        [_bottomView removeFromSuperview];
        _editNum = 0;
        
        if (_isDelete==0) {
            if (_total == 1) {
                [_dataArrays removeAllObjects];// 清空全部数据
            }
            
            _total = [[dics objectForKey:@"totalNum"] intValue];
            NSArray *dataArr = [[obj objectForKey:@"page"] objectForKey:@"page"];
            for (NSDictionary *item in dataArr) {
                MessageBox *mBox = [[MessageBox alloc] init];
                
                mBox.titleName = [item objectForKey:@"title"];
                mBox.status = [item objectForKey:@"read_status"];
                mBox.selectall = @"0";
                
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[[item objectForKey:@"time"] objectForKey:@"time"] doubleValue]/1000];
                NSDateFormatter *dataFormat = [[NSDateFormatter alloc] init];
                [dataFormat setDateFormat:@"MM-dd"];
                mBox.timeStr = [dataFormat stringFromDate: date];
                mBox.messageId = [[item objectForKey:@"id"] integerValue];
                mBox.selectall = @"0";
                
                mBox.content = [NSString stringWithFormat:@"%@",[item objectForKey:@"content"]];
                
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                UIFont *font = [UIFont boldSystemFontOfSize:12.f];
                NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
                CGSize contentSize = [mBox.content boundingRectWithSize:CGSizeMake(260, 999) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
                mBox.contentHeight = contentSize.height;
                
                [_dataArrays addObject:mBox];
                
                //DLOG(@"title -> %@", mBox.titleName);
            }
            
            [_listView reloadData];// 刷新表格
            
        }else {
            [SVProgressHUD showSuccessWithStatus:[obj objectForKey:@"msg"]];
        }
    }else {
        //DLOG(@"返回失败  msg -> %@",[obj objectForKey:@"msg"]);
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", [obj objectForKey:@"msg"]]];
    }
}

// 返回失败
-(void) httpResponseFailure:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didFailWithError:(NSError *)error
{
    _listView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    // 服务器返回数据异常
    [self hiddenRefreshView];
}

// 无可用的网络
-(void) networkError
{
    _listView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self hiddenRefreshView];
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"无可用网络"]];
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    _isDelete = 0;
    _currPage = 1;
    _total = 1;
    _selectNum = 0;
    _deleteNum = 0;
    
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

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestClient != nil) {
        [_requestClient cancel];
    }
}

@end
