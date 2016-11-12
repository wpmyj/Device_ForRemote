//
//  MHLumiFMSearchViewController.m
//  MiHome
//
//  Created by Lynn on 1/19/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLumiFMSearchViewController.h"
#import "MHLumiXMDataManager.h"
#import "MHDeviceSettingDefaultCell.h"
#import "MHTableViewControllerInternal.h"
#import "MHLumiFMCell.h"
#import "MHLumiFMCollectionInvoker.h"
#import "MHLumiFmPlayerViewController.h"

@interface MHLumiFMSearchViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, MHTableViewControllerInternalDelegate>

@property (nonatomic, strong) NSArray *topWords;
@property (nonatomic, strong) NSArray *historyWords;
@property (nonatomic, strong) MHTableViewControllerInternal* tvcInternal;
@property (nonatomic, strong) NSMutableArray *searchResultDataSource;
@property (nonatomic, assign) CGRect tableFrame;

@end

@implementation MHLumiFMSearchViewController
{
    UISearchBar *               _searchBar;
    NSString *                  _searchText;
    
    UITableView *               _historyTable;
    CGFloat                     _keyBoardHeight;
}

- (void)setHistoryWords:(NSArray *)historyWords {
    if (_historyWords != historyWords) {
        _historyWords = historyWords;
        [_historyTable reloadData];
    }
}

- (void)setSearchResultDataSource:(NSMutableArray *)searchResultDataSource {
    if(_searchResultDataSource != searchResultDataSource) {
        _searchResultDataSource = searchResultDataSource;
        
//        if (searchResultDataSource.count){
//            self.fmPlayer.radioPlayList = searchResultDataSource;
//            self.fmPlayer.currentRadio = searchResultDataSource[0];
//        }
        
        [_searchBar resignFirstResponder];
        [self buildSearchResults];
        _searchBar.text = _searchText;
    }
}

- (void)setTableFrame:(CGRect)tableFrame {
    _tableFrame = tableFrame;
    self.tvcInternal.view.frame = tableFrame;
}

- (void)dealloc {
    NSLog(@"ddd");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setImage:[UIImage imageNamed:@"navi_back_black"] forState:UIControlStateNormal];
    leftBtn.frame = CGRectMake(0, 0, 35, 35);
    self.navigationItem.leftBarButtonItem.customView = leftBtn;
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    rightView.backgroundColor = [UIColor clearColor];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self fetchHistoryWords];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    _keyBoardHeight = keyboardRect.size.height;
    _historyTable.frame = CGRectMake(0, 0, WIN_WIDTH, self.view.frame.size.height - _keyBoardHeight);
}

// 热搜词
//- (void)buildTopWordsView {
//    UIColor *yellow = [UIColor colorWithRed:233.f/255.f green:239.f/255.f blue:75.f/255.f alpha:1.f];
//    UIColor *green = [UIColor colorWithRed:216.f/255.f green:253.f/255.f blue:219.f/255.f alpha:1.f];
//    UIColor *white = [UIColor colorWithRed:251.f/255.f green:248.f/255.f blue:248.f/255.f alpha:1.f];
//    NSArray *colorArray = @[yellow, green , white];
//    XM_WS(weakself);
//    
//    __block CGFloat lastMaxX;
//    [_topWords enumerateObjectsUsingBlock:^(MHLumiXMTopWord *topword, NSUInteger idx, BOOL *stop) {
//        int x = arc4random() % 3;
//        UILabel *label = [[UILabel alloc] init];
//        label.text = topword.search_word;
//        label.textColor = [MHColorUtils colorWithRGB:0x6d6d72];
//        label.font = [UIFont systemFontOfSize:13.f];
//        label.backgroundColor = colorArray[x];
//        [label sizeToFit];
//        label.layer.cornerRadius = label.frame.size.height / 2;
//        
//        CGFloat pointX = lastMaxX + label.frame.size.width / 2 + 20;
//        CGFloat pointY = idx / 3 * 40 + 96 + label.frame.size.height / 2;
//        label.center = CGPointMake(pointX, pointY);
//        [weakself.view addSubview:label];
//    }];
//}

- (void)buildSubviews {
    [super buildSubviews];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20, 7, WIN_WIDTH - 130, 30)];
    _searchBar.delegate = self;
    _searchBar.placeholder = NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.searchplaceholder", @"plugin_gateway", nil);
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.tintColor = [UIColor lightGrayColor];
    [_searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_searchBar becomeFirstResponder];
    _searchBar.center = CGPointMake(self.view.center.x, self.navigationItem.titleView.center.y);
    self.navigationItem.titleView = _searchBar;

    _historyTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, self.view.frame.size.height - _keyBoardHeight) style:UITableViewStyleGrouped];
    _historyTable.dataSource = self;
    _historyTable.delegate = self;
    [self.view addSubview:_historyTable];
}

- (void)buildSearchResults {
    if (self.tvcInternal.view) {
        self.tvcInternal.view.hidden = NO;
        self.tvcInternal.dataSource = self.searchResultDataSource;
        [self.tvcInternal stopRefreshAndReload];
        [self.view bringSubviewToFront:self.tvcInternal.view];
    }
    else {
        self.tableFrame = CGRectMake(0, 64, WIN_WIDTH, self.view.frame.size.height - 64);
        self.tvcInternal = [[MHTableViewControllerInternal alloc] initWithStyle:UITableViewStylePlain];
        self.tvcInternal.cellClass = [MHLumiFMCell class];
        self.tvcInternal.delegate = self;
        self.tvcInternal.dataSource = self.searchResultDataSource;
        [self.tvcInternal.view setFrame:self.tableFrame];
        [self addChildViewController:self.tvcInternal];
        [self.view addSubview:self.tvcInternal.view];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_searchBar becomeFirstResponder];
    [MHLumiFmPlayer shareInstance].hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MHLumiFmPlayer shareInstance].hidden = NO;
    [_searchBar resignFirstResponder];
}

- (void)fetchHistoryWords {
    XM_WS(weakself);
    [[MHLumiXMDataManager sharedInstance] restoreHistoryKeywords:^(id obj) {
        weakself.historyWords = obj;
    }];
}

#pragma mark - tableview delagate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _historyWords.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.searchhistory", @"plugin_gateway", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    MHDeviceSettingDefaultCell *cell = (MHDeviceSettingDefaultCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MHDeviceSettingDefaultCell alloc] initWithReuseIdentifier:cellIdentifier];
    }
    
    MHDeviceSettingItem *item = [[MHDeviceSettingItem alloc] init];
    item.identifier = @"setting cell";
    item.type = MHDeviceSettingItemTypeDefault;
    item.caption = [_historyWords[indexPath.row] valueForKey:@"search_word"];
    item.accessories = [[MHStrongBox alloc]
                        initWithDictionary:@{ SettingAccessoryKey_CellHeight        :  @(45.f),
                                              SettingAccessoryKey_CaptionFontSize   :  @(15),
                                              SettingAccessoryKey_CaptionFontColor  :  [MHColorUtils colorWithRGB:0x333333]
                                              }];
//    item.comment = [[_historyWords[indexPath.row] valueForKey:@"count"] stringValue];
    
    [cell fillWithItem:item];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *keyword = [_historyWords[indexPath.row] valueForKey:@"search_word"];
    [self searchKey:keyword];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete){
        if (self.historyWords.count){
            NSMutableArray *ds = [NSMutableArray arrayWithArray:self.historyWords];
            [ds removeObjectAtIndex:indexPath.row];
            [[MHLumiXMDataManager sharedInstance] removeOneWord:self.historyWords[indexPath.row]];
            self.historyWords = [ds mutableCopy];
        }
        else {
            [tableView reloadData];
        }
    }
}

#pragma mark - search bar delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.tvcInternal.view.hidden = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchKey:searchBar.text];
}

- (void)searchKey:(NSString *)keyWord {
    XM_WS(weakself);
    _searchText = keyWord;
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"searching...", @"plugin_gateway", nil) modal:YES];
    [[MHLumiXMDataManager sharedInstance] fetchKeywordRadios:keyWord withCompletionHandler:^(id result, NSError *error) {
        [[MHTipsView shareInstance] hide];
        weakself.searchResultDataSource = result;
        [weakself fetchHistoryWords];
    }];
}

#pragma mark - MHTableViewControllerInternalDelegate
- (void)startRefresh {
    [self.tvcInternal stopRefreshAndReload];
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76.f;
}

//选中indexPath
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MHLumiXMRadio *radio = self.searchResultDataSource[indexPath.row];
    [self playRadioWith:radio];
    
    [self hideAllCellAnimation];
    
    MHLumiFMCell *cell = (MHLumiFMCell *)[self.tvcInternal.tableView cellForRowAtIndexPath:indexPath];
    cell.isAnimation = YES;
}

//列表为空时的展示
- (UIView*)emptyView {
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

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XM_WS(weakself);
    static NSString* cellIdentifier = @"reuseCellId";
    MHLumiFMCell* cell = (MHLumiFMCell* )[self.tvcInternal.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MHLumiFMCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    MHLumiXMRadio *radio = self.searchResultDataSource[indexPath.row];
    [cell configureWithDataObject:radio];
    
    if ([radio.radioId isEqualToString:[_fmPlayer.currentRadio valueForKey:@"radioId"]] &&
        _fmPlayer.isPlaying &&
        _fmPlayer.radioPlayList == self.searchResultDataSource ){
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

- (void)hideAllCellAnimation {
    for (MHLumiFMCell *obj in self.tvcInternal.tableView.visibleCells){
        obj.isAnimation = NO;
    }
}

#pragma mark - play
- (void)playRadioWith:(MHLumiXMRadio *)radio {
    XM_WS(weakself);
    [_radioDevice playSpecifyRadioWithProgramID:[[radio valueForKey:@"radioId"] integerValue]
                                            Url:[radio valueForKey:@"radioRateUrl"]
                                           Type:@"0"
                                     andSuccess:^(id obj){
                                         
                                         [weakself showFmPlayer:radio];
                                         
                                     } andFailure:^(NSError *error){
                                         NSLog(@"%@",error);
                                     }];
}


- (void)showFmPlayer:(id)radio {
    self.tableFrame = CGRectMake(0, 64, WIN_WIDTH,
                                 CGRectGetHeight(self.view.bounds) - 64 - MiniPlayerHeight);
    
    if(self.fmPlayer.isHide){
        self.fmPlayer = [MHLumiFmPlayer shareInstance];
        [self.fmPlayer showMiniPlayer:CGRectGetMaxY(self.view.bounds) - MiniPlayerHeight isMainPage:NO];
    }

    self.fmPlayer.radioPlayList = self.searchResultDataSource;
    self.fmPlayer.isPlaying = YES;
    self.fmPlayer.currentRadio = radio;
    self.fmPlayer.hidden = NO;
    
    [self fmCallback];
}

- (void)fmCallback {
    XM_WS(weakself);
    self.fmPlayer.playCallBack = ^(MHLumiXMRadio *currentRadio){
        [weakself hideAllCellAnimation];
        [weakself showAnimation:currentRadio];
    };
    
    self.fmPlayer.pauseCallBack = ^(MHLumiXMRadio *currentRadio){
        [weakself hideAllCellAnimation];
    };
    
    self.fmPlayer.showFullPlayerCallBack = ^() {
        [weakself showFullPlayer];
    };
}

- (void)showFullPlayer {
    MHLumiFmPlayerViewController *fullPlayer = [[MHLumiFmPlayerViewController alloc] init];
    fullPlayer.miniPlayer = [MHLumiFmPlayer shareInstance];
    
    XM_WS(weakself);
    [self presentViewController:fullPlayer animated:YES completion:^{
        weakself.fmPlayer.hidden = YES;
    }];
}

- (void)showAnimation:(MHLumiXMRadio *)currentRadio {
    NSInteger index = [self.searchResultDataSource indexOfObject:currentRadio];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    MHLumiFMCell *cell = (MHLumiFMCell *)[self.tvcInternal.tableView cellForRowAtIndexPath:indexPath];
    cell.isAnimation = YES;
}

@end
