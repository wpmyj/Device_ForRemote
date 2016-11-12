//
//  MHLumiPlugQuant.h
//  MiHome
//
//  Created by Lynn on 12/26/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHLumiPlugQuant : MHDataBase <NSCoding>

@property (nonatomic,strong) NSString *deviceId;    //key deviceId + dateString + dateType
@property (nonatomic,strong) NSString *dateString; 
@property (nonatomic,strong) NSString *dateType;
@property (nonatomic,strong) NSString *quantValue;

@end
