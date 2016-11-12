//
//  MHACPartnerTypeSearchViewController.m
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerTypeSearchViewController.h"
#import "MHTableViewControllerInternal.h"
#import "MHACPartnerAddListCell.h"
#import "MHACTypeModel.h"
#import "MHLumiHtmlHandleTools.h"

#define kCELLID @"MHACPartnerAddListCell"

@interface MHACPartnerTypeSearchViewController () <UISearchBarDelegate, MHTableViewControllerInternalDelegate>
@property (nonatomic, strong) NSArray *topWords;
@property (nonatomic, strong) NSArray *dataBase;
@property (nonatomic, strong) MHTableViewControllerInternal* tvcInternal;
@property (nonatomic, strong) NSMutableArray *searchResultDataSource;
@property (nonatomic, assign) CGRect tableFrame;
@property (nonatomic, assign) BOOL isChinese;

@end

@implementation MHACPartnerTypeSearchViewController
{
    UISearchBar *               _searchBar;
    NSString *                  _searchText;
    
    CGFloat                     _keyBoardHeight;
}

- (instancetype)initWithACList:(NSArray *)ACList
{
    self = [super init];
    if (self) {
        self.dataBase = ACList;
        _isChinese = [[MHLumiHtmlHandleTools sharedInstance] currentLanguageIsChinese];
    }
    return self;
}


- (void)setSearchResultDataSource:(NSMutableArray *)searchResultDataSource {
    if(_searchResultDataSource != searchResultDataSource) {
        _searchResultDataSource = searchResultDataSource;
        
        [self buildSearchResults];
        _searchBar.text = _searchText;
    }
}

- (void)setTableFrame:(CGRect)tableFrame {
    _tableFrame = tableFrame;
    self.tvcInternal.view.frame = tableFrame;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isTabBarHidden = YES;

}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    _keyBoardHeight = keyboardRect.size.height;
}

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
        self.tvcInternal.cellClass = [MHACPartnerAddListCell class];
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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_searchBar resignFirstResponder];
}






#pragma mark - search bar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self searchKey:searchBar.text];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.tvcInternal.view.hidden = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchKey:searchBar.text];
    [_searchBar resignFirstResponder];
}

- (void)searchKey:(NSString *)keyWord {
    [self.searchResultDataSource removeAllObjects];
    _searchText = keyWord;
    __block NSMutableArray *tempArray = [NSMutableArray new];
    
    __weak typeof(self) weakself = self;
    [self.dataBase enumerateObjectsUsingBlock:^(MHACTypeModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        bool flag = NO;
        NSString *lowKeyWord = [keyWord lowercaseString];
        if (weakself.isChinese){
            if ([[model.name lowercaseString] hasPrefix:lowKeyWord] ||
                [[model.nameFirstLetter lowercaseString] hasPrefix:lowKeyWord] ||
                [[model.eng_name lowercaseString] hasPrefix:lowKeyWord]){
                flag = YES;
            }
        }else{
            if ([[model.eng_name lowercaseString] hasPrefix:lowKeyWord]){
                flag = YES;
            }
        }
        if (flag){
            [tempArray addObject:model];
        }
    }];
    [self setSearchResultDataSource:tempArray];
   
    [self.tvcInternal stopRefreshAndReload];
    
}

#pragma mark - MHTableViewControllerInternalDelegate
- (void)startRefresh {
    [self.tvcInternal stopRefreshAndReload];
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 57.f;
}

//选中indexPath
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MHACTypeModel *typeModel = self.searchResultDataSource[indexPath.row];
    if (self.selectBrand) {
        self.selectBrand(typeModel.brand_id);
    }
    [self.navigationController popViewControllerAnimated:YES];
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
    static NSString* cellIdentifier = @"reuseCellId";
    MHACPartnerAddListCell* cell = (MHACPartnerAddListCell* )[self.tvcInternal.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MHACPartnerAddListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    MHACTypeModel *typeModel = self.searchResultDataSource[indexPath.row];

    cell.nameLabel.text = _isChinese ? typeModel.name : typeModel.eng_name;
    cell.arrowImage.hidden = YES;
    return cell;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
