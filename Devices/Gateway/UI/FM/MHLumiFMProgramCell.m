//
//  MHLumiFMCell.m
//  MiHome
//
//  Created by Lynn on 11/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiFMProgramCell.h"
#import "MHLumiXMProgram.h"
#import "MHlumiXMAnnouncer.h"

#define CellSize  65.f

@interface MHLumiFMProgramCell ()

@end

@implementation MHLumiFMProgramCell
{
    UIImageView *           _coverImageView;
    UILabel *               _contentTitle;
    UILabel *               _contentSubTitle;
    UILabel *               _programTime;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self buildSubviews];
    }
    return self;
}

- (void)configureWithDataObject:(id)object {
    
    MHLumiXMProgram *program = (MHLumiXMProgram *)object;
    _contentTitle.text = program.program_name;
    NSString *announcers = @"";
    for (MHLumiXMAnnouncer *ann in program.live_announcers){
        announcers = [NSString stringWithFormat:@"%@ %@",announcers, ann.nickname];
    }
    _contentSubTitle.text = announcers;
    _programTime.text = [NSString stringWithFormat:@"%@ - %@",program.programStartTime,program.programEndTime];
}

- (void)setIsAnimation:(BOOL)isAnimation {
    _isAnimation = isAnimation ;
    
    if (isAnimation) {
        _coverImageView.hidden = NO;
        [self animationStart];
    }
    else  {
        _coverImageView.hidden = YES;
        
        CGFloat screenWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);
        _contentTitle.frame = CGRectMake( 20.f,
                                         10.f,
                                         screenWidth - 100,
                                         28.f);
        _contentTitle.textColor = [UIColor colorWithWhite:1.0 alpha:0.4];
        _contentSubTitle.textColor = [UIColor colorWithWhite:1.0 alpha:0.4f];
        _programTime.textColor = [UIColor colorWithWhite:1.0 alpha:0.4f];
    }
}

- (void)animationStart {
    CGFloat screenWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);

    NSArray *imageArray = @[ [UIImage imageNamed:@"lumi_fm_program_animate1"] ,
                             [UIImage imageNamed:@"lumi_fm_program_animate2"] ,
                             [UIImage imageNamed:@"lumi_fm_program_animate3"] ,
                             [UIImage imageNamed:@"lumi_fm_program_animate4"] ];
    _coverImageView.animationImages = imageArray;
    _coverImageView.animationDuration = 1.5;
    [_coverImageView startAnimating];
    
    _contentTitle.frame = CGRectMake( 45.f,
                                     10.f,
                                     screenWidth - 100,
                                     28.f);
    _contentTitle.textColor = [UIColor colorWithWhite:1.0 alpha:1];
    _contentSubTitle.textColor = [UIColor colorWithWhite:1.0 alpha:1.f];
    _programTime.textColor = [UIColor colorWithWhite:1.0 alpha:0.8f];
}

- (void)buildSubviews {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    CGFloat screenWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    
    _coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.f, 13.f, 20.f, 20.f)];
    _coverImageView.image = [UIImage imageNamed:@"lumi_fm_program_animate1"];
    if(self.isAnimation) _coverImageView.hidden = NO;
    else _coverImageView.hidden = YES;
    [self.contentView addSubview:_coverImageView];
    
    CGFloat buffer ;
    if(self.isAnimation) buffer = 45.f;
    else buffer = 20.f;
    _contentTitle = [[UILabel alloc] initWithFrame:CGRectMake( buffer,
                                                              10.f,
                                                              screenWidth - buffer * 2 - 90,
                                                              28.f)];
    if(self.isAnimation) _contentTitle.textColor = [UIColor colorWithWhite:1.0 alpha:1];
    else _contentTitle.textColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    _contentTitle.backgroundColor = [UIColor clearColor];
    _contentTitle.font = [UIFont systemFontOfSize:15.f];
    [self.contentView addSubview:_contentTitle];
    
    _contentSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(18.f, CellSize * 0.5, screenWidth - 36.f, 25.f)];
    
    if(self.isAnimation) _contentSubTitle.textColor = [UIColor colorWithWhite:1.0 alpha:1.f];
    else _contentSubTitle.textColor = [UIColor colorWithWhite:1.0 alpha:0.4f];
    
    _contentSubTitle.backgroundColor = [UIColor clearColor];
    _contentSubTitle.font = [UIFont systemFontOfSize:13.f];
    [self.contentView addSubview:_contentSubTitle];
    
    _programTime = [[UILabel alloc ] initWithFrame:CGRectMake(screenWidth - 115, 10.f, 95, 24)];
    _programTime.text = @"09:00 - 10:00";
    _programTime.textAlignment = NSTextAlignmentRight;
    
    if(self.isAnimation) _programTime.textColor = [UIColor colorWithWhite:1.0 alpha:0.8f];
    else _programTime.textColor = [UIColor colorWithWhite:1.0 alpha:0.4f];
    
    _programTime.backgroundColor = [UIColor clearColor];
    _programTime.font = [UIFont systemFontOfSize:13.f];
    [self addSubview:_programTime];
    
    UIView *bottomLine = [[UIView alloc] init];
    [bottomLine setFrame:CGRectMake(20.0f, CellSize - 1.0f, screenWidth - 40.f, 0.5f)];
    bottomLine.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.3f];
    [self.contentView addSubview:bottomLine];
}

@end
