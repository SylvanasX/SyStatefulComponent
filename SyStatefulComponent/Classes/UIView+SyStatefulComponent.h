//
//  UIView+SyStatefulComponent.h
//  Pods-SyStatefulComponent_Example
//
//  Created by Sylvanas on 26/02/2018.
//

#import <UIKit/UIKit.h>
#import "SyViewStateMachine.h"

typedef NS_ENUM(NSInteger, SyStatefulState) {
    SyStatefulStateContent,
    SyStatefulStateLoading,
    SyStatefulStateError,
    SyStatefulStateEmpty
};


@interface UIView (SyStatefulComponent)

@property (nonatomic, strong, readonly) SyViewStateMachine *sy_stateMachine;

@property (nonatomic, assign, readonly) SyStatefulState sy_currentState;

@property (nonatomic, assign, readonly) SyStatefulState sy_lastState;

@property (nonatomic, strong) UIView *sy_loadingView;

@property (nonatomic, strong) UIView *sy_errorView;

@property (nonatomic, strong) UIView *sy_emptyView;

- (void)setupInitialViewStateWithCompletionHandler:(void(^)(void))handler;

- (void)startLoadingWithAnimated:(BOOL)animated completionHandler:(void(^)(void))handler;

- (void)endLoadingWithAnimated:(BOOL)animated error:(NSError *)error completionHandler:(void(^)(void))handler;

- (void)transitionViewState:(BOOL)loading error:(NSError *)error animated:(BOOL)animated completionHandler:(void(^)(void))handler;

- (void)hasContent:(BOOL(^)(void))handler;

@property (nonatomic, copy, readonly) BOOL(^contentBlock)(void);

- (void)handleErrorWhenContentAvailable:(NSError *)error;

@end
