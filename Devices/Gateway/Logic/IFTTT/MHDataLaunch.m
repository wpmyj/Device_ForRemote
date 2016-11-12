//
//  MHDataLaunch.m
//  MiHome
//
//  Created by Lynn on 9/9/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHDataLaunch.h"
#import "MHDeviceListCache.h"

@implementation MHDataLaunch

+(instancetype)dataWithJSONObject:(id)object
{
    MHDataLaunch* launch = [[self alloc] init];

    if(self){
        if([object isKindOfClass:[NSDictionary class]]){
            launch.name = [object valueForKey:@"name"] ? [object valueForKey:@"name"] : @"";
            launch.deviceName = [object valueForKey:@"device_name"] ? [object valueForKey:@"device_name"] : @"";
            launch.deviceDid = [object valueForKey:@"did"] ? [object valueForKey:@"did"] : @"";
            launch.deviceKey = [object valueForKey:@"key"] ? [object valueForKey:@"key"] : @"";
            launch.src = [object valueForKey:@"src"] ? [object valueForKey:@"src"] : @"";
            launch.value = [object valueForKey:@"value"] ? [object valueForKey:@"value"] : @"";
            launch.timeSpan = [object valueForKey:@"timespan"];
            launch.extra = [object valueForKey:@"extra"] ? [object valueForKey:@"extra"] : @"";
            launch.plug_id = [object valueForKey:@"plug_id"] ? [object valueForKey:@"plug_id"] : @"";
        }
    }
    return launch;
}

-(instancetype)initWithRecomObject:(id)object
{
    if(self){
        self.name = [object valueForKey:@"name"] ? [object valueForKey:@"name"] : @"";
        self.deviceName = [object valueForKey:@"device_name"] ? [object valueForKey:@"device_name"] : @"";
        self.deviceDid = [object valueForKey:@"did"] ? [object valueForKey:@"did"] : @"";
        self.deviceKey = [object valueForKey:@"key"] ? [object valueForKey:@"key"] : @"";
        self.src = [object valueForKey:@"src"] ? [object valueForKey:@"src"] : @"";
        self.value = [object valueForKey:@"value"] ? [object valueForKey:@"value"] : @"";
        self.timeSpan = [object valueForKey:@"timespan"];
        self.extra = [object valueForKey:@"extra"] ? [object valueForKey:@"extra"] : @"";
        self.plug_id = [object valueForKey:@"plug_id"] ? [object valueForKey:@"plug_id"] : @"";
    }
    return self;
}

-(BOOL)isEqual:(id)object
{
    MHDataLaunch *launch = (MHDataLaunch *)object;
    if(![object isKindOfClass:[self class]]){
        return NO;
    }
    
    if(!launch.timeSpan && !self.timeSpan) return YES;
    
    if(self.value)
        return ([launch.name isEqualToString:self.name] &&
                [launch.deviceName isEqualToString:self.deviceName] &&
                [launch.deviceKey isEqualToString:self.deviceKey] &&
                [launch.src isEqualToString:self.src] &&
                [launch.deviceDid isEqual:self.deviceDid] &&
                [launch.timeSpan isEqual:self.timeSpan]);
    else
        return ([launch.name isEqualToString:self.name] &&
                [launch.deviceName isEqualToString:self.deviceName] &&
                [launch.deviceKey isEqualToString:self.deviceKey] &&
                [launch.src isEqualToString:self.src] &&
                [launch.deviceDid isEqual:self.deviceDid] &&
                [launch.value isEqual:self.value] &&
                [launch.timeSpan isEqual:self.timeSpan]);
}

+(MHDataLaunch *)reBuildLaunchData:(NSMutableArray *)launchList withDeviceId:(NSString *)did
{
    for (id launch in launchList){
        if([[launch valueForKey:@"device_did"] isEqualToString:did]){
            for(id obj in [launch valueForKey:@"launch"]){
                if (![obj valueForKey:@"plug_id"]){
                    NSMutableDictionary *selectedLaunchObject = [NSMutableDictionary dictionaryWithCapacity:1];
                    [selectedLaunchObject setObject:[launch valueForKey:@"device_name"] forKey:@"device_name"];
                    [selectedLaunchObject setObject:[launch valueForKey:@"device_did"] forKey:@"did"];
                    [selectedLaunchObject setObject:[obj valueForKey:@"name"] forKey:@"name"];
                    [selectedLaunchObject setObject:[obj valueForKey:@"key"] forKey:@"key"];
                    [selectedLaunchObject setObject:[obj valueForKey:@"value"] forKey:@"value"];
                    [selectedLaunchObject setObject:[obj valueForKey:@"src"] forKey:@"src"];
                    if([obj valueForKey:@"extra"])[selectedLaunchObject setObject:[obj valueForKey:@"extra"] forKey:@"extra"];
                    if([obj valueForKey:@"plug_id"])[selectedLaunchObject setObject:[obj valueForKey:@"plug_id"] forKey:@"plug_id"];
                    
                    MHDataLaunch *newLaunchObj = [MHDataLaunch dataWithJSONObject:selectedLaunchObject];
                    newLaunchObj.model = [obj valueForKey:@"model"];
                 
                    return newLaunchObj;
                }
            }
        }
    }
    return nil;
}

+(NSDictionary *)launchToDictionary:(MHDataLaunch *)launch
{
    NSMutableDictionary *actionDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
    [actionDictionary setObject:launch.name ? launch.name : @"" forKey:@"name"];
    [actionDictionary setObject:launch.deviceName ? launch.deviceName : @"" forKey:@"device_name"];
    [actionDictionary setObject:launch.src ? launch.src : @"" forKey:@"src"];
    [actionDictionary setObject:launch.deviceKey ? launch.deviceKey : @"" forKey:@"key"];
    [actionDictionary setObject:launch.deviceDid ? launch.deviceDid : @"" forKey:@"did"];
    [actionDictionary setObject:launch.value ? launch.value : @"" forKey:@"value"];
    if(launch.timeSpan)[actionDictionary setObject:launch.timeSpan forKey:@"timespan"];
    if(launch.extra && launch.extra.length) [actionDictionary setObject:launch.extra forKey:@"extra"];
    if(launch.plug_id) [actionDictionary setObject:launch.plug_id forKey:@"plug_id"];
    
    return actionDictionary;
}

-(MHDataDeviceTimer *)timeSpanToTimer{
    MHDataDeviceTimer *timer = [[MHDataDeviceTimer alloc] init];
    timer.onHour = [[[self.timeSpan valueForKey:@"from"] valueForKey:@"hour"] intValue];
    timer.onMinute = [[[self.timeSpan valueForKey:@"from"] valueForKey:@"min"] intValue];
    
    timer.offHour = [[[self.timeSpan valueForKey:@"to"] valueForKey:@"hour"] intValue];
    timer.offMinute = [[[self.timeSpan valueForKey:@"to"] valueForKey:@"min"] intValue];
    
    timer.onRepeatType = timer.offRepeatType = [self repeatDayFromWdayArray:[self.timeSpan valueForKey:@"wday"]];
    
    [MHDataLaunch parseTimeSpanRepeatType:timer.onRepeatType];
    return timer;
}

-(NSInteger)repeatDayFromWdayArray:(NSArray *)wday{
    NSInteger repeat = 0;
    NSString *repeatString = @"0000000";
    
//    wday = @[@(1),@(2),@(3),@(4),@(5),@(6),@(7)];
//    wday = @[@(0),@(1),@(2),@(3),@(4),@(5),@(6)]; 防止两种情况
    if ([wday isEqualToArray:@[@(1),@(2),@(3),@(4),@(5),@(6),@(7)]]){
        wday = @[@(0),@(1),@(2),@(3),@(4),@(5),@(6)];
    }
    for (id i in wday){
        int index = 6 - [i intValue];
        NSRange range = NSMakeRange(index, 1);
        if (index >= 0 && index < [repeatString length]) {
            repeatString = [repeatString stringByReplacingCharactersInRange:range withString:@"1"];
        }
    }
    if([repeatString isEqualToString:@"0000000"]){
        repeatString = @"1111111";
    }
    
    for (int j = 6 ; j >= 0 ; j --){
        if ([[repeatString substringWithRange:NSMakeRange(j, 1)] isEqualToString:@"1"]){
            repeat = pow(2, 6 - j) + repeat;
        }
    }
    
    return repeat;
}

+(NSArray *)parseTimeSpanRepeatType:(NSInteger)repeatType
{
    NSMutableArray *wday = [NSMutableArray array];
    
    for (int j = 0 ; j <= 6 ; j ++){
        if ((repeatType & 1) == 1){
            [wday addObject:@(j)];
        }
        repeatType /= 2;
    }
    
    return wday;
}

+(NSDictionary *)parseTimerToTimeSpanDictionary:(MHDataDeviceTimer *)timer
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    
    NSDictionary *from = [NSDictionary dictionaryWithObjectsAndKeys:[timer valueForKey:@"onHour"],@"hour",[timer valueForKey:@"onMinute"],@"min", nil];
    [dic setObject:from forKey:@"from"];
    
    NSDictionary *to = [NSDictionary dictionaryWithObjectsAndKeys:[timer valueForKey:@"offHour"],@"hour",[timer valueForKey:@"offMinute"],@"min", nil];
    [dic setObject:to forKey:@"to"];
    
    NSArray *wday = [self parseTimeSpanRepeatType:[[timer valueForKey:@"onRepeatType"] integerValue]];
    [dic setObject:wday forKey:@"wday"];
    
    return [dic mutableCopy];
}


#pragma mark - encoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.deviceName forKey:@"deviceName"];
    [aCoder encodeObject:self.deviceDid forKey:@"deviceDid"];
    [aCoder encodeObject:self.deviceKey forKey:@"deviceKey"];
    [aCoder encodeObject:self.src forKey:@"src"];
    [aCoder encodeObject:self.value forKey:@"value"];
    [aCoder encodeObject:self.model forKey:@"model"];
    [aCoder encodeObject:self.timeSpan forKey:@"timeSpan"];
    [aCoder encodeObject:self.extra forKey:@"extra"];
    [aCoder encodeObject:self.plug_id forKey:@"plug_id"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.deviceName = [aDecoder decodeObjectForKey:@"deviceName"];
        self.deviceDid = [aDecoder decodeObjectForKey:@"deviceDid"];
        self.deviceKey = [aDecoder decodeObjectForKey:@"deviceKey"];
        self.src = [aDecoder decodeObjectForKey:@"src"];
        self.value = [aDecoder decodeObjectForKey:@"value"];
        self.model = [aDecoder decodeObjectForKey:@"model"];
        self.timeSpan = [aDecoder decodeObjectForKey:@"timeSpan"];
        self.extra = [aDecoder decodeObjectForKey:@"extra"];
        self.plug_id = [aDecoder decodeObjectForKey:@"plug_id"];
    }
    return self;
}
@end
