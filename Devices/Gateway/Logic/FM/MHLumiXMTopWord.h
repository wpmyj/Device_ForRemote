//
//  MHLumiXMTopWord.h
//  MiHome
//
//  Created by Lynn on 1/19/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHLumiXMTopWord : MHDataBase <NSCoding> 

@property (nonatomic,strong) NSString *search_word;
@property (nonatomic,strong) NSString *degree;
@property (nonatomic,strong) NSNumber *count;

@end
