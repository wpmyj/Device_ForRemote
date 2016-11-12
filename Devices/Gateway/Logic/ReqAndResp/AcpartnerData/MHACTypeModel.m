//
//  MHACTypeModel.m
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACTypeModel.h"
#import "NSString+MHLumiPinYin.h"

@interface MHACTypeModel()
/**
 *  拼音
 like pingguodiannao
 */
@property (nonatomic, copy) NSString * namePinYin;

/**
 *  拼音首字母
 */
@property (nonatomic, copy) NSString * nameFirstLetter;

@end

@implementation MHACTypeModel

+ (instancetype)instanceWithJSONObject:(id)object {
    MHACTypeModel* type = [super instanceWithJSONObject:object];
    if (type) {
        type.name = [[object objectForKey:@"name"] stringValue];
        type.eng_name = [object objectForKey:@"eng_name"];
        //        NSLog(@"英文名有毒啊%@", type.eng_name);
        if ([type.eng_name isEqualToString:@""]) {
            type.eng_name = type.name;
        }
        type.brand_id = [[object objectForKey:@"brand_id"] integerValue];
        type.number = [[object objectForKey:@"number"] intValue];
    }
    return type;
}

#pragma mark - 支持序列化存储
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.eng_name forKey:@"eng_name"];
    [aCoder encodeObject:@(self.brand_id) forKey:@"brand_id"];
    [aCoder encodeObject:@(self.number) forKey:@"number"];

}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.eng_name = [aDecoder decodeObjectForKey:@"eng_name"];
        self.brand_id = [[aDecoder decodeObjectForKey:@"brand_id"] integerValue];
        self.number = [[aDecoder decodeObjectForKey:@"number"] intValue];
    }
    return self;
}

- (NSString *)namePinYin{
    if (!_namePinYin){
        _namePinYin = [_name transformToPinyin];
    }
    return _namePinYin;
}

- (NSString *)nameFirstLetter{
    if (!_nameFirstLetter){
        _nameFirstLetter = [_name transformToPinyinFirstLetter];
    }
    return _nameFirstLetter;
}
@end
