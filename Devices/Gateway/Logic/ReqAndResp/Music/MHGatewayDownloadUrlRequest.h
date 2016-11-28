//
//  MHGatewayDownloadUrlRequest.h
//  MiHome
//
//  Created by Lynn on 10/28/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHGatewayDownloadUrlRequest : MHBaseRequest

@property (nonatomic,copy) NSString *fileName;

@property (nonatomic,copy) NSString *did;
@property (nonatomic,copy) NSString *uid;
@property (nonatomic,copy) NSString *suffix;
@property (nonatomic,assign) NSInteger time;
@end
