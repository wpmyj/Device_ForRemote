//
//  MHGwMusicInvoker.m
//  MiHome
//
//  Created by Lynn on 10/29/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGwMusicInvoker.h"
#import "MHMusicTipsView.h"
#import "MHDeviceGatewaySensorLoopData.h"

@interface MHGwMusicInvoker ()

@property (nonatomic,strong) MHGatewayUploadMusicManager *manager;
@property (nonatomic,strong) MHDeviceGateway *device;

//文件相关信息
@property (nonatomic,strong) NSURL *filePath;
@property (nonatomic,strong) NSString *userfileName;
@property (nonatomic,assign) int userfileMid;
@property (nonatomic,assign) CGFloat fileduration;

//用户配置信息
@property (nonatomic,assign) int total;
@property (nonatomic,assign) int size;
@property (nonatomic,assign) int keyForPageIndex;
@property (nonatomic,strong) NSMutableArray *valueList;
@property (nonatomic,strong) NSMutableArray *firstPageValueList;
@property (nonatomic,strong) NSDictionary *pageInfo;

//上传文件信息
@property (nonatomic,strong) NSString *uploadUrl;
@property (nonatomic,strong) NSString *uploadFileName; //上传需要按照对方的要求文件名格式

//下载文件信息
@property (nonatomic,strong) NSString *downloadUrl;
@property (nonatomic,strong) NSString *grouptype;

//网关下载数据,timer
@property (nonatomic,assign) CGFloat deviceProgress;
@property (nonatomic,strong) void (^gwDownloadSuccess)();
@property (nonatomic,assign) BOOL shouldKeepRunning;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) int runCount;

@end

@implementation MHGwMusicInvoker

-(instancetype)initWithDevice:(MHDeviceGateway *)device{
    self = [super init];
    if (self) {
        self.manager = [[MHGatewayUploadMusicManager alloc] initWithDevice:device];
        self.device = device;
        [self deviceDownloadSuccessDefine];
    }
    return self;
}

- (void)userClickUpload:(NSURL *)filepath
     userDefineFileName:(NSString *)userfileName
           fileduration:(CGFloat)fileduration
              groupType:(NSString *)grouptype {
    XM_WS(weakself);
    self.filePath = filepath;
    self.userfileName = userfileName;
    self.fileduration = fileduration;
    self.grouptype = grouptype;
    
//    [self.manager setUserDataWithSuccess:^(id obj){
//                    NSLog(@"%@",obj);
//    } andfailure:^(NSError *error){
//        NSLog(@"%@",error);
//    } PageIndex:1 Value:[NSMutableArray array]];
    
    //0,先下载网关当前下载音乐列表的配置信息
    [self readGatwayDownloadListWithSuccess:nil andFailure:nil];
    
    //1,获取成功，获取上传URL
    __block void (^uploadURLSuccess)(id obj);
    [weakself fetchUploadURLWithSuccess:^(id obj){
        weakself.downloadProgress(0.01);
        uploadURLSuccess(obj);
    }
    andFailure:^(NSError *v){
        [[MHMusicTipsView shareInstance] hide];
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed",@"plugin_gateway",nil) duration:1.5f modal:YES];
    } Suffix:@"aac"];
   
    //2,进行上传文件操作
    __block void (^uploadFileSuccess)(id obj);
    uploadURLSuccess = ^(id obj){
        
        [weakself.manager uploadFileWithSuccess:^(id obj){
            uploadFileSuccess(obj);
            
        } andfailure:^(NSError *error){
            [[MHMusicTipsView shareInstance] hide];
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.upload.failed",@"plugin_gateway",nil) duration:1.5f modal:YES];
            
        } URL:weakself.uploadUrl Suffix:@"aac" FilePath:weakself.filePath FileName:weakself.uploadFileName];
    };

    //判断上传进度
    self.manager.uploadProgressBlock = ^(CGFloat progress){
        progress = [[NSString stringWithFormat:@"%.2f",progress] doubleValue];
        NSLog(@"upload at %f", progress);
        weakself.downloadProgress(progress * 0.4 + 0.01);
    };
    
    //3,上传成功，获取用户音乐配置数据，读取缓存（在网关设置页面进行下载缓存）
    __block void (^readPdataSuccess)();
    uploadFileSuccess = ^(id obj){
        weakself.downloadProgress(0.41);

        [self readPdataInvocationWithSuccess:^(BOOL v){
            if(readPdataSuccess)readPdataSuccess();
            
        } andFailure:^(NSError *error){
            [[MHMusicTipsView shareInstance] hide];
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed",@"plugin_gateway",nil) duration:1.5f modal:YES];
        }];
    };
    
    //4,读取配置成功，设置配置文件
    __block void (^setPdataSuccess)(id obj);
    readPdataSuccess = ^(){
        weakself.downloadProgress(0.44);
        
        //设置配置文件
        [weakself setUserPdataPageIndex:weakself.keyForPageIndex withSuccess:^(id obj){
            setPdataSuccess(obj);
            
        } andFailure:^(NSError *error){
            [[MHMusicTipsView shareInstance] hide];
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed",@"plugin_gateway",nil) duration:1.5f modal:YES];
        }];
    };

    //5,获取下载URL
    __block void (^fetchDownloadUrlSuccess)(id obj);
    setPdataSuccess = ^(id obj){
        weakself.downloadProgress(0.47);
        
        [weakself fetchDownloadURL:weakself.uploadFileName withSuccess:^(id obj){
            weakself.downloadUrl = obj;
            fetchDownloadUrlSuccess(obj);
            
        } andFailure:^(NSError *error){
            
            [[MHMusicTipsView shareInstance] hide];
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed",@"plugin_gateway",nil) duration:1.5f modal:YES];
        }];
    };
    
    //6,下发网关，播放
    fetchDownloadUrlSuccess = ^(id v){
        weakself.downloadProgress(0.57);

        //下载成功，设置downloadmusiclist
        NSMutableArray *downloadList = [NSMutableArray arrayWithArray:weakself.device.downloadMusicList];
        NSDictionary *obj = @{ @"mid"           :   @(weakself.userfileMid) ,
                               @"time"          :   @(weakself.fileduration),
                               @"alias_name"    :   weakself.userfileName
                               };
        [downloadList addObject:obj];
        [weakself setGatwayDownloadListWithValue:[downloadList mutableCopy] Success:nil andFailure:nil];

        NSString *newURL = [weakself replaceURL:weakself.downloadUrl];
        [weakself.device downloadUserMusicWithMid:[NSString stringWithFormat:@"%d",weakself.userfileMid]
                                               url:newURL
                                           success:^(id v){
                                               if(!weakself.timer){
                                                   [weakself runTimer];
                                               }
                                           }
                                           failure:^(NSError *error){
                                               if(error.code == -5019){
                                                   [[MHMusicTipsView shareInstance] hide];
                                                   [[MHTipsView shareInstance]  showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.download.oversize", @"plugin_gateway", nil) duration:1.5f modal:YES];
                                               }
                                               else{
                                                   if(!weakself.timer){
                                                       [weakself runTimer];
                                                   }
                                               }
                                           }];
    };
    
}

//如果下载成功了，执行方法定义
- (void)deviceDownloadSuccessDefine {
    XM_WS(weakself);
    
    //7，下载成功，设置组别
    __block void (^gwSetGroupSuccess)(id obj);
    self.gwDownloadSuccess = ^(){
        
        weakself.downloadProgress(0.80);
        
        int type = 0;
        NSInteger vol = 0;
        if([weakself.grouptype isEqualToString:DoorBell_RecordFile]){
            type = 1;
            vol = weakself.device.doorbell_volume;
        }
        else if([weakself.grouptype isEqualToString:Alarm_RecordFile]){
            type = 0;
            vol = weakself.device.alarming_volume;
        }
        else if([weakself.grouptype isEqualToString:AlarmClock_RecordFile]){
            type = 2;
            vol = weakself.device.gateway_volume;
        }
        
        //设置 mid,grouptype
        [weakself.device setDefaultSoundWithGroup:type
                                          musicId:[NSString stringWithFormat:@"%d",weakself.userfileMid]
                                          Success:^(id v){
                                              [weakself.device playMusicWithMid:[NSString stringWithFormat:@"%d",weakself.userfileMid]
                                                                         volume:vol
                                                                        Success:nil
                                                                        failure:nil];
                                              
                                              gwSetGroupSuccess(nil);
                                          } failure:^(NSError *error){
                                              gwSetGroupSuccess(nil);
                                          }];
    };
    
    //8,删除本地文件
    gwSetGroupSuccess = ^(id v){
        weakself.downloadProgress(0.99);
        
        //成功，返回
        [[MHMusicTipsView shareInstance] hide];
        
        NSDictionary *fileinfo = @{@"filename":self.userfileName,@"mid":@(self.userfileMid),@"time":@(self.fileduration)};
        if(weakself.downloadSuccess)weakself.downloadSuccess(fileinfo);
    };
}

#pragma mark - 操作函数
- (NSString *)replaceURL:(NSString *)oldURLString {
    NSString *tmpHeader = @"http://cdn.fds.api.xiaomi.com";
    
    NSString *newURL = @"";
    newURL = [oldURLString stringByReplacingOccurrencesOfString:@"https://cdns.fds.api.xiaomi.com" withString:tmpHeader];
    newURL = [oldURLString stringByReplacingOccurrencesOfString:@"https://cdn.fds-ssl.api.xiaomi.com" withString:tmpHeader];
    
    return newURL;
}

- (void)runTimer {
    self.shouldKeepRunning = YES;

    XM_WS(weakself);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        weakself.timer = [NSTimer timerWithTimeInterval:0.5f target:self selector:@selector(fetchDownloadProgress) userInfo:nil repeats:YES];
        [weakself.timer fire];
        weakself.runCount = 1;
        
        NSRunLoop *currentRL = [NSRunLoop currentRunLoop];
        [currentRL addTimer:weakself.timer forMode:NSDefaultRunLoopMode];
        while (weakself.shouldKeepRunning && [currentRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    });
}

- (void)stopRunTimer {
    [_timer invalidate];
    _timer = nil;
    self.shouldKeepRunning = NO;
}

- (void)fetchDownloadProgress {
    NSLog(@"run");
    XM_WS(weakself);
    [self.device getDownloadMusicProgressWithSuccess:^(id obj) {
        weakself.deviceProgress = [obj integerValue];
        if (weakself.deviceProgress >= 1){
            weakself.gwDownloadSuccess();
            [weakself stopRunTimer];
        }
        else{
            weakself.downloadProgress(0.57 + weakself.deviceProgress * 0.23);
        }
        
    } failure:^(NSError *error) {
        if(error.code == -10009){
            [[MHMusicTipsView shareInstance] hide];
            [[MHTipsView shareInstance]  showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.download.oversize", @"plugin_gateway", nil) duration:1.5f modal:YES];
            [weakself stopRunTimer];
        }
        else if (error.code == -3){
            //如果是这种错误，继续查询。最多查10次，大概5s。
            weakself.runCount ++ ;
            if(weakself.runCount > 10){
                [[MHMusicTipsView shareInstance] hide];
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.timeout",@"plugin_gateway",nil) duration:1.5f modal:YES];
                [weakself stopRunTimer];
            }
        }
        else {
            [[MHMusicTipsView shareInstance] hide];
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed",@"plugin_gateway",nil) duration:1.5f modal:YES];
            [weakself stopRunTimer];
        }
        
    }];
}

- (void)dealloc {
    [self stopRunTimer];
}

//读Pdata
-(void)readPdataInvocationWithSuccess:(void (^)(BOOL))success andFailure:(void (^)(NSError *))failure
{
    __weak typeof(self) weakSelf = self;
    //首先读取第一页，获取pageinfo，计算现在应该去取第几页的值
    [self.manager fetchUserDefineDataWithPageIndex:1 success:^(id obj){
        if ([[obj valueForKey:@"result"] valueForKey:@"value"] && [[[obj valueForKey:@"result"] valueForKey:@"value"] count]) {
            //计算应该去第几页取值
            weakSelf.pageInfo = [obj lastObject];
            weakSelf.total = [[weakSelf.pageInfo valueForKey:@"total"] intValue];
            weakSelf.size = [[weakSelf.pageInfo valueForKey:@"size"] intValue];
            weakSelf.userfileMid = [[weakSelf.pageInfo valueForKey:@"currentmax"] intValue] + 1;
            weakSelf.firstPageValueList = [NSMutableArray arrayWithArray:[obj subarrayWithRange:NSMakeRange(0, [obj count] - 1)]];
            
            if(weakSelf.total < weakSelf.size){ //第一页就OK
                weakSelf.keyForPageIndex = 1;
                weakSelf.valueList = [NSMutableArray arrayWithArray:[obj subarrayWithRange:NSMakeRange(0, [obj count] - 1)]];
                if(success) success(YES);
            }
            else{ //获得页数
                weakSelf.keyForPageIndex = weakSelf.total / weakSelf.size + 1;
                [weakSelf.manager fetchUserDefineDataWithPageIndex:weakSelf.keyForPageIndex success:^(id valuelist){
                    if([valuelist count])
                        weakSelf.valueList = [NSMutableArray arrayWithArray:[valuelist subarrayWithRange:NSMakeRange(0, [valuelist count] - 1)]];
                    else
                        weakSelf.valueList = [NSMutableArray array];
                    if(success)success(YES);
                    
                } andfailure:^(NSError *error){
                    if(failure) failure(error);
                }];
            }
        }
        else{
            //第一页就不存在，那么就可以直接设置从第一页开始
            weakSelf.userfileMid = 10001;
            weakSelf.total = 0;
            weakSelf.size = 10;
            weakSelf.keyForPageIndex = 1;
            weakSelf.valueList = [NSMutableArray array];
            if(success)success(YES);
        }
        
    } andfailure:^(NSError *error){
        if(failure) failure(error);
    }];
}

-(void)fetchUploadURLWithSuccess:(void (^)(id))success andFailure:(void (^)(NSError *error))failure Suffix:(NSString *)suffix
{
    __weak typeof(self) weakSelf = self;
    [self.manager fetchUserDefineUploadURLWithSuccess:^(id obj){
        weakSelf.uploadUrl = [obj valueForKey:@"url"];
        weakSelf.uploadFileName = [obj valueForKey:@"filename"];
        if (success) success(obj);

    } andfailure:^(NSError *error){
        if(failure) failure(error);
        
    } Suffix:suffix];
}

-(NSArray *)userPdata:(NSArray *)valuelist andPageIndex:(int)pageIndex{
    NSDictionary *pageInfo = @{@"index":@(pageIndex),@"size":@(10),@"total":@(self.total + 1),@"currentmax":@(self.userfileMid)};
    
    NSMutableArray *userData = [NSMutableArray arrayWithArray:valuelist];
    [userData addObject:pageInfo];
    
    return [userData mutableCopy];
}

-(void)addNewObjectToValueList{
    NSDictionary *userAddInfo = @{@"alias_name":self.userfileName,
                                  @"name":@(self.userfileMid),
                                  @"mid":@(self.userfileMid),
                                  @"time":@(self.fileduration),
                                  @"filename":self.uploadFileName};
    
    [self.valueList addObject:userAddInfo];
}

//写Pdata
-(void)setUserPdataPageIndex:(int)PageIndex withSuccess:(void (^)(id))success andFailure:(void (^)(NSError *))failure
{
    __weak typeof(self) weakSelf = self;
    //首先设置第一页数据，主要是修改pageinfo，total数据。设置成功后再修改当前page数据
    [self.manager setUserDataWithSuccess:^(id obj){
    
        [weakSelf addNewObjectToValueList];
        [weakSelf.manager setUserDataWithSuccess:^(id obj){
            if (success) success(obj);
            
        } andfailure:^(NSError *error){
            if (failure) failure(error);
            
        } PageIndex:PageIndex Value:[weakSelf userPdata:weakSelf.valueList andPageIndex:PageIndex]];
        
    } andfailure:^(NSError *error){
        if (failure) failure(error);
        
    } PageIndex:1 Value:[self userPdata:self.firstPageValueList andPageIndex:1]];
    
}

-(void)fetchDownloadURL:(NSString *)filename withSuccess:(void (^)(id))success andFailure:(void (^)(NSError *))failure
{
    [self.manager fetchUserMusicURLWithSuccess:^(id obj){
        if(success) success(obj);
        
    } andfailure:^(NSError *error){
        if(failure) failure(error);
        
    } Filename:filename];
}

#pragma mark - 配置网关下载音乐的列表
-(void)readGatwayDownloadListWithSuccess:(void (^)(id))success andFailure:(void (^)(NSError *))failure
{
    [self.manager fetchGatewayDownloadListWithSuccess:^(id obj){
        if (success) success(obj);
        
    } andfailure:^(NSError *error){
        if(failure) failure(error);
    }];
}

-(void)setGatwayDownloadListWithValue:(NSArray *)value Success:(void (^)(id))success andFailure:(void (^)(NSError *))failure
{
    NSLog(@"%@",value);
    [self.manager setGatewayDownloadListWithSuccess:^(id obj){
        if (success) success(obj);

    } andfailure:^(NSError *error){
        if(failure) failure(error);
    } Value:value];
}

@end
