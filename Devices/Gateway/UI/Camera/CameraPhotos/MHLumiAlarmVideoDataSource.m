//
//  MHLumiAlarmVideoDataSource.m
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/14.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiAlarmVideoDataSource.h"
#import "MHLumiAlarmVideoResponse.h"
#import "MHLumiAlarmVideoGridData.h"
#import <SDWebImage/SDWebImageManager.h>
#import <AVFoundation/AVFoundation.h>
#import "MHGatewayDownloadUrlRequest.h"
#import "MHGatewayDownloadUrlResponse.h"


@interface MHLumiAlarmVideoDataSource()<MHLumiPhotoGridDataSourceProtocol>

- (NSUInteger)numberOfSection;
- (NSUInteger)numberOfRowInSection:(NSUInteger)section;
- (NSString *)headerTitleInSection:(NSUInteger)section;
- (void)fetchVImageOfItemAtIndexPath:(NSIndexPath *)indexPath completeHandler:(void(^)(UIImage *image)) completeHandler;
- (void)fetchVideoDurationAtIndexPath:(NSIndexPath *)indexPath completeHandler:(void(^)(NSTimeInterval duration)) completeHandler;
- (void)fetchvideoUrlAtIndexPath:(NSIndexPath *)indexPath completeHandler:(void(^)(NSString *videoUrl)) completeHandler;
- (void)fetchthumbnailUrlAtIndexPath:(NSIndexPath *)indexPath completeHandler:(void(^)(NSString *thumbnailUrl)) completeHandler;

@property (nonatomic, strong) NSMutableArray<NSMutableArray<MHLumiAlarmVideoGridData*>*> *dataSource;
@property (nonatomic, copy) NSString *deviceDid;
@end

@implementation MHLumiAlarmVideoDataSource
- (instancetype)initWithReques:(MHLumiAlarmVideoRequest *)request withDeviceDid:(NSString *)did{
    self = [super init];
    if (self) {
        _request = request;
        _deviceDid = did;
        [SDWebImageDownloader.sharedDownloader setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    }
    return self;
}

-(void)fetchData{
    [self fetchDataWithReques:_request];
}

- (void)fetchDataWithReques:(MHLumiAlarmVideoRequest *)request{

    void(^completeHandler)(NSError *) = ^(NSError *error){
        if ([self.delegate respondsToSelector:@selector(alarmVideoDataSourceDidUpdate:withError:)]){
            [self.delegate alarmVideoDataSourceDidUpdate:self withError:error];
        }
    };
    
    __weak typeof(self) weakself = self;
    NSLog(@"开始获取列表");
    [[MHNetworkEngine sharedInstance] sendRequest:request success:^(id obj) {
        MHLumiAlarmVideoResponse *response = [MHLumiAlarmVideoResponse responseWithJSONObject:obj];
        NSLog(@"获取列表回来，获取了 %d 个",(int)response.alarmVideoDownloadUnits.count);
        if (response.code == 0) {
            NSMutableArray *dataArray = [NSMutableArray array];
            for (MHLumiAlarmVideoDownloadUnit *unit in response.alarmVideoDownloadUnits) {
                MHLumiAlarmVideoGridData *data = [[MHLumiAlarmVideoGridData alloc] init];
                data.duration = unit.videoDuration;
                data.videoUrlIdentifier = unit.fileName;
                data.imageUrlIdentifier = @"1_nnmmbb.jpg";
                NSLog(@"identifier = %@",unit.fileName);
                data.imageDownLoadUrl = @"http://avatar.csdn.net/B/2/8/1_nnmmbb.jpg";
                [dataArray addObject:data];
            }
            weakself.dataSource = [NSMutableArray arrayWithObjects:dataArray, nil];;
            
            completeHandler(nil);
            return ;
        }else{
            NSLog(@"获取失败");
            NSError *unwarpError = [NSError errorWithDomain:@"com.lumiunited" code:989 userInfo:nil];
            completeHandler(unwarpError);
        }
    } failure:^(NSError *error) {
        NSLog(@"获取动作失败");
        completeHandler(error);
    }];
    
//    NSMutableArray *dataArray = [NSMutableArray array];
//    for (NSInteger index = 0; index < 100; index ++) {
//        MHLumiAlarmVideoGridData *data = [[MHLumiAlarmVideoGridData alloc] init];
//        data.videoUrl = @"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";
//        data.imageUrl = @"http://avatar.csdn.net/B/2/8/1_nnmmbb.jpg";
//        [dataArray addObject:data];
//    }
//    
//    @synchronized (self.dataSource) {
//        if (!self.dataSource) {
//            self.dataSource = [NSMutableArray array];
//        }
//        self.dataSource = [NSMutableArray arrayWithObjects:dataArray, nil];
//    }
    
//    completeHandler(nil);
    //数据更新，可能就是一个数组，或者数组的数组
    //如果需要可以做时间记录
    //或者拓展分页也不怕
//    return ;
}

- (MHLumiAlarmVideoGridData *)dataAtIndexPath:(NSIndexPath *)indexPath{
    if ([self numberOfRowInSection:indexPath.section] <= indexPath.row){
        return nil;
    }
    return self.dataSource[indexPath.section][indexPath.row];
}

- (NSUInteger)numberOfSection{
    return self.dataSource.count;
}

- (NSUInteger)numberOfRowInSection:(NSUInteger)section{
    if (section < [self numberOfSection]){
        return self.dataSource[section].count;
    }
    return 0;
}

- (NSString *)headerTitleInSection:(NSUInteger)section{
    return @"header";
}

- (void)fetchVImageOfItemAtIndexPath:(NSIndexPath *)indexPath completeHandler:(void (^)(UIImage *))completeHandler{
    MHLumiAlarmVideoGridData *todoData = [self dataAtIndexPath:indexPath];
    [[SDWebImageManager sharedManager].imageCache queryDiskCacheForKey:todoData.imageUrlIdentifier done:^(UIImage *image, SDImageCacheType cacheType) {
        if (image){
            completeHandler(image);
        }else{
            if (!todoData.imageDownLoadUrl){
                completeHandler(nil);
                return;
            }
            NSURL *url = [NSURL URLWithString:todoData.imageDownLoadUrl];
            
            [[SDWebImageManager sharedManager] downloadImageWithURL:url
                                                            options:SDWebImageRetryFailed
                                                           progress:nil
                                                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                              if (error){
                                                                  completeHandler(nil);
                                                              }else if(image){
                                                                  completeHandler(image);
                                                                  NSString *cacheKey = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
                                                                  [[SDWebImageManager sharedManager].imageCache storeImage:image forKey:todoData.imageUrlIdentifier];
                                                                  [[SDWebImageManager sharedManager].imageCache removeImageForKey:cacheKey];
                                                              }else{
                                                                  completeHandler(nil);
                                                              }
                                                          }];
        }
    }];
}

- (void)fetchVideoDurationAtIndexPath:(NSIndexPath *)indexPath completeHandler:(void (^)(NSTimeInterval))completeHandler{
    MHLumiAlarmVideoGridData *todoData = [self dataAtIndexPath:indexPath];
    if (todoData.duration >= 0){
        completeHandler(todoData.duration);
        return;
    }
    todoData.duration = 0;
    completeHandler(todoData.duration);
//    if (todoData.duration == -2) {
//        completeHandler(0);
//        return;
//    }
//    todoData.duration = -2;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:todoData.videoUrl] options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @YES}];
//        NSTimeInterval duration = CMTimeGetSeconds(urlAsset.duration);
////        AVURLAssetPreferPreciseDurationAndTimingKey
//        dispatch_async(dispatch_get_main_queue(), ^{
//            todoData.duration = duration;
//            completeHandler(duration);
//        });
//    });

}

- (void)fetchvideoUrlAtIndexPath:(NSIndexPath *)indexPath completeHandler:(void (^)(NSString *))completeHandler{
    void(^complete)(NSString *) = ^(NSString *url){
        if(completeHandler){
            completeHandler(url);
        }
    };
    MHLumiAlarmVideoGridData *todoData = [self dataAtIndexPath:indexPath];
    if (todoData.videoDownLoadUrl == nil) {
        todoData.videoDownLoadUrl = @"loading";
        NSLog(@"开始获取视频下载url indexPath = %@",indexPath);
        MHGatewayDownloadUrlRequest *downloadUrlRequest = [[MHGatewayDownloadUrlRequest alloc] init];
        downloadUrlRequest.fileName = todoData.videoUrlIdentifier;
        [[MHNetworkEngine sharedInstance] sendRequest:downloadUrlRequest success:^(id obj) {
            MHGatewayDownloadUrlResponse *downloadUrlResponse = [MHGatewayDownloadUrlResponse responseWithJSONObject:obj];
            NSLog(@"获取下载url回来了 obj = %@",obj);
            todoData.videoDownLoadUrl = downloadUrlResponse.url;
            complete(todoData.videoDownLoadUrl);
        } failure:^(NSError *error) {
            NSLog(@"下载url失败 error = %@",error);
            todoData.videoDownLoadUrl = nil;
            complete(todoData.videoDownLoadUrl);
        }];
    }
    
    if ([todoData.videoDownLoadUrl isEqualToString:@"loading"]){
        return;
    }
    
    if (todoData.videoDownLoadUrl){
        complete(todoData.videoDownLoadUrl);
    }else{
        complete(@"");
    }
}

- (void)fetchthumbnailUrlAtIndexPath:(NSIndexPath *)indexPath completeHandler:(void (^)(NSString *))completeHandler{
    MHLumiAlarmVideoGridData *todoData = [self dataAtIndexPath:indexPath];
    if (todoData.imageDownLoadUrl){
        completeHandler(todoData.imageDownLoadUrl);
    }else{
        completeHandler(@"");
    }
}

- (NSString *)fetchVideoUrlIdentifierAtIndexPath:(NSIndexPath *)indexPath{
    MHLumiAlarmVideoGridData *todoData = [self dataAtIndexPath:indexPath];
    return todoData.videoUrlIdentifier;
}

@end
