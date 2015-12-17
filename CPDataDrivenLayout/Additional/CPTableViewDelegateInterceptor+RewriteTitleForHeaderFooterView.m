//
//  CPTableViewDelegateInterceptor+RewriteTitleForHeaderFooterView.m
//  Pods
//
//  Created by caoping on 12/17/15.
//
//

#import "CPTableViewDelegateInterceptor+RewriteTitleForHeaderFooterView.h"
#import "UITableView+CPDataDrivenLayout.h"

@implementation CPTableViewDelegateInterceptor (RewriteTitleForHeaderFooterView)

/**
 *  rewrite title for header (the section header title is uppercase string by default)
 */
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    NSString *titleForHeaderInSection = [tableView cp_sectionInfoForSection:section].titleForHeaderInSection;
    if (titleForHeaderInSection && [view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        [view setValue:titleForHeaderInSection forKeyPath:@"_label.text"];
    }
}

@end
