//
//  MHLumiXMPageInfo.h
//  MiHome
//
//  Created by Lynn on 11/24/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHLumiXMPageInfo : MHDataBase <NSCoding>

@property (nonatomic,strong) NSNumber *totalCount;
@property (nonatomic,strong) NSNumber *totalPage;
@property (nonatomic,strong) NSNumber *currentPage;

@end
