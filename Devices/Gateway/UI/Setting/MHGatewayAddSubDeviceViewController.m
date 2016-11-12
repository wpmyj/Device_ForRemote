//
//  MHGatewayAddSubDeviceWithoutVideoViewController.m
//  MiHome
//
//  Created by guhao on 3/7/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayAddSubDeviceViewController.h"
#import "SDProgressView.h"
#import "MHLuWebViewController.h"
#import "MHGatewayNamingSpeedViewController.h"
#import <MiHomeKit/MHIoTDevice.h>
#import "MHLumiChooseLogoListManager.h"

#define CancelButtonHeight 46.f
#define ProgressViewHeight 90.f
#define LineSpacing 5
#define DeviceAnimationDuration 3.f

static NSArray* modelNames = nil;

@interface MHGatewayAddSubDeviceViewController ()


@property (nonatomic, assign) NSUInteger index;//产品类别
@property (nonatomic,weak) NSString *deviceTypeImageName;
@property (nonatomic,weak) NSString *deviceImageName;

@property (nonatomic, strong) UIImageView *device;
@property (nonatomic, strong) UIImageView *succeedView;
@property (nonatomic, strong) UIImageView *failedView;
@property (nonatomic, strong) UIImageView *failedExtraImage;

@property (nonatomic, strong) UILabel *labelGuide;
@property (nonatomic, strong) UILabel *failedTips;
@property (nonatomic, strong) UILabel *failedExtraTip;

@property (nonatomic, strong) UIButton *btnCancel;
@property (nonatomic, strong) UIButton *btnDone;
@property (nonatomic, strong) UIButton *btnRetry;

@property (nonatomic, strong) CountTimerProgressView *progressView;

@property (nonatomic, assign) BOOL isShare;
@property (nonatomic, strong) MHDeviceGatewayBase *subDeviceNew;

@property (nonatomic, strong) MHDeviceGateway *gateway;


@property (nonatomic, strong) UILabel *failureTitle;
@property (nonatomic, strong) UILabel *failureOne;
@property (nonatomic, strong) UILabel *failureTwo;
@end

@implementation MHGatewayAddSubDeviceViewController{
    
    NSTimer*                _progressTimer;
    
    NSArray*                _subDevices;
    NSTimer*                _monitorTimer;
}

- (id)initWithGateway:(MHDeviceGateway*)gateway andDeviceModel:(NSString *)deviceModel {
    if (self = [super init]) {
        [self handleModelNames];
        _index = 0;
        XM_WS(weakself);
        [modelNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:deviceModel]) {
                weakself.index = idx;
                *stop = YES;
            }
        }];
        _gateway = gateway;
    }
    return self;
}

- (id)initWithGateway:(MHDeviceGateway*)gateway deviceType:(ADD_SUBDEVICE_TYPE)type {
    if (self = [super init]) {
        [self handleModelNames];
        _index = (NSInteger)type;
        _gateway = gateway;
    }
    return self;
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}


- (void)handleModelNames {
    modelNames = @[DeviceModelMotionClassName,
                   DeviceModelMagnetClassName,
                   DeviceModelSwitchClassName,
                   DeviceModelPlugClassName,
                   DeviceModelHtClassName,
                   DeviceModelCubeClassName,
                   DeviceModelCtrlNeutral1ClassName,
                   DeviceModelCtrlNeutral2ClassName,
                   DeviceModel86Switch1ClassName,
                   DeviceModel86Switch2ClassName,
                   DeviceModelCurtainClassName,
                   DeviceModel86PlugClassName,
                   DeviceModelSmokeClassName,
                   DeviceModelNatgasClassName];
}

- (void)buildSubviews {
    [super buildSubviews];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.isTabBarHidden = YES;
    
    _device = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.deviceTypeImageName]];
    _device.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_device];
    
    _succeedView = [[UIImageView alloc] init];
    [_succeedView setImage:[UIImage imageNamed:@"gateway_addsub_succeed"]];
    _succeedView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_succeedView];
    _succeedView.hidden = YES;
    
    _labelGuide = [[UILabel alloc] init];
    _labelGuide.translatesAutoresizingMaskIntoConstraints = NO;
    _labelGuide.font = [UIFont systemFontOfSize:15 * ScaleWidth];
    _labelGuide.textColor = [MHColorUtils colorWithRGB:0x333333];
    _labelGuide.numberOfLines = 0;
    _labelGuide.lineBreakMode = NSLineBreakByWordWrapping;
    
       switch (_index) {
           case Motion_Index: {
               NSString *test = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_motion.color",@"plugin_gateway", "蓝灯连续闪烁3次");
               NSString *str = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_motion",@"plugin_gateway","请按一下要插入设备的重置孔");
               NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:str];
               NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
               
               [paragraphStyle setLineSpacing:LineSpacing];//调整行间距
               
               [todayCountTailAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
               [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x1084c1] range:[str rangeOfString:test]];
               self.labelGuide.attributedText = todayCountTailAttribute;
               
               self.controllerIdentifier = @"mydevice.gateway.addsub_guide_motion";
               self.deviceTypeImageName = @"gateway_add_subdevice_body";
               _device.image = [UIImage imageNamed:self.deviceTypeImageName];
           }
               break;
           case Magnet_Index: {
               NSString *test = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_magnet.color",@"plugin_gateway", "蓝灯连续闪烁3次");
               NSString *str = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_magnet",@"plugin_gateway","请按一下要插入设备的重置孔");
               NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:str];
               NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
               
               [paragraphStyle setLineSpacing:LineSpacing];//调整行间距
               
               [todayCountTailAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
               [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x1084c1] range:[str rangeOfString:test]];
               self.labelGuide.attributedText = todayCountTailAttribute;
               
               self.controllerIdentifier = @"mydevice.gateway.addsub_guide_magnet";
               self.deviceTypeImageName = @"gateway_add_subdevice_window";
               _device.image = [UIImage imageNamed:self.deviceTypeImageName];
               
           }
               break;
           case Switch_Index: {
               NSString *test = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_switch.color",@"plugin_gateway", "蓝灯连续闪烁3次");
               NSString *str = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_switch",@"plugin_gateway","请按一下要插入设备的重置孔");
               NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:str];
               NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
               
               [paragraphStyle setLineSpacing:LineSpacing];//调整行间距
               
               [todayCountTailAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
               [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x1084c1] range:[str rangeOfString:test]];
               self.labelGuide.attributedText = todayCountTailAttribute;
               
               self.controllerIdentifier = @"mydevice.gateway.addsub_guide_switch";
               self.deviceTypeImageName = @"gateway_add_subdevice_swich";
               _device.image = [UIImage imageNamed:self.deviceTypeImageName];
           }
               break;
           case Plug_Index: {
               NSString *test = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_plugreset_tips.color",@"plugin_gateway", "红灯闪烁");
               NSString *str = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_plugreset_tips",@"plugin_gateway","请按一下要插入设备的重置孔");
               NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:str];
               NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
               
               [paragraphStyle setLineSpacing:LineSpacing];//调整行间距
               
               [todayCountTailAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
               [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x1084c1] range:[str rangeOfString:test]];
               self.labelGuide.attributedText = todayCountTailAttribute;
               
               self.controllerIdentifier = @"mydevice.gateway.addsub_guide_plugreset_tips";
               self.deviceTypeImageName = @"lumi_plug_reset";
               _device.image = [UIImage imageNamed:self.deviceTypeImageName];
               
           }
               break;
        case Cube_Index: {
            NSString *test = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_humiturereset_tips.color",@"plugin_gateway", "蓝灯连续闪烁3次");
            NSString *str = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_humiturereset_tips",@"plugin_gateway","请按一下要插入设备的重置孔");
            NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:str];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            
            [paragraphStyle setLineSpacing:LineSpacing];//调整行间距
            
            [todayCountTailAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
            [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x1084c1] range:[str rangeOfString:test]];
            self.labelGuide.attributedText = todayCountTailAttribute;
            
            self.controllerIdentifier = @"mydevice.gateway.addsub_guide_humiture";
            self.deviceTypeImageName = @"lumi_humiture_reset";
            _device.image = [UIImage imageNamed:self.deviceTypeImageName];
 
        }
            break;
        case HT_Index: {
            NSString *test = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_cube.color",@"plugin_gateway", "用力甩一下");
            NSString *str = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_cube",@"plugin_gateway","请用力甩一下魔方，等待网关语音提示");
            NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:str];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            
            [paragraphStyle setLineSpacing:LineSpacing];//调整行间距
            
            [todayCountTailAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
            [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x1084c1] range:[str rangeOfString:test]];
            self.labelGuide.attributedText = todayCountTailAttribute;
            
            self.controllerIdentifier = @"mydevice.gateway.addsub_guide_cube";
            self.deviceTypeImageName = @"lumi_cube_reset_one";
            _device.image = [UIImage imageNamed:self.deviceTypeImageName];

        }
            break;
        case SingleNeutral_Index: {
            NSString *test = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_add_singleNeutral.color",@"plugin_gateway", "蓝灯闪烁");
            NSString *str = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_add_singleNeutral",@"plugin_gateway","请长按开关键5秒以上，直到蓝灯闪烁后松开");
            NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:str];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            
            [paragraphStyle setLineSpacing:LineSpacing];//调整行间距
            
            [todayCountTailAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
            [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x1084c1] range:[str rangeOfString:test]];
            self.labelGuide.attributedText = todayCountTailAttribute;
            
            self.controllerIdentifier = @"mydevice.gateway.addsub_guide_add_singleNeutral";
            self.deviceTypeImageName = @"gateway_singleNeutral_reset";
            _device.image = [UIImage imageNamed:self.deviceTypeImageName];
        }
            break;
        case DoubleNeutral_Index: {
            NSString *test = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_add_doubleNeutral.color",@"plugin_gateway", "蓝灯闪烁");
            NSString *str = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_add_doubleNeutral",@"plugin_gateway","请长按任意开关键5秒以上，直到蓝灯闪烁后松开");
            NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:str];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            
            [paragraphStyle setLineSpacing:LineSpacing];//调整行间距
            
            [todayCountTailAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
            [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x1084c1] range:[str rangeOfString:test]];
            self.labelGuide.attributedText = todayCountTailAttribute;
            
            self.controllerIdentifier = @"mydevice.gateway.addsub_guide_add_doubleNeutral";
            self.deviceTypeImageName = @"gateway_doubleNeutral_reset";
            _device.image = [UIImage imageNamed:self.deviceTypeImageName];
        }
            break;
        case SingleSwitch_Index: {
            NSString *test = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_add_single86swtich.color",@"plugin_gateway", "蓝灯闪烁");
            NSString *str = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_add_single86swtich",@"plugin_gateway","请长按开关键5秒以上，直到蓝灯闪烁后松开");
            NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:str];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            
            [paragraphStyle setLineSpacing:LineSpacing];//调整行间距
            
            [todayCountTailAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
            [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x1084c1] range:[str rangeOfString:test]];
            self.labelGuide.attributedText = todayCountTailAttribute;
            
            self.controllerIdentifier = @"mydevice.gateway.addsub_guide_add_single86swtich";
            self.deviceTypeImageName = @"gateway_singleNeutral_reset";
            _device.image = [UIImage imageNamed:self.deviceTypeImageName];
        }
            break;
        case DoubleSwitch_Index: {
            NSString *test = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_add_double86swtich.color",@"plugin_gateway", "蓝灯闪烁");
            NSString *str = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_add_double86swtich",@"plugin_gateway","请长按任意开关键5秒以上，直到蓝灯闪烁后松开");
            NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:str];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            
            [paragraphStyle setLineSpacing:LineSpacing];//调整行间距
            
            [todayCountTailAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
            [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x1084c1] range:[str rangeOfString:test]];
            self.labelGuide.attributedText = todayCountTailAttribute;
            
            self.controllerIdentifier = @"mydevice.gateway.addsub_guide_add_double86swtich";
            self.deviceTypeImageName = @"gateway_doubleNeutral_reset";
            _device.image = [UIImage imageNamed:self.deviceTypeImageName];
        }
            break;
           case Curtain_Index: {
               NSString *test = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_add_double86swtich.color",@"plugin_gateway", "蓝灯闪烁");
               NSString *str = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_add_double86swtich",@"plugin_gateway","请长按任意开关键5秒以上，直到蓝灯闪烁后松开");
               NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:str];
               NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
               
               [paragraphStyle setLineSpacing:LineSpacing];//调整行间距
               
               [todayCountTailAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
               [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x1084c1] range:[str rangeOfString:test]];
               self.labelGuide.attributedText = todayCountTailAttribute;
               
               self.controllerIdentifier = @"mydevice.gateway.addsub_guide_add_double86swtich";
               self.deviceTypeImageName = @"gateway_doubleNeutral_reset";
               _device.image = [UIImage imageNamed:self.deviceTypeImageName];
           }
               break;
           case Cassette_Index: {
               NSString *test = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_add_double86swtich.color",@"plugin_gateway", "蓝灯闪烁");
               NSString *str = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_add_double86swtich",@"plugin_gateway","请长按任意开关键5秒以上，直到蓝灯闪烁后松开");
               NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:str];
               NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
               
               [paragraphStyle setLineSpacing:LineSpacing];//调整行间距
               
               [todayCountTailAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
               [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x1084c1] range:[str rangeOfString:test]];
               self.labelGuide.attributedText = todayCountTailAttribute;
               
               self.controllerIdentifier = @"mydevice.gateway.addsub_guide_add_double86swtich";
               self.deviceTypeImageName = @"gateway_doubleNeutral_reset";
               _device.image = [UIImage imageNamed:self.deviceTypeImageName];
           }
               break;
           case Smoke_Index: {
//               NSString *test = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_add_double86swtich.color",@"plugin_gateway", "听到设备响三下即可");
//               NSString *str = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_add_double86swtich",@"plugin_gateway","快速按三下设备, 听到设备响三下即可");
               NSString *test = @"听到设备响3下即可";
               NSString *str = @"快速按3下设备, 听到设备响3下即可";
               NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:str];
               NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
               
               [paragraphStyle setLineSpacing:LineSpacing];//调整行间距
               
               [todayCountTailAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
               [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x1084c1] range:[str rangeOfString:test]];
               self.labelGuide.attributedText = todayCountTailAttribute;
               
               self.controllerIdentifier = @"mydevice.gateway.addsub_guide_add_double86swtich";
               self.deviceTypeImageName = @"gateway_add_subdevice_smoke";
               _device.image = [UIImage imageNamed:self.deviceTypeImageName];
           }
               break;
           case Natgas_Index: {
               //              NSString *test = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_add_double86swtich.color",@"plugin_gateway", "听到设备响三下即可");
               //               NSString *str = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_add_double86swtich",@"plugin_gateway","快速按三下设备, 听到设备响三下即可");
               NSString *test = @"听到设备响3下即可";
               NSString *str = @"快速按3下设备, 听到设备响3下即可";
               NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:str];
               NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
               
               [paragraphStyle setLineSpacing:LineSpacing];//调整行间距
               
               [todayCountTailAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
               [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x1084c1] range:[str rangeOfString:test]];
               self.labelGuide.attributedText = todayCountTailAttribute;
               
               self.controllerIdentifier = @"mydevice.gateway.addsub_guide_add_double86swtich";
               self.deviceTypeImageName = @"gateway_add_subdevice_smoke";
               _device.image = [UIImage imageNamed:self.deviceTypeImageName];
           }
               break;
        default:
            break;
               
               
    }
    _labelGuide.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_labelGuide];
    
    _btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnCancel setTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway","取消") forState:(UIControlStateNormal)];
    _btnCancel.titleLabel.font = [UIFont systemFontOfSize:14];
    [_btnCancel setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:(UIControlStateNormal)];
    [_btnCancel.layer setCornerRadius:CancelButtonHeight / 2.f];
    _btnCancel.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _btnCancel.layer.borderWidth = 0.5;
    _btnCancel.translatesAutoresizingMaskIntoConstraints = NO;
    [_btnCancel addTarget:self action:@selector(onCancel:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_btnCancel];
    
    _btnDone = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnDone setTitle:NSLocalizedStringFromTable(@"done",@"plugin_gateway","完成") forState:(UIControlStateNormal)];
    _btnDone.titleLabel.font = [UIFont systemFontOfSize:14];
    [_btnDone setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:(UIControlStateNormal)];
    [_btnDone.layer setCornerRadius:CancelButtonHeight / 2.f];
    _btnDone.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _btnDone.layer.borderWidth = 0.5;
    _btnDone.translatesAutoresizingMaskIntoConstraints = NO;
    [_btnDone addTarget:self action:@selector(onDone:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_btnDone];
    _btnDone.hidden = YES;
    
    _btnRetry = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnRetry setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.addsubdeviceslist.failedretry",@"plugin_gateway","重试") forState:(UIControlStateNormal)];
    _btnRetry.titleLabel.font = [UIFont systemFontOfSize:14];
    [_btnRetry setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:(UIControlStateNormal)];
    [_btnRetry.layer setCornerRadius:CancelButtonHeight / 2.f];
    _btnRetry.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _btnRetry.layer.borderWidth = 0.5;
    _btnRetry.translatesAutoresizingMaskIntoConstraints = NO;
    [_btnRetry addTarget:self action:@selector(onRetry:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_btnRetry];
    _btnRetry.hidden = YES;
    
    _progressView = [CountTimerProgressView progressView];
    _progressView.translatesAutoresizingMaskIntoConstraints = NO;
    _progressView.progress = 0;
    _progressView.totalCount = 30.f;
    [self.view addSubview:_progressView];
    
    _failedView = [[UIImageView alloc] init];
    [_failedView setImage:[UIImage imageNamed:@"gateway_addsub_failed"]];
    _failedView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_failedView];
    _failedView.hidden = YES;
    
    _failedExtraImage = [[UIImageView alloc] init];
    [_failedExtraImage setImage:[UIImage imageNamed:self.deviceTypeImageName]];
    _failedExtraImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_failedExtraImage];
    _failedExtraImage.hidden = YES;
    
    _failedExtraTip = [[UILabel alloc] init];
    _failedExtraTip.translatesAutoresizingMaskIntoConstraints = NO;
    _failedExtraTip.font = [UIFont systemFontOfSize:14];
    _failedExtraTip.textColor = [MHColorUtils colorWithRGB:0x333333];
    _failedExtraTip.text = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_plugreset_tips", @"plugin_gateway", nil);
    [self.view addSubview:_failedExtraTip];
    _failedExtraTip.hidden = YES;
    
    _failedTips = [[UILabel alloc] init];
    _failedTips.translatesAutoresizingMaskIntoConstraints = NO;
    _failedTips.font = [UIFont systemFontOfSize:14];
    _failedTips.textColor = [MHColorUtils colorWithRGB:0x333333];
    _failedTips.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.addsubdeviceslist.failed",@"plugin_gateway",  @"添加子设备失败");
    [self.view addSubview:_failedTips];
    _failedTips.hidden = YES;
    
    
    //烟气感特殊提示
    self.failureTitle = [[UILabel alloc] init];
    self.failureTitle.textAlignment = NSTextAlignmentCenter;
    self.failureTitle.textColor = [UIColor blackColor];
    self.failureTitle.font = [UIFont systemFontOfSize:14.0f];
    self.failureTitle.backgroundColor = [UIColor clearColor];
    self.failureTitle.text = @"常见问题";
    [self.view addSubview:self.failureTitle];
    self.failureTitle.hidden = YES;
    
    self.failureOne = [[UILabel alloc] init];
    self.failureOne.textAlignment = NSTextAlignmentCenter;
    self.failureOne.textColor = [UIColor blackColor];
    self.failureOne.font = [UIFont systemFontOfSize:14.0f];
    self.failureOne.backgroundColor = [UIColor clearColor];
    self.failureOne.text = _index == Smoke_Index ? @"1.请检查是否安装电池" : @"1.需连续快速按3下";
    [self.view addSubview:self.failureOne];
    self.failureOne.hidden = YES;


    self.failureTwo = [[UILabel alloc] init];
    self.failureTwo.textAlignment = NSTextAlignmentCenter;
    self.failureTwo.textColor = [UIColor blackColor];
    self.failureTwo.font = [UIFont systemFontOfSize:14.0f];
    self.failureTwo.backgroundColor = [UIColor clearColor];
    self.failureTwo.text = @"2.需连续快速按3下";
    [self.view addSubview:self.failureTwo];
    self.failureTwo.hidden = YES;



    
}

- (void)buildConstraints {
    [super buildConstraints];
    
    CGFloat leadSpacing = 120 * ScaleHeight;
    CGFloat progressSpacing = 40 * ScaleHeight;
    CGFloat veritalSapcing = 30 * ScaleHeight;
    CGFloat herizonSpacing = 30 * ScaleWidth;
    CGFloat progressSize = 90 * ScaleWidth;
    CGFloat guideSpacing = 20;
    //添加设备
    XM_WS(weakself);
    [self.device mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.view).with.offset(leadSpacing);
        make.centerX.equalTo(weakself.view);
    }];
    [self.labelGuide mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.device.mas_bottom).with.offset(guideSpacing);
        make.centerX.equalTo(weakself.view);
        make.width.mas_equalTo(WIN_WIDTH - 80);
    }];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.labelGuide.mas_bottom).with.offset(progressSpacing);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(progressSize, progressSize));
    }];
    [self.btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view).with.offset(herizonSpacing);
        make.bottom.equalTo(weakself.view).with.offset(-veritalSapcing);
        make.right.equalTo(weakself.view).with.offset(-herizonSpacing);
        make.height.mas_equalTo(CancelButtonHeight);
    }];
    
    //添加失败
    [self.failedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.view).with.offset(leadSpacing);
        make.centerX.equalTo(weakself.view);
    }];
    [self.failedExtraImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakself.failedView);
    }];
    [self.failedTips mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.failedView.mas_bottom).with.offset(guideSpacing);
        make.centerX.equalTo(weakself.view);
    }];
    [self.failedExtraTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.failedTips.mas_bottom).with.offset(guideSpacing);
        make.centerX.equalTo(weakself.view);
    }];
    [self.btnRetry mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view).with.offset(herizonSpacing);
        make.bottom.equalTo(weakself.view).with.offset(-veritalSapcing);
        make.right.equalTo(weakself.view).with.offset(-herizonSpacing);
        make.height.mas_equalTo(CancelButtonHeight);
    }];
    
    //添加成功
    [self.succeedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.view).with.offset(leadSpacing);
        make.centerX.equalTo(weakself.view);
    }];
    [self.btnDone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view).with.offset(herizonSpacing);
        make.bottom.equalTo(weakself.view).with.offset(-veritalSapcing);
        make.right.equalTo(weakself.view).with.offset(-herizonSpacing);
        make.height.mas_equalTo(CancelButtonHeight);
    }];
    
    
    
    [self.failureTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view);
        make.bottom.mas_equalTo(weakself.btnCancel.mas_top).with.offset(-guideSpacing);
    }];
    
    [self.failureOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view);
        make.bottom.mas_equalTo(weakself.failureTwo.mas_top).with.offset(-guideSpacing);
    }];
    [self.failureTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view);
        make.bottom.mas_equalTo(weakself.failureOne.mas_top).with.offset(-guideSpacing);
    }];

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XM_WS(weakself);
    [_gateway startZigbeeJoinWithSuccess:^(id v) {
        [weakself startProgressTimer];
        [weakself startMonitorNewSubDevice];
    } failure:^(NSError *error) {
        [weakself startProgressTimer];
        NSLog(@"%@", error);
    }];
    if (_index <= HT_Index ||
        _index == Smoke_Index ||
        _index == Natgas_Index) {
        [self performSelector:@selector(startAnimation) withObject:self afterDelay:0.f];
    }
    [self getShareIdentifier];
    
    NSString *tempModel = nil;
    
    switch (_index) {
        case HT_Index:
            tempModel = DeviceModelgatewaySensorHt;
            break;
        case Motion_Index:
            tempModel = DeviceModelgateWaySensorMotionV1;
            break;
        case Magnet_Index:
            tempModel = DeviceModelgateWaySensorMagnetV2;
            break;
        case Switch_Index:
            tempModel = DeviceModelgateWaySensorSwitchV2;
            break;
        case Plug_Index:
            tempModel = DeviceModelgateWaySensorPlug;
            break;
        case SingleNeutral_Index:
            tempModel = DeviceModelgatewaySencorCtrlNeutral1V1;
            break;
        case Cube_Index:
            tempModel = DeviceModelgateWaySensorCubeV1;
            break;
        case DoubleNeutral_Index:
            tempModel = DeviceModelgatewaySencorCtrlNeutral2V1;
            break;
        case SingleSwitch_Index:
            tempModel = DeviceModelgateWaySensor86Switch1V1;
            break;
        case DoubleSwitch_Index:
            tempModel = DeviceModelgateWaySensor86Switch2V1;
            break;
        case Curtain_Index:
            tempModel = DeviceModelgateWaySensorCurtainV1;
            break;
        case Cassette_Index:
            tempModel = DeviceModelgateWaySensor86PlugV1;
            break;
        case Smoke_Index:
            tempModel = DeviceModelgateWaySensorSmokeV1;
            break;
        case Natgas_Index:
            tempModel = DeviceModelgateWaySensorNatgasV1;
            break;
        default:
            break;
    }
    [[MHLumiChooseLogoListManager sharedInstance] isShowLogoListWithandDeviceModel:tempModel finish:nil];
    
}

- (void)onCancel:(id)sender {
    [self gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"addDeviceCancel:%@",self.controllerIdentifier]];
    
    [_gateway stopZigbeeJoinWithSuccess:nil failure:nil];
    [self stopMonitorNewSubDevice];
    [self stopProgressTimer];
    [_device stopAnimating];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onBack:(id)sender {
    [super onBack:sender];
    [_gateway stopZigbeeJoinWithSuccess:nil failure:nil];
    [self stopMonitorNewSubDevice];
    [self stopProgressTimer];
    [_device stopAnimating];
}

- (void)onContinue:(id)sender {
    
    XM_WS(weakself);
    [_gateway startZigbeeJoinWithSuccess:^(id v){
        [weakself startProgressTimer];
    } failure:^(NSError *v) {
        [weakself startProgressTimer];
    }];
    
    _device.hidden = NO;
    _labelGuide.hidden = NO;
    switch (_index) {
        case Cube_Index: {
            NSString *test =  NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_add_cube2.color",@"plugin_gateway", "蓝灯连续闪烁3次");
            NSString *str = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_add_cube2",@"plugin_gateway","请打开魔方底盖，长按圆形重置键三秒以上，直到蓝灯连续闪烁三次后松开");
            NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:str];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            
            [paragraphStyle setLineSpacing:LineSpacing];//调整行间距
            
            [todayCountTailAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
            [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x1084c1] range:[str rangeOfString:test]];
            self.labelGuide.attributedText = todayCountTailAttribute;
            
            self.deviceTypeImageName = @"lumi_cube_reset_two";
            _device.image = [UIImage imageNamed:self.deviceTypeImageName];
            
        }
            break;
        default:
            break;
    }

    _succeedView.hidden = YES;
    _failedView.hidden = YES;
    _failedExtraTip.hidden = YES;
    _failedTips.hidden = YES;
    _failedExtraImage.hidden = YES;
    
    _btnRetry.hidden = YES;
    _btnDone.hidden = YES;
    _btnCancel.hidden = NO;
    
    self.failureTitle.hidden = YES;
    self.failureOne.hidden = YES;
    self.failureTwo.hidden = YES;

}

- (void)onDone:(id)sender {
    [self gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"addDeviceDone:%@",self.controllerIdentifier]];
    
    [_gateway stopZigbeeJoinWithSuccess:nil failure:nil];
    [self stopMonitorNewSubDevice];
    [_device stopAnimating];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 图片动画
- (void)startAnimation {
    
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:3];
    for (int i = 1 ;i <= 6; i++){
        int j = i ;
        if(i > 3) j = 3;
        self.deviceImageName = [NSString stringWithFormat:@"%@%d", self.deviceTypeImageName, j];
        
        if([UIImage imageNamed:self.deviceImageName])
            [imageArray addObject:[UIImage imageNamed:self.deviceImageName]];
    }
    _device.animationImages = imageArray;
    _device.animationDuration = DeviceAnimationDuration;
    [_device startAnimating];
}

#pragma mark - 倒计时进度
- (void)startProgressTimer {
    _progressView.hidden = NO;
    _progressView.progress = 0;
    _progressView.totalCount = 30.f;
    _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(startProgressCnt) userInfo:nil repeats:YES];
}

- (void)startProgressCnt {
    CGFloat progress = _progressView.progress;
    if (progress <= 1.0) {
        progress += 0.01;
        
        //循环
        if (progress > 1.0) {
            [self stopProgressTimer];
            [self addSubDevicesFailed];
        }
        _progressView.progress = progress;
    }
}

- (void)stopProgressTimer {
    if(_progressTimer){
        [_progressTimer invalidate];
        _progressTimer = nil;
    }
}

#pragma mark - 添加子设备失败
-(void)addSubDevicesFailed
{
    [self gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"addDeviceFailure:%@",self.controllerIdentifier]];
    _failedView.hidden = NO;
    _failedExtraImage.hidden = YES;
    _failedExtraTip.hidden = YES;
    _failedTips.hidden = NO;
    _btnRetry.hidden = NO;
    
    _labelGuide.hidden = YES;
    _device.hidden = YES;
    _btnCancel.hidden = YES;
    
    switch (_index) {
        case Cube_Index:
            [_btnRetry setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.addsubdeviceslist.cube.failedretry",@"plugin_gateway","重置") forState:(UIControlStateNormal)];
            break;
        case Natgas_Index: {
            self.failureTitle.hidden = NO;
            self.failureOne.hidden = NO;
            break;
        }
        case Smoke_Index: {
            self.failureTitle.hidden = NO;
            self.failureOne.hidden = NO;
            self.failureTwo.hidden = NO;
            break;
        }
        default:
            break;
    }
}

-(void)onRetry:(id)sender
{
    [self gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"addDeviceRetry:%@",self.controllerIdentifier]];
    [self onContinue:nil];
}

#pragma mark - 子设备列表监控
- (void)startMonitorNewSubDevice {
    [_monitorTimer invalidate];
    _monitorTimer = nil;
    _monitorTimer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(onMonitorTimer:) userInfo:nil repeats:YES];
}

- (void)stopMonitorNewSubDevice {
    [_monitorTimer invalidate];
    _monitorTimer = nil;
}

- (void)onGetSubDevicesSucceed:(NSArray* )list {
    XM_WS(weakself);
    if (!_subDevices) {
        //第一次进来
        _subDevices = list;
        __block NSMutableArray *newDeviceArray = [NSMutableArray new];
        
        [_subDevices enumerateObjectsUsingBlock:^(MHDevice *newDevice, NSUInteger idx, BOOL * _Nonnull stop) {
            //        NSLog(@"子设备的did <<<%@>>>, 模型<<%@>>", newDevice.did, newDevice.model);
            MHDeviceGatewayBase *sensor = (MHDeviceGatewayBase *)[MHDevFactory deviceFromModelId:newDevice.model dataDevice:newDevice];
            sensor.parent = weakself.gateway;
            [newDeviceArray addObject:sensor];
        }];
        
        self.gateway.subDevices = newDeviceArray;
        return;
    }
    
    for (MHDevice* newDevice in list) {
        BOOL found = NO;
        for (MHDevice*  oldDevice in _subDevices) {
            if ([newDevice.did isEqualToString:oldDevice.did]) {
                found = YES;
                break;
            }
        }
        
        //如果找到新的网关子设备
        if (!found) {
//            [self onConnectSucceed];
            NSLog(@"Gateway connected new device:%@", newDevice.did);
            self.subDeviceNew = (MHDeviceGatewayBase *)[MHDevFactory deviceFromModelId:newDevice.model dataDevice:newDevice];
            [self.subDeviceNew buildServices];
//            self.subDeviceNew.isNew = YES;
            self.subDeviceNew.isNewAdded = YES;
            [_gateway.subDevices addObject:self.subDeviceNew];
            [self addSubDeviceSucceed];
            break;
        }
    }
    _subDevices = list;
}

#pragma mark - 添加成功
- (void)addSubDeviceSucceed {
    [self gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"addDeviceSucceed:%@",self.controllerIdentifier]];

    [self stopProgressTimer];
    [_gateway stopZigbeeJoinWithSuccess:nil failure:nil];
    [self stopMonitorNewSubDevice];
    [_device stopAnimating];
    [_progressView dismiss];
    
    MHGatewayNamingSpeedViewController *namingVC = [[MHGatewayNamingSpeedViewController alloc] initWithSubDevice:self.subDeviceNew gatewayDevice:_gateway shareIdentifier:self.isShare serviceIndex:0];
    [self.navigationController pushViewController:namingVC animated:YES];
}

#pragma mark - 是否分享
- (void)getShareIdentifier {
    XM_WS(weakself);
    [_gateway getShareUserListSuccess:^(id obj) {
        weakself.isShare = [obj count] > 0 ? YES : NO;
    } failure:^(NSError *error) {
        
    }];
}

- (void)onMonitorTimer:(NSTimer* )timer {
    
    __weak typeof(self) weakSelf = self;
    [_gateway getSubDeviceListWithSuccess:^(id obj) {
        if ([obj isKindOfClass:[NSArray class]]) {
            [weakSelf onGetSubDevicesSucceed:obj];
        }
    } failuer:^(NSError *v) {
        
    }];
}

- (void)onConnectSucceed {
    _device.hidden = YES;
    _succeedView.hidden = NO;
    _btnCancel.hidden = YES;
    _btnDone.hidden = NO;
    _labelGuide.text = NSLocalizedStringFromTable(@"devcnnt.success.title",@"plugin_gateway","连接成功");
    
    _failedView.hidden = YES;
    _failedExtraTip.hidden = YES;
    _failedTips.hidden = YES;
    _failedExtraImage.hidden = YES;
    
    [self stopProgressTimer];
    [self stopMonitorNewSubDevice];
    [_device stopAnimating];
    [_progressView dismiss];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_progressTimer invalidate];
    _progressTimer = nil;
    [_monitorTimer invalidate];
    _monitorTimer = nil;
}



@end
