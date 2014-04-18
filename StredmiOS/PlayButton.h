//
//  PlayButton.h
//  StredmiOS
//
//  Created by Conner Fromknecht on 3/15/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomPlayButton : UIButton

@property (nonatomic) BOOL isPlaying;

@end


@interface PlayButton : UIButton

@property (nonatomic) float percentageOfSong;
@property (nonatomic, strong) CustomPlayButton* customPlayButton;
@property (nonatomic) float buttonAngle;

-(void)redrawButton;

@end

