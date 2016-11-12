//
//  MHLumiLocalCachePathHelper.h
//  MiHome
//
//  Created by LM21Mac002 on 16/10/17.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, MHLumiLocalCacheType){
    MHLumiLocalCacheTypeLumiLibraryCachesHome,
    MHLumiLocalCacheTypeTUTKPath,
    MHLumiLocalCacheTypeCommon,
};

@interface MHLumiLocalCachePathHelper : NSObject
+ (MHLumiLocalCachePathHelper *)defaultHelper;

- (NSString *)pathWithLocalCacheType:(MHLumiLocalCacheType)type andFilename:(NSString *)filename;
@end
