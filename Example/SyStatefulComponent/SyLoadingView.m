//
//  SyLoadingView.m
//  SyStatefulComponent_Example
//
//  Created by Sylvanas on 26/02/2018.
//  Copyright © 2018 SylvanasX. All rights reserved.
//

#import "SyLoadingView.h"

@interface SyLoadingView()
@property (nonatomic, strong) UIActivityIndicatorView *view;
@end

@implementation SyLoadingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor redColor];
    [self addSubview:self.view];
    [self.view startAnimating];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.view.center = self.center;
}

- (UIActivityIndicatorView *)view {
    if (!_view) {
        _view = [[UIActivityIndicatorView alloc] init];
    }
    return _view;
}


@end
