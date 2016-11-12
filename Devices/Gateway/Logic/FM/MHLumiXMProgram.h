//
//  MHLumiXMRadio.h
//  MiHome
//
//  Created by Lynn on 11/23/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHLumiXMProgram : MHDataBase <NSCoding>

@property (nonatomic,strong) NSString *program_id;
@property (nonatomic,strong) NSString *program_name;
@property (nonatomic,strong) NSString *programStartTime;
@property (nonatomic,strong) NSString *programEndTime;
@property (nonatomic,strong) NSString *listen_back_url;
@property (nonatomic,strong) NSString *rate64_aac_url;
@property (nonatomic,strong) NSArray  *live_announcers;
@property (nonatomic,strong) NSString *updated_at;

@end
