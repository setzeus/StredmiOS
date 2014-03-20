//
//  PlayButton.m
//  StredmiOS
//
//  Created by Conner Fromknecht on 3/15/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "PlayButton.h"

@interface PlayButton()

@end

@implementation PlayButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}


-(void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
    CGContextAddEllipseInRect(ctx, CGRectMake(10, 10, self.frame.size.width-20, self.frame.size.height-20));
    CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor colorWithRed:(247/255.0) green:(247/255.0) blue:(247/255.0) alpha:1.0] CGColor]));
    CGContextEOFillPath(ctx);
    
    if (!self.invisible) {
        if (!self.isPlaying) {
            CGContextBeginPath(ctx);
            CGContextMoveToPoint   (ctx, 80, 80);  // top left
            CGContextAddLineToPoint(ctx, 160, 120);  // mid right
            CGContextAddLineToPoint(ctx, 80, 160);  // bottom left
            CGContextClosePath(ctx);
            
            CGContextSetRGBFillColor(ctx, 247/255.0, 247/255.0, 247/255.0, 1.0);
            CGContextFillPath(ctx);
        }
        else {
            [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9] setFill];
            UIRectFill(CGRectMake(80, 80, 30, 80));
            UIRectFill(CGRectMake(130, 80, 30, 80));
        }
        
        CGContextSetLineWidth(ctx, 8.0);
        
        CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:90/255.0 green:200/255.0 blue:250/255.0 alpha:.9] CGColor]);
        static CGFloat startingRadians = -1.5709353072;
        CGContextAddArc(ctx, 120, 120, 115, startingRadians, startingRadians + 2*3.1415926535*self.percentageOfSong, 0);
        CGContextStrokePath(ctx);

    }
    else {
        CGContextSetLineWidth(ctx, 2.0);
        CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9] CGColor]);
    
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, 20, 120);
        CGContextAddLineToPoint(ctx, 220, 120);
        
        CGContextStrokePath(ctx);
    }
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
