//
//  MHGetSubDataRequest.h
//  MiHome
//
//  Created by Woody on 15/4/10.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHGetSubDataRequest : MHBaseRequest
@property (nonatomic, copy) NSString* did;
@property (nonatomic, retain) NSArray* keys;
@property (nonatomic, assign) NSInteger timestamp;
@property (nonatomic, assign) NSInteger limit;
@end
