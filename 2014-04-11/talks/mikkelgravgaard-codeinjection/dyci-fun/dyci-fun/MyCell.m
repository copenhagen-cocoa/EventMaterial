//
// Created by Mikkel Gravgaard on 09/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MyCell.h"


@implementation MyCell {

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [UILabel new];
        self.label.frame = self.bounds;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.label];
    }

    return self;
}


@end