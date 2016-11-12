//
//  MHLumiPlugQuantCache.m
//  MiHome
//
//  Created by Lynn on 12/26/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiPlugQuantCache.h"
#import "MHLumiCache.h"
#import "MHLumiPlugQuant.h"

@implementation MHLumiPlugQuantCache

- (NSString *)entityName
{
    return kEntityNamePlugQuant;
}

- (void)fillManagedObject:(NSManagedObject *)mo withData:(id)data
{
    MHLumiPlugQuant *plugquant = data;

    [mo setValue:plugquant.deviceId forKey:@"deviceId"];
    [mo setValue:plugquant.dateString forKey:@"dateString"];
    [mo setValue:plugquant.quantValue forKey:@"quantValue"];
    [mo setValue:plugquant.dateType forKey:@"dateType"];
}

- (id)fillDataWithManagedObject:(NSManagedObject *)mo
{
    MHLumiPlugQuant* data = [[MHLumiPlugQuant alloc] init];
    
    data.deviceId = [mo valueForKey:@"deviceId"];
    data.dateString = [mo valueForKey:@"dateString"];
    data.dateType = [mo valueForKey:@"dateType"];
    data.quantValue = [mo valueForKey:@"quantValue"];
    
    return data;
}

@end
