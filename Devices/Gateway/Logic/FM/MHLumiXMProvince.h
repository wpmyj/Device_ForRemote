//
//  MHLumiXMProvince.h
//  MiHome
//
//  Created by Lynn on 11/20/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHLumiXMProvince : MHDataBase <NSCoding>

@property (nonatomic,strong) NSDate *createtime;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *code;
@property (nonatomic,strong) NSString *provinceId;
@property (nonatomic,assign) BOOL isCurrentLocal;  //默认为NO，后期设置

@end
