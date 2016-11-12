//
//  MHACTypeModel.h
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHACTypeModel : MHDataBase

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* eng_name;
@property (nonatomic, assign) NSInteger brand_id;
@property (nonatomic, assign) int number;

/**
 *  拼音
 like pingguodiannao
 */
@property (nonatomic, readonly) NSString * namePinYin;

/**
 *  拼音首字母
 */
@property (nonatomic, readonly) NSString * nameFirstLetter;

@end
