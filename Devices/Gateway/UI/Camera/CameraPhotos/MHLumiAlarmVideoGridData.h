//
//  MHLumiAlarmVideoGridData.h
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHLumiAlarmVideoGridData : NSObject
@property (nonatomic, assign) NSUInteger *videoHeight;
@property (nonatomic, assign) NSUInteger *videoWidth;
@property (nonatomic, assign) NSData *rawData;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, assign) NSInteger duration;

///用于获取视频下载地址
@property (nonatomic, copy) NSString *videoUrlIdentifier;
///视频的下载地址，有时效的
@property (nonatomic, copy) NSString *videoDownLoadUrl;
///视频在本地的路径
@property (nonatomic, copy) NSString *videoLocalPath;

///用于获取缩略图下载地址
@property (nonatomic, copy) NSString *imageUrlIdentifier;
///缩略图的下载地址，有时效的
@property (nonatomic, copy) NSString *imageDownLoadUrl;


@end
