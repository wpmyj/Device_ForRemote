//
//  MHLumiFMViewController.m
//  MiHome
//
//  Created by Lynn on 11/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiFMRadioViewController.h"
#import "MHLumiFMCell.h"
#import "MHLumiFMCollectionInvoker.h"

@interface MHLumiFMRadioViewController ()<MHTableViewControllerInternalDelegate>

@property (nonatomic, strong) NSString *localCode;
@property (nonatomic, strong) MHLumiXMPageInfo *pageInfo;
@end

@implementation MHLumiFMRadioViewController
{
    MHDeviceGateway *   _radioDevice;
}
@synthesize radioType = _radioType;

- (id)initWithFrame:(CGRect)frame andRadioDevice:(MHDeviceGateway *)radioDevice{
    self = [super init];
    if (self) {
        _radioDevice = radioDevice;
        _viewFrame = frame;
    }
    return self;
}

-(void)setRadioType:(RadioType)radioType{
    XM_WS(weakself);
    _radioType = radioType;
    if(radioType == Radio_Province && !_dataSource){
        //获取缓存的省份信息
        [[MHLumiXMDataManager sharedInstance] restoreRadioDataListWithDataType:DataType_Province andFinish:^(id obj){
            if(weakself.currentPlace){
                MHLumiXMProvince *province = [[MHLumiXMDataManager sharedInstance]
                                              fetchCurrentProvince:weakself.currentPlace andProvinceList:obj];
                weakself.localCode = province.code;
            }
            else{
                for(MHLumiXMProvince *province in obj){
                    if(province.isCurrentLocal) weakself.localCode = province.code;
                }
            }
            [self firstRestoreData];
        }];
    }
    else if(!_dataSource){
        [self firstRestoreData];
    }else if (!self.localCode){
        [[MHLumiXMDataManager sharedInstance] restoreRadioDataListWithDataType:DataType_Province andFinish:^(id obj){
            if(weakself.currentPlace){
                MHLumiXMProvince *province = [[MHLumiXMDataManager sharedInstance]
                                              fetchCurrentProvince:weakself.currentPlace andProvinceList:obj];
                weakself.localCode = province.code;
            }
            else{
                for(MHLumiXMProvince *province in obj){
                    if(province.isCurrentLocal) weakself.localCode = province.code;
                }
            }
            [self firstRestoreData];
        }];
    }
}

- (void)setViewFrame:(CGRect)viewFrame {
    _viewFrame = viewFrame;
    [self.tvcInternal.view setFrame:_viewFrame];
}

- (void)dealloc {
    NSLog(@"ddd");
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.isTabBarHidden = YES;
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     
    [self.tvcInternal stopRefreshAndReload];
}

-(void)buildSubviews{
    [super buildSubviews];
    
    self.tvcInternal = [[MHTableViewControllerInternal alloc] initWithStyle:UITableViewStylePlain];
    self.tvcInternal.cellClass = [MHLumiFMCell class];
    self.tvcInternal.delegate = self;
    self.tvcInternal.dataSource = self.dataSource;
    [self.tvcInternal.view setFrame:_viewFrame];
    [self addChildViewController:self.tvcInternal];
    [self.view addSubview:self.tvcInternal.view];
}

#pragma mark - 数据操作
-(void)firstRestoreData{
    //读取缓存先，如果没有缓存，则直接网络请求；如果有缓存，则显示缓存，然后再悄悄的网络请求。
    XM_WS(weakself);

    if(_radioType == Radio_Rank){
        [[MHLumiXMDataManager sharedInstance] restoreRankRadioWithFinish:^(NSMutableArray *datalist){
            if(datalist.count) {
                [weakself showReceivedData:datalist];
                [weakself fetchRemoteDataForPage:1 withFinish:nil];
            }
            else{
                [weakself fetchNewData:1 withSpinning:YES];
            }
        }];
    }
    else{
        NSString *radioDataType;
        if(_radioType == Radio_Province){
            radioDataType = DataType_LocalRadio;
        }
        else if(_radioType == Radio_Country){
            radioDataType = DataType_CountryRadio;
        }
        else if(_radioType == Radio_NetWork){
            radioDataType = DataType_NetworkRadio;
        }
        
        [[MHLumiXMDataManager sharedInstance] restoreRadioType:radioDataType withFinish:^(NSMutableArray *datalist){
            if(datalist.count) {
                [weakself showReceivedData:datalist];
                if(weakself.localCode && weakself.radioType == Radio_Province){
                    [weakself fetchRemoteDataForPage:1 withFinish:nil];
                }
                else if(weakself.radioType != Radio_Province)[weakself fetchRemoteDataForPage:1 withFinish:nil];
            }
            else{
                [weakself fetchNewData:1 withSpinning:YES];
            }
        }];
    }
}

-(void)fetchRemoteDataForPage:(NSInteger)pageIndex withFinish:(void (^)(NSMutableArray *datalist))finish
{
    XM_WS(weakself);
    if(_radioType == Radio_Rank){
        [[MHLumiXMDataManager sharedInstance] fetchRankWithFinish:^(NSMutableArray *datalist) {
            if (datalist) {
                if(finish)finish(datalist);
                [weakself showReceivedData:datalist];
            }
            else {
                [[MHTipsView shareInstance] hide];;
            }
            
        } andDeviceId:_radioDevice.did];
    }
    else{
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:@(20) forKey:@"count"];
        [params setObject:@(pageIndex) forKey:@"page"];
        [params setObject:@(_radioType + 1) forKey:@"radio_type"];
        if(self.radioType == Radio_Province && self.localCode){
            [params setObject:self.localCode forKey:@"province_code"];
        }
        else {
            [params setObject:@(110000) forKey:@"province_code"];
        }
        
        [[MHLumiXMDataManager sharedInstance] fetchRadio:params withFinish:^(NSMutableArray *datalist) {
            if (datalist) {
                if(finish)finish(datalist);
                [weakself showReceivedData:datalist];
            }
            else {
                //获取失败
                [[MHTipsView shareInstance] hide];
            }
            
            
        } andDeviceId:_radioDevice.did];
    }
}

-(void)fetchNewData:(NSInteger)pageIndex withSpinning:(BOOL)canSpinning
{
    if (canSpinning) {
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"updating", @"plugin_gateway", nil) modal:YES];
    }
    [self fetchRemoteDataForPage:pageIndex withFinish:^(NSMutableArray *datalist){
        [[MHTipsView shareInstance] hide];
    }];
}

-(void)showReceivedData:(NSMutableArray *)datalist{
    if([datalist.lastObject isKindOfClass:[MHLumiXMPageInfo class]]) {
        self.pageInfo = datalist.lastObject;
        [datalist removeObject:self.pageInfo];
    }
    else{
        _pageInfo = [[MHLumiXMPageInfo alloc] init];
        _pageInfo.currentPage = @(1);
        _pageInfo.totalPage = @(2);
    }
    
    if(_pageInfo.currentPage.integerValue != 1) [self.dataSource addObjectsFromArray:datalist];
    else self.dataSource = [NSMutableArray arrayWithArray:datalist];

    self.tvcInternal.dataSource = self.dataSource;
    [self.tvcInternal stopRefreshAndReload];
}

//将编辑后的data上传，缓存
- (void)resetEditedData:(MHLumiXMRadio *)radio {
    MHLumiFMCollectionInvoker *invoker = [[MHLumiFMCollectionInvoker alloc] init];
    invoker.radioDevice = _radioDevice;
    
    XM_WS(weakself);
    if([radio.radioCollection isEqualToString:@"yes"]){
        radio.radioCollection = @"no";
        [invoker removeElementFromCollection:radio
                                 WithSuccess:nil
                                  andFailure:^(NSError *error){
                                      radio.radioCollection = @"yes";
                                      [weakself.tvcInternal.tableView reloadData];
                                 }];
    }
    else{
        radio.radioCollection = @"yes";
        [invoker addElementToCollection:radio
                            WithSuccess:nil
                             andFailure:^(NSError *error){
                                 radio.radioCollection = @"no";
                                 [weakself.tvcInternal.tableView reloadData];
                            }];
    }
    [self.tvcInternal.tableView reloadData];
}

#pragma mark - tableview delegte
//通知manager刷新
- (void)startRefresh
{
    if(_pageInfo)
        _pageInfo.currentPage = @(1);
    else {
        _pageInfo = [[MHLumiXMPageInfo alloc] init];
        _pageInfo.currentPage = @(1);
    }
    [self fetchNewData:_pageInfo.currentPage.integerValue withSpinning:NO];
}

//通知manager获取更多
- (void)startGetmore
{
    if(_radioType != Radio_Rank){
        _pageInfo.currentPage = [NSNumber numberWithInteger:_pageInfo.currentPage.integerValue + 1];
        if(_pageInfo.totalPage.integerValue >= _pageInfo.currentPage.integerValue){
            [self fetchNewData:_pageInfo.currentPage.integerValue withSpinning:YES];
        }    
    }
}

- (UIView *)emptyView {
    UIView *messageView = [[UIView alloc] initWithFrame:self.view.bounds];
    [messageView setBackgroundColor:[MHColorUtils colorWithRGB:0xefefef alpha:0.4f]];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableview_blank_logo"]];
    [messageView addSubview:icon];
    CGRect imageFrame = icon.frame;
    imageFrame.origin.x = messageView.bounds.size.width / 2.0f - icon.frame.size.width / 2.0f;
    imageFrame.origin.y = CGRectGetHeight(self.view.bounds) / 3.f;
    [icon setFrame:imageFrame];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(messageView.frame.origin.x, CGRectGetMaxY(icon.frame) + 10.0f, messageView.frame.size.width, 19.0f)];
    label.text = NSLocalizedStringFromTable(@"list.blank", @"plugin_gateway", @"列表空");
    label.textAlignment = NSTextAlignmentCenter;
    [label setTextColor:[UIColor lightGrayColor]];
    [label setFont:[UIFont systemFontOfSize:15.0f]];
    [messageView addSubview:label];
    
    return messageView;
}

//根据indexPath获得row高度
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76.f;
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XM_WS(weakself);
    static NSString* cellIdentifier = @"reuseCellId";
    MHLumiFMCell* cell = (MHLumiFMCell* )[self.tvcInternal.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MHLumiFMCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    MHLumiXMRadio *radio = self.dataSource[indexPath.row];
    [cell configureWithDataObject:radio];
    
    if (([radio.radioId integerValue] == [[_fmPlayer.currentRadio valueForKey:@"radioId"] integerValue]) &&
        _fmPlayer.isPlaying ){
        cell.isAnimation = YES;
    }
    else {
        cell.isAnimation = NO;
    }
    
    cell.onCollectionClicked = ^(MHLumiFMCell *cell){
        [weakself resetEditedData:radio];
    };
    
    return cell;
}

-(void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MHLumiXMRadio *radio = self.dataSource[indexPath.row];
    if(self.radioSelected)self.radioSelected(radio);
    
    [self hideAllCellAnimation];
    [self.tvcInternal.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    MHLumiFMCell *cell = (MHLumiFMCell *)[self.tvcInternal.tableView cellForRowAtIndexPath:indexPath];
    cell.isAnimation = YES;
}

- (void)hideAllCellAnimation {
    for (MHLumiFMCell *obj in self.tvcInternal.tableView.visibleCells){
        obj.isAnimation = NO;
    }
}

- (void)showAnimation:(MHLumiXMRadio *)currentRadio {
    NSInteger index = [self.dataSource indexOfObject:currentRadio];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    MHLumiFMCell *cell = (MHLumiFMCell *)[self.tvcInternal.tableView cellForRowAtIndexPath:indexPath];
    cell.isAnimation = YES;
}

@end
