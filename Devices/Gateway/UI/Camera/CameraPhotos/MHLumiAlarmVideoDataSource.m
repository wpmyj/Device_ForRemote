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


@interface MHLumiAlarmVideoDataSource()<MHLumiPhotoGridDataSourceProtocol>

- (NSUInteger)numberOfSection;
- (NSUInteger)numberOfRowInSection:(NSUInteger)section;
- (NSString *)headerTitleInSection:(NSUInteger)section;
- (void)fetchVImageOfItemAtIndexPath:(NSIndexPath *)indexPath completeHandler:(void(^)(UIImage *image)) completeHandler;
- (void)fetchVideoDurationAtIndexPath:(NSIndexPath *)indexPath completeHandler:(void(^)(NSTimeInterval duration)) completeHandler;
- (void)fetchvideoUrlAtIndexPath:(NSIndexPath *)indexPath completeHandler:(void(^)(NSString *videoUrl)) completeHandler;
- (void)fetchthumbnailUrlAtIndexPath:(NSIndexPath *)indexPath completeHandler:(void(^)(NSString *thumbnailUrl)) completeHandler;

@property (nonatomic, assign) NSInteger num;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<MHLumiAlarmVideoGridData*>*> *dataSource;
@end

@implementation MHLumiAlarmVideoDataSource
- (instancetype)initWithReques:(MHLumiAlarmVideoRequest *)request{
    self = [super init];
    if (self) {
        _request = request;
        _num = 10;
        [SDWebImageDownloader.sharedDownloader setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
        [self fetchDataWithReques:request];
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
    
//    __weak typeof(self) weakself = self;
//    [[MHNetworkEngine sharedInstance] sendRequest:request success:^(id obj) {
//        MHLumiAlarmVideoResponse *response = [MHLumiAlarmVideoResponse responseWithJSONObject:obj];
//        if (response.code == 0) {
//            NSMutableArray *dataArray = [NSMutableArray array];
//            for (NSInteger index = 0; index < 20; index ++) {
//                MHLumiAlarmVideoGridData *data = [[MHLumiAlarmVideoGridData alloc] init];
//                data.videoUrl = @"http://192.168.1.135/longVideo.mp4";
//                data.imageUrl = @"http://avatar.csdn.net/B/2/8/1_nnmmbb.jpg";
//                [dataArray addObject:data];
//            }
//            weakself.dataSource = [NSMutableArray arrayWithArray:dataArray];
//            
//            completeHandler(nil);
//            //数据更新，可能就是一个数组，或者数组的数组
//            //如果需要可以做时间记录
//            //或者拓展分页也不怕
//            return ;
//        }
//        NSError *unwarpError = [NSError errorWithDomain:@"com.lumiunited" code:989 userInfo:nil];
//        completeHandler(unwarpError);
//    } failure:^(NSError *error) {
//        completeHandler(error);
//    }];
    
    NSMutableArray *dataArray = [NSMutableArray array];
    for (NSInteger index = 0; index < 100; index ++) {
        MHLumiAlarmVideoGridData *data = [[MHLumiAlarmVideoGridData alloc] init];
        data.videoUrl = @"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";
        data.imageUrl = @"http://avatar.csdn.net/B/2/8/1_nnmmbb.jpg";
        [dataArray addObject:data];
    }
    
    @synchronized (self.dataSource) {
        if (!self.dataSource) {
            self.dataSource = [NSMutableArray array];
        }
        self.dataSource = [NSMutableArray arrayWithObjects:dataArray, nil];
    }
    
    completeHandler(nil);
    //数据更新，可能就是一个数组，或者数组的数组
    //如果需要可以做时间记录
    //或者拓展分页也不怕
    return ;
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
    if (!todoData.imageUrl){
        completeHandler(nil);
        return;
    }
    NSURL *url = [NSURL URLWithString:todoData.imageUrl];
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:url
                                                    options:SDWebImageRetryFailed
                                                   progress:nil
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                      if (error){
                                                          completeHandler(nil);
                                                      }else if(image){
//                                                          UIImage *image = [UIImage imageNamed:@"about_icon_app@3x"];
                                                          completeHandler(image);
                                                      }else{
                                                          completeHandler(nil);
                                                      }
    }];

}

- (void)fetchVideoDurationAtIndexPath:(NSIndexPath *)indexPath completeHandler:(void (^)(NSTimeInterval))completeHandler{
    MHLumiAlarmVideoGridData *todoData = [self dataAtIndexPath:indexPath];
    if (!todoData.videoUrl){
        completeHandler(0);
        return;
    }
    if (todoData.duration >= 0){
        completeHandler(todoData.duration);
        return;
    }
    todoData.duration = 62;
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
    MHLumiAlarmVideoGridData *todoData = [self dataAtIndexPath:indexPath];
    if (todoData.videoUrl){
        completeHandler(todoData.videoUrl);
    }else{
        completeHandler(@"");
    }
}

- (void)fetchthumbnailUrlAtIndexPath:(NSIndexPath *)indexPath completeHandler:(void (^)(NSString *))completeHandler{
    MHLumiAlarmVideoGridData *todoData = [self dataAtIndexPath:indexPath];
    if (todoData.imageUrl){
        completeHandler(todoData.imageUrl);
    }else{
        completeHandler(@"");
    }
}


@end
