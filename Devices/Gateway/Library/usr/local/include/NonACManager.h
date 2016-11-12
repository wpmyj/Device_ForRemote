//
//  NonACManager.h
//  kookongIphone
//
//  Created by shuaiwen on 16/3/15.
//  Copyright © 2016年 shuaiwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NonACManager : NSObject
-(id)KKNonACManagerWith:(NSDictionary * )irData;
-(NSArray *)getAllKeys;
-(int)getRemoteID;
-(NSArray* )getParams;
-(NSArray *)getKeyIrWith:(NSString *)fkey;
@end
