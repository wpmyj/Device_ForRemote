//
//  MHLMACTipsView.m
//  MiHome
//
//  Created by ayanami on 16/8/10.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLMACTipsView.h"
//key for tips
#define KeyForTipsContextInfo                                       @"info"
#define KeyForTipsContextDuration                                   @"duration"
#define KeyForTipsContextModelFlag                                  @"isModel"



#define BoardViewSize   (160.f) //面板的宽度和高度，高度会变
#define BoardViewImageCapInset   (20.f) //面板背景图显示时的cap inset
#define TBGap (20.f)    //顶端和低端的间隙
#define LRGap   (10.f)  //左右间隙
#define ResultIconSize (70.f)   //成功或失败icon的尺寸
#define ResultIconTextVGap   (11.f) //成功或失败icon和其下面的文本的间隙
#define TextHeight   (50.f) //默认文本高度
#define TextFont    (14.f)  //文本字体大小

static MHLMACTipsView* gTipsView = nil;


@interface MHLMACTipsView ()

@property (nonatomic, copy) modelCallBack handle;

@end

@implementation MHLMACTipsView

+ (MHLMACTipsView *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (gTipsView == nil)
        {
            gTipsView = [[MHLMACTipsView alloc] initMHtips];
        }
    });
    
    return gTipsView;
}

- (void)showTips:(NSString *)info modal:(BOOL)isModal handle:(modelCallBack)handle {
    NSMutableDictionary* context = [[NSMutableDictionary alloc] initWithCapacity:3];
    if (info) {
        [context setObject:info forKey:KeyForTipsContextInfo];
    }
    
    NSNumber* modelFlag = [[NSNumber alloc] initWithBool:isModal];
    [context setObject:modelFlag forKey:KeyForTipsContextModelFlag];
    _window.hidden = NO;
    
    [self performSelectorOnMainThread:@selector(showTipsOnMainTread:)
                           withObject:context
                        waitUntilDone:NO];
    
    context = nil;
    modelFlag = nil;    self.handle = handle;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancleHanlde:)];
    [self addGestureRecognizer:tap];
    self.userInteractionEnabled = YES;
//    _backgroundView.backgroundColor = [UIColor blackColor];
//    _backgroundView.alpha = 0.3f;
}

- (void)showTipsOnMainTread:(NSDictionary*)diction
{
    NSString* info = [diction objectForKey:KeyForTipsContextInfo];
    NSNumber* modelFlag = [diction objectForKey:KeyForTipsContextModelFlag];
    BOOL isModal = [modelFlag boolValue];
    [self setModal:isModal];
    
    self.hidden = NO;
    _imageView.hidden = YES;
    
    [_boardView addSubview:_activityView];
    [_activityView startAnimating];
    
    [self updateUIWithInfo:info];
    
    //这个特殊处理，不使用顶层窗口
    _window.hidden = YES;
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:self];
}

- (void)setModal:(BOOL)isModal
{
    if (isModal)
    {
        [self setUserInteractionEnabled:YES];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0.1f;
    }
    else
    {
        [self setUserInteractionEnabled:NO];
        _backgroundView.backgroundColor = [UIColor clearColor];
    }
}

- (void)updateUIWithInfo:(NSString*)info {
    /*设置默认position*/
    float infoTextY;
    if (_imageView.hidden && ![_activityView superview]) {
        infoTextY = TBGap;
    } else {
        infoTextY = TBGap+ResultIconSize+ResultIconTextVGap;
    }
    
    _boardView.center = CGPointMake(self.bounds.size.width /2, self.bounds.size.height /2) ;
    
    CGRect labelRect = CGRectMake(LRGap, infoTextY, BoardViewSize-LRGap*2, TextHeight);
    [_labelInfo setFrame:labelRect];
    
    _imageView.center = CGPointMake(BoardViewSize/2.f, TBGap+ResultIconSize/2.f) ;
    
    /*根据info调整position*/
    _labelInfo.text = info;
    CGFloat textHeight = [info boundingRectWithSize:CGSizeMake(_labelInfo.frame.size.width, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:TextFont]} context:nil].size.height;
    [_labelInfo setFrame:CGRectMake(_labelInfo.frame.origin.x, _labelInfo.frame.origin.y, _labelInfo.frame.size.width, textHeight)];
    
    [_boardView setFrame:CGRectMake(_boardView.frame.origin.x, _boardView.frame.origin.y, _boardView.frame.size.width, CGRectGetMaxY(_labelInfo.frame) + TBGap)];
    
    //如果文字为空，菊花居中.
    if ([info length] <= 0) {
        _activityView.center = CGPointMake(CGRectGetWidth(_boardView.bounds) / 2, CGRectGetHeight(_boardView.bounds) / 2);
    } else {
        _activityView.center = CGPointMake(BoardViewSize/2, TBGap+ResultIconSize/2.f);
    }
}

- (void)cancleHanlde:(id)sender {
    if (self.handle) {
        self.handle();
    }
}


@end
