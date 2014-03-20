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
        self.backgroundColor = [UIColor clearColor];
        self.currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 70, 20)];
        self.currentTimeLabel.textAlignment = NSTextAlignmentCenter;
        
        self.durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 70, 40)];
        self.durationLabel.textColor = [UIColor whiteColor];
        self.durationLabel.textAlignment = NSTextAlignmentCenter;
                
        self.songScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(90, 10, 220, 40)];
        self.songScrollView.clipsToBounds = YES;
        
        self.songTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220, 40)];
        self.songTitleLabel.textColor = [UIColor whiteColor];
        self.songTitleLabel.font = [UIFont fontWithName:@"Helvetica Nueue" size:24.0];
        self.songTitleLabel.textAlignment = NSTextAlignmentLeft;

        [self.songScrollView addSubview:self.songTitleLabel];
        self.songScrollView.contentSize = self.songTitleLabel.frame.size;
        [self addSubview:self.songScrollView];
        
        [self addSubview:self.durationLabel];
//        [self addSubview:self.songTitleLabel];
//        [self addSubview:self.currentTimeLabel];
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
