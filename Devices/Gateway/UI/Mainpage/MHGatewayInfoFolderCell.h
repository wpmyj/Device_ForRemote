//
//  MHGatewayInfoFolderCell.h
//  MiHome
//
//  Created by Lynn on 2/17/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHTableViewCell.h"

@interface MHGatewayInfoFolderCell : MHTableViewCell

@property (nonatomic,assign) BOOL shouldfold; //yes fold, no unfold
@property (nonatomic,assign) BOOL canUnfold; 
@property (nonatomic,strong) NSDictionary *folderInfo;
@property (nonatomic,copy) void (^longPressed)(MHGatewayInfoFolderCell *cell);

@end
