//
//  MHLumiFMViewController.m
//  MiHome
//
//  Created by Lynn on 11/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiFMProgramViewController.h"
#import "MHTableViewControllerInternal.h"
#import "MHLumiFMProgramCell.h"
#import "MHLumiFMCollectionInvoker.h"
#import "MHLumiFmPlayer.h"

@interface MHLumiFMProgramViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation MHLumiFMProgramViewController
{
    MHLumiFmPlayer *    _fmPlayer;
    UIView *            _messageView;
    CGRect              _viewFrame;
}

- (id)initWithFrame:(CGRect)frame andRadio:(MHLumiXMRadio *)radio {
    self = [super init];
    if (self) {
        _currentRadio = radio;
        _viewFrame = frame;
        _tableView.frame = _viewFrame;
        
        [self fetchRemoteDataWithFinish];
    }
    return self;
}

- (void)setCurrentRadio:(MHLumiXMRadio *)currentRadio {
    _currentRadio = currentRadio;

    [self fetchRemoteDataWithFinish];
}

- (void)dealloc {
    NSLog(@"ddd");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isTabBarHidden = YES;
    self.view.backgroundColor = [UIColor clearColor];
    _fmPlayer = [MHLumiFmPlayer shareInstance];
}

- (void)setDataSource:(NSMutableArray *)dataSource {
    _dataSource = dataSource;
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
        if ([program.programEndTime isEqualToString:@"00:00"]) {
            endTime = [NSString stringWithFormat:@"%@ %@",currentDayString, @"23:59"];
        }
        NSDate *endDate = [dateFormatter dateFromString:endTime];
        
        if ([[currentDate earlierDate:endDate] isEqualToDate:currentDate]) {
            weakself.currentIndex = idx;
            * stop = YES;
        }
    }];
    [_tableView reloadData];
    
    if (dataSource.count && _tableView.visibleCells){
        if (_currentIndex >= dataSource.count) _currentIndex = dataSource.count - 1;
        NSIndexPath *index = [NSIndexPath indexPathForRow:_currentIndex inSection:0];
        [_tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionMiddle animated:YES];        
    }
}

- (void)buildSubviews {
    [super buildSubviews];
    
    _tableView = [[UITableView alloc] initWithFrame:_viewFrame];
    [_tableView registerClass:[MHLumiFMProgramCell class] forCellReuseIdentifier:@"reuseCellId"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
}

#pragma mark - 数据操作
-(void)fetchRemoteDataWithFinish
{
    XM_WS(weakself);
    
    NSDictionary *params = @{ @"radio_id" : [_currentRadio valueForKey:@"radioId"] };
    [[MHLumiXMDataManager sharedInstance] fetchProgramList:params withSuccess:^(NSMutableArray *datalist) {
        weakself.dataSource = [NSMutableArray arrayWithArray:datalist];
        if(weakself.dataLoaded) weakself.dataLoaded(weakself.dataSource);
        
    } andFailure:^(NSError *error) {
        
    }];
}

#pragma mark - tableview delegte

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.dataSource.count) {
        [_messageView removeFromSuperview];
        return self.dataSource.count;
    }
    else {
        if (!_messageView){
            _messageView = [[UIView alloc] initWithFrame:self.view.bounds];
        }
        [_messageView setBackgroundColor:[UIColor clearColor]];
        
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableview_blank_logo"]];
        [_messageView addSubview:icon];
        CGRect imageFrame = icon.frame;
        imageFrame.origin.x = _messageView.bounds.size.width / 2.0f - icon.frame.size.width / 2.0f;
        imageFrame.origin.y = CGRectGetHeight(self.view.bounds) / 3.f;
        [icon setFrame:imageFrame];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(_messageView.frame.origin.x,
                                                                   CGRectGetMaxY(icon.frame) + 10.0f,
                                                                   _messageView.frame.size.width,
                                                                   19.0f)];
        label.text = NSLocalizedStringFromTable(@"list.blank", @"plugin_gateway", @"列表空");
        label.textAlignment = NSTextAlignmentCenter;
        [label setTextColor:[UIColor lightGrayColor]];
        [label setFont:[UIFont systemFontOfSize:15.0f]];
        [_messageView addSubview:label];
        [self.view addSubview:_messageView];
        
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"reuseCellId";
    MHLumiFMProgramCell* cell = (MHLumiFMProgramCell* )[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MHLumiFMProgramCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    MHLumiXMProgram *radio = self.dataSource[indexPath.row];
    [cell configureWithDataObject:radio];
    
    cell.isAnimation = NO;
    if (_currentIndex == indexPath.row && _fmPlayer.isPlaying) cell.isAnimation = YES;
    
    return cell;
}

@end
