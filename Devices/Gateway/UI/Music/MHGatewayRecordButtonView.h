//
//  MHGatewayRecordButtonView.h
//  MiHome
//
//  Created by Lynn on 10/27/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MiHomeKit/MiHomeKit.h>
#import "MHDeviceGateway.h"
#import "MHGwMusicInvoker.h"

@interface MHGatewayRecordButtonView : UIView

@property (nonatomic,strong) void (^recordSuccess)();
@property (nonatomic,strong) void (^playStoped)();
@property (nonatomic,strong) void (^uploadSuccess)(NSDictionary *fileinfo);
@property (nonatomic,strong) void (^uploadProgress)(CGFloat progress);
@property (nonatomic,strong) void (^uploadStart)(CGFloat progress);

@property (nonatomic,strong) MHDeviceGateway *gateway;
@property (nonatomic,strong) NSURL *outputFileURL;

- (instancetype)initWithFrame:(CGRect)frame andType:(NSString *)type;
-(BOOL)recordFileExist;
-(NSDictionary *)fileAttributes;
-(void)upload;
-(void)play;
-(void)pause;
-(BOOL)removeFile:(NSURL *)fileURL;

@end
