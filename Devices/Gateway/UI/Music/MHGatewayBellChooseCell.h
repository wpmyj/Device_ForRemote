//
//  MHGatewayBellChooseCell.h
//  MiHome
//
//  Created by Lynn on 10/30/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHTableViewCell.h"

#define BellChooseCellId @"bellChooseCellId"

@interface MHGatewayBellChooseCell : MHTableViewCell

@property (nonatomic,strong) void (^uploadPressed)(MHGatewayBellChooseCell *cell);
@property (nonatomic,strong) void (^deletePressed)(MHGatewayBellChooseCell *cell);

@end
