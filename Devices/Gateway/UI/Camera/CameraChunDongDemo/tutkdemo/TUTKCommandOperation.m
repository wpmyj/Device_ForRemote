//
//  MHTutkOperation.m
//  TutkOperation
//
//  Created by huchundong on 2016/8/23.
//  Copyright © 2016年 huchundong. All rights reserved.
//

#import "TUTKCommandOperation.h"
#import "MHBaseClient.h"

@implementation TUTKCommandOperation{
}
@synthesize lock = _lock;
@synthesize client = _client;

#pragma mark thread -
+(NSThread*)tutkCommandThread{
    static dispatch_once_t once;
    static NSThread* tutkCommandThread;
    dispatch_once(&once,^(){
        tutkCommandThread = [[NSThread alloc ] initWithTarget:self selector:@selector(tutkCommand:) object:nil];
        [tutkCommandThread start];
    });
    return tutkCommandThread;
}

+ (void)tutkCommand:(id)sender{
    @autoreleasepool {
        [[NSThread currentThread] setName:@"tutkCommandThead"];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

#pragma mark -

- (instancetype)initWithClient:(MHBaseClient*)client_{
    self = [ super init];
    if (self){
        _client = client_;
        _state = TUTKCommandOperationStateReady;
        _lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}
#pragma mark operation -

- (void)start{
    MTCOLog(@"operation start");
    [_lock lock];
    if([self isCancelled]){
        
    }else if([self isReady]){
        self.state = TUTKCommandOperationStateExecuting;
        [self performSelector:@selector(operationRun:) onThread:[TUTKCommandOperation tutkCommandThread] withObject:nil waitUntilDone:NO];
    }
    
    
    [_lock unlock];
}

- (void)operationRun:(id)obj{
    MTCOLog(@"operationRun  %@ %@",self,self.isCancelled == YES?@" isCancel ":@"no Cancel");
    [_lock lock];
    if(self.isCancelled == NO){
        if( self.handle){
            BOOL ret = self.handle(self.client);
            MTCOLog(@"ret == %@",ret == YES?@"operation handle success":@"operation handle fail");
        }
    }
    [self finish];
    [_lock unlock];
}
- (void)cancel{
    [_lock lock];
    if ([self isFinished ] != YES && [self isCancelled] == NO){
        [super cancel];
    }
    [self finish];
    MTCOLog(@"operation cancel");
    [_lock unlock];
}

- (BOOL)isReady {
    return self.state == TUTKCommandOperationStateReady && [super isReady];
}
- (BOOL)isConcurrent{
    return YES;
}
- (BOOL)isExecuting{
    return self.state == TUTKCommandOperationStateExecuting;
}
- (void)finish {
    [_lock lock];
    self.state = TUTKCommandOperationStateFinish;
    [_lock unlock];
}
- (BOOL)isFinished{
    return self.state == TUTKCommandOperationStateFinish;
}


- (void)dealloc{
    MTCOLog(@"operation dealloc");
}

- (void)setState:(TUTKCommandOperationState)state{
    [_lock lock];
    NSString* oldStateKey = MHKeyPathFromCommandOperationState(self.state);
    NSString* newStateKey = MHKeyPathFromCommandOperationState(state);
    [self willChangeValueForKey:newStateKey];
    [self willChangeValueForKey:oldStateKey];
    _state = state;
    [self didChangeValueForKey:oldStateKey];
    [self didChangeValueForKey:newStateKey];
    [_lock unlock];
}
static inline NSString * MHKeyPathFromCommandOperationState(TUTKCommandOperationState state) {
    switch (state) {
        case TUTKCommandOperationStateReady:
            return @"isReady";
        case TUTKCommandOperationStateExecuting:
            return @"isExecuting";
        case TUTKCommandOperationStateFinish:
            return @"isFinished";
        case TUTKCommandOperationStatePause:
            return @"isPaused";
        default: {
            return @"state";
        }
    }
}

@end
