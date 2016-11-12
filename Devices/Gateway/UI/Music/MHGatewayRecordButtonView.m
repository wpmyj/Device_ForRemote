//
//  MHGatewayRecordButtonView.m
//  MiHome
//
//  Created by Lynn on 10/27/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayRecordButtonView.h"
#import <AVFoundation/AVFoundation.h>
#import "MHMusicTipsView.h"

@interface MHGatewayRecordButtonView () <UIAlertViewDelegate,AVAudioPlayerDelegate>

@property (nonatomic,assign) RecordingStatus recordingStatus;
@property (nonatomic,strong) UIView *indicatorLine;

@end

@implementation MHGatewayRecordButtonView
{
    NSString *                  _recordType;
    AVAudioRecorder*            _audioRecorder;
    UIButton *                  _addCloudMusicBtn;
    
    AVAudioSession *            _audioSession;
    AVAudioPlayer *             _audioPlayer;
    
    NSString *                  _audioName;
    
    NSTimer *                   _timer;
    
    MHGwMusicInvoker *          _invoker;
    
    NSURL *                     _tmpURL;
    
    UIViewAnimationOptions      _indicatorOptions;
    
    MHMusicTipsView *           _musictip;
    MHTipsView *                _tip;
}

-(void)setRecordingStatus:(RecordingStatus)recordingStatus{
    _musictip.rescordStatus = recordingStatus;
    switch (recordingStatus) {
        case Recording_Start:{
            [_musictip hide];
            [_musictip showVolumeViewWithTips:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.recordCancel",@"plugin_gateway", nil)];
            [_addCloudMusicBtn setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.recording", @"plugin_gateway",@"正在录音...") forState:UIControlStateNormal];
        }
            break;
        case Recording_Stop:{
            [_musictip hide];
            [self stopIndicatorAnimation];
            [_addCloudMusicBtn setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record",@"plugin_gateway", @"录音") forState:UIControlStateNormal];
        }
            break;
        case Recording_Cancel:{
            [_musictip hide];
            [self stopIndicatorAnimation];
            [_addCloudMusicBtn setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record",@"plugin_gateway", @"录音") forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

- (instancetype)initWithFrame:(CGRect)frame andType:(NSString *)type
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self canRecord];
    _recordType = type;
    _musictip = [MHMusicTipsView shareInstance];
    _tip = [MHTipsView shareInstance];
    [self buildRecorder];
    [self buildSubviews];
    return self;
}

- (void)buildRecorder {
    _outputFileURL =  [self createFileFullPath];
    
    NSError *sessionError;
    _audioSession = [AVAudioSession sharedInstance];
    [_audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if(_audioSession == nil)  {
        NSLog(@"Error creating session: %@", [sessionError description]);
    }
    else {
        [_audioSession setActive:YES error:nil];
    }
    
    //录音设置
    NSDictionary* recordSetting =[[NSDictionary alloc] initWithObjectsAndKeys:
                                  [NSNumber numberWithInt:kAudioFormatMPEG4AAC],AVFormatIDKey,
                                  [NSNumber numberWithInt:64000],AVEncoderBitRateKey,
                                  [NSNumber numberWithFloat:44100.0],AVSampleRateKey,
                                  [NSNumber numberWithInt:2],AVNumberOfChannelsKey,
                                  [NSNumber numberWithInt:8],AVLinearPCMBitDepthKey,
                                  [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                  [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                  [NSNumber numberWithInt:AVAudioQualityMax],AVEncoderAudioQualityKey,nil];
    NSError *error ;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:_tmpURL
                                                 settings:recordSetting
                                                    error:&error];
    _audioRecorder.meteringEnabled = YES;
}

- (void)buildSubviews{
    //初始化view
    _addCloudMusicBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)*0.1f, 11, CGRectGetWidth(self.frame)*0.8f, 46.f)];
    [_addCloudMusicBtn setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:UIControlStateNormal];
    [_addCloudMusicBtn addTarget:self action:@selector(onRecordBtnDown:) forControlEvents:UIControlEventTouchDown];
    [_addCloudMusicBtn addTarget:self action:@selector(onRecordBtnCancel:) forControlEvents:UIControlEventTouchUpOutside];
    [_addCloudMusicBtn addTarget:self action:@selector(onRecordBtnUp:) forControlEvents:UIControlEventTouchUpInside];
    [_addCloudMusicBtn addTarget:self action:@selector(onRecordBtnOut:) forControlEvents:UIControlEventTouchDragExit];
    [_addCloudMusicBtn addTarget:self action:@selector(onRecordBtnInAgain:) forControlEvents:UIControlEventTouchDragEnter];
    
    _addCloudMusicBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    _addCloudMusicBtn.layer.cornerRadius = 46.f / 2.f;
    _addCloudMusicBtn.layer.borderWidth = 0.5;
    _addCloudMusicBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    [_addCloudMusicBtn setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record", @"plugin_gateway",@"录音") forState:UIControlStateNormal];
    [self addSubview:_addCloudMusicBtn];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:line];
    
    self.indicatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, -1, self.frame.size.width, 0.5)];
    self.indicatorLine.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:self.indicatorLine];
    self.indicatorLine.hidden = YES;
}

#pragma mark - indicator 倒计时显示
-(void)updateIndicatorView:(CGFloat)duration
{
    __weak typeof(self) weakSelf = self;
    
    self.indicatorLine.hidden = NO;
    self.indicatorLine.frame = CGRectMake(0, -1, self.frame.size.width, 2);
    
    _indicatorOptions = UIViewAnimationOptionCurveLinear;
    [self.indicatorLine.layer removeAllAnimations];
    [UIView animateWithDuration:duration delay:0 options:_indicatorOptions animations:^{
        weakSelf.indicatorLine.frame = CGRectMake(0, -1, 1, 2);
        weakSelf.indicatorLine.center = CGPointMake(self.center.x, 0);
    } completion:^(BOOL finished){
        weakSelf.indicatorLine.hidden = YES;
    }];
}

-(void)stopIndicatorAnimation{
    __weak typeof(self) weakSelf = self;

    self.indicatorLine.hidden = NO;
    [self.indicatorLine.layer removeAllAnimations];
    [UIView animateWithDuration:.4f delay:0 options:_indicatorOptions animations:^{
        weakSelf.indicatorLine.frame = CGRectMake(0, -1, self.frame.size.width, 2);
    } completion:^(BOOL finished){
        weakSelf.indicatorLine.hidden = YES;
    }];
}

#pragma mark - 文件操作
-(NSURL *)createFileFullPath{
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileFullName = [NSString stringWithFormat:@"%@/lumi_record_%@_%@.aac",docDir,_recordType,_gateway.did];
    NSURL *fileUrl = [NSURL URLWithString:fileFullName];
    _tmpURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/lumi_record_%@_%@_tmp.aac",docDir,_recordType,_gateway.did]];
    
    return fileUrl;
}

-(BOOL)recordFileExist{
    NSString *fileString = _outputFileURL.absoluteString;
    return [[NSFileManager defaultManager] isWritableFileAtPath:fileString];
}

-(NSDictionary *)fileAttributes{
    NSMutableDictionary *returnFileAttributes = [NSMutableDictionary dictionaryWithCapacity:1];
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:_outputFileURL.absoluteString error:nil];
    
    //获取文件修改日
    NSDate *fileModDate;
    if ((fileModDate = [fileAttributes objectForKey:NSFileModificationDate])) {
        NSLog(@"Modification date: %@\n", fileModDate);
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *createtime = [dateFormatter stringFromDate:fileModDate];
    [returnFileAttributes setObject:createtime forKey:@"createtime"];
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_outputFileURL error:nil];
    CGFloat duration = _audioPlayer.duration + 0.5;
    duration = [[NSString stringWithFormat:@"%.0f",duration] doubleValue];
    [returnFileAttributes setObject:@(duration) forKey:@"duration"];
    
    return [returnFileAttributes mutableCopy];
}

-(BOOL)removeFile:(NSURL *)fileURL{
    if(!fileURL) fileURL = _outputFileURL;
    BOOL flag ;
    NSError *error;
    
    NSString *formerURL = [NSString stringWithFormat:@"file://%@",fileURL.absoluteString];
    
    flag = [[NSFileManager defaultManager] removeItemAtURL:[NSURL URLWithString:formerURL] error:&error];
    if(error) NSLog(@"Unable to move file: %@", [error localizedDescription]);
    
    return flag;
}

//完成，替换临时文件
-(void)fileReplace
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *error;
    if ([fileMgr fileExistsAtPath:_tmpURL.absoluteString]){
        if ([fileMgr fileExistsAtPath:_outputFileURL.absoluteString]) [self removeFile:_outputFileURL];
        if ([fileMgr moveItemAtPath:_tmpURL.absoluteString toPath:_outputFileURL.absoluteString error:&error] != YES)
            NSLog(@"Unable to move file: %@", [error localizedDescription]);
    }
}

#pragma mark - button
//录音／上传
-(void)onRecordBtnDown:(id)sender
{
    if (!_audioRecorder.recording) { // 开始录音
        if([_audioRecorder prepareToRecord] == YES){
            
            self.recordingStatus = Recording_Start;

            [_audioRecorder record];
            
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                      target:self
                                                    selector:@selector(handleTimer:)
                                                    userInfo:nil
                                                     repeats:YES];
            [_timer fire];
            [self updateIndicatorView:26.f];
        }
    }
}

-(void)onRecordBtnCancel:(id)sender
{
    [_timer invalidate];
    _timer = nil;
    if([_audioRecorder isRecording]){
        [_audioRecorder deleteRecording];
        [_audioRecorder stop];
        self.recordingStatus = Recording_Cancel;
    }
    [self removeFile:_tmpURL];
}

-(void)onRecordBtnUp:(id)sender
{
    //结束定时器
    [_timer invalidate];
    _timer = nil;

    [_audioRecorder stop];
    self.recordingStatus = Recording_Stop;
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_tmpURL error:nil];
    if(_audioPlayer.duration < 1.0){
        [_tip showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record.timershort",@"plugin_gateway", nil) duration:1.f modal:YES];
        [_musictip hide];
    }
    else{
        [self fileReplace];
        [self showPlayAndUploadView];
        if (self.recordSuccess)self.recordSuccess();
    }
}

-(void)onRecordBtnOut:(id)sender
{
    //向上滑动离开的，中间状态
    [_musictip hide];
    [_musictip showCancelView];
}

-(void)onRecordBtnInAgain:(id)sender
{
    //又回来了，中间状态
    [_musictip hide];
    [_musictip showVolumeViewWithTips:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.recordCancel",@"plugin_gateway", nil)];
}

-(void)onUploadBtn:(id)sender{
    [self showPlayAndUploadView];
}

#pragma mark - timer
//时长判断
-(void)handleTimer:(id)sender{

    double lowPassResults = 0.f;
    [_audioRecorder updateMeters];
    const double ALPHA = 0.05;
    double peakPowerForChannel = pow(10, (0.05 * [_audioRecorder peakPowerForChannel:0]));
    lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
    NSString *volume = [NSString stringWithFormat:@"%.0f",lowPassResults * 100 * 20 + 13];
    [_musictip setVolume:[volume intValue]];
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_tmpURL error:nil];
    CGFloat duration = _audioPlayer.duration + 0.5;
    
    if (duration > 29.f){
        [_musictip hide];
        [_tip showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record.timerlong",@"plugin_gateway", nil) duration:2.f modal:YES];
        
        [_audioRecorder stop];
        //结束定时器
        [_timer invalidate];
        _timer = nil;
        
        [self fileReplace];
        [self stopIndicatorAnimation];

        [_addCloudMusicBtn setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record",@"plugin_gateway", @"录音") forState:UIControlStateNormal];
        if ([self recordFileExist]) {
            if (self.recordSuccess)self.recordSuccess();
            [self performSelector:@selector(showPlayAndUploadView) withObject:nil afterDelay:2.f];
        }
    }
}

#pragma mark - 录音操作
-(void)showPlayAndUploadView{
    CGFloat duration = [[[self fileAttributes] valueForKey:@"duration"] doubleValue];
    NSString *info = [NSString stringWithFormat:@"%.0f″",duration];
    
    XM_WS(weakself);
    [_musictip showRecordModal:YES withTouchBlock:^(NSString *status){
        if([status isEqualToString:CallBackPlayKey]){
            [weakself play];
        }
        else if([status isEqualToString:CallBackPauseKey]){
            [weakself pause];
        }
        else if([status isEqualToString:CallBackUploadKey]){
            [weakself upload];
        }
        else if([status isEqualToString:CallBackGiveUp]){
            [weakself removeFile:nil];
            if(weakself.recordSuccess)weakself.recordSuccess();
        }
    } andInfo:info];
}

//播放
-(void)play{
    _audioPlayer = nil;
    NSError *playerError;
    
    NSError *error;
    BOOL success = [_audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if(!success){
        NSLog(@"error doing outputaudioportoverride - %@", [error localizedDescription]);
    }
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_outputFileURL error:&playerError];
    _audioPlayer.delegate = self;
    if (_audioPlayer == nil){
        NSLog(@"Error creating player: %@", [playerError description]);
    }
    else{
        [_audioPlayer play];
    }
}

//暂停
-(void)pause{
    [_audioPlayer pause];
}

//上传
-(void)upload{
    if(!_audioName){//命名
        //弹出修改名称的输入框
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.upload.name",@"plugin_gateway", "") message:@"" delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway","") otherButtonTitles:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway", "确定"), nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert textFieldAtIndex:0].placeholder = NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.upload.placeholder",@"plugin_gateway",nil);
        [alert show];
        
    }//上传
    else{
        XM_WS(weakself);
        
        if(self.uploadStart) self.uploadStart(0.0001);
        _invoker = [[MHGwMusicInvoker alloc] initWithDevice:self.gateway];
        _invoker.downloadProgress = ^(CGFloat progress){
            if(weakself.uploadProgress) weakself.uploadProgress(progress);
        };
        _invoker.downloadSuccess = ^(NSDictionary *fileinfo){
            if(weakself.uploadSuccess) weakself.uploadSuccess(fileinfo);
        };
        [_invoker userClickUpload:_outputFileURL
               userDefineFileName:_audioName
                     fileduration:[[[self fileAttributes] valueForKey:@"duration"] doubleValue]
                        groupType:_recordType];
        _audioName = nil;
    }
}

#pragma mark - alert view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *tf = [alertView textFieldAtIndex:0];
    if(tf.text.length){
        _audioName = tf.text;
        if(buttonIndex){
            [tf resignFirstResponder];
            [self upload];
        }
    }
}

#pragma mark - 判断是否允许录音
-(BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    _audioSession = [AVAudioSession sharedInstance];
    [_audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    if ([_audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [_audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                bCanRecord = YES;
            }
            else {
                bCanRecord = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:nil
                                                message:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record.nopermit",@"plugin_gateway", nil)
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedStringFromTable(@"Ok", @"plugin_gateway",nil)
                                      otherButtonTitles:nil] show];
                });
            }
        }];
    }
    
    return bCanRecord;
}

#pragma mark - player delegete
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    _musictip.currentStatus = CallBackPlayKey;
    if (self.playStoped) self.playStoped();
}

@end
