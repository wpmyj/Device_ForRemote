//
//  MHLumiCameraPhotosNavHeaderView.m
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/7.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiCameraPhotosNavHeaderView.h"

@interface MHLumiCameraPhotosNavHeaderView()
@property (nonatomic, strong) UIView *centerView;
//@property (nonatomic, strong) NSArray<UIButton *> *navButtons;
//@property (nonatomic, strong) NSArray<NSString *> *navButtontitles;
//@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation MHLumiCameraPhotosNavHeaderView

- (void)layoutSubviews{
    [super layoutSubviews];
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window addSubview:self.centerView];
    CGFloat w = self.centerView.bounds.size.width;
    CGFloat h = self.centerView.bounds.size.height;
    self.centerView.frame = CGRectMake((window.bounds.size.width-w)/2.0, 20, w, h);
    CGRect rect = [window convertRect:self.centerView.frame toView:self];
    [self addSubview:self.centerView];
    rect = CGRectMake(MAX(0, rect.origin.x), rect.origin.y, rect.size.width, rect.size.height);
    self.centerView.frame = rect;
}

- (void)setCenterView:(UIView *)centerView{
    for (UIView *todoView in self.subviews) {
        [todoView removeFromSuperview];
    }
    _centerView = centerView;
    [self addSubview:centerView];
}

//
//- (instancetype)initWithFrame:(CGRect)frame withTitles:(NSArray <NSString *> *)titles{
//    self = [super initWithFrame:frame];
//    if (self) {
//        self.backgroundColor = [UIColor greenColor];
//        CGFloat navTitleViewWidth = 0;
//        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
//        CGFloat buttonWidth = screenWidth / (titles.count + 2);
//        for (NSInteger index = 0; index < titles.count ; index ++) {
//            UIButton *todoButton = self.navButtons[index];
//            [self.navTitleView addSubview:todoButton];
//            todoButton.frame = CGRectMake(index*buttonWidth, 0, buttonWidth, 44);
//            navTitleViewWidth += buttonWidth;
//        }
//        self.navTitleView.frame = CGRectMake((screenWidth - navTitleViewWidth)/2, 0, navTitleViewWidth, 44);
//        self.navTitleView.backgroundColor = [UIColor redColor];
//        [titleBGView addSubview:self.navTitleView];
//    }
//    return self;
//}
//
//#pragma mark - event response
//- (void)navButtonAction:(UIButton *)sender{
//    if (sender.tag == _currentIndex){
//        return;
//    }
//    NSInteger todoIndex = 0;
//    for (UIButton *button in self.navButtons) {
//        if (button == sender){
//            NSLog(@"tag=%@, selected",button.currentTitle);
//            button.selected = YES;
//            todoIndex = button.tag;
//        }else{
//            NSLog(@"tag=%@, ;",button.currentTitle);
//            button.selected = NO;
//        }
//    }
//    _currentIndex = todoIndex;
//    self.photoGridViewController.dateSource = [self.cameraMediaDataManager fetchDataWithType:[self currentType]];
//    [self.photoGridViewController reloadData];
//}
//
//- (NSArray<UIButton *> *)navButtons{
//    if (!_navButtons) {
//        NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.navButtontitles.count];
//        for (NSInteger index = 0; index < self.navButtontitles.count; index ++) {
//            UIButton *aButton = [[UIButton alloc] init];
//            aButton.tag = index;
//            [aButton setTitle:self.navButtontitles[index] forState:UIControlStateNormal];
//            [aButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            [aButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
//            [aButton addTarget:self action:@selector(navButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//            aButton.selected = index == _currentIndex;
//            [array addObject:aButton];
//        }
//        _navButtons = array;
//    }
//    return _navButtons;
//}

@end
