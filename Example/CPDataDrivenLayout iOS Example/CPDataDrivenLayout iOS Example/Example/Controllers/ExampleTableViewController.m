//
//  ExampleTableViewController.m
//  CPDataDrivenLayout iOS Example
//
//  Created by caoping on 12/14/15.
//  Copyright © 2015 caoping. All rights reserved.
//

#import "ExampleTableViewController.h"
#import <CPDataDrivenLayout/UITableView+CPDataDrivenLayout.h>
#import <SafariServices/SafariServices.h>

@interface ExampleTableViewController ()

@end

@implementation ExampleTableViewController

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    UIBarButtonItem *resetItem = [[UIBarButtonItem alloc] initWithTitle:@"reset"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(reset)];
    self.navigationItem.leftBarButtonItem = resetItem;
    
    UIBarButtonItem *reloadItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                             target:self
                                                                             action:@selector(reload)];

    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:self
                                                                             action:@selector(add)];
    self.navigationItem.rightBarButtonItems = @[reloadItem,addItem];
    
    
    self.tableView.dataDrivenLayoutEnabled = YES;
    [self reset];
}

- (void)reset {
    NSArray<NSDictionary *> *mockDataArray = @[@{@"title":@"mock website 1", @"url":@"http://www.bing.com/"},
                                               @{@"title":@"mock website 2", @"url":@"http://www.bing.com/"},
                                               @{@"title":@"mock website 3", @"url":@"http://www.bing.com/"},
                                               @{@"title":@"mock website 4", @"url":@"http://www.bing.com/"}];
    [self.tableView cp_reloadSections:[self sectionsByJSONArray:mockDataArray]];
}

- (void)reload {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    CPDataDrivenLayoutCellInfo *cellInfo = [self.tableView cp_cellInfoForRowAtIndexPath:indexPath];
    if (cellInfo) {
        cellInfo.rowHeight = 300;
        [self.tableView cp_reloadCellInfo:cellInfo atIndexPath:indexPath];
    }
}

- (void)add {
    CPDataDrivenLayoutSectionInfo *sectionInfo = [self.tableView cp_sectionInfoForSection:0];
    NSInteger index = sectionInfo?sectionInfo.numberOfObjects+1:1;
    NSDictionary *mockData = @{@"title":[@"mock website " stringByAppendingFormat:@"%@",@(index)],
                               @"url":@"http://www.bing.com/"};
    [self.tableView cp_appendSections:[self sectionsByJSONArray:@[mockData]]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark -

- (NSArray<CPDataDrivenLayoutSectionInfo *> *)sectionsByJSONArray:(NSArray<NSDictionary *> *)JSONArray {
    
    __weak typeof(self) weakSelf = self;
    
    NSMutableArray *cellInfoArray = [@[] mutableCopy];
    [JSONArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //you can use Cell Class or Cell Nib to create cell info
        CPDataDrivenLayoutCellInfo *cellInfo = [[CPDataDrivenLayoutCellInfo alloc] initWithCellClass:[UITableViewCell class] nib:nil cellReuseIdentifier:nil data:obj cellDidReuseCallback:^(UITableView *tableView, UITableViewCell *cell, NSIndexPath *indexPath, NSDictionary *data) {
            
            //config cell (Notes: be careful strong reference cycle, use weak self in callback)
            cell.textLabel.text = [data valueForKey:@"title"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        } cellDidSelectCallback:^(UITableView *tableView, id cell, NSIndexPath *indexPath, NSDictionary *data) {
            
            //cell did select event handler (Notes: be careful strong reference cycle, use weak self in callback)
            NSURL *url = [NSURL URLWithString:[data valueForKey:@"url"]];
            [weakSelf openWebsiteInSafariViewControllerWithURL:url title:[data valueForKey:@"title"]];
        }];
        cellInfo.rowHeight = 60;//specify row height stead use autolayout to calculate
        [cellInfoArray addObject:cellInfo];
    }];

    //return single section
    return @[[[CPDataDrivenLayoutSectionInfo alloc] initWithCellInfos:[cellInfoArray copy]]];
}

#pragma mark -

- (void)openWebsiteInSafariViewControllerWithURL:(NSURL *)url title:(NSString *)title {
    SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
    safariViewController.title = title;
    [self.navigationController pushViewController:safariViewController animated:YES];
}

@end
