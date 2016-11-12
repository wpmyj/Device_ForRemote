//
//  MHGatewaySensorSceneCell.h
//  MiHome
//
//  Created by Lynn on 3/8/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHTableViewCell.h"

#define TableViewCellHeight 60.f

@interface MHGatewaySensorSceneCell : MHTableViewCell

@property (nonatomic, copy) void (^relocateRecordBlock)();
@property (nonatomic, copy) void (^offlineRecord)();

@end
