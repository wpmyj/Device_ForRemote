//
//  MHLumiCameraMediaDataManager.m
//  Lumi_demo_OC
//
//  Created by LM21Mac002 on 2016/10/25.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import "MHLumiCameraMediaDataManager.h"
#import <Photos/Photos.h>

@interface MHLumiCameraMediaDataManager()
@property (nonatomic, strong) PHAssetCollection *assetCollection;
@end

@implementation MHLumiCameraMediaDataManager
static NSString *kLumiCameraAlbumTitle = @"绿米摄像头";
- (instancetype)initWithAssetCollection:(PHAssetCollection *)assetCollection{
    self = [super init];
    if (self) {
        _assetCollection = assetCollection;
    }
    
    return self;
}

- (NSMutableArray<NSMutableArray<PHAsset *> *> *)fetchDataWithType:(MHLumiCameraMediaDataType)type{
    switch (type) {
        case MHLumiCameraMediaDataTypeAll:
            return [self fetchAllMediaData];
            break;
        case MHLumiCameraMediaDataTypePhotoWithoutAlarm:
            return [self fetchPhotoWithoutAlarm];
            break;
        case MHLumiCameraMediaDataTypeVideoWithoutAlarm:
            return [self fetchVideoWithoutAlarm];
            break;
        case MHLumiCameraMediaDataTypeAlarm:
            return [NSMutableArray array];
            break;
        default:
            break;
    }
    return [NSMutableArray array];
}

- (UIImage *)lastCreationImageWithSize:(CGSize)size{
    return [self lastCreationAssetIncludeImage:YES includeVideoThumbnail:NO withSize:size];
}

- (UIImage *)lastCreationVideoThumbnailWithSize:(CGSize)size{
    return [self lastCreationAssetIncludeImage:NO includeVideoThumbnail:YES withSize:size];
}

- (UIImage *)lastCreationImageOrVideoThumbnailWithSize:(CGSize)size{
    return [self lastCreationAssetIncludeImage:YES includeVideoThumbnail:YES withSize:size];
}

- (UIImage *)lastCreationAssetIncludeImage:(BOOL) isIncludeImage includeVideoThumbnail:(BOOL) isincludeVideoThumbnail withSize:(CGSize)size{
    if (!isIncludeImage && !isincludeVideoThumbnail){
        return nil;
    }
    PHFetchOptions *opition = [[PHFetchOptions alloc] init];
    opition.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO]];
    PHFetchResult<PHAsset *> * todoFetchResult = [PHAsset fetchAssetsInAssetCollection:self.assetCollection options:opition];
    __block PHAsset *todoAsset = nil;
    [todoFetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        if (asset.mediaType == PHAssetMediaTypeImage && isIncludeImage){
            todoAsset = asset;
            *stop = YES;
        }
        
        if (asset.mediaType == PHAssetMediaTypeImage && isincludeVideoThumbnail){
            todoAsset = asset;
            *stop = YES;
        }
    }];
    if (!todoAsset){
        return nil;
    }
    PHImageRequestOptions *requestOption = [[PHImageRequestOptions alloc] init];
    requestOption.synchronous = YES;
    __block UIImage *todoImage = nil;
    [[PHImageManager defaultManager] requestImageForAsset:todoAsset targetSize:size contentMode:PHImageContentModeAspectFit options:requestOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        todoImage = result;
    }];
    return todoImage;
}

- (NSMutableArray<NSMutableArray<PHAsset *> *> *)fetchPhotoWithoutAlarm{
    PHFetchOptions *opition = [[PHFetchOptions alloc] init];
    opition.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO]];
    PHFetchResult<PHAsset *> * todoFetchResult = [PHAsset fetchAssetsInAssetCollection:self.assetCollection options:opition];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay;
    __block NSMutableArray<NSMutableArray<PHAsset *> *> *todoDateSource = [NSMutableArray array];
    __block NSDateComponents *currentDateComponents = nil;
    __block NSMutableArray<PHAsset *> *currentArray = [NSMutableArray array];
    [todoFetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        NSDateComponents *dateComponents  = [calendar components:unitFlags fromDate:asset.creationDate];
        if (asset.mediaType == PHAssetMediaTypeImage){
            if (currentDateComponents == nil){
                [currentArray addObject:obj];
            }else if (dateComponents.day == currentDateComponents.day
                      && dateComponents.month == currentDateComponents.month
                      && dateComponents.year == currentDateComponents.year){
                [currentArray addObject:obj];
            }else{
                [todoDateSource addObject:currentArray];
                currentArray = [NSMutableArray array];
                [currentArray addObject:obj];
            }
            currentDateComponents = dateComponents;
        }
        if (idx == todoFetchResult.count-1 && currentArray.count > 0){
            [todoDateSource addObject:currentArray];
        }
        //        NSLog(@"idx = %ld,creatDate = %@",idx,asset.creationDate);
    }];
    NSLog(@"%s, count = %ld",__func__, todoDateSource.count);
    return todoDateSource;
}

- (NSMutableArray<NSMutableArray<PHAsset *> *> *)fetchVideoWithoutAlarm{
    PHFetchOptions *opition = [[PHFetchOptions alloc] init];
    opition.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO]];
    PHFetchResult<PHAsset *> * todoFetchResult = [PHAsset fetchAssetsInAssetCollection:self.assetCollection options:opition];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay;
    __block NSMutableArray<NSMutableArray<PHAsset *> *> *todoDateSource = [NSMutableArray array];
    __block NSDateComponents *currentDateComponents = nil;
    __block NSMutableArray<PHAsset *> *currentArray = [NSMutableArray array];
    [todoFetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        NSDateComponents *dateComponents  = [calendar components:unitFlags fromDate:asset.creationDate];
        if (asset.mediaType == PHAssetMediaTypeVideo){
            if (currentDateComponents == nil){
                [currentArray addObject:obj];
            }else if (dateComponents.day == currentDateComponents.day
                      && dateComponents.month == currentDateComponents.month
                      && dateComponents.year == currentDateComponents.year){
                [currentArray addObject:obj];
            }else{
                [todoDateSource addObject:currentArray];
                currentArray = [NSMutableArray array];
                [currentArray addObject:obj];
            }
            currentDateComponents = dateComponents;
        }
        if (idx == todoFetchResult.count-1 && currentArray.count > 0){
            [todoDateSource addObject:currentArray];
        }
        //        NSLog(@"idx = %ld,creatDate = %@",idx,asset.creationDate);
    }];
    NSLog(@"%s, count = %ld",__func__, todoDateSource.count);
    return todoDateSource;
}

- (NSMutableArray<NSMutableArray<PHAsset *> *> *)fetchAllMediaData{
    PHFetchOptions *opiton = [[PHFetchOptions alloc] init];
    opiton.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO]];
    PHFetchResult<PHAsset *> * todoFetchResult = [PHAsset fetchAssetsInAssetCollection:self.assetCollection options:opiton];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay;
    __block NSMutableArray<NSMutableArray<PHAsset *> *> *todoDateSource = [NSMutableArray array];
    __block NSDateComponents *currentDateComponents = nil;
    __block NSMutableArray<PHAsset *> *currentArray = [NSMutableArray array];
    [todoFetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        NSDateComponents *dateComponents  = [calendar components:unitFlags fromDate:asset.creationDate];
        if (currentDateComponents == nil){
            [currentArray addObject:obj];
        }else if (dateComponents.day == currentDateComponents.day
                  && dateComponents.month == currentDateComponents.month
                  && dateComponents.year == currentDateComponents.year){
            [currentArray addObject:obj];
        }else{
            [todoDateSource addObject:currentArray];
            currentArray = [NSMutableArray array];
            [currentArray addObject:obj];
        }
        if (idx == todoFetchResult.count-1){
            [todoDateSource addObject:currentArray];
        }
        currentDateComponents = dateComponents;
        //        NSLog(@"idx = %ld,creatDate = %@",idx,asset.creationDate);
    }];
    NSLog(@"%s, count = %ld",__func__, todoDateSource.count);
    return todoDateSource;
}

+ (PHAssetCollection *)lumiCameraAssetCollection{
    static int count = 2;
    PHFetchResult *topLevelUserCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    __block PHAssetCollection *assetCollection = nil;
    [topLevelUserCollections enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetCollection * todoAssetCollection = (PHAssetCollection *)obj;
        if ([todoAssetCollection.localizedTitle isEqualToString:kLumiCameraAlbumTitle]){
            NSLog(@"%@",todoAssetCollection.localizedTitle);
            assetCollection = todoAssetCollection;
            *stop = YES;
        }
    }];
    if (assetCollection == nil){
        NSError *error = nil;
        __block NSString *todoIdentifier = nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            todoIdentifier = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:kLumiCameraAlbumTitle].placeholderForCreatedAssetCollection.localIdentifier;
        } error:&error];
        if (todoIdentifier){
            assetCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[todoIdentifier] options:nil].firstObject;
        }
    }
    if (!assetCollection && count >= 0){
        count --;
        return [MHLumiCameraMediaDataManager lumiCameraAssetCollection];
    }
    return assetCollection;
}

+ (void)saveImage:(UIImage *)image toAssetColletion:(PHAssetCollection *)assetColletion andError:(NSError *__autoreleasing *)error{
    __block NSString *createdAssetId = nil;
    // 同步方法,直接创建图片,代码执行完,图片没创建完,所以使用占位ID (createdAssetId)
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:error];
    
    // 在保存完毕后取出图片
    PHFetchResult<PHAsset *> *createdAssets = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetColletion];
        // 自定义相册封面默认保存第一张图,所以使用以下方法把最新保存照片设为封面
        [request insertAssets:createdAssets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:error];
}

+ (void)saveVideoWithPath:(NSString *)path
        toAssetCollection:(PHAssetCollection *)assetCollection
                 andError:(NSError *__autoreleasing *)error{
    __block NSString *createdAssetId = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        NSURL *url = [NSURL URLWithString:path];
        PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
        options.originalFilename = path.stringByDeletingPathExtension.lastPathComponent;
        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
        [request addResourceWithType:PHAssetResourceTypeVideo fileURL:url options:options];
        createdAssetId = request.placeholderForCreatedAsset.localIdentifier;
//        createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url].placeholderForCreatedAsset.localIdentifier;
    } error:error];
    
    // 在保存完毕后取出视频
    PHFetchResult<PHAsset *> *createdAssets = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        // 自定义相册封面默认保存第一张图,所以使用以下方法把最新保存照片设为封面
        [request insertAssets:createdAssets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:error];
}

- (void)saveImage:(UIImage *)image andError:(NSError *__autoreleasing *)error{
    [MHLumiCameraMediaDataManager saveImage:image toAssetColletion:self.assetCollection andError:error];
}
@end
