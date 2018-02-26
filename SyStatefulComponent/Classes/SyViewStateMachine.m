//
//  SyViewStateMachine.m
//  Pods-SyStatefulComponent_Example
//
//  Created by Sylvanas on 26/02/2018.
//

#import "SyViewStateMachine.h"
#import <UIKit/UIKit.h>
#import "SyStatefulPlaceholderViewProtocol.h"

@interface SyViewStateMachine()

@property (nonatomic, strong) NSMutableDictionary *viewStore;

@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, strong) UIView *containerView;


@property (nonatomic, assign) SyViewStateMachineState sy_currentState;

@property (nonatomic, assign) SyViewStateMachineState sy_lastState;

@end

@implementation SyViewStateMachine

- (instancetype)initWithView:(UIView *)view states:(NSDictionary *)states {
    if (self = [super init]) {
        self.view = view;
        if (!states) {
            self.viewStore = states.mutableCopy;
        }
    }
    return self;
}

- (UIView *)viewForState:(SyViewStateMachineState)state {
    return self.viewStore[@(state).stringValue];
}

- (void)addView:(UIView *)view state:(SyViewStateMachineState)state {
    self.viewStore[@(state).stringValue] = view;
}

- (void)removeViewForState:(SyViewStateMachineState)state {
    self.viewStore[@(state).stringValue] = nil;
}

- (void)transitionToState:(SyViewStateMachineState)state animated:(BOOL)animated completionHanlder:(void (^)(void))handler {
    self.sy_lastState = state;
    
    __weak typeof (self) weakSelf = self;
    dispatch_async(self.queue, ^{
        
        NSLog(@"--->>>>><<><");
        __strong typeof (self) strongSelf = weakSelf;
        
        if (!strongSelf) {
            return ;
        }
        if (state == strongSelf.sy_currentState) {
            return;
        }
        
        dispatch_suspend(strongSelf.queue);
        strongSelf.sy_currentState = state;
        dispatch_block_t block = ^ {
            dispatch_resume(strongSelf.queue);
            NSLog(@"dispatch_resume");
            if (handler) {
                handler();
            }
        };
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            switch (state) {
                case SyViewStateMachineStateNone:
                    [strongSelf hideAllViewsWithAnimated:SyViewStateMachineStateNone completionHandler:block];
                    break;
                case SyViewStateMachineStateLoading:
                    [strongSelf showViewForState:SyViewStateMachineStateLoading animated:animated completionHandler:block];
                    break;
                case SyViewStateMachineStateError:
                    [strongSelf showViewForState:SyViewStateMachineStateError animated:animated completionHandler:block];
                    break;
                case SyViewStateMachineStateEmpty:
                    [strongSelf showViewForState:SyViewStateMachineStateEmpty animated:animated completionHandler:block];
                    break;
                default:
                    break;
            }
        });
        
    });
}

- (void)showViewForState:(SyViewStateMachineState)state animated:(BOOL)animated completionHandler:(void(^)(void))handler {
    self.containerView.frame = self.view.bounds;
    [self.view addSubview:self.containerView];
    
    NSMutableDictionary *store = self.viewStore;
    
    NSString *stateString = @(state).stringValue;
    
    UIView *newView = store[stateString];
    if (newView) {
        newView.alpha = animated ? 0.0 : 1.0;
        newView.translatesAutoresizingMaskIntoConstraints = NO;
        UIEdgeInsets insets = UIEdgeInsetsZero;
        
        
        if ([newView conformsToProtocol:@protocol(SyStatefulPlaceholderViewProtocol)]) {
            id<SyStatefulPlaceholderViewProtocol> temp = (id<SyStatefulPlaceholderViewProtocol>)newView;
            if ([temp respondsToSelector:@selector(placeholderViewInsets)]) {
                insets = [temp placeholderViewInsets];
            }
        }
        
        [self.containerView addSubview:newView];
        NSArray *vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[view]-bottom-|" options:0 metrics:@{@"top": @(insets.top), @"bottom": @(insets.bottom)} views:@{@"view": newView}];
        NSArray *hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-left-[view]-right-|" options:0 metrics:@{@"left": @(insets.left), @"right": @(insets.right)} views:@{@"view": newView}];
        
        [self.containerView addConstraints:vConstraints];
        [self.containerView addConstraints:hConstraints];
    }
    
    dispatch_block_t animations = ^{
        UIView *newView = store[stateString];
        if (newView) {
            newView.alpha = 1.0;
        }

    };
    
    dispatch_block_t animationCompletion = ^{
        [store enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIView * _Nonnull obj, BOOL * _Nonnull stop) {
            if (![stateString isEqualToString:key]) {
                [obj removeFromSuperview];
            }
        }];
        if (handler) {
            handler();
        }
    };
    
    [self animateChanges:animated animations:^{
        animations();
    } completion:^(BOOL flag) {
        animationCompletion();
    }];
}

- (void)animateChanges:(BOOL)animated animations:(void(^)(void))animations completion:(void(^)(BOOL))completion {
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            if (animations) {
                animations();
            }
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        if (completion) {
            completion(true);
        }
    }
}

- (void)hideAllViewsWithAnimated:(BOOL)animated completionHandler:(void(^)(void))handler {
    NSMutableDictionary *store = self.viewStore;
    
    dispatch_block_t animations = ^ {
        [store enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIView * _Nonnull obj, BOOL * _Nonnull stop) {
            obj.alpha = 0.0;
        }];
    };
    
    dispatch_block_t animationCompletion = ^ {
        [store enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIView * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        
        [self.containerView removeFromSuperview];
        if (handler) {
            handler();
        }
    };
    
    [self animateChanges:animated animations:^{
        animations();
    } completion:^(BOOL flag) {
        animationCompletion();
    }];
    
}


- (NSMutableDictionary *)viewStore {
    if (!_viewStore) {
        _viewStore = @{}.mutableCopy;
    }
    return _viewStore;
}

- (dispatch_queue_t)queue {
    if (!_queue) {
        _queue = dispatch_queue_create("com.sy.viewStateMachine.queue", DISPATCH_QUEUE_SERIAL);
    }
    return _queue;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return _containerView;
}

- (void)dealloc {
    NSLog(@"dealloc");
}

@end
