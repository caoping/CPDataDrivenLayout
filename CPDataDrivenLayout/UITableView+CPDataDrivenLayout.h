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

#import <UIKit/UIKit.h>
#import "CPDataDrivenLayoutSectionInfo.h"

@interface UITableView (CPDataDrivenLayout)

@property (nonatomic) BOOL dataDrivenLayoutEnabled;
@property (nonatomic, readonly) NSArray<CPDataDrivenLayoutSectionInfo *> * _Nonnull sections;

#pragma mark - Reloading

- (void)cp_reloadSections:(NSArray<CPDataDrivenLayoutSectionInfo *> * _Nonnull)sections;
- (void)cp_reloadCellInfo:(CPDataDrivenLayoutCellInfo * _Nonnull)cellInfo atIndexPath:(NSIndexPath * _Nonnull)indexPath;

#pragma mark - Appending And Inserting

- (void)cp_appendSections:(NSArray<CPDataDrivenLayoutSectionInfo *> * _Nonnull)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void)cp_insertCellInfos:(NSArray<CPDataDrivenLayoutCellInfo *> * _Nonnull)cellInfos atIndexPaths:(NSArray<NSIndexPath *> * _Nonnull)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;

#pragma mark - Deleting

- (void)cp_deleteCellInfoAtIndexPath:(NSIndexPath * _Nonnull)indexPath withRowAnimation:(UITableViewRowAnimation)animation;
- (void)cp_deleteCellInfosInSection:(NSInteger)section atIndexSet:(NSIndexSet * _Nonnull)indexSet withRowAnimation:(UITableViewRowAnimation)animation;

#pragma mark - Get Cell And Section Info

- (CPDataDrivenLayoutCellInfo * _Nullable)cp_cellInfoForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (CPDataDrivenLayoutSectionInfo * _Nullable)cp_sectionInfoForSection:(NSInteger)section;

@end
