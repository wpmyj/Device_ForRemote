//
//  MHBaseClient.h
//  TutkOperation
//
//  Created by huchundong on 2016/8/24.
//  Copyright © 2016年 huchundong. All rights reserved.
//

#import <Foundation/Foundation.h>
#define DCDLog(x,...)\
{\
NSLog(@"%@",[NSString stringWithFormat:x, ##__VA_ARGS__]);\
}
static NSString* const kTutkDemoGetUIDTickerID = @"kTutkDemoGetUIDTickerID";

@interface MHBaseClient : NSObject

@end

typedef BOOL (^TUTKCommandBlock)(MHBaseClient* client);
typedef void (^TUTKCommandSuccess)();
typedef void (^TUTKCommandFail)(NSInteger errcode);