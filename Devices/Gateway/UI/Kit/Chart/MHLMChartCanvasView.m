//
//  MHLMChartCanvasView.m
//  MiHome
//
//  Created by Lynn on 12/9/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLMChartCanvasView.h"
#import "MHLumiDateTools.h"

@interface MHLMChartCanvasView () <UIScrollViewDelegate>

@property (nonatomic,assign) NSInteger screenCnt; //算出一共需要多少屏(页)
@property (nonatomic,assign) NSInteger currentIdx; //现在应该是第几屏(页)
@property (nonatomic,assign) CGFloat currentOffsetX; //当前scrollview偏移量
@property (nonatomic,strong) NSMutableArray *tmpDataSource;
@property (nonatomic,strong) NSMutableArray *tmpDateLineSource;

@property (nonatomic,strong) NSString *currentSelectTitle;

@property (nonatomic, strong) UILabel *currentQuantLabel;

@end

@implementation MHLMChartCanvasView
{
    UIScrollView *              _scrollView;
    
    MHLMChartType               _chartType;
    CGRect                      _viewFrame;
    
    NSMutableDictionary *       _bufferChartView;
    
    NSInteger                   _lastCntIndex;
    UIView *                    _line;
    UIView *                    _textBar;
}

- (id)initWithFrame:(CGRect)frame
         DataSource:(NSMutableArray *)dataSource
     DateLineSource:(NSMutableArray *)dateLineSource
        LargestData:(CGFloat)largestData
      ScreenSpotCnt:(NSInteger)screenSpotCnt
          ChartType:(MHLMChartType)chartType {
    
    if(self = [super initWithFrame:frame]){
        _viewFrame = frame;
        _dateType = @"day";
        _chartType = chartType;
        _screenSpotNum = screenSpotCnt;
        _largestData = largestData;
        _dateLineSource = dateLineSource;
        _dataSource = dataSource;
        //计算页数
        _screenCnt = (_dataSource.count / _screenSpotNum) + (_dataSource.count % _screenSpotNum ? 1 : 0);

        [self buildSubviews];
    }
    return self;
}

//追加数据
- (void)setDataSource:(NSMutableArray *)dataSource {
    if(_dataSource != dataSource){
        _dataSource = dataSource;

        //一屏bar数，算出一共可以有多少屏
        NSInteger newScreenCnt = (dataSource.count / _screenSpotNum) + (dataSource.count % self.screenSpotNum ? 1 : 0);
        NSInteger addedScreen = 0;
        if (_screenCnt) addedScreen = newScreenCnt - _screenCnt;
        _screenCnt = newScreenCnt;
        
        //屏数变化，那之前的编号都增加
        _currentIdx = _currentIdx + addedScreen;
        if (_bufferChartView){
            [self rebuildBufferAfterDatasourceRenew:addedScreen];
        }

        [self buildScrollView];
    }
}

//切换显示
- (void)setScreenSpotNum:(NSInteger)screenSpotNum {
    if (_screenSpotNum != screenSpotNum) {
        _screenSpotNum = screenSpotNum;
        
        //一屏bar数，算出一共可以有多少屏
        _screenCnt = (_dataSource.count / screenSpotNum) + (_dataSource.count % screenSpotNum ? 1 : 0);
        [self buildSubviews];
    }
}

- (void)setDateType:(NSString *)dateType {
    if (_dateType != dateType) {
        _dateType = dateType;
        
        _bufferChartView = nil;
        _screenCnt = 0;
        _currentIdx = 0;
    }
}

- (void)rebuildBufferAfterDatasourceRenew:(NSInteger)addedIndex {
    NSLog(@"%@",_bufferChartView);
    _scrollView.contentSize = CGSizeMake( (_screenCnt + 1 ) * Screen_Width, 128);
    
    NSDictionary *dic = [_bufferChartView valueForKey:@"MHLMBarChartView"];
    NSMutableDictionary *newDic = [NSMutableDictionary dictionary];
    
    NSArray *allKeys = dic.allKeys;
    for (NSString *key in allKeys){
        NSInteger index = key.integerValue + addedIndex;
        
        NSString *indexNewKey = [NSString stringWithFormat:@"%ld",index];
        MHLMBarChartView *oldCharterView = [dic valueForKey:key];
        oldCharterView.center = CGPointMake(oldCharterView.center.x + addedIndex * Screen_Width, oldCharterView.center.y);
        [newDic setValue:oldCharterView forKey:indexNewKey];
    }
    [_bufferChartView setValue:newDic forKey:@"MHLMBarChartView"];
    
    
    //先让scrollview偏移量到最后一页
    NSInteger offsetIndex = addedIndex * Screen_Width;
    [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x + offsetIndex, _scrollView.contentOffset.y) animated:NO];
    _currentOffsetX = _currentOffsetX + offsetIndex;
    [self redrawHightBar];


    NSLog(@"%@",_bufferChartView);
}

- (void)setSwitchBtnTitleGroup:(NSArray *)switchBtnTitleGroup {
    _switchBtnTitleGroup = switchBtnTitleGroup;
    [self addSwitchButton];
}

- (void)setCurrentIdx:(NSInteger)currentIdx {
    _currentIdx = currentIdx;
    
    [self.switchButtonGroup enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        [obj setBackgroundImage:[UIImage imageNamed:@"lumi_plug_chartswitchbtn_unselected"] forState:UIControlStateNormal];
    }];
    [(UIButton *)self.switchButtonGroup[currentIdx] setBackgroundImage:[UIImage imageNamed:@"lumi_plug_chartswitchbtn_selected"] forState:UIControlStateNormal];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    //bottom line 0基准线
    {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        [shapeLayer setBounds:self.bounds];
        [shapeLayer setPosition:self.center];
        [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
        [shapeLayer setStrokeColor:self.strokeColor.CGColor];
        // 3.0f设置虚线的宽度
        [shapeLayer setLineWidth:1.0f];
        [shapeLayer setLineJoin:kCALineJoinRound];
        // 3=线的宽度 1=每条线的间距
        [shapeLayer setLineDashPattern: [NSArray arrayWithObjects:@3, @1, nil]];
        
        // Setup the path
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 0, CGRectGetHeight(_viewFrame) - ScrollViewBuffer);
        CGPathAddLineToPoint(path, NULL, Screen_Width, CGRectGetHeight(_viewFrame) - ScrollViewBuffer);
        
        [shapeLayer setPath:path];
        CGPathRelease(path);
        [self.layer addSublayer:shapeLayer];
        
        //三角形
        CAShapeLayer *triangleShapeLayer = [CAShapeLayer layer];
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        CGPoint center = CGPointMake( CGRectGetWidth(_viewFrame) / 2, CGRectGetHeight(_viewFrame) - ScrollViewBuffer - 9);
        CGPoint bottomLeft = CGPointMake( CGRectGetWidth(_viewFrame) * 0.5 - 8, CGRectGetHeight(_viewFrame) - ScrollViewBuffer );
        CGPoint bottomRight = CGPointMake( CGRectGetWidth(_viewFrame) * 0.5 + 8, CGRectGetHeight(_viewFrame) - ScrollViewBuffer );
        [bezierPath moveToPoint:center];
        [bezierPath addLineToPoint:bottomLeft];
        [bezierPath addLineToPoint:bottomRight];
        [bezierPath closePath];
        triangleShapeLayer.path = bezierPath.CGPath;
        triangleShapeLayer.fillColor = [MHColorUtils colorWithRGB:0xf2f2f2].CGColor;
        [self.layer addSublayer:triangleShapeLayer];
    }
    
    if(_chartType == MHLMLineChart) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        [shapeLayer setBounds:self.bounds];
        [shapeLayer setPosition:self.center];
        [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
        [shapeLayer setStrokeColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2].CGColor];
        // 3.0f设置虚线的宽度
        [shapeLayer setLineWidth:1.0f];
        [shapeLayer setLineJoin:kCALineJoinRound];
        // 3=线的宽度 1=每条线的间距
        [shapeLayer setLineDashPattern: [NSArray arrayWithObjects:@3, @1, nil]];
        
        // Setup the path
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, Screen_Width * 0.5, CGRectGetHeight(_viewFrame) * 0.2);
        CGPathAddLineToPoint(path, NULL, Screen_Width * 0.5, CGRectGetHeight(_viewFrame) - ScrollViewBuffer);
        
        [shapeLayer setPath:path];
        CGPathRelease(path);
        
        [self.layer addSublayer:shapeLayer];
    }
}

- (void)buildScrollView {
    NSLog(@"%@%@", _dateLineSource, _dataSource);
    _tmpDataSource = [NSMutableArray arrayWithArray:_dataSource];
    _tmpDateLineSource = [NSMutableArray arrayWithArray:_dateLineSource];
    NSInteger gapNum =  _screenSpotNum * _screenCnt - _dataSource.count;
    for (NSInteger i = 0 ; i < gapNum ; i ++) {
        //重构数据，补零
        [_tmpDataSource insertObject:@0.000f atIndex:0];
        
        //重构一下时间线的数据
        NSString *tmpDate = _tmpDateLineSource[0];
        NSString *nextDateString;
        if([self.dateType isEqualToString:@"day"]){
            nextDateString = [MHLumiDateTools dateStringMinusOneDay:tmpDate];
        }
        else if ([self.dateType isEqualToString:@"month"]) {
            nextDateString = [MHLumiDateTools dateStringMinusOneMonth:tmpDate];
        }
        if (nextDateString) {
            [_tmpDateLineSource insertObject:nextDateString atIndex:0];  
        }
    }
    
    NSLog(@"%@",_tmpDateLineSource);
    
    //根据当前最大值，计算scrollview高度
    CGFloat totalHeight = _viewFrame.size.height;
    CGRect scrollFrame = CGRectMake(0, 64, Screen_Width, totalHeight);
    
    if(!_scrollView){
        _scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.bounces = NO;
        _scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:_scrollView];
    }
    
    _scrollView.frame = scrollFrame;
    //contentsize 为页数＋1 屏的内容，为了前后留半屏。
    _scrollView.contentSize = CGSizeMake( (_screenCnt + 1 ) * Screen_Width, 128);
    
  
    if (!self.currentQuantLabel) {
        self.currentQuantLabel = [[UILabel alloc] init];
        self.currentQuantLabel.textAlignment = NSTextAlignmentCenter;
        self.currentQuantLabel.textColor = [UIColor whiteColor];
        self.currentQuantLabel.font = [UIFont systemFontOfSize:18.0f];
        self.currentQuantLabel.backgroundColor = [UIColor clearColor];
        self.currentQuantLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.currentQuantLabel];
    }
    

}

- (void)buildSubviews {

    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _bufferChartView = nil;
    
    self.backgroundColor = [MHColorUtils colorWithRGB:0x202f3b];

    if([self.subviews indexOfObject:_line] == NSNotFound) {
        _line = [[UIView alloc] initWithFrame:CGRectMake(0, 64, Screen_Width, 0.5)];
        [self addSubview:_line];
    }
    _line.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.2f];

    //坐标轴
    if([self.subviews indexOfObject:_textBar] == NSNotFound) {
        _textBar = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                            CGRectGetHeight(_viewFrame) - ScrollViewBuffer,
                                                            CGRectGetWidth(_viewFrame),
                                                            ScrollViewBuffer)];
        [self addSubview:_textBar];
    }
    _textBar.backgroundColor = [MHColorUtils colorWithRGB:0xf2f2f2];

    [self buildScrollView];
    
    //先让scrollview偏移量到最后一页
    CGFloat hbarOffsizeSpace = Screen_Width / _screenSpotNum * 0.5;
    [_scrollView setContentOffset:CGPointMake(Screen_Width * _screenCnt - hbarOffsizeSpace, _scrollView.contentOffset.y) animated:NO];
    _currentOffsetX = Screen_Width * _screenCnt;
    
    //第一次从最后一屏开始
    _currentIdx = _screenCnt - 2;
    if (_dataSource.count) [self firstSetupSubview];
    
    [self insertSubview:_scrollView aboveSubview:_textBar];
    [self addSwitchButton];
    
    [self performSelector:@selector(redrawHightBar) withObject:nil afterDelay:0.5f];
}

- (void)addSwitchButton {
    [self.switchButtonGroup makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //switch btn
    XM_WS(weakself);
    [_switchBtnTitleGroup enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:title forState:UIControlStateNormal];
        btn.frame = CGRectMake(Screen_Width - 80 - 65 * idx, 74, 55, 55);
        btn.tag = idx;
        [btn addTarget:weakself action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:[UIImage imageNamed:@"lumi_plug_chartswitchbtn_unselected"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithWhite:1.0 alpha:.3f] forState:UIControlStateNormal];
        [weakself addSubview:btn];
        if(!weakself.currentSelectTitle) {
            if(idx == weakself.switchBtnTitleGroup.count - 1){
                [btn setTitleColor:[UIColor colorWithWhite:1.0 alpha:1.f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"lumi_plug_chartswitchbtn_selected"] forState:UIControlStateNormal];
            }
        }
        else if([weakself.currentSelectTitle isEqualToString:title]){
            [btn setTitleColor:[UIColor colorWithWhite:1.0 alpha:1.f] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"lumi_plug_chartswitchbtn_selected"] forState:UIControlStateNormal];
        }
        if(!weakself.switchButtonGroup){
            weakself.switchButtonGroup = [NSMutableArray arrayWithCapacity:1];
        }
        [weakself.switchButtonGroup addObject:btn];
    }];
}

- (void)firstSetupSubview {
    [self subviewAtIndex:_currentIdx + 1];
    [self subviewAtIndex:_currentIdx];
    [self subviewAtIndex:_currentIdx - 1];
}

- (void)btnClicked:(UIButton *)btn {
    if(![btn.titleLabel.text isEqualToString:self.currentSelectTitle]){
        self.currentSelectTitle = btn.titleLabel.text;
        ( ( void (^)() ) self.switchBtnBlockGroup[btn.tag]) ();    
    }
}

#pragma mark - construct the buffer
//先从缓存的view group中查找是否有可用的，有则返回
- (UIView *)reusedScreenBuffer:(NSString *)identifier forIndexPath:(NSInteger)indexPath{

    NSMutableDictionary *reusedViewDic = [_bufferChartView valueForKey:identifier];
    if (reusedViewDic.allKeys.count <= 2) return nil;
    
    NSInteger oldIndex = indexPath - 3;
    UIView *reusedView = [reusedViewDic valueForKey:[NSString stringWithFormat:@"%ld",oldIndex]];
    if(!reusedView){
        oldIndex = indexPath + 3;
        reusedView = [reusedViewDic valueForKey:[NSString stringWithFormat:@"%ld",oldIndex]];
    }
    
    if(!reusedView) return nil;
    else {
        [reusedViewDic removeObjectForKey:[NSString stringWithFormat:@"%ld",oldIndex]];
        [reusedViewDic setObject:reusedView forKey:[NSString stringWithFormat:@"%ld",indexPath]];
    }
    
    return reusedView;
}

//创建view的buffer，存储一个屏幕大小的view（这里就是一个chartview）。需要缓存三屏的chartview
- (void)addReusedScreenToBuffer:(UIView *)bufferView
                 WithIdentifier:(NSString *)identifier
                   forIndexPath:(NSInteger)indexPath {
    
    if(!_bufferChartView) {
        _bufferChartView = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    
    NSMutableDictionary *bufferViewDics = [_bufferChartView valueForKey:identifier];
    if (!bufferViewDics) bufferViewDics = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [bufferViewDics setObject:bufferView forKey:[NSString stringWithFormat:@"%ld",indexPath]];
    
    [_bufferChartView setObject:bufferViewDics forKey:identifier];
}

#pragma mark - 画柱图
- (void)subviewAtIndex:(NSInteger)indexPath {
    
    if(indexPath >= _screenCnt || indexPath < 0) return;
    
    static NSString *reusedIdentifer = @"MHLMBarChartView";
    
    CGRect chartViewFrame = CGRectMake((0.5 + indexPath) * Screen_Width,
                                       -64,
                                       Screen_Width,
                                       CGRectGetHeight(_scrollView.frame) - ScrollViewBuffer);
    
    MHLMBarChartView *barChartView = (MHLMBarChartView *)[self reusedScreenBuffer:reusedIdentifer forIndexPath:indexPath];
    barChartView.frame = chartViewFrame;
    if(!barChartView) {
        barChartView = [[MHLMBarChartView alloc] initWithFrame:chartViewFrame
                                             chartDataArray:nil];
        [self addReusedScreenToBuffer:barChartView WithIdentifier:reusedIdentifer forIndexPath:indexPath];
        [_scrollView addSubview:barChartView];
    }
    barChartView.barOriginColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    barChartView.barHighlightColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8f];
    
    //取数值的方法。。。。
    NSRange range = [self fetchDataIndexPath:indexPath];
    barChartView.dateType = _dateType;
    if (_largestData > 0) barChartView.barHeightScale = (_scrollView.frame.size.height - 250 ) / _largestData;
    else barChartView.barHeightScale = 0.7;
    barChartView.dateLineSource = [[_tmpDateLineSource subarrayWithRange:range] mutableCopy];
    barChartView.dataSource = [[_tmpDataSource subarrayWithRange:range] mutableCopy];
}

- (NSRange)fetchDataIndexPath : (NSInteger)indexPath {
    //一次 screenSpotNum 个，反向取出数据
    NSRange range = NSMakeRange( _tmpDataSource.count - (_screenCnt - indexPath) * _screenSpotNum, _screenSpotNum);
//    chartDataSource = [[_tmpDataSource subarrayWithRange:range] mutableCopy];
    return range;
}

#pragma mark - 画线图
- (void)rebuildLineSubviews:(NSMutableArray *)rebuildDataSource {

}

//让某个点产生膨胀的动画
- (void)addSpotAnimation:(NSInteger)spotIdx {

}

- (void)removeSpoteAnimation {

}

#pragma mark - scrollview delegate
//判断scrollview的滑动方向，向右滑动时，计算chartview的frame，然后调用重用方法
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
   
    //控制滑动速度，大小
    CGFloat kCellWidth = Screen_Width / _screenSpotNum ;
    CGFloat halfKCellWidth = kCellWidth * 0.5;
    
    CGFloat kMaxIndex = _tmpDataSource.count + _screenSpotNum - 1;
    CGFloat targetX = scrollView.contentOffset.x - halfKCellWidth + velocity.x * 60.0;
    CGFloat targetIndex = round(targetX / kCellWidth);

    if (targetIndex < 0){
        targetIndex = 0;
    }
    if (targetIndex > kMaxIndex){
        targetIndex = kMaxIndex;
    }
    targetContentOffset->x = targetIndex * kCellWidth + halfKCellWidth;
    if(scrollView.contentOffset.x >= scrollView.contentSize.width - Screen_Width){
        targetContentOffset->x = Screen_Width * _screenCnt - halfKCellWidth;
    }
    
    //计算缓存
    [self rebuildCacheData:targetContentOffset->x];
    
    XM_WS(weakself);
    [UIView animateWithDuration:0.2 animations:^{
        weakself.currentQuantLabel.alpha = 0;
    }];
}

CGFloat lastIndex;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self redrawHightBar];
    
    
    if (lastIndex > _currentIdx){
        if(self.getMoreBlock) self.getMoreBlock(self.dateLineSource.firstObject);
    }
    lastIndex = _currentIdx;
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    
}

#pragma mark - 计算高亮动画
- (void)redrawHightBar {
    XM_WS(weakself);

    CGFloat currentOffsetX = _scrollView.contentOffset.x;
    NSInteger currentIdx = ( currentOffsetX + Screen_Width ) / Screen_Width - 1;
    NSLog(@"currentIdx = %ld",currentIdx);

    //把上一屏的清除
    if(_lastCntIndex != currentIdx) {
        MHLMBarChartView *barChartView = [ [_bufferChartView valueForKey:@"MHLMBarChartView"]
                                          valueForKey:[NSString stringWithFormat:@"%ld",_lastCntIndex] ];
        [barChartView removeBarAnimation];
    }
    _lastCntIndex = currentIdx;

    //当前屏的chartView
    MHLMBarChartView *barChartView = [ [_bufferChartView valueForKey:@"MHLMBarChartView"]
                                      valueForKey:[NSString stringWithFormat:@"%ld",currentIdx] ];
    CGFloat inPageOffsetx = currentOffsetX - Screen_Width * currentIdx ;
    NSLog(@"inPageOffsetx = %f",inPageOffsetx);
    
    CGFloat barSize = Screen_Width / _screenSpotNum ;
    NSInteger barIndex = _screenSpotNum - inPageOffsetx / barSize;
    NSLog(@"barIndex = %ld",barIndex);
    
    
    [self.currentQuantLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself);
        make.width.mas_equalTo((WIN_WIDTH - 20) / 9);
        make.bottom.mas_equalTo(weakself.mas_bottom).with.offset(-[barChartView.dataSource[weakself.screenSpotNum - 1 - barIndex] doubleValue] * barChartView.barHeightScale - 35 * ScaleHeight);
    }];

    self.currentQuantLabel.text = [NSString stringWithFormat:@"%.3f%@", [barChartView.dataSource[_screenSpotNum - 1 - barIndex] doubleValue], NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.quant.degree", @"plugin_gateway", @"度") ];

    [UIView animateWithDuration:0.2f animations:^{
        weakself.currentQuantLabel.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    

   
    //回调，显示当前高亮的值
    if(self.updateCurrent) self.updateCurrent( [barChartView.dataSource[_screenSpotNum - 1 - barIndex] doubleValue] );
    [barChartView addBarAnimation:barIndex];
}

#pragma mark - 计算缓存
- (void)rebuildCacheData : (CGFloat)targetOffsetX {
    //如果向左滑，offsize变小
    if(targetOffsetX < _currentOffsetX) {
        //变小，直到小于前一整屏，则减一
        if( ( _currentOffsetX - targetOffsetX ) >= Screen_Width &&  _currentIdx > 1) {
            _currentIdx = _currentIdx - 1;
            //缓存下一屏，跳过已预先缓存过的
            [self subviewAtIndex:_currentIdx - 1];
            
//            if(self.getMoreBlock) self.getMoreBlock(self.dateLineSource.firstObject);
        }
        
        //修改－－currentoffset
        _currentOffsetX = Screen_Width * (_currentIdx + 1);
    }
    else {
        //向右滑, offset变大，直到大于前一整屏，则加一
        if( (targetOffsetX - _currentOffsetX) >= Screen_Width && _currentIdx < _screenCnt - 2) {
            
            _currentIdx = _currentIdx + 1;
            
            //缓存上一屏
            [self subviewAtIndex:_currentIdx + 1];
        }
        _currentOffsetX = Screen_Width * _currentIdx;
    }
}

@end
