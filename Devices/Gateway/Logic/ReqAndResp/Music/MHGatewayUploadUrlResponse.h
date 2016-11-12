//
//  MHGatewayUploadUrlResponse.h
//  MiHome
//
//  Created by Lynn on 10/28/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHGatewayUploadUrlResponse : MHBaseResponse

@property (nonatomic,strong) NSString *url;
@property (nonatomic,strong) NSString *uploadFileName;

+ (instancetype)responseWithJSONObject:(id)object andSuffix:(NSString *)suffix;

@end
