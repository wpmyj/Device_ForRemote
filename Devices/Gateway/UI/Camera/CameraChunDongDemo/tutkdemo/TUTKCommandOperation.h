//
//  MHTutkOperation.h
//  TutkOperation
//
//  Created by huchundong on 2016/8/23.
//  Copyright © 2016年 huchundong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHBaseClient.h"
#define MTCOLog(x,...) \
{\
    NSLog(@"%@",[NSString stringWithFormat:x, ##__VA_ARGS__]);\
}

typedef enum TUTKCommandOperationState{
    TUTKCommandOperationStateReady,
    TUTKCommandOperationStatePause,
    TUTKCommandOperationStateExecuting,
    TUTKCommandOperationStateFinish,
}TUTKCommandOperationState;


@interface TUTKCommandOperation : NSOperation
@property(nonatomic, strong)MHBaseClient*           client;
@property(nonatomic, strong)NSRecursiveLock*        lock;
@property(nonatomic, copy)TUTKCommandBlock   handle;
//@property(nonatomic, copy)TUTKCommandSuccess sucess;
//@property(nonatomic, copy)TUTKCommandFail   fail;
//@property(nonatomic, strong)NSError* error;o
@property(nonatomic, assign)NSInteger   errCode;
@property(nonatomic, assign)TUTKCommandOperationState state;

- (instancetype)initWithClient:(MHBaseClient*)client;
@end
