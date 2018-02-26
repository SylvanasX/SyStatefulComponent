//
//  SyViewController.m
//  SyStatefulComponent
//
//  Created by SylvanasX on 02/26/2018.
//  Copyright (c) 2018 SylvanasX. All rights reserved.
//

#import "SyViewController.h"
#import "SyLoadingView.h"
#import "SyEmptyView.h"
#import "SyFailureView.h"
#import <SyStatefulComponent/UIView+SyStatefulComponent.h>

@interface SyViewController () <UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *array;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    __weak typeof (self) weakSelf = self;
    [self.view addSubview:self.tableView];
    self.tableView.frame = self.view.bounds;
    
    [self.view hasContent:^BOOL{
        return weakSelf.array.count > 0;
    }];
    self.view.sy_loadingView = [[SyLoadingView alloc] initWithFrame:self.view.bounds];
    self.view.sy_emptyView = [[SyEmptyView alloc] initWithFrame:self.view.bounds];
    self.view.sy_errorView = [[SyFailureView alloc] initWithFrame:self.view.bounds];
    
    [self.view setupInitialViewStateWithCompletionHandler:^{

    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refresh];
}

- (void)refresh {
    if (self.view.sy_lastState == SyStatefulStateLoading) {
        return;
    }
    
    [self.view startLoadingWithAnimated:YES completionHandler:^{
        
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // Success
        self.array = @[].mutableCopy;
        [self.array addObject:@"1321321"];
        [self.view endLoadingWithAnimated:YES error:nil completionHandler:^{

        }];
        
        
        // Error
//        [self.view endLoadingWithAnimated:YES error:[NSError errorWithDomain:@"test" code:-1 userInfo:nil] completionHandler:nil];
        
        // No Content
//        [self.view endLoadingWithAnimated:YES error:nil completionHandler:^{
//
//        }];
        
        [self.tableView reloadData];
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.text = self.array[indexPath.row];
    return cell;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        Class cellClass = [UITableViewCell class];
        [_tableView registerClass:cellClass forCellReuseIdentifier:NSStringFromClass(cellClass)];
    }
    return _tableView;
}

@end
