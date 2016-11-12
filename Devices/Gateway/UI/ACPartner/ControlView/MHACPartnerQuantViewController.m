//
//  MHACPartnerQuantViewController.m
//  MiHome
//
//  Created by ayanami on 16/6/4.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerQuantViewController.h"
#import "MHLMChartCanvasView.h"
#import "MHLumiPlugQuantEngine.h"
#import "MHLumiDateTools.h"

#define chartCanvasFrame CGRectMake(0, 0, Screen_Width, Screen_Height * 0.7)

@interface MHACPartnerQuantViewController ()

@property (nonatomic,assign) CGFloat largestData;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSMutableArray *dateLineSource;
@property (nonatomic,strong) NSString *dateType;
@property (nonatomic,strong) MHLMChartCanvasView *chartCanvasView;
@property (nonatomic,strong) MHDeviceAcpartner *acpartner;
@property (nonatomic,strong) UILabel *dataDisplayLabel;

@property (nonatomic, strong) UIButton *payBtn;


@end

@implementation MHACPartnerQuantViewController
{
    UIView *                        _dataCanvasView;
    UILabel *                       _dataDisplayUnitLabel;
    
    MHLumiPlugQuantEngine *         _plugQuantEngine;
}

- (id)initWithSensor:(MHDeviceAcpartner *)acpartner {
    if (self = [super init]) {
        _acpartner = acpartner;
        self.dateType = @"day";
    }
    return self;
}



- (void)fetchDBData:(NSString *)dateType {
    XM_WS(weakself);
    
    _plugQuantEngine = [MHLumiPlugQuantEngine sharedEngine] ;
    NSString *startString = [_plugQuantEngine fullStringFromDate:[NSDate date]];
    __weak MHLumiPlugQuantEngine *weakQuantEngine = _plugQuantEngine;
    [[MHLumiPlugQuantEngine sharedEngine] fetchQuantData:startString LimitedNum:50 DateType:dateType withCompletionBlock:^(NSArray *array) {
        //增加当日/月显示
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
        if ([dateType isEqualToString:@"day"]) {
            [newArray insertObject:weakQuantEngine.currentDay atIndex:0];
        }
        if ([dateType isEqualToString:@"month"]) {
            [newArray insertObject:weakQuantEngine.currentMonth atIndex:0];
        }
        array = newArray;
        [[MHLumiPlugQuantEngine sharedEngine] rebuildDBData:array
                                                   dateType:dateType
                                             withFinishData:^(NSArray *displayData, NSArray *timeLineData , MHLumiPlugQuant *largestQuant) {
                                                 
                                                 if (largestQuant.quantValue.doubleValue > weakself.largestData){
                                                     weakself.largestData = largestQuant.quantValue.doubleValue;
                                                 }
                                                 weakself.dateLineSource = [timeLineData mutableCopy];
                                                 weakself.dataSource = [displayData mutableCopy];
                                             }];
    }];
}

- (void)viewDidLoad {
    self.isTabBarHidden = YES;
    self.isNavBarTranslucent = YES;
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"lumi_plug_quant_clicked"];
    
    if(_selectedType == 10001){
        //        self.dateType = @"month";
        [_chartCanvasView btnClicked:_chartCanvasView.switchButtonGroup[0]];
    }
}

- (void)setDataSource:(NSMutableArray *)dataSource {
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        
        if(!_chartCanvasView) {
            [self buildCanvasView];
        }
        
        _chartCanvasView.largestData = _largestData;
        _chartCanvasView.dateLineSource = _dateLineSource;
        _chartCanvasView.dataSource = dataSource;
        if ([_dateType isEqualToString:@"day"]){
            _chartCanvasView.screenSpotNum = 9;
        }
        else {
            _chartCanvasView.screenSpotNum = 5;
        }
    }
}

- (void)setDateType:(NSString *)dateType {
    if (_dateType != dateType) {
        _dateType = dateType;
        
        _chartCanvasView.dateType = dateType;
        _largestData = 0;
        [self fetchDBData:dateType];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)buildCanvasView {
    XM_WS(weakself);
    
    self.dateType = @"day";
    
    _chartCanvasView = [[MHLMChartCanvasView alloc] initWithFrame:chartCanvasFrame
                                                       DataSource:_dataSource
                                                   DateLineSource:_dateLineSource
                                                      LargestData:_largestData
                                                    ScreenSpotCnt:9
                                                        ChartType:MHLMBarChart];
    _chartCanvasView.strokeColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2];
    _chartCanvasView.hightLightColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8f];
    _chartCanvasView.switchBtnTitleGroup = @[ NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.quantvc.month", @"plugin_gateway", nil) ,
                                              NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.quantvc.day", @"plugin_gateway", nil) ,
                                              ];
    
    //callback
    void (^dayButtonClicked)() = ^(){
        weakself.dateType = @"day";
    };
    void (^monthButtonClicked)() = ^(){
        weakself.dateType = @"month";
    };
    _chartCanvasView.switchBtnBlockGroup = @[ monthButtonClicked , dayButtonClicked];
    _chartCanvasView.dateType = _dateType ;
    _chartCanvasView.updateCurrent = ^(CGFloat currentData) {
        weakself.dataDisplayLabel.text = [NSString stringWithFormat:@"%0.3f", currentData];
    };
    
    _chartCanvasView.getMoreBlock = ^(NSString *dateString) {
        [weakself getMore:dateString];
    };
    
    [self.view addSubview:_chartCanvasView];
}

- (void)buildSubviews {
    [super buildSubviews];
    self.view.backgroundColor = [MHColorUtils colorWithRGB:0x202f3b];
    
    if (_dataSource.count) {
        [self buildCanvasView];
    }
    
    CGRect dataCanvasFrame = CGRectMake(0,
                                        CGRectGetMaxY(chartCanvasFrame),
                                        Screen_Width,
                                        CGRectGetMaxY(self.view.frame) - CGRectGetMaxY(chartCanvasFrame));
    _dataCanvasView = [[UIView alloc] initWithFrame:dataCanvasFrame];
    _dataCanvasView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_dataCanvasView];
    
    _dataDisplayLabel =  [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 90)];
    _dataDisplayLabel.textAlignment = NSTextAlignmentRight;
    _dataDisplayLabel.font = [UIFont fontWithName:@"DINCond-Regular" size:47.f];
    _dataDisplayLabel.center = CGPointMake(_dataCanvasView.center.x - 30, dataCanvasFrame.size.height * 0.3);
    [_dataCanvasView addSubview:_dataDisplayLabel];
    
    _dataDisplayUnitLabel =  [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_dataDisplayLabel.frame) + 5,
                                                                       dataCanvasFrame.size.height  * 0.3 , 50, 24)];
    _dataDisplayUnitLabel.textAlignment = NSTextAlignmentLeft;
    _dataDisplayUnitLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.quant.degree", @"plugin_gateway", nil);
    _dataDisplayUnitLabel.font = [UIFont systemFontOfSize:12.f];
    [_dataCanvasView addSubview:_dataDisplayUnitLabel];
    [self.view bringSubviewToFront:_dataCanvasView];
    
    _payBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //    [_payBtn setTitle:NSLocalizedStringFromTable(@"done",@"plugin_gateway","完成") forState:(UIControlStateNormal)];
    [_payBtn setTitle:@"点击交电费" forState:(UIControlStateNormal)];
    _payBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_payBtn setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:(UIControlStateNormal)];
    [_payBtn.layer setCornerRadius:46 / 2.f];
    _payBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _payBtn.layer.borderWidth = 0.5;
    [_payBtn addTarget:self action:@selector(onPay:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_payBtn];
    _payBtn.hidden = YES;
    
    
}

- (void)buildConstraints {
    [super buildConstraints];
    
    CGFloat veritalSapcing = 20 * ScaleHeight;
    CGFloat herizonSpacing = 30 * ScaleWidth;
    //添加设备
    XM_WS(weakself);
    
    [self.payBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view).with.offset(herizonSpacing);
        make.bottom.equalTo(weakself.view).with.offset(-veritalSapcing);
        make.right.equalTo(weakself.view).with.offset(-herizonSpacing);
        make.height.mas_equalTo(46);
    }];
    
}

- (void)onPay:(id)sender {
    
    [self gw_clickMethodCountWithStatType:@"openPlugPay:"];
}

#pragma mark - more
- (void)getMore:(NSString *)currentDateString{
    NSLog(@"%@",currentDateString);
    NSInteger curentUnix = [[_plugQuantEngine fetchUnixTimeStamp:currentDateString] integerValue];
    
    NSString *campareDate = @"2015-10-10 00:00:00";
    NSInteger campareUnix = [[_plugQuantEngine fetchUnixTimeStamp:campareDate] integerValue];
    
    if (curentUnix < campareUnix){
        return;
    }
    
    XM_WS(weakself);
    [_plugQuantEngine fetchQuantData:currentDateString LimitedNum:50 DateType:_dateType withCompletionBlock:^(NSArray *array) {
        
        [[MHLumiPlugQuantEngine sharedEngine] rebuildDBData:array
                                                   dateType:weakself.dateType
                                             withFinishData:^(NSArray *displayData, NSArray *timeLineData , MHLumiPlugQuant *largestQuant) {
                                                 
                                                 if (largestQuant.quantValue.doubleValue > weakself.largestData){
                                                     weakself.largestData = largestQuant.quantValue.doubleValue;
                                                 }
                                                 NSMutableArray *tmpDateLineSource = [timeLineData mutableCopy];
                                                 NSMutableArray *tmpDataSource = [displayData mutableCopy];
                                                 
                                                 [tmpDateLineSource addObjectsFromArray:weakself.dateLineSource];
                                                 [tmpDataSource addObjectsFromArray:weakself.dataSource];
                                                 
                                                 weakself.dateLineSource = tmpDateLineSource;
                                                 weakself.dataSource = tmpDataSource;
                                             }];
    }];
}

@end
