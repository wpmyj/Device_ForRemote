//
//  MHLumiChooseLogoTool.h
//  MiHome
//
//  Created by guhao on 3/21/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHDeviceGatewayBase.h"
#import "MHDeviceGatewayBaseService.h"

typedef void (^FinishCallBack)(id obj, NSError *error);

#define kISSHOWLOGOLISTKEY @"logoFalg_"

@interface MHLumiChooseLogoListManager : NSObject

+ (id)sharedInstance;

@property (nonatomic, assign) BOOL isAddSubDevice;
@property (nonatomic, strong) MHDeviceGatewayBaseService *currentService;
@property (nonatomic,strong) void (^setIconName)(NSString *iconName, NSString *iconId);
@property (nonatomic,strong) void (^setIconSuccessed)(MHDeviceGatewayBaseService *service);
/**
 *  选择图标列表
 *
 *  @param service            换图的service
 *  @param iconID             iconID,没有值时传@""
 *  @param identifier         标题字段(NSLocalizedStringFromTable(identifier, @"plugin_gateway", nil))
 *  @param segeViewController 当前带导航的视图控制器
 */
- (void)chooseLogoWithSevice:(MHDeviceGatewayBaseService *)service
                      iconID:(NSString *)iconID
             titleIdentifier:(NSString *)identifier
          segeViewController:(UIViewController *)segeViewController;

/**
 *  选择图标后的回调
 *
 *  @param imageID   imageID description
 *  @param imageName imageName description
 *  @param imageUrls imageUrlArray @[ @"mainpage_on", @"mainpage_off", @"device_on", @"device_off"]
 */
- (void)updateLogoWithImageID:(NSString *)imageID
                 andImageName:(NSString *)imageName
                 andImageUrls:(NSArray *)imageUrls;
/**
 *  读取缓存中是否显示图标flag
 *
 *  @param model  设备model
 *  @param finish 如果返回NO，则会读远程数据
 *
 *  @return 支持更换图标与否
 */
- (BOOL)isShowLogoListWithandDeviceModel:(NSString *)model finish:(FinishCallBack)finish;
@end
