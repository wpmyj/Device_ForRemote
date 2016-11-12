//
//  MHGatewayUserDefineCell.h
//  MiHome
//
//  Created by Lynn on 11/5/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHTableViewCell.h"

#define UserDefinedCellId @"UserDefinedCellId"

@interface MHGatewayUserDefineCell : MHTableViewCell

@property (nonatomic,strong) void (^deletePressed)(MHGatewayUserDefineCell *cell);

@end
