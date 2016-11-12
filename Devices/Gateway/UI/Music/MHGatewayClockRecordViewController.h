//
//  MHGatewayClockRecordViewController.h
//  MiHome
//
//  Created by guhao on 16/4/27.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceGateway.h"

@interface MHGatewayClockRecordViewController : MHLuViewController

@property (nonatomic,strong) void (^recordSuccess)();
@property (nonatomic,strong) void (^playStoped)();
@property (nonatomic,strong) void (^uploadSuccess)(NSDictionary *fileinfo);

- (id)initWithGateway:(MHDeviceGateway*)gateway;

-(BOOL)recordFileExist;
-(NSDictionary *)fileAttributes;
-(void)upload;
-(void)play;
-(void)pause;
-(BOOL)removeFile:(NSURL *)fileURL;

@end
