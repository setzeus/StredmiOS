//
//  HomeView.m
//  StredmiOS
//
//  Created by Conner Fromknecht on 3/20/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "HomeView.h"
#import "JNAppDelegate.h"

@implementation HomeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initMethod];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initMethod];
    }
    return self;
}

-(void)random:(id)sender {
    JNAppDelegate *jnad = (JNAppDelegate*)[[UIApplication sharedApplication] delegate];
    [jnad.playerView playRandom];
}

-(void)initMethod {
    self.randomButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.randomButton.frame = CGRectMake(0, self.frame.size.height/2 -100, 320, 100);
    self.randomButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:28.0];
    [self.randomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.randomButton setTitle:@"random" forState:UIControlStateNormal];
    self.randomButton.backgroundColor = [UIColor clearColor];
    [self.randomButton addTarget:self action:@selector(random:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.randomButton];
    
    self.searchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.searchButton.frame = CGRectMake(0, self.frame.size.height/2, 320, 100);
    self.searchButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:28.0];
    [self.searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.searchButton setTitle:@"search" forState:UIControlStateNormal];
    self.searchButton.backgroundColor = [UIColor clearColor];
    [self addSubview:self.searchButton];
    
}

-(void)drawRect:(CGRect)rect {
    NSLog(@"DrawRect");
    float halfHeight = self.frame.size.height/2;
    float inset = (self.frame.size.width-240)/2;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, CGRectMake(inset, halfHeight-120, 240, 240));
    CGContextAddEllipseInRect(ctx, CGRectMake(inset + 10, halfHeight - 110, 220, 220));
    CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor colorWithRed:(247/255.0) green:(247/255.0) blue:(247/255.0) alpha:1.0] CGColor]));
    CGContextEOFillPath(ctx);
    
    CGContextSetLineWidth(ctx, 2.0);
    CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9] CGColor]);
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, inset + 20, halfHeight);
    CGContextAddLineToPoint(ctx, 340-2*inset, halfHeight);
    
    CGContextStrokePath(ctx);
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
