//
//  MHLumiFmPlayerViewController.m
//  MiHome
//
//  Created by Lynn on 12/23/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiFmPlayerViewController.h"
#import "MHLumiFmPlayer.h"
#import "MHLumiFMVolumeControl.h"
#import "MHLumiFMProgramViewController.h"
#import "MHImageView.h"
#import "MHLumiXMDataManager.h"
#import "MHLumiFMCollectionInvoker.h"
#import "MHLumiFMPlayerAnimation.h"

@interface MHLumiFmPlayerViewController () <UIActionSheetDelegate>

@property (nonatomic,strong) MHDeviceGateway *radioDevice;
@property (nonatomic,strong) MHLumiXMRadio *currentRadio;
@property (nonatomic,strong) NSString *currentProgramName;
@property (nonatomic,assign) BOOL isHide;
@property (nonatomic,assign) BOOL isPlaying;
@property (nonatomic,strong) NSMutableArray *radioPlayList;
@property (nonatomic,strong) UIButton *playBtn;

@property (nonatomic,strong) NSString *programStart;
@property (nonatomic,strong) NSString *programEnd;
@property (nonatomic,assign) CGFloat currentProgramValue;
@property (nonatomic,strong) UILabel *timerDisplayLabel;

@end

@implementation MHLumiFmPlayerViewController
{
    UIButton *                          _lastBtn;
    UIButton *                          _nextBtn;
    UISlider *                          _slider;
    UILabel *                           _miniSlideLabel;
    UILabel *                           _maxSlideLabel;
    
    UIImageView *                       _bigCircle;
    UIImageView *                       _smallCircle;
    UIImageView *                       _halfCircle;
    MHImageView *                       _coverImage;
    UILabel *                           _radioTitle;
    UILabel *                           _programTitle;
    UIView *                            _playerBackView;
    UIButton *                          _collectionBtn;
    
    UILabel *                           _title;
    MHLumiFMProgramViewController *     _programList;
    
    UIPageControl *                     _pageControl;
    
    NSArray *                           _timerList;
}

- (void)setMiniPlayer:(MHLumiFmPlayer *)miniPlayer {
    _miniPlayer = miniPlayer;
    
    self.isPlaying = _miniPlayer.isPlaying;
    self.radioDevice = _miniPlayer.radioDevice;
    self.currentRadio = _miniPlayer.currentRadio;
    self.currentProgramName = _miniPlayer.currentProgramName;
    self.isPlaying = _miniPlayer.isPlaying;
    self.radioPlayList = _miniPlayer.radioPlayList;
    
    XM_WS(weakself)
    _miniPlayer.playCallBack = ^(MHLumiXMRadio *currentRadio){
        weakself.isPlaying = YES;
        weakself.currentRadio = currentRadio;
        [weakself.playBtn setImage:[UIImage imageNamed:@"lumi_fm_pause_big"] forState:UIControlStateNormal];
    };
    
    _miniPlayer.pauseCallBack = ^(MHLumiXMRadio *currentRadio){
        weakself.isPlaying = NO;
        weakself.currentRadio = currentRadio;
        [weakself.playBtn setImage:[UIImage imageNamed:@"lumi_fm_play_big"] forState:UIControlStateNormal];
    };
}

- (void)setCurrentRadio:(MHLumiXMRadio *)currentRadio {
    _currentRadio = currentRadio;
    
    _title.text = [self.currentRadio valueForKey:@"radioName"];
    _programList.currentRadio = currentRadio;
    _coverImage.imageUrl = [_currentRadio valueForKey:@"radioCoverLargeUrl"];
    [_coverImage loadImage];
    _radioTitle.text = [self.currentRadio valueForKey:@"radioName"];
    
    if([currentRadio.radioCollection isEqualToString:@"yes"]){
        [_collectionBtn setImage:[UIImage imageNamed:@"lumi_fm_player_shoucanged"] forState:UIControlStateNormal];
    }
    else{
        [_collectionBtn setImage:[UIImage imageNamed:@"lumi_fm_player_shoucang"] forState:UIControlStateNormal];
    }
}

- (void)setCurrentProgramName:(NSString *)currentProgramName {
    _currentProgramName = currentProgramName;
    self.miniPlayer.currentProgramName = currentProgramName;
    
    _programTitle.text = currentProgramName;
    _miniSlideLabel.text = _programStart;
    _maxSlideLabel.text = _programEnd;
    _slider.value = _currentProgramValue;
}

- (void)setIsPlaying:(BOOL)isPlaying {
    _isPlaying = isPlaying;

    if (_isPlaying){
        [_playBtn setImage:[UIImage imageNamed:@"lumi_fm_pause_big"] forState:UIControlStateNormal];
    }
    else {
        [_playBtn setImage:[UIImage imageNamed:@"lumi_fm_play_big"] forState:UIControlStateNormal];
    }
}

- (void)viewDidLoad {
    self.isNavBarTranslucent = YES;
    self.isTabBarHidden = YES;
    self.view.backgroundColor = [MHColorUtils colorWithRGB:0x0ca8ba];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    [swipeRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:swipeRight];
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    [swipeLeft setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:swipeLeft];
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissViewController:)];
    [swipeDown setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:swipeDown];
    
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addAnimation];
    
    [self fetchTimerToDisplay];
}

- (void)applicationDidEnterBackground {
    [super applicationDidEnterBackground];
    [self removeAnimation];
}

- (void)applicationWillEnterForeground {
    [super applicationWillEnterForeground];
    [self addAnimation];
}

- (void)dismissViewController:(id)sender {
    
    [[MHLumiFMVolumeControl shareInstance] hide];
    [self.miniPlayer showPlayerSubs];
    self.miniPlayer.hidden = NO;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)dealloc {
    NSLog(@"ddd");
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)loadProgramData:(NSMutableArray *)dataSource {
    NSDate *currentDate = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    
    NSString *currentDayString = [dateFormatter stringFromDate:currentDate];
    
    XM_WS(weakself);
    [dataSource enumerateObjectsUsingBlock:^(MHLumiXMProgram *program, NSUInteger idx, BOOL *stop) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
        dateFormatter.timeZone = [NSTimeZone systemTimeZone];
        
        NSString *endTime = [NSString stringWithFormat:@"%@ %@",currentDayString,program.programEndTime];
        NSDate *endDate = [dateFormatter dateFromString:endTime];
        
        if ([[currentDate earlierDate:endDate] isEqualToDate:currentDate]) {
            NSString *startTime = [NSString stringWithFormat:@"%@ %@",currentDayString,program.programStartTime];
            NSDate *startDate = [dateFormatter dateFromString:startTime];
            
            NSTimeInterval totalInterval = [endDate timeIntervalSinceDate:startDate];
            NSTimeInterval currentInterval = [currentDate timeIntervalSinceDate:startDate];
            
            weakself.currentProgramValue = currentInterval / totalInterval * 100;

            weakself.programStart = program.programStartTime;
            weakself.programEnd = program.programEndTime;
            weakself.currentProgramName = program.program_name;
            * stop = YES;
        }
    }];
}

#pragma mark - subviews
- (void)titleSubviews {
    CGFloat btnY = ScaleHeight * 28;
    
    UIImage *backgroundImage = [UIImage imageNamed:@"lumi_fm_player_bg"];
    UIImageView *myImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [myImageView setImage:[backgroundImage stretchableImageWithLeftCapWidth:3 topCapHeight:3]];
    [self.view addSubview:myImageView];
    [self.view sendSubviewToBack:myImageView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(8, btnY , 28, 28);
    [backBtn addTarget:self action:@selector(dismissViewController:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"navi_back_white"] forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth - 100, 40)];
    _title.center = CGPointMake(self.view.center.x, backBtn.center.y );
    _title.textAlignment = NSTextAlignmentCenter;
    _title.text = [self.currentRadio valueForKey:@"radioName"];
    _title.textColor = [UIColor whiteColor];
    [self.view addSubview:_title];
    
    [self.view bringSubviewToFront:_playBtn];
    [self.view bringSubviewToFront:_lastBtn];
    [self.view bringSubviewToFront:_nextBtn];
}

- (void)commonSubviews {    
    _playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    if (_isPlaying){
        [_playBtn setImage:[UIImage imageNamed:@"lumi_fm_pause_big"] forState:UIControlStateNormal];
    }
    else{
        [_playBtn setImage:[UIImage imageNamed:@"lumi_fm_play_big"] forState:UIControlStateNormal];
    }
    _playBtn.center = CGPointMake(self.view.center.x, CGRectGetHeight(self.view.frame) - 50);
    [_playBtn addTarget:self action:@selector(onPlayClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playBtn];
    
    _lastBtn =  [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [_lastBtn setImage:[UIImage imageNamed:@"lumi_fm_play_last_big"] forState:UIControlStateNormal];
    _lastBtn.center = CGPointMake(_playBtn.center.x - 85, _playBtn.center.y);
    [_lastBtn addTarget:self action:@selector(onLastClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_lastBtn];
    
    _nextBtn =  [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [_nextBtn setImage:[UIImage imageNamed:@"lumi_fm_next_big"] forState:UIControlStateNormal];
    _nextBtn.center = CGPointMake(_playBtn.center.x + 85, _playBtn.center.y);
    [_nextBtn addTarget:self action:@selector(onNextClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextBtn];
    
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth - 130, 30)];
    _slider.center = CGPointMake(self.view.center.x,  _playBtn.center.y - 60);
    _slider.minimumValue = 0;   //最小值
    _slider.maximumValue = 100;  //最大值
    _slider.value = 40;
    _slider.continuous = NO;
    _slider.userInteractionEnabled = NO;
    [_slider setThumbImage:[UIImage imageNamed:@"lumi_fm_play_jindudian"] forState:UIControlStateNormal];
    [_slider setMaximumTrackTintColor:[UIColor colorWithWhite:1 alpha:0.2]];
    [_slider setMinimumTrackTintColor:[UIColor colorWithWhite:1 alpha:0.7]];
    [self.view addSubview:_slider];
    
    _miniSlideLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    _miniSlideLabel.textAlignment = NSTextAlignmentRight;
    _miniSlideLabel.center = CGPointMake(CGRectGetMinX(_slider.frame) - 25, _slider.center.y);
    _miniSlideLabel.text = @"09:00";
    _miniSlideLabel.textColor = [UIColor colorWithWhite:1 alpha:0.6];
    _miniSlideLabel.font = [UIFont systemFontOfSize:12.f];
    [self.view addSubview:_miniSlideLabel];
    
    _maxSlideLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    _maxSlideLabel.text = @"10:00";
    _maxSlideLabel.textAlignment = NSTextAlignmentLeft;
    _maxSlideLabel.center = CGPointMake( CGRectGetMaxX(_slider.frame) + 25, _slider.center.y);
    _maxSlideLabel.textColor = [UIColor colorWithWhite:1 alpha:0.6];
    _maxSlideLabel.font = [UIFont systemFontOfSize:12.f];
    [self.view addSubview:_maxSlideLabel];
}

- (void)buildSubviews{
    [super buildSubviews];
    [self commonSubviews];
    
    [self playerView];
    
    XM_WS(weakself);
    CGRect viewFrame = CGRectMake(0, 74, ScreenWidth, CGRectGetMinY(_slider.frame) - 100);
    _programList = [[MHLumiFMProgramViewController alloc] initWithFrame:viewFrame
                                                               andRadio:_currentRadio];
    _programList.dataLoaded = ^(NSMutableArray *datasource){
        [weakself loadProgramData:datasource];
    };
    _programList.view.hidden = YES;
    [self.view addSubview:_programList.view];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0,
                                                                   CGRectGetMinY(_slider.frame) - 10,
                                                                   ScreenWidth,
                                                                   20.f)];
    _pageControl.numberOfPages = 2;
    _pageControl.currentPage = 0;
    [_pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_pageControl];

    [self titleSubviews];
}

- (void)playerView {
    CGFloat coverImageHeight = 160 * ScaleHeight;
    CGFloat circleSize = 205 * ScaleHeight;
    CGFloat imageSize = 115 * ScaleHeight;
    
    if([UIScreen mainScreen].bounds.size.height < 548.f)
        coverImageHeight = 100 * ScaleHeight;
    
    _playerBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 74,
                                                                      ScreenWidth,
                                                                      CGRectGetMinY(_slider.frame) - 100)];
    _playerBackView.userInteractionEnabled = YES;
    _playerBackView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_playerBackView];
    
    _bigCircle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, circleSize, circleSize)];
    _bigCircle.center = CGPointMake(_playerBackView.center.x, coverImageHeight);
    _bigCircle.image = [UIImage imageNamed:@"lumi_fm_player_waiyuan"];
    [_playerBackView addSubview:_bigCircle];
    
    _smallCircle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, circleSize, circleSize)];
    _smallCircle.center = _bigCircle.center;
    _smallCircle.image = [UIImage imageNamed:@"lumi_fm_player_neiyuan"];
    [_playerBackView addSubview:_smallCircle];

    _halfCircle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, circleSize, circleSize)];
    _halfCircle.center = _bigCircle.center;
    _halfCircle.image = [UIImage imageNamed:@"lumi_fm_player_guang"];
    [_playerBackView addSubview:_halfCircle];

    _coverImage = [[MHImageView alloc] init];
    _coverImage.frame = CGRectMake(0, 0, imageSize, imageSize);
    _coverImage.center = _bigCircle.center;
    _coverImage.layer.cornerRadius = imageSize / 2;
    _coverImage.placeHolderImage = [UIImage imageNamed:@"lumi_fm_cover_placeholder"];
    [_playerBackView addSubview:_coverImage];
    _coverImage.imageUrl = [_currentRadio valueForKey:@"radioCoverLargeUrl"];
    [_coverImage loadImage];

    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lumi_fm_xmlogo"]];
    logoImageView.frame = _coverImage.frame ;
    [_playerBackView addSubview:logoImageView];
    
    _collectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if([_currentRadio.radioCollection isEqualToString:@"yes"]){
        [_collectionBtn setImage:[UIImage imageNamed:@"lumi_fm_player_shoucanged"] forState:UIControlStateNormal];
    }
    else{
        [_collectionBtn setImage:[UIImage imageNamed:@"lumi_fm_player_shoucang"] forState:UIControlStateNormal];
    }
    _collectionBtn.frame = CGRectMake(0, 0, 35, 35);
    _collectionBtn.center = CGPointMake(self.view.center.x, _playerBackView.frame.size.height - 20);
    [_collectionBtn addTarget:self action:@selector(addCollection) forControlEvents:UIControlEventTouchUpInside];
    [_playerBackView addSubview:_collectionBtn];
    
    UIButton *volumeControlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [volumeControlBtn setImage:[UIImage imageNamed:@"lumi_fm_player_volum"] forState:UIControlStateNormal];
    volumeControlBtn.frame = CGRectMake(0, 0, 35, 35);
    volumeControlBtn.center = CGPointMake(_collectionBtn.center.x - 56, _collectionBtn.center.y);
    [volumeControlBtn addTarget:self action:@selector(volumeControl) forControlEvents:UIControlEventTouchUpInside];
    [_playerBackView addSubview:volumeControlBtn];

    UIButton *colockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [colockBtn setImage:[UIImage imageNamed:@"lumi_fm_player_clock"] forState:UIControlStateNormal];
    colockBtn.frame = CGRectMake(0, 0, 35, 35);
    colockBtn.center = CGPointMake(_collectionBtn.center.x + 56, _collectionBtn.center.y);
    [colockBtn addTarget:self action:@selector(clockControl) forControlEvents:UIControlEventTouchUpInside];
    [_playerBackView addSubview:colockBtn];
    
    _timerDisplayLabel = [[UILabel alloc] initWithFrame:CGRectMake( CGRectGetMaxX(colockBtn.frame), 0, 100, 40)];
    _timerDisplayLabel.center = CGPointMake(_timerDisplayLabel.center.x, colockBtn.center.y);
    _timerDisplayLabel.textAlignment = NSTextAlignmentLeft;
    _timerDisplayLabel.textColor = [UIColor colorWithWhite:1.f alpha:0.8];
    _timerDisplayLabel.font = [UIFont systemFontOfSize:12.f];
    _timerDisplayLabel.hidden = YES;
    [_playerBackView addSubview:_timerDisplayLabel];

    CGFloat centerOfBtnAndImage = CGRectGetMaxY(_bigCircle.frame) + ( CGRectGetMinY(volumeControlBtn.frame) - CGRectGetMaxY(_bigCircle.frame) ) / 2;
    _radioTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth - 100, 30)];
    _radioTitle.center = CGPointMake(_playerBackView.center.x, centerOfBtnAndImage);
    _radioTitle.textAlignment = NSTextAlignmentCenter;
    _radioTitle.text = [_currentRadio valueForKey:@"radioName"];
    _radioTitle.textColor = [UIColor whiteColor];
    [_playerBackView addSubview:_radioTitle];
    
    _programTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth - 100, 20)];
    _programTitle.center = CGPointMake(_playerBackView.center.x, _radioTitle.center.y + 25);
    _programTitle.textAlignment = NSTextAlignmentCenter;
    _programTitle.textColor = [UIColor colorWithWhite:1.f alpha:0.5];
    _programTitle.font = [UIFont systemFontOfSize:12.f];
    [_playerBackView addSubview:_programTitle];
}

#pragma mark - animation
- (void)addAnimation {
    //在添加动画之前，先删除之前的动画
    [MHLumiFMPlayerAnimation addAnimation:_coverImage.layer duration:10.f];
    [MHLumiFMPlayerAnimation addReverseAnimation:_halfCircle.layer duration:8.f];
    
    if (!self.miniPlayer.isPlaying){
        [self pauseLayer:_coverImage.layer];
        [self pauseLayer:_halfCircle.layer];
    }
}

- (void)removeAnimation {
    [_coverImage.layer removeAllAnimations];
    [_halfCircle.layer removeAllAnimations];
}

-(void)pauseLayer:(CALayer*)layer
{
    [MHLumiFMPlayerAnimation pauseLayer:layer];
}

-(void)resumeLayer:(CALayer*)layer
{
    [MHLumiFMPlayerAnimation resumeLayer:layer];
}

#pragma mark - page control
- (void)pageTurn:(UIPageControl *)sender {
    CATransition *animation = [[CATransition alloc] init];
    animation.duration = 0.5;
    animation.timingFunction = [ CAMediaTimingFunction  functionWithName: kCAMediaTimingFunctionEaseInEaseOut ];
    animation.type = kCATransitionPush;

    if (sender.currentPage == 1){
        animation.subtype = kCATransitionFromRight;
        [_playerBackView.layer addAnimation:animation forKey:nil];
        [_programList.view.layer addAnimation:animation forKey:nil];
        
        _programList.view.hidden = NO;
        _playerBackView.hidden = YES;
    }
    else {
        animation.subtype = kCATransitionFromLeft;
        [_playerBackView.layer addAnimation:animation forKey:nil];
        [_programList.view.layer addAnimation:animation forKey:nil];
        
        _programList.view.hidden = YES;
        _playerBackView.hidden = NO;
    }
}

- (void)swiped:(UISwipeGestureRecognizer *)sender {
    NSInteger current = _pageControl.currentPage;
    NSInteger next = 0;

    if(current == 0 && sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        next = current + 1;
        _pageControl.currentPage = next;
        [self pageTurn:_pageControl];
    }
    else if(current == 1 && sender.direction == UISwipeGestureRecognizerDirectionRight) {
        next = current - 1;
        _pageControl.currentPage = next;
        [self pageTurn:_pageControl];
    }
}

#pragma mark - player control
- (void)volumeControl {
    MHLumiFMVolumeControl *volumeControl = [MHLumiFMVolumeControl shareInstance];
    volumeControl.gateway = self.radioDevice;
    [volumeControl showVolumeControl:CGRectGetMaxY(self.view.bounds) - VolumePlayerHeight withVolumeValue:_radioDevice.fm_volume];
    
    XM_WS(weakself);
    volumeControl.volumeControlCallBack = ^(NSInteger value){
        NSLog(@"%ld",value);
        [weakself.radioDevice radioVolumeControlWithDirection:nil Value:value andSuccess:^(id obj) {
            NSLog(@"%@",obj);
            if ([[obj valueForKey:@"result"] isKindOfClass:[NSDictionary class]]) {
                weakself.radioDevice.fm_volume = [[[obj valueForKey:@"result"] valueForKey:@"volume"] integerValue];
            }
            
        } andFailure:^(NSError *v) {
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"setting.failed", @"plugin_gateway", nil)
                                              duration:1.5f
                                                 modal:NO];
        }];
    };
}

- (void)addCollection {
    MHLumiFMCollectionInvoker *invoker = [[MHLumiFMCollectionInvoker alloc] init];
    invoker.radioDevice = _radioDevice;
    
    XM_WS(weakself);
    if([[_currentRadio valueForKey:@"radioCollection"] isEqualToString:@"yes"]){
        
        if ([_currentRadio isKindOfClass:[MHLumiXMRadio class]]) _currentRadio.radioCollection = @"no";
        
        [_collectionBtn setImage:[UIImage imageNamed:@"lumi_fm_player_shoucang"] forState:UIControlStateNormal];
        [invoker removeElementFromCollection:_currentRadio
                                 WithSuccess:nil
                                  andFailure:^(NSError *error){
                                      if ([weakself.currentRadio isKindOfClass:[MHLumiXMRadio class]])
                                          weakself.currentRadio.radioCollection = @"yes";
                                  }];
    }
    else{
        if ([_currentRadio isKindOfClass:[MHLumiXMRadio class]]) _currentRadio.radioCollection = @"yes";

        [_collectionBtn setImage:[UIImage imageNamed:@"lumi_fm_player_shoucanged"] forState:UIControlStateNormal];
        [invoker addElementToCollection:_currentRadio
                            WithSuccess:nil
                             andFailure:^(NSError *error){
                                 if ([weakself.currentRadio isKindOfClass:[MHLumiXMRadio class]])
                                     weakself.currentRadio.radioCollection = @"no";
                             }];
    }
}

- (void)clockControl {
    _timerList = @[ NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.timer.cancel", @"plugin_gateway", @"取消关机") ,
                         NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.timer.10", @"plugin_gateway", @"十分钟后关机") ,
                         NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.timer.20", @"plugin_gateway", @"二十分钟后关机") ,
                         NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.timer.30", @"plugin_gateway", @"三十分钟后关机") ,
                         NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.timer.40", @"plugin_gateway", @"四十分钟后关机") ,
                         NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.timer.50", @"plugin_gateway", @"五十分钟后关机") ,
                         NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.timer.60", @"plugin_gateway", @"六十分钟后关机") ,
                       ];
    MHLumiFMVolumeControl *timerControl = [MHLumiFMVolumeControl shareInstance];
    [timerControl showTimerControler:CGRectGetMaxY(self.view.bounds) - ListControlHeight withTimerList:_timerList];
    
    XM_WS(weakself);
    timerControl.timerControlCallBack = ^(NSString *timer) {
        NSInteger timeInterval = [self mapTimerStringToInt:timer];
        if (timeInterval == 0 ) {
            [weakself.radioDevice deleteFMCloseTimerWithSuccess:^(id obj) {
                [[MHTipsView shareInstance] showFinishTips:NSLocalizedStringFromTable(@"delete.succeed", @"plugin_gateway", nil)
                                                  duration:1.5f
                                                     modal:NO];
                [weakself.timerDisplayLabel setHidden:YES];

            } andFailure:^(NSError *v) {
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"delete.failed", @"plugin_gateway", nil)
                                                  duration:1.5f
                                                     modal:NO];
            }];
        }
        else {
            [weakself.radioDevice addFMCloseNewTimer:timeInterval WithSuccess:^(id obj) {
                [weakself fetchTimerToDisplay];

            } andFailure:^(NSError *v) {
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"setting.failed", @"plugin_gateway", nil)
                                                  duration:1.5f
                                                     modal:NO];
            }];
        }
    };
}

- (void)fetchTimerToDisplay {
    MHDataDeviceTimer *timer = [self.radioDevice hasFMCloseTimer];
    if (timer.isEnabled) {
        NSInteger stopTimer = timer.offMinute;
        
        NSDate *currentDate = [NSDate date];
        NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        calendar.timeZone = [NSTimeZone systemTimeZone];
        NSInteger currentTimer = [calendar component:NSCalendarUnitMinute fromDate:currentDate];
        
        NSInteger timerInterval = stopTimer - currentTimer;
        if (timerInterval <= 0) timerInterval = timerInterval + 60;
        
        _timerDisplayLabel.text = [NSString stringWithFormat:@"%ld%@", timerInterval, NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.timer.display", @"plugin_gateway", nil)];
        _timerDisplayLabel.hidden = NO;
    }
}

- (NSInteger)mapTimerStringToInt:(NSString *)timer {
    NSInteger index = [_timerList indexOfObject:timer];

    if (index == 1) return 10;
    if (index == 2) return 20;
    if (index == 3) return 30;
    if (index == 4) return 40;
    if (index == 5) return 50;
    if (index == 6) return 60;
    
    return 0;
}

- (void)onPlayClicked:(id)sender {
    if (self.miniPlayer.isPlaying) {
        [self.miniPlayer pause];
        [self pauseLayer:_coverImage.layer];
        [self pauseLayer:_halfCircle.layer];
    }
    else{
        [self.miniPlayer play];
        [self resumeLayer:_coverImage.layer];
        [self resumeLayer:_halfCircle.layer];
    }
}

- (void)onLastClicked:(id)sender {
    [self.miniPlayer playLast];
}

- (void)onNextClicked:(id)sender {
    [self.miniPlayer playNext];
}

@end
