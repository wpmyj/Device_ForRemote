//
//  MHGatewayMusicListManager.h
//  MiHome
//
//  Created by Lynn on 8/17/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHGatewayMusicListManager : MHDataListManagerBase

-(void)fetchMusicListWithPageIndex:(int)pageIndex success:(void (^)(id))success andfailure:(void (^)(NSError *))failure;

@end
