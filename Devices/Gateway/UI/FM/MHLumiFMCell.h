//
//  MHLumiFMCell.h
//  MiHome
//
//  Created by Lynn on 11/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHTableViewCell.h"

@interface MHLumiFMCell : MHTableViewCell

@property (nonatomic,assign) BOOL isAnimation;
@property (nonatomic,strong) void (^onCollectionClicked)(MHLumiFMCell *cell);

@end
