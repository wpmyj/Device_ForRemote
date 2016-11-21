//
//  MHLumiPhotoGridDataSourceProtocol.h
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MHLumiPhotoGridDataSourceProtocol <NSObject>

- (NSUInteger)numberOfSection;
- (NSUInteger)numberOfRowInSection:(NSUInteger)section;
- (NSString *)headerTitleInSection:(NSUInteger)section;
- (void)fetchVImageOfItemAtIndexPath:(NSIndexPath *)indexPath completeHandler:(void(^)(UIImage *image)) completeHandler;
- (void)fetchVideoDurationAtIndexPath:(NSIndexPath *)indexPath completeHandler:(void(^)(NSTimeInterval duration)) completeHandler;
- (void)fetchvideoUrlAtIndexPath:(NSIndexPath *)indexPath completeHandler:(void(^)(NSString *videoUrl)) completeHandler;
- (void)fetchthumbnailUrlAtIndexPath:(NSIndexPath *)indexPath completeHandler:(void(^)(NSString *thumbnailUrl)) completeHandler;
@end
