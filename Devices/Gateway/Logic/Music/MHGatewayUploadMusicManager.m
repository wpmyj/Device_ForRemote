//
//  MHGatewayRecordManager.m
//  MiHome
//
//  Created by Lynn on 10/27/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayUploadMusicManager.h"
#import <AFNetworking/AFNetworking.h>
#import "MHGatewayUserDefineDataRequest.h"
#import "MHGatewayUserDefineDataResponse.h"
#import "MHGatewayUploadUrlRequest.h"
#import "MHGatewayUploadUrlResponse.h"
#import "MHGatewayDownloadUrlRequest.h"
#import "MHGatewayDownloadUrlResponse.h"
#import "MHGatewaySetUserDataRequest.h"
#import "MHGatewaySetUserDataResponse.h"

#define Gateway_UserData_Key @"lumi_gateway_usermusic_"

@interface MHGatewayUploadMusicManager ()

@property (nonatomic,strong) NSProgress *progress;

@end

static void *ProgressObserverContext = &ProgressObserverContext;

@implementation MHGatewayUploadMusicManager

-(instancetype)initWithDevice:(MHDeviceGateway *)device{
    self = [super init];
    if (self) {
        self.device = device;
    }
    return self;
}

/**
 *  根据命名规则获取上传文件名
 *  {年4位}/{月2位}/{日2位}/{用户id}/{设备id}_{时2位}{分2位}{秒2位}{毫秒3位}.后缀
 *  2015/08/06/75240291/11198765_181352700.mp3 是这个文件的全名
 */

#pragma mark - 网关下载音乐列表配置信息
-(void)saveGatwayDownloadList:(id)json
{
    NSString *userid = [MHPassportManager sharedSingleton].currentAccount.userId;
    NSData *archiveSceneTplData = [NSKeyedArchiver archivedDataWithRootObject:json];
    [[NSUserDefaults standardUserDefaults] setObject:archiveSceneTplData forKey:[NSString stringWithFormat:@"%@_%@_%@",GatewayDownloadListKey,self.device.did,userid]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(id)restoreGatwayDownloadList
{
    NSString *userid = [MHPassportManager sharedSingleton].currentAccount.userId;
    NSData *myEncodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@_%@",GatewayDownloadListKey,self.device.did,userid]];
    if(myEncodedObject) return [NSKeyedUnarchiver unarchiveObjectWithData:myEncodedObject];
    else return nil;
}

//网关下载音乐列表
-(void)fetchGatewayDownloadListWithSuccess:(void (^)(id))success andfailure:(void (^)(NSError *))failure
{
    MHGatewayUserDefineDataRequest *req = [[MHGatewayUserDefineDataRequest alloc] init];
    req.keyString = [NSString stringWithFormat:@"%@%@",GatewayDownloadListKey,self.device.did];

    __weak typeof(self) weakSelf = self;
    
    [[MHNetworkEngine sharedInstance] sendRequest:req success:^(id json) {
        MHGatewayUserDefineDataResponse *rsp = [MHGatewayUserDefineDataResponse responseWithJSONObject:json andKeystring:req.keyString];
        [weakSelf saveGatwayDownloadList:rsp.valueList];
        weakSelf.device.downloadMusicList = rsp.valueList;
        
        if(success)success(rsp.valueList);
        
    } failure:^(NSError *error) {
        if(failure)failure(error);
    }];
}

-(void)setGatewayDownloadListWithSuccess:(void (^)(id))success andfailure:(void (^)(NSError *))failure Value:(id)value
{
    MHGatewaySetUserDataRequest *rsp = [[MHGatewaySetUserDataRequest alloc] init];
    rsp.keyString = [NSString stringWithFormat:@"%@%@",GatewayDownloadListKey,self.device.did],
    rsp.value = value;
    
    __weak typeof(self) weakSelf = self;
    [[MHNetworkEngine sharedInstance] sendRequest:rsp success:^(id obj){
        MHGatewaySetUserDataResponse *req = [MHGatewaySetUserDataResponse responseWithJSONObject:obj];
        if(success) success(req.result);

        //成功后直接将刚设置的数据缓存
        [weakSelf saveGatwayDownloadList:value];
        weakSelf.device.downloadMusicList = value;
        
    } failure:^(NSError *error){
        if(failure) failure(error);
    }];
}

#pragma mark - 原请求
/**
 *  A - 读取配置文件，根据命名规则，设置mid，name ...
 */
-(void)fetchUserDefineDataWithPageIndex:(int)pageIndex success:(void (^)(id))success andfailure:(void (^)(NSError *))failure
{
    MHGatewayUserDefineDataRequest *req = [[MHGatewayUserDefineDataRequest alloc] init];
    req.keyString = [NSString stringWithFormat:@"%@%d",Gateway_UserData_Key,pageIndex];
    NSLog(@"read pdata key = %@",req.keyString);
    [[MHNetworkEngine sharedInstance] sendRequest:req success:^(id json) {
        MHGatewayUserDefineDataResponse *rsp = [MHGatewayUserDefineDataResponse responseWithJSONObject:json andKeystring:req.keyString];
        if(success)success(rsp.valueList);
        
    } failure:^(NSError *error) {
        if(failure)failure(error);
    }];
}

/**
 *  B - 获取文件上传的url
 *  http://api.io.mi.com/app/home/genpresignedurl
 */
-(void)fetchUserDefineUploadURLWithSuccess:(void (^)(id))success andfailure:(void (^)(NSError *))failure Suffix:(NSString *)suffix
{
    MHGatewayUploadUrlRequest *req = [[MHGatewayUploadUrlRequest alloc] init];
    req.suffix = suffix;
    req.device = self.device;
    [[MHNetworkEngine sharedInstance] sendRequest:req success:^(id json){
        MHGatewayUploadUrlResponse *rsp = [MHGatewayUploadUrlResponse responseWithJSONObject:json andSuffix:suffix];
        NSDictionary *dic = @{@"url":rsp.url,@"filename":rsp.uploadFileName};
        if(success) success(dic);
        
    } failure:^(NSError *error){
        if(failure) failure(error);
        
    }];
}

/**
 *  C - 上传文件音频文件,PUT
 *  sufix @"aac" - aac; @"mpeg" - mp3;
 */
-(void)uploadFileWithSuccess:(void (^)(id))success andfailure:(void (^)(NSError *))failure URL:(NSString *)url Suffix:(NSString *)suffix FilePath:(NSURL *)filepath FileName:(NSString *)fileName
{
    NSURL *fileFormerPath = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",filepath.absoluteString]];
    NSString *name = [fileName substringToIndex:[fileName rangeOfString:@"."].location];
    NSString *mimeType = [NSString stringWithFormat:@"audio/%@",suffix];
    
    NSMutableURLRequest *request =
    [[AFHTTPRequestSerializer serializer]
     multipartFormRequestWithMethod:@"PUT" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:fileFormerPath name:name fileName:fileName mimeType:mimeType error:nil];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    NSProgress *progress = nil;
    //设置content－type为空,xiaomi要求
    AFHTTPResponseSerializer *responseSerial = [AFHTTPResponseSerializer serializer];
    responseSerial.acceptableContentTypes = nil;
    manager.responseSerializer = responseSerial;

    [request setValue:@"" forHTTPHeaderField:@"Content-Type"];

    __weak typeof(self) weaSelf = self;
    NSURLSessionUploadTask *uploadTask =
    [manager uploadTaskWithStreamedRequest:request
                                  progress:&progress
                         completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                            if (error) {
                                NSLog(@"Error: %@", error);
                                if(failure)failure(error);
                            }
                            else{
                                NSLog(@"%@ %@", response, responseObject);
                                if(success) success(responseObject);
                            }
                             
                            [weaSelf.progress removeObserver:weaSelf
                                                  forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                                                     context:ProgressObserverContext];
    }];
    [uploadTask resume];
    
    //监控下载进度
    self.progress = [manager uploadProgressForTask:uploadTask];
    [self.progress addObserver:self
                    forKeyPath:@"fractionCompleted"
                       options:NSKeyValueObservingOptionInitial
                       context:ProgressObserverContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if (context == ProgressObserverContext){
        NSProgress *progress = object;
        NSLog(@"upload at %f", progress.fractionCompleted);
        if(self.uploadProgressBlock)self.uploadProgressBlock(progress.fractionCompleted);
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object
                               change:change context:context];
    } 
}

/**
 *  D - 设置配置文件
 *  http://api.io.mi.com/app/user/setpdata
 */
-(void)setUserDataWithSuccess:(void (^)(id))success andfailure:(void (^)(NSError *))failure PageIndex:(int)pageIndex Value:(id)value
{
    MHGatewaySetUserDataRequest *rsp = [[MHGatewaySetUserDataRequest alloc] init];
    rsp.keyString = [NSString stringWithFormat:@"%@%d",Gateway_UserData_Key,pageIndex];
    NSLog(@"set pdata key = %@",rsp.keyString);
    rsp.value = value;
    
    [[MHNetworkEngine sharedInstance] sendRequest:rsp success:^(id obj){
        MHGatewaySetUserDataResponse *rsp = [MHGatewaySetUserDataResponse responseWithJSONObject:obj];
        if(success) success(rsp.result);
        
    } failure:^(NSError *error){
        if(failure) failure(error);
    }];
}

/**
 *  E - 获取下载文件URL
 *  http://api.io.mi.com/app/home/getfileurl
 */
-(void)fetchUserMusicURLWithSuccess:(void (^)(id))success andfailure:(void (^)(NSError *))failure Filename:(NSString *)filename
{
    MHGatewayDownloadUrlRequest *req = [[MHGatewayDownloadUrlRequest alloc] init];
    req.fileName = filename;
    [[MHNetworkEngine sharedInstance] sendRequest:req success:^(id obj){
        MHGatewayDownloadUrlResponse *rsp = [MHGatewayDownloadUrlResponse responseWithJSONObject:obj];
        if(success) success(rsp.url);
        
    } failure:^(NSError *error){
        if(failure) failure(error);
    }];
}

@end
