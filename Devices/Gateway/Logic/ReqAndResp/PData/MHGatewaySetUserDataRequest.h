//
//  MHGatewaySetUserDataRequest.h
//  MiHome
//
//  Created by Lynn on 10/29/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHGatewaySetUserDataRequest : MHBaseRequest

@property (nonatomic,strong) NSDictionary *value;
@property (nonatomic,strong) NSString *keyString;

@end
