//
//  MHLuTableViewController.h
//  MiHome
//
//  Created by Lynn on 1/4/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHTableViewControllerInternal.h"

@class MHLuTableViewController;

@protocol MHLuTableViewControllerInternalDelegate <NSObject>
@optional

- (void)deleteTableViewCell:(NSIndexPath *)indexPath;

@end

@interface MHLuTableViewController : MHTableViewControllerInternal

@property (nonatomic,assign) BOOL canDelete;
@property (nonatomic, weak) id<MHLuTableViewControllerInternalDelegate> luDelegate;

@end
