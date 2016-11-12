//
//  MHGatewayPlugQuantViewController.m
//  MiHome
//
//  Created by Lynn on 9/21/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayPlugQuantViewController.h"
#import "MHLMChartCanvasView.h"
#import "MHLumiPlugQuantEngine.h"
#import "MHLumiDateTools.h"
#import "MHRechargeManager.h"
#import "MHGatewayWebViewController.h"

#define chartCanvasFrame CGRectMake(0, 0, Screen_Width, Screen_Height * 0.8)

@interface MHGatewayPlugQuantViewController ()

@property (nonatomic,assign) CGFloat largestData;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSMutableArray *dateLineSource;
@property (nonatomic,strong) NSString *dateType;
@property (nonatomic,strong) MHLMChartCanvasView *chartCanvasView;
@property (nonatomic,strong) MHDeviceGatewayBase *devicePlug;
@property (nonatomic,strong) UILabel *dataDisplayLabel;

@property (nonatomic, strong) UIButton *payBtn;
@property (nonatomic, strong) UILabel *electricityLabel;
@property (nonatomic, strong) UILabel *balanceLabel;
@property (nonatomic,assign) int electricityBalance;


@end

@implementation MHGatewayPlugQuantViewController
{
    UIView *                        _dataCanvasView;
    UILabel *                       _dataDisplayUnitLabel;
    
    MHLumiPlugQuantEngine *         _plugQuantEngine;
}

- (id)initWithDevice:(MHDeviceGatewayBase *)devicePlug {
    
    if (self = [super init]) {
        _devicePlug = devicePlug;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    XM_WS(weakself);
    [MHRechargeManager getBalances:self.devicePlug type:MHRechargeElectric completion:^(int elc) {
        //-1说明第一次使用
        if (elc != -1) {
            weakself.electricityLabel.hidden = NO;
            weakself.electricityBalance = elc;
            weakself.balanceLabel.text = [NSString stringWithFormat:@"%.02f%@", elc / 100.0f ,NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.pay.rmb",@"plugin_gateway","元") ];
        }
        else {
            weakself.electricityLabel.hidden = YES;
        }
        
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"lumi_plug_quant_clicked"];
    
    if(_selectedType == kMonthDateType){
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
    
    _payBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_payBtn setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.pay",@"plugin_gateway","點擊交電費") forState:(UIControlStateNormal)];
    _payBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_payBtn setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:(UIControlStateNormal)];
    [_payBtn.layer setCornerRadius:46 / 2.f];
    _payBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _payBtn.layer.borderWidth = 0.5;
    [_payBtn addTarget:self action:@selector(onPay:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_payBtn];
//    _payBtn.hidden = YES;

    self.electricityLabel = [[UILabel alloc] init];
    self.electricityLabel.textAlignment = NSTextAlignmentRight;
    self.electricityLabel.textColor = [UIColor blackColor];
    self.electricityLabel.font = [UIFont systemFontOfSize:18.0f];
    self.electricityLabel.backgroundColor = [UIColor clearColor];
    self.electricityLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.pay.electricityaccountbalance",@"plugin_gateway","电费余额:");
    self.electricityLabel.hidden = YES;
    [self.view addSubview:self.electricityLabel];
    
    self.balanceLabel = [[UILabel alloc] init];
    self.balanceLabel.textAlignment = NSTextAlignmentLeft;
    self.balanceLabel.textColor = [UIColor blackColor];
    self.balanceLabel.font = [UIFont systemFontOfSize:18.0f];
    self.balanceLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.balanceLabel];

    
}

- (void)buildConstraints {
    [super buildConstraints];
    
    CGFloat veritalSapcing = 20 * ScaleHeight;
    CGFloat herizonSpacing = 30 * ScaleWidth;
    XM_WS(weakself);

    [self.payBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view).with.offset(herizonSpacing);
        make.bottom.equalTo(weakself.view).with.offset(-veritalSapcing);
        make.right.equalTo(weakself.view).with.offset(-herizonSpacing);
        make.height.mas_equalTo(46);
    }];
    
    [self.electricityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakself.view.mas_centerX);
        make.bottom.mas_equalTo(weakself.payBtn.mas_top).with.offset(-18 * ScaleHeight);
        make.left.equalTo(weakself.view).with.offset(herizonSpacing);
    }];
    
    [self.balanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.electricityLabel.mas_right).with.offset(-5);
        make.bottom.mas_equalTo(weakself.payBtn.mas_top).with.offset(-18 * ScaleHeight);
        make.right.equalTo(weakself.view).with.offset(-herizonSpacing);
    }];

}

#pragma mark - 交电费
- (void)onPay:(id)sender {
    XM_WS(weakself);
    [MHRechargeManager getRechargeWebURL:self.devicePlug type:MHRechargeElectric completion:^(NSString *strHomePay) {
        NSURL *URL = [[NSURL alloc] initWithString:strHomePay];
        MHGatewayWebViewController *web = [[MHGatewayWebViewController alloc] initWithURL:URL];
        web.hasShare = NO;
        web.strOriginalURL = strHomePay;
        web.isTabBarHidden = YES;
        web.controllerIdentifier = @"mydevice.gateway.sensor.plug.pay";
//        MHWebViewController *web = [[MHWebViewController alloc] initWithURL:URL];
        [weakself.navigationController pushViewController:web animated:YES];
    }];

//        NSString *strHomePay = [MHRechargeManager getHomeFeeWebURL];
//    NSURL *URL = [[NSURL alloc] initWithString:strHomePay];
//    MHGatewayWebViewController *web = [[MHGatewayWebViewController alloc] initWithURL:URL];
//    web.hasShare = NO;
//    web.strOriginalURL = strHomePay;
//    web.isTabBarHidden = YES;
//    web.controllerIdentifier = @"mydevice.gateway.sensor.plug.pay";
//    
//    [self.navigationController pushViewController:web animated:YES];

    
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
