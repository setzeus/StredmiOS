//
//  RemoteApplication.h
//  StredmiOS
//
//  Created by Conner Fromknecht on 4/14/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RemoteApplication : UIApplication

-(void)remoteControlReceivedWithEvent:(UIEvent *)event;
-(BOOL)canBecomeFirstResponder;

@end
