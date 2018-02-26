//
//  SyEmptyView.m
//  SyStatefulComponent_Example
//
//  Created by Sylvanas on 26/02/2018.
//  Copyright © 2018 SylvanasX. All rights reserved.
//

#import "SyEmptyView.h"

@implementation SyEmptyView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor yellowColor];
    return self;
}


@end
