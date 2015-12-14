//
//  ExampleTableViewController.m
//  CPDataDrivenLayout iOS Example
//
//  Created by caoping on 12/14/15.
//  Copyright © 2015 alibaba. All rights reserved.
//

#import "ExampleTableViewController.h"
#import <CPDataDrivenLayout/UITableView+CPDataDrivenLayout.h>
#import <SafariServices/SafariServices.h>

@interface ExampleTableViewController ()

@end

@implementation ExampleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray<NSDictionary *> *mockDataArray = @[@{@"title":@"mock website 1", @"url":@"http://www.bing.com/"},
                                               @{@"title":@"mock website 2", @"url":@"http://www.bing.com/"},
                                               @{@"title":@"mock website 3", @"url":@"http://www.bing.com/"},
                                               @{@"title":@"mock website 4", @"url":@"http://www.bing.com/"},
                                               @{@"title":@"mock website 5", @"url":@"http://www.bing.com/"},
                                               @{@"title":@"mock website 6", @"url":@"http://www.bing.com/"},
                                               @{@"title":@"mock website 7", @"url":@"http://www.bing.com/"}];
    self.tableView.dataDrivenLayoutEnabled = YES;
    [self.tableView cp_reloadSections:[self sectionsByJSONArray:mockDataArray]];
}

- (NSArray<CPDataDrivenLayoutSectionInfo *> *)sectionsByJSONArray:(NSArray<NSDictionary *> *)JSONArray {
    
    __weak typeof(self) weakSelf = self;
    
    NSMutableArray *cellInfoArray = [@[] mutableCopy];
    [JSONArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //you can use Cell Class or Cell Nib to create cell info
        CPDataDrivenLayoutCellInfo *cellInfo = [[CPDataDrivenLayoutCellInfo alloc] initWithCellClass:[UITableViewCell class] nib:nil data:obj cellDidReuseCallback:^(UITableView *tableView, UITableViewCell *cell, NSIndexPath *indexPath, NSDictionary *data) {
            
            //config cell (Notes: be careful strong reference cycle, use weak self in callback)
            cell.textLabel.text = [data valueForKey:@"title"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        } cellDidSelectCallback:^(UITableView *tableView, id cell, NSIndexPath *indexPath, NSDictionary *data) {
            
            //cell did select event handler (Notes: be careful strong reference cycle, use weak self in callback)
            NSURL *url = [NSURL URLWithString:[data valueForKey:@"url"]];
            [weakSelf openWebsiteInSafariViewControllerWithURL:url title:[data valueForKey:@"title"]];
        }];
        cellInfo.rowHeight = 44;//specify row height stead use autolayout to calculate
        [cellInfoArray addObject:cellInfo];
    }];

    //return single section
    return @[[[CPDataDrivenLayoutSectionInfo alloc] initWithCellInfos:[cellInfoArray copy]]];
}

- (void)openWebsiteInSafariViewControllerWithURL:(NSURL *)url title:(NSString *)title {
    SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
    safariViewController.title = title;
    [self.navigationController pushViewController:safariViewController animated:YES];
}

@end
