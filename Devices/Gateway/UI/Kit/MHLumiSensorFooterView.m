//
//  MHLumiSensorFooterView.m
//  MiHome
//
//  Created by ayanami on 16/6/2.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiSensorFooterView.h"
//#import "MHDeviceAcpartner.h"
#import "IRConstants.h"




#define BtnTag_Left 0
#define BtnTag_Middle 1
#define BtnTag_Right 2
#define BtnTag_Delete 10086


#define kDuration 0.3
#define DefaultHeight (153 * ScaleHeight)


#define CloseBgColor [MHColorUtils colorWithRGB:0x464646]


@interface MHLumiSensorFooterView ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, assign) LUMIFootviewType footerType;

@property (nonatomic, strong) UIButton *oneBtn;
@property (nonatomic, strong) UIButton *twoBtn;
@property (nonatomic, strong) UIButton *threeBtn;
@property (nonatomic, strong) UIButton *fourthBtn;

@property (nonatomic, strong) UILabel *oneLabel;
@property (nonatomic, strong) UILabel *twoLabel;
@property (nonatomic, strong) UILabel *threeLabel;
@property (nonatomic, strong) UILabel *fourthLabel;

@property (nonatomic, strong) UIButton *foldBtn;
@property (nonatomic, assign) BOOL showDelete;

@property (nonatomic, copy) MHLumiSensorFooterHanlder handle;


@property (nonatomic, copy) NSDictionary *source;
@property (nonatomic, strong) NSMutableArray *imageNames;
@property (nonatomic, strong) NSMutableArray *labelNames;
@property (nonatomic, strong) NSMutableArray *btnArray;
@property (nonatomic, strong) NSMutableArray *labelArray;
@property (nonatomic, strong) NSMutableArray *deleteBtns;


@property (nonatomic, strong) UIPanGestureRecognizer *foldPan;

@property (nonatomic, assign) NSUInteger customBegin;


@end
@implementation MHLumiSensorFooterView
- (id)initWithSource:(NSDictionary *)source handle:(MHLumiSensorFooterHanlder)handle
{
    self = [super init];
    if (self) {
//        self.frame = frame;
        self.handle = handle;
        [self buildSources:source];
              [self buildSubviews];
        [self buildConstraints];
        
        self.foldPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFoldEvent:)];
        self.foldPan.delegate = self;
        [self addGestureRecognizer:self.foldPan];
    }
    return self;
}

- (id)initWithFixedSource:(NSDictionary *)fixed customSource:(NSDictionary *)custom handle:(MHLumiSensorFooterHanlder)handle
{
    self = [super init];
    if (self) {
        //        self.frame = frame;
        self.handle = handle;
//        [self buildSources:source];
        [self buildSubviews];
        [self buildConstraints];
        
        self.foldPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFoldEvent:)];
        self.foldPan.delegate = self;
        [self addGestureRecognizer:self.foldPan];
    }
    return self;
}


- (void)buildSources:(NSDictionary *)source {
    self.source = source;
    self.imageNames = [NSMutableArray arrayWithArray:source[kIMAGENAMEKEY]];
    self.labelNames = [NSMutableArray arrayWithArray:source[kTEXTKEY]];
    self.labelArray = [NSMutableArray new];
    self.btnArray = [NSMutableArray new];
    self.deleteBtns = [NSMutableArray new];
    self.showDelete = NO;
    //灯光键一会有一会没的
    if ([self.imageNames[7] isEqualToString:@"acpartner_device_led"]) {
        self.customBegin = 8;
    }
    else {
        self.customBegin = 7;
    }

}

- (void)buildSubviews {
    
    self.backgroundColor = [UIColor whiteColor];
    
//    self.footerView = [[UIView alloc] init];
//    [self.footerView setBackgroundColor:[UIColor whiteColor]];
//    [self addSubview:self.footerView];
    
    _foldBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_foldBtn addTarget:self action:@selector(onFold:) forControlEvents:UIControlEventTouchUpInside];
    [_foldBtn setImage:[UIImage imageNamed:@"acpartner_device_fold"] forState:UIControlStateNormal];
    [_foldBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 0, 0)];
    [self addSubview:_foldBtn];
    

    XM_WS(weakself);
    
    [self.imageNames enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn addTarget:weakself action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:[[UIImage imageNamed:weakself.imageNames[idx]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
//        [btn setBackgroundImage:[UIImage imageNamed:weakself.imageNames[idx]] forState:UIControlStateNormal];
        [weakself addSubview:btn];
        [weakself.btnArray addObject:btn];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = weakself.labelNames[idx];
        label.font = [UIFont systemFontOfSize:14];
        [label setTextColor:CloseBgColor];
        [label setTextAlignment:NSTextAlignmentCenter];
        [weakself addSubview:label];
        [weakself.labelArray addObject:label];
        
    }];
    
}

- (void)buildConstraints {
    XM_WS(weakself);
    CGFloat btnTopSpacing = 45 * ScaleHeight;
    CGFloat btnSize = 48  * ScaleHeight;
    CGFloat labWidth = 80;
    CGFloat labHeight = 16 * ScaleHeight;
    CGFloat spacing = 13 * ScaleHeight;

    CGFloat foldSize = 25 * ScaleHeight;
    
    
    CGFloat twoSpacing = WIN_WIDTH / 4;
    CGFloat threeSpacing = WIN_WIDTH / 6;
    CGFloat fourSpacing = WIN_WIDTH / 8 ;
    
    CGFloat lingHeight = btnSize + spacing + labHeight + btnTopSpacing;
    
//    [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(weakself);
//    }];
    
    [self.foldBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(weakself.mas_top).with.offset(10);
                make.top.mas_equalTo(weakself.mas_top);
        make.centerX.equalTo(weakself);
        make.size.mas_equalTo(CGSizeMake(3 * foldSize, foldSize));
    }];
    
    [self.btnArray enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = weakself.labelArray[idx];
        if (weakself.btnArray.count == 1) {
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(weakself);
                make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
                make.top.equalTo(weakself.footerView).with.offset(btnTopSpacing);
            }];
        }
        else if (weakself.btnArray.count == 2) {
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(weakself).with.offset(btnTopSpacing);
                make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
                make.left.mas_equalTo(weakself.mas_left).with.offset((1 + 2 * idx) * twoSpacing - btnSize/ 2);
            }];
        }
        else if (weakself.btnArray.count == 3) {
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(weakself).with.offset(btnTopSpacing);
                make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
                make.left.mas_equalTo(weakself.mas_left).with.offset((1 + 2 * idx) * threeSpacing - btnSize/ 2);
            }];
        }
        else {
            //列数
            NSInteger row = idx % 4;
            //行数
            NSInteger line = idx / 4;
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(weakself).with.offset(btnTopSpacing + line * lingHeight);
                make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
                make.left.mas_equalTo(weakself.mas_left).with.offset((1 + 2 * row) * fourSpacing - btnSize/ 2);
            }];
            //固定按键-添加按键之间
            if (weakself.btnArray.count >= (weakself.customBegin + 3) && idx >= weakself.customBegin && idx <= weakself.btnArray.count - 3) {
                NSLog(@"第%ld个需要删除的按钮", idx);
                NSLog(@"总的按钮个数%ld", weakself.btnArray.count);
                UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeSystem];
                UIImage *deleteImage = [UIImage imageNamed:@"acpartner_delete"];
                [deleteBtn setImage:[deleteImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
                [deleteBtn addTarget:weakself action:@selector(deleteCustom:) forControlEvents:UIControlEventTouchUpInside];
                deleteBtn.tag = idx;
                [weakself addSubview:deleteBtn];
            [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(btn);
                make.top.equalTo(btn);
                make.size.mas_equalTo(deleteImage.size);
            }];
                deleteBtn.hidden = YES;
                [weakself.deleteBtns addObject:deleteBtn];
            }

            if (idx == weakself.btnArray.count - 1) {
                btn.tag = BtnTag_Delete;
            }
            else if (idx == weakself.btnArray.count - 2) {
                btn.tag = BtnTag_Add;
            }
            
            if ([weakself.imageNames[idx] isEqualToString:@"acpartner_device_led"]) {
                btn.tag = BtnTag_Light;
            }
            

        }
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(btn);
            make.top.equalTo(btn.mas_bottom).with.offset(spacing);
            make.size.mas_equalTo(CGSizeMake(labWidth, labHeight));
        }];
        if (idx == (weakself.customBegin + 1)) {
            btn.hidden = idx == weakself.btnArray.count - 1;
            label.hidden = idx == weakself.btnArray.count - 1;
        }
    }];
    
}


- (void)buildRandomOrder {
    XM_WS(weakself);
    CGFloat btnTopSpacing = 45 * ScaleHeight;
    CGFloat btnSize = 48  * ScaleHeight;
    CGFloat labWidth = 80;
    CGFloat labHeight = 16 * ScaleHeight;
    CGFloat spacing = 13 * ScaleHeight;
    
    CGFloat foldSize = 25 * ScaleHeight;
        
    CGFloat fourSpacing = WIN_WIDTH / 8 ;
    
    CGFloat lingHeight = btnSize + spacing + labHeight + btnTopSpacing;
    
    //    [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.edges.equalTo(weakself);
    //    }];
    
    [self.foldBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.top.mas_equalTo(weakself.mas_top).with.offset(10);
        make.top.mas_equalTo(weakself.mas_top);
        make.centerX.equalTo(weakself);
        make.size.mas_equalTo(CGSizeMake(3 * foldSize, foldSize));
    }];
    
    [self.btnArray enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = weakself.labelArray[idx];
        
            //列数
            NSInteger row = idx % 4;
            //行数
            NSInteger line = idx / 4;
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(weakself).with.offset(btnTopSpacing + line * lingHeight);
                make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
                make.left.mas_equalTo(weakself.mas_left).with.offset((1 + 2 * row) * fourSpacing - btnSize/ 2);
            }];
        
            if (idx == weakself.btnArray.count - 1) {
                btn.tag = BtnTag_Delete;
            }
            else if (idx == weakself.btnArray.count - 2) {
                btn.tag = BtnTag_Add;
            }
            
            if ([weakself.imageNames[idx] isEqualToString:@"acpartner_device_led"]) {
                btn.tag = BtnTag_Light;
            }
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(btn);
            make.top.equalTo(btn.mas_bottom).with.offset(spacing);
            make.size.mas_equalTo(CGSizeMake(labWidth, labHeight));
        }];
        if (idx == (weakself.customBegin + 1)) {
            btn.hidden = idx == weakself.btnArray.count - 1;
            label.hidden = idx == weakself.btnArray.count - 1;
        }
    }];
}


- (void)buttonClicked:(UIButton *)sender {
    if (sender.tag == BtnTag_Delete) {
        XM_WS(weakself);
        [self.deleteBtns enumerateObjectsUsingBlock:^(UIButton *deleteBtn, NSUInteger idx, BOOL * _Nonnull stop) {
            
            deleteBtn.hidden = weakself.showDelete;
        }];
        weakself.showDelete = !weakself.showDelete;
    }
    else {
        [self.deleteBtns enumerateObjectsUsingBlock:^(UIButton *deleteBtn, NSUInteger idx, BOOL * _Nonnull stop) {
            deleteBtn.hidden = YES;
        }];
    }
    if (self.handle) {
        self.handle([self.btnArray indexOfObject:sender], sender.tag, self.labelNames[[self.btnArray indexOfObject:sender]]);
    }
}


- (void)deleteCustom:(UIButton *)sender {
    if (self.deleteCallback) {
        self.deleteCallback(self.labelNames[sender.tag]);
    };
}

- (void)rebuildView:(NSDictionary *)newSource {
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self buildSources:newSource];
    [self buildSubviews];
    [self buildConstraints];
}

- (void)hideDelete {
    XM_WS(weakself);
    [self.deleteBtns enumerateObjectsUsingBlock:^(UIButton *deleteBtn, NSUInteger idx, BOOL * _Nonnull stop) {
        deleteBtn.hidden = YES;
        weakself.showDelete = NO;
    }];
}

- (void)needFoldButton:(BOOL)need {
    self.foldBtn.hidden = !need;
}

- (void)updateArrow:(NSString *)imageName {
    [_foldBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)onFold:(UIButton *)sender {
    if (self.foldCallback) {
        self.foldCallback();
    }
//    if (self.isFold) {
//        [self foldView];
//    }
//    else {
//        [self unfoldView];
//    }
}

- (void)panFoldEvent:(UIPanGestureRecognizer *)sender {
    
static UIPanGestureRecognizerDirection direction = UIPanGestureRecognizerDirectionUndefined;
    
    switch (sender.state) {
            
        case UIGestureRecognizerStateBegan: {
            
            if (direction == UIPanGestureRecognizerDirectionUndefined) {
                
                CGPoint velocity = [sender velocityInView:self];
                
                BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
                
                if (isVerticalGesture) {
                    if (velocity.y > 0) {
                        direction = UIPanGestureRecognizerDirectionDown;
                    } else {
                        direction = UIPanGestureRecognizerDirectionUp;
                    }
                }
                
                else {
                    if (velocity.x > 0) {
                        direction = UIPanGestureRecognizerDirectionRight;
                    } else {
                        direction = UIPanGestureRecognizerDirectionLeft;
                    }
                }
            }
            
            break;
        }
            
//        case UIGestureRecognizerStateChanged: {
//            switch (direction) {
//                case UIPanGestureRecognizerDirectionUp: {
//                    [self handleUpwardsGesture:sender];
//                    break;
//                }
//                case UIPanGestureRecognizerDirectionDown: {
//                    [self handleDownwardsGesture:sender];
//                    break;
//                }
//                default: {
//                    break;
//                }
//            }
//        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            switch (direction) {
                case UIPanGestureRecognizerDirectionUp: {
                    [self handleUpwardsGesture:sender];
                    break;
                }
                case UIPanGestureRecognizerDirectionDown: {
                    [self handleDownwardsGesture:sender];
                    break;
                }
                default: {
                    break;
                }
            }
            direction = UIPanGestureRecognizerDirectionUndefined;
            break;
        }
            
        default:
            break;
    }
    
}

- (void)handleUpwardsGesture:(UIPanGestureRecognizer *)sender
{
    if (self.panFoldCallback) self.panFoldCallback(UIPanGestureRecognizerDirectionUp);

    NSLog(@"Up");
}

- (void)handleDownwardsGesture:(UIPanGestureRecognizer *)sender
{
    if (self.panFoldCallback) self.panFoldCallback(UIPanGestureRecognizerDirectionDown);
    NSLog(@"Down");
}

- (void)handleLeftGesture:(UIPanGestureRecognizer *)sender
{
    NSLog(@"Left");
}

- (void)handleRightGesture:(UIPanGestureRecognizer *)sender
{
    NSLog(@"Right");
}


#pragma mark - UIGestureRecognizerDelegate
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    return YES;
//}
//
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end
