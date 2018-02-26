//
//  UIView+SyStatefulComponent.m
//  Pods-SyStatefulComponent_Example
//
//  Created by Sylvanas on 26/02/2018.
//

#import "UIView+SyStatefulComponent.h"
#import "SyViewStateMachine.h"
#import <objc/runtime.h>

@implementation UIView (SyStatefulComponent)

@dynamic sy_errorView, sy_emptyView, sy_loadingView;

- (SyViewStateMachine *)sy_stateMachine {
    SyViewStateMachine *machine = objc_getAssociatedObject(self, _cmd);
    if (!machine) {
        machine = [[SyViewStateMachine alloc] initWithView:self states:@{}];
        objc_setAssociatedObject(self, _cmd, machine, OBJC_ASSOCIATION_RETAIN);
    }
    return machine;
}

- (void)hasContent:(BOOL (^)(void))handler {
     objc_setAssociatedObject(self, @selector(contentBlock), handler, OBJC_ASSOCIATION_COPY);
}

- (BOOL (^)(void))contentBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (SyStatefulState)sy_currentState {
    switch (self.sy_stateMachine.sy_currentState) {
        case SyViewStateMachineStateNone:
            return SyStatefulStateContent;
            break;
        case SyViewStateMachineStateLoading:
            return SyStatefulStateLoading;
            break;
        case SyViewStateMachineStateError:
            return SyStatefulStateError;
            break;
        case SyViewStateMachineStateEmpty:
            return SyStatefulStateEmpty;
            break;
    }
}

- (SyStatefulState)sy_lastState {
    switch (self.sy_stateMachine.sy_lastState) {
        case SyViewStateMachineStateNone:
            return SyStatefulStateContent;
            break;
        case SyViewStateMachineStateLoading:
            return SyStatefulStateLoading;
            break;
        case SyViewStateMachineStateError:
            return SyStatefulStateError;
            break;
        case SyViewStateMachineStateEmpty:
            return SyStatefulStateEmpty;
            break;
    }
}

- (UIView *)sy_loadingView {
    return [self.sy_stateMachine viewForState:SyViewStateMachineStateLoading];
}

- (void)setSy_loadingView:(UIView *)sy_loadingView {
    [self.sy_stateMachine addView:sy_loadingView state:SyViewStateMachineStateLoading];
}

- (UIView *)errorView {
    return [self.sy_stateMachine viewForState:SyViewStateMachineStateError];
}

- (void)setSy_errorView:(UIView *)sy_errorView {
    [self.sy_stateMachine addView:sy_errorView state:SyViewStateMachineStateError];
}

- (UIView *)sy_emptyView {
    return [self.sy_stateMachine viewForState:SyViewStateMachineStateEmpty];
}

- (void)setSy_emptyView:(UIView *)sy_emptyView {
    [self.sy_stateMachine addView:sy_emptyView state:SyViewStateMachineStateEmpty];
}

- (void)setupInitialViewStateWithCompletionHandler:(void (^)(void))handler {
    BOOL isLoading = SyStatefulStateLoading == self.sy_lastState;
    BOOL isError = SyStatefulStateError == self.sy_lastState;
    
    NSError *error = isError ? [NSError errorWithDomain:@"com.sy" code:-1 userInfo:nil] : nil;

    [self transitionViewState:isLoading error:error animated:false completionHandler:^{
        if (handler) {
            handler();
        }
    }];
}

- (void)startLoadingWithAnimated:(BOOL)animated completionHandler:(void (^)(void))handler {
    [self transitionViewState:true error:nil animated:animated completionHandler:^{
        if (handler) {
            handler();
        }
    }];
}

- (void)endLoadingWithAnimated:(BOOL)animated error:(NSError *)error completionHandler:(void (^)(void))handler {
    [self transitionViewState:false error:error animated:animated completionHandler:^{
        if (handler) {
            handler();
        }
    }];
}

- (void)transitionViewState:(BOOL)loading error:(NSError *)error animated:(BOOL)animated completionHandler:(void (^)(void))handler {
    if (self.contentBlock) {
        if (self.contentBlock()) {
            if (error) {
                [self handleErrorWhenContentAvailable:error];
            }
            [self.sy_stateMachine transitionToState:SyViewStateMachineStateNone animated:animated completionHanlder:^{
                if (handler) {
                    handler();
                }
            }];
            return;
        } else {
            SyStatefulState newState = SyStatefulStateEmpty;
            if (loading) {
                newState = SyStatefulStateLoading;
            } else if (error) {
                newState = SyStatefulStateError;
            }
            [self.sy_stateMachine transitionToState:[self mapStatefulState:newState] animated:animated completionHanlder:^{
                if (handler) {
                    handler();
                }
            }];
        }
    }
}

- (SyViewStateMachineState)mapStatefulState:(SyStatefulState)state {
    switch (state) {
        case SyStatefulStateEmpty:
            return SyViewStateMachineStateEmpty;
            break;
        case SyStatefulStateError:
            return SyViewStateMachineStateError;
            break;
        case SyStatefulStateContent:
            return SyViewStateMachineStateNone;
            break;
        case SyStatefulStateLoading:
            return SyViewStateMachineStateLoading;
            break;
    }
}

- (void)handleErrorWhenContentAvailable:(NSError *)error {
    
}
@end
