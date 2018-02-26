//
//  SyViewStateMachine.h
//  Pods-SyStatefulComponent_Example
//
//  Created by Sylvanas on 26/02/2018.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, SyViewStateMachineState) {
    SyViewStateMachineStateNone = 0,
    SyViewStateMachineStateLoading,
    SyViewStateMachineStateError,
    SyViewStateMachineStateEmpty
};


@interface SyViewStateMachine : NSObject

@property (nonatomic, assign, readonly) SyViewStateMachineState sy_currentState;

@property (nonatomic, assign, readonly) SyViewStateMachineState sy_lastState;

- (instancetype)initWithView:(UIView *)view states:(NSDictionary *)states;

@property (nonatomic, weak) UIView *view;

- (UIView *)viewForState:(SyViewStateMachineState)state;

- (void)addView:(UIView *)view state:(SyViewStateMachineState)state;

- (void)removeViewForState:(SyViewStateMachineState)state;

- (void)transitionToState:(SyViewStateMachineState)state animated:(BOOL)animated completionHanlder:(void(^)(void))handler;

@end
