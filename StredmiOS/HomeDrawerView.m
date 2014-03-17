//
//  HomeDrawerView.m
//  StredmiOS
//
//  Created by Conner Fromknecht on 3/16/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "HomeDrawerView.h"

@implementation HomeDrawerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 70, 20)];
        self.currentTimeLabel.textAlignment = NSTextAlignmentCenter;
        self.durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 70, 20)];
        self.durationLabel.textAlignment = NSTextAlignmentCenter;
        self.songTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 240, 40)];
        self.songTitleLabel.font = [UIFont fontWithName:@"System" size:24.0];
        self.songTitleLabel.textAlignment = NSTextAlignmentLeft;

        
        [self addSubview:self.durationLabel];
        [self addSubview:self.songTitleLabel];
        [self addSubview:self.currentTimeLabel];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
