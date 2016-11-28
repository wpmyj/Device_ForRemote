//
//  MHLumiAVBufferSynchronizer.m
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/17.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiAVBufferSynchronizer.h"

@interface MHLumiAVBufferSynchronizer()
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, strong) NSMutableArray *aacDataArray;
@property (nonatomic, strong) NSMutableArray *h264DataArray;
@end

@implementation MHLumiAVBufferSynchronizer
- (instancetype)init{
    self = [super init];
    if (self) {
        _isReady = NO;
        _aacDataArray = [NSMutableArray array];
    }
    return self;
}
@end
