//
//  NSString+MHLumiPinYin.h
//  MiHome
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (pinyin)

/**
 *  拼音 -> pinyin
 */
- (NSString *)transformToPinyin;

/**
 *  拼音首字母 -> py
 */
- (NSString *)transformToPinyinFirstLetter;
@end
