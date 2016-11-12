//
//  MHSetSubDataRequest.h
//  MiHome
//
//  Created by Woody on 15/4/10.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHSetSubDataRequest : MHBaseRequest
@property (nonatomic, copy) NSString* did;
@property (nonatomic, copy) NSString* key;
@property (nonatomic, copy) NSString* type;
@end
