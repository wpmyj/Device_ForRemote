//
//  MHLumiXMRadio.h
//  MiHome
//
//  Created by Lynn on 11/23/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHLumiXMAnnouncer : MHDataBase <NSCoding>

@property (nonatomic,strong) NSString *announcer_id;
@property (nonatomic,strong) NSString *nickname;
@property (nonatomic,strong) NSString *avatar_url;

@end
