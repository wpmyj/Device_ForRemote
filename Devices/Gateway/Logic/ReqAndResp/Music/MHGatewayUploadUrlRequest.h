//
//  MHGatewayUploadUrlRequest.h
//  MiHome
//
//  Created by Lynn on 10/28/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHGatewayUploadUrlRequest : MHBaseRequest

@property (nonatomic,strong) MHDevice *device;
@property (nonatomic,strong) NSString *suffix;

@end
