//
//  BrowseTableCell.m
//  StredmiOS
//
//  Created by Conner Fromknecht on 3/12/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "BrowseTableCell.h"

@implementation BrowseTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
