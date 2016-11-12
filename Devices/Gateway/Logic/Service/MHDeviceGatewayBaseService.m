//
//  MHDeviceGatewayBaseService.m
//  MiHome
//
//  Created by Lynn on 2/19/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewayBaseService.h"

@implementation MHDeviceGatewayBaseService

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@ %@ - %@",self, self.serviceName,self.serviceParentDid];
}

- (void)serviceMethod {
    if(self.serviceMethodCallBack)self.serviceMethodCallBack(self);
}

- (void)changeName {
    if(self.serviceChangeNameCall)self.serviceChangeNameCall(self);
}

- (void)changeIcon {
    NSString *iconName = [self fetchIconNameWithHeader:@"home"];
    if([[NSFileManager defaultManager] fileExistsAtPath:iconName]) {
        self.serviceIcon = [UIImage imageWithContentsOfFile:iconName];
    }
}

#pragma mark - 获取图片名字
- (NSString *)fetchIconNameWithHeader:(NSString *)header {

    NSString *deviceType = [NSString stringWithFormat:@"%@_Service%d", self.serviceParentClass, self.serviceId];
    NSString *imageName = [NSString stringWithFormat:@"%@_%@_%@_%@.png", header, deviceType, self.serviceIconId , self.isOpen ? @"on" : @"off"];
   
    NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [docPath objectAtIndex:0];
    NSString *readPath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",@"lumi/icons/",imageName]];

    return readPath;
}

@end
