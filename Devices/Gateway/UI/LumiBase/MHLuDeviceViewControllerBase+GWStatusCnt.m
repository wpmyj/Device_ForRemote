//
//  MHLuDeviceViewControllerBase+GWStatusCnt.m
//  MiHome
//
//  Created by Lynn on 10/23/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLuDeviceViewControllerBase+GWStatusCnt.h"
#import <objc/runtime.h>

@implementation MHLuDeviceViewControllerBase (GWStatusCnt)

NSDate *            _startTime_MHLuDeviceViewControllerBase;
NSDate *            _endTime_MHLuDeviceViewControllerBase;

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //        SEL originalSel_BecomeActive = @selector(applicationDidBecomeActive);
        //        SEL swizzledSel_BecomeActive = @selector(gw_applicationDidBecomeActive);
        //        [self methodSwizzleWithOriganl:originalSel_BecomeActive andSwizzled:swizzledSel_BecomeActive];
        //
        //        SEL originalSel_willResign = @selector(applicationWillResignActive);
        //        SEL swizzledSel_willResign = @selector(gw_applicationWillResignActive);
        //        [self methodSwizzleWithOriganl:originalSel_willResign andSwizzled:swizzledSel_willResign];
        
        SEL originalSel_willAppear = @selector(viewWillAppear:);
        SEL swizzledSel_willAppear = @selector(gw_viewWillAppear:);
        [self gw_methodSwizzleWithOriganl:originalSel_willAppear andSwizzled:swizzledSel_willAppear];
        
        SEL originalSel_willDisAppear = @selector(viewWillDisappear:);
        SEL swizzledSel_willDisAppear = @selector(gw_viewWillDisappear:);
        [self gw_methodSwizzleWithOriganl:originalSel_willDisAppear andSwizzled:swizzledSel_willDisAppear];
    });
}

+(void)gw_methodSwizzleWithOriganl:(SEL)originalSel andSwizzled:(SEL)swizzledSel{
    Class cls = [self class];
    
    Method originalMethod = class_getInstanceMethod(cls, originalSel);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSel);
    
    BOOL didAddMethod =
    class_addMethod(cls,
                    originalSel,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(cls,
                            swizzledSel,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

//typedef void (*_VIMP)(id, SEL, ...);
//typedef id (*_IMP)(id, SEL, ...);

//+(BOOL)resolveInstanceMethod:(SEL)sel
//{
//    NSString *classString = NSStringFromClass(self);
//
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"LM_StatusCountMethodList" ofType:@"plist"];
//    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
//
//    for (NSString *cntClassName in data.allKeys){
//        if([classString isEqualToString:cntClassName]){
//            static dispatch_once_t onceToken;
//            dispatch_once(&onceToken, ^{
//
//                NSDictionary *methods_list = [data valueForKey:classString];
//
//                for (NSString *method_name in methods_list.allKeys){
//                    SEL org_sel = NSSelectorFromString(method_name);
//                    Method org_method = class_getInstanceMethod(self, org_sel);
//
//                    if([[methods_list valueForKey:method_name] boolValue]){ //如果返回不为空
//                        _IMP org_method_imp = (_IMP)method_getImplementation(org_method);
//                        method_setImplementation(org_method, imp_implementationWithBlock(^(id target, SEL action){
//                            id rt = org_method_imp(target,org_sel);
//                            // 统计点击事件
//                            [[MHStatReportManager shareInstance] appendEventStatType:method_name value:@(1) extra:classString appid:@"lumi"];
//                            NSLog(@"页面 ＝ %@ ， 事件＝%@",classString, method_name);
//                            return rt;
//                        }));
//                    }
//                    else{
//                        _VIMP org_method_imp = (_VIMP)method_getImplementation(org_method);
//                        method_setImplementation(org_method, imp_implementationWithBlock(^(id target, SEL action){
//                            org_method_imp(target,org_sel);
//                            // 统计点击事件
//                            [[MHStatReportManager shareInstance] appendEventStatType:method_name value:@(1) extra:classString appid:@"lumi"];
//                            NSLog(@"页面 ＝ %@ ， 事件＝%@",classString, method_name);
//                        }));
//                    }
//                }
//            });
//        }
//    }
//    return [super resolveInstanceMethod:sel];
//}

#pragma mark - 统计页面信息，页面停留时间
//-(void)gw_applicationDidBecomeActive{
//    [self gw_applicationDidBecomeActive];
//    //页面活跃，统计页面开始时间
//    _startTime = [NSDate date];
//}
//
//-(void)gw_applicationWillResignActive{
//    [self gw_applicationWillResignActive];
//    //页面结束，统计页面，页面结束时间
//    _endTime = [NSDate date];
//    [self gw_viewTimeCount];
//}

-(void)gw_viewWillAppear:(BOOL)animated{
    [self gw_viewWillAppear:animated];
    _startTime_MHLuDeviceViewControllerBase = [NSDate date];
}

-(void)gw_viewWillDisappear:(BOOL)animated{
    [self gw_viewWillDisappear:animated];
    
    _endTime_MHLuDeviceViewControllerBase = [NSDate date];
    [self gw_viewTimeCount];
}

-(void)gw_viewTimeCount{
    //statType，统计名；value，时间值
    NSString *statType = NSStringFromClass([self class]);
    NSTimeInterval timerInterval = [_endTime_MHLuDeviceViewControllerBase timeIntervalSinceDate:_startTime_MHLuDeviceViewControllerBase];
    NSString *timerValue = [NSString stringWithFormat:@"%.2f",timerInterval];
    
    NSString *title = self.controllerIdentifier;
    
    NSLog(@"页面 ＝ %@ - %@， 时长＝%@",statType,title,timerValue);
    [[MHStatReportManager shareInstance] appendEventStatType:statType value:timerValue extra:title appid:@"lumi"];
}

@end
