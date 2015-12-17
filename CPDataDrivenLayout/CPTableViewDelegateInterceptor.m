// The MIT License (MIT)
//
// Copyright (c) 2015 caoping <caoping.dev@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "CPTableViewDelegateInterceptor.h"
#import "UITableView+CPDataDrivenLayout.h"
#import <UITableView+FDTemplateLayoutCell/UITableView+FDTemplateLayoutCell.h>

@implementation CPTableViewDelegateInterceptor

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    CPDataDrivenLayoutSectionInfo *sectionInfo = [tableView cp_sectionInfoForSection:section];
    return sectionInfo?sectionInfo.titleForHeaderInSection:nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    CPDataDrivenLayoutSectionInfo *sectionInfo = [tableView cp_sectionInfoForSection:section];
    return sectionInfo?sectionInfo.titleForFooterInSection:nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *titles = [NSMutableArray new];
    [tableView.sections enumerateObjectsUsingBlock:^(CPDataDrivenLayoutSectionInfo * _Nonnull sectionInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        if (sectionInfo.indexTitle) {
            [titles addObject:sectionInfo.indexTitle];
        }
    }];
    return [titles copy];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:index];
    [tableView scrollToRowAtIndexPath:selectIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    return index;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPDataDrivenLayoutCellInfo *cellInfo = [tableView cp_cellInfoForRowAtIndexPath:indexPath];
    if (cellInfo.cellDidSelectCallback) {
        cellInfo.cellDidSelectCallback(tableView,[tableView cellForRowAtIndexPath:indexPath],indexPath,cellInfo.data);
    }
}

static Class __UIMutableIndexPathClass;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!__UIMutableIndexPathClass) {
        __UIMutableIndexPathClass = NSClassFromString(@"UIMutableIndexPath");
    }
    
    if ([indexPath isKindOfClass:__UIMutableIndexPathClass]) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    }
    
    CPDataDrivenLayoutCellInfo *cellInfo = [tableView cp_cellInfoForRowAtIndexPath:indexPath];
    if (cellInfo.rowHeight != UITableViewAutomaticDimension) {
        return cellInfo.rowHeight;
    }
    
    //use UITableView+FDTemplateLayoutCell to calculate row height (https://github.com/forkingdog/UITableView-FDTemplateLayoutCell)
    CGFloat height = [tableView fd_heightForCellWithIdentifier:cellInfo.cellReuseIdentifier cacheByIndexPath:indexPath configuration:^(UITableViewCell *cell) {
        if (cellInfo.cellDidReuseCallback) {
            cellInfo.cellDidReuseCallback(tableView,cell,indexPath,cellInfo.data);
        }
    }];
    
    return height;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return tableView.sections.count>0?tableView.sections.count:1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CPDataDrivenLayoutSectionInfo *sectionInfo = [tableView cp_sectionInfoForSection:section];
    if (sectionInfo) {
        return sectionInfo.numberOfObjects;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    CPDataDrivenLayoutCellInfo *cellInfo = [tableView cp_cellInfoForRowAtIndexPath:indexPath];
    if (cellInfo) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellInfo.cellReuseIdentifier
                                               forIndexPath:indexPath];
        
        if (cellInfo.cellDidReuseCallback) {
            cellInfo.cellDidReuseCallback(tableView,cell,indexPath,cellInfo.data);
        }
    }
    
    return cell;
}

@end
