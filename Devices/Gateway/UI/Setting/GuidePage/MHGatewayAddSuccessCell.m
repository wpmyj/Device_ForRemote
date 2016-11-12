//
//  MHGatewayAddSuccessCell.m
//  MiHome
//
//  Created by ayanami on 16/6/14.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayAddSuccessCell.h"


@interface MHGatewayAddSuccessCell ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIWebViewDelegate>

@property (nonatomic, strong) UICollectionView *roomCollectionView;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *logoLabel;
@property (nonatomic, strong) UIWebView *logoView;
@property (nonatomic, assign) BOOL isFirst;

@end

@implementation MHGatewayAddSuccessCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _selectedItem = -1;

        [self locaitonTitle];
        [self buildSubviews];
    }
    return self;
}

- (void)locaitonTitle {
    self.locaitonNames = [[NSMutableArray alloc] init];
    NSArray *identifier = @ [ @"livingroom", @"masterBedroom", @"secondBedroom",
                             @"study",      @"smallroom", @"balcony",
                             @"kitchen",    @"toilets", @"other" ];
    for (NSInteger i = 0; i < identifier.count; i++) {
        NSString *strIdentifier = [NSString stringWithFormat:@"mydevice.gateway.addsub_guide.device.location.%@", identifier[i]];
        [self.locaitonNames addObject:NSLocalizedStringFromTable(strIdentifier,@"plugin_gateway","")];
    }
    
    self.selectedArray = [NSMutableArray arrayWithObjects:@"YES", @"YES",  @"YES", @"YES", @"YES", @"YES", @"YES", @"YES", @"YES", nil];
}

- (void)buildSubviews {
    XM_WS(weakself);
    CGFloat labelSpacingH = 20 * ScaleWidth;
    
    if (!self.logoLabel) {
        self.locationLabel = [[UILabel alloc] init];
        self.locationLabel.textColor = [MHColorUtils colorWithRGB:0x000000];
        self.locationLabel.font = [UIFont systemFontOfSize:16.0f];
        self.locationLabel.backgroundColor = [UIColor clearColor];
        self.locationLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.deviceloction",@"plugin_gateway","选择位置");
        [self.contentView addSubview:self.locationLabel];
        
        [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakself.contentView).with.offset(15);
            make.left.equalTo(weakself.contentView).with.offset(labelSpacingH);
        }];
    }
    
    if (_roomCollectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsZero;
        _roomCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(20 * ScaleWidth, 60, WIN_WIDTH - 40 * ScaleWidth, 180) collectionViewLayout:flowLayout];
        _roomCollectionView.delegate = self;
        _roomCollectionView.dataSource = self;
        _roomCollectionView.layer.borderWidth = 0.5f;
        _roomCollectionView.layer.borderColor = [MHColorUtils colorWithRGB:0xBCBCBC].CGColor;
        _roomCollectionView.backgroundColor = [MHColorUtils colorWithRGB:0xBCBCBC];
        [_roomCollectionView registerClass:[MHLumiNamingSpeedCell class] forCellWithReuseIdentifier:kCELLID];
        _roomCollectionView.scrollEnabled = NO;
        [self.contentView addSubview:_roomCollectionView];
    }
    
    if (!self.logoLabel) {
        self.logoLabel = [[UILabel alloc] init];
        self.logoLabel.textColor = [MHColorUtils colorWithRGB:0x000000];
        self.logoLabel.font = [UIFont systemFontOfSize:16.0f];
        self.logoLabel.backgroundColor = [UIColor clearColor];
        self.logoLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.devicelogo",@"plugin_gateway","选择图标");
        [self.contentView addSubview:self.logoLabel];
        _logoLabel.hidden = YES;
        [self.logoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakself.roomCollectionView.mas_bottom).with.offset(25);
            make.left.equalTo(weakself.contentView).with.offset(labelSpacingH);
        }];
    }
    
    
    
    if (_logoView == nil) {
        _logoView = [[UIWebView alloc] init];
        _logoView.hidden = YES;
        _logoView.delegate = self;
        _logoView.backgroundColor = [UIColor whiteColor];
        _logoView.scrollView.showsVerticalScrollIndicator = NO;
        _logoView.scrollView.showsHorizontalScrollIndicator = NO;
        _logoView.scrollView.scrollEnabled = NO;
//        _logoView.opaque = NO;
        [self.contentView addSubview:_logoView];
        
        [self.logoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(weakself.contentView);
            make.top.equalTo(weakself.logoLabel.mas_bottom).with.offset(5);
//            make.width.mas_equalTo(WIN_WIDTH - 40 * ScaleWidth);
            make.left.mas_equalTo(weakself.contentView.mas_left).with.offset(20 * ScaleWidth);
            make.right.mas_equalTo(weakself.contentView.mas_right).with.offset(-20 * ScaleWidth);
            make.height.mas_equalTo(320);
        }];
    }
    if (self.subDevice && !self.isFirst) {
        NSString *currentLanguage = [[MHLumiHtmlHandleTools sharedInstance] currentLanguage];
        NSString *strUrl = [NSString stringWithFormat:@"https://app-ui.aqara.cn/icon/index?language=%@&deviceModel=%@&iconId=%@", currentLanguage, self.subDevice.model, self.iconID ? self.iconID : @""];
        NSURL *url = [NSURL URLWithString:strUrl];
        [_logoView loadRequest:[NSURLRequest requestWithURL:url]];
        self.isFirst = YES;
    }
   
    
}

- (void)refreshUI {
    [self buildSubviews];
    
}

#pragma mark - UICollectionViewDelegate&UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 9;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MHLumiNamingSpeedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCELLID forIndexPath:indexPath];
    cell.locationLabel.text = self.locaitonNames[indexPath.row];
    cell.isSelected = self.selectedArray[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((WIN_WIDTH - 40 * ScaleWidth) / 3 - 0.6, 60);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.6;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectedItem == -1) {
        self.selectedArray[indexPath.row] = @"NO";
    }
    else {
        [self.selectedArray exchangeObjectAtIndex:_selectedItem withObjectAtIndex:indexPath.row];
    }
    [collectionView reloadData];
    _selectedItem = indexPath.row;
    
    self.logoView.hidden = !self.showChangeLogo;
    self.logoLabel.hidden = !self.showChangeLogo;
   
    self.isLocation = YES;
    if (indexPath.row == self.locaitonNames.count - 1) {
        self.location = @"";
        _nameField.text = [NSString stringWithFormat:@"-%@",  self.subDevice.name];
        [_nameField becomeFirstResponder];
        [_nameField setSelectedRange:NSMakeRange(0, 0)];
    }
    else {
        self.location = self.locaitonNames[indexPath.row];
        if (self.imageName) {
            _nameField.text = [NSString stringWithFormat:@"%@-%@", self.location, self.imageName];
        }
        else {
            _nameField.text = [NSString stringWithFormat:@"%@-%@", self.location, self.subDevice.name];
        }
        [_nameField setSelectedRange:NSMakeRange(_nameField.text.length, 0)];
    }
    if (self.selectLocation) {
        self.selectLocation(YES, self.location);
    }
}

#pragma mark - UIWebViewDelegate
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    [self updateJSContext];
//    return YES;
//}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self updateJSContext];

}

- (void)updateJSContext {
    JSContext *js = [self.logoView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    MHLumiJavascriptObjectBridge *jsOCBridge = [[MHLumiJavascriptObjectBridge alloc] initWithJSContext:js];
    js[@"MHLMShare"] = jsOCBridge;
    
    
}

@end
