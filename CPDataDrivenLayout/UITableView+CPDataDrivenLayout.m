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

#import "UITableView+CPDataDrivenLayout.h"
#import <objc/runtime.h>
#import <UITableView+FDTemplateLayoutCell/UITableView+FDTemplateLayoutCell.h>

static BOOL _isInterceptedSelector(SEL sel)
{
    return (//UITableViewDataSource
            sel == @selector(numberOfSectionsInTableView:) ||
            sel == @selector(tableView:numberOfRowsInSection:) ||
            sel == @selector(tableView:cellForRowAtIndexPath:) ||
            
            //UITableViewDelegate
            sel == @selector(tableView:heightForRowAtIndexPath:) ||
            sel == @selector(tableView:didSelectRowAtIndexPath:) ||
            sel == @selector(tableView:willDisplayCell:forRowAtIndexPath:) ||
            sel == @selector(tableView:willDisplayHeaderView:forSection:) ||
            
            sel == @selector(tableView:sectionForSectionIndexTitle:atIndex:) ||
            sel == @selector(sectionIndexTitlesForTableView:) ||
            
            sel == @selector(tableView:titleForHeaderInSection:) ||
            sel == @selector(tableView:titleForFooterInSection:)
            );
}

@interface _CPTableViewProxy : NSProxy

@property (nonatomic, weak) id<NSObject> target;
@property (nonatomic, weak) UITableView *interceptor;

- (instancetype)initWithTarget:(id<NSObject>)target interceptor:(UITableView *)interceptor;

@end

@implementation _CPTableViewProxy

- (instancetype)initWithTarget:(id<NSObject>)target interceptor:(UITableView *)interceptor
{
    if (!self) {
        return nil;
    }
    _target = target;
    _interceptor = interceptor;
    
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return (_isInterceptedSelector(aSelector) || [_target respondsToSelector:aSelector]);
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if (_isInterceptedSelector(aSelector)) {
        return _interceptor;
    }
    
    return [_target respondsToSelector:aSelector] ? _target : nil;
}

@end

@implementation UITableView (CPDataDrivenLayout)

+ (void)load {
    Class class = [self class];
    Method originalDelegateSetter = class_getInstanceMethod(class, @selector(setDelegate:));
    Method myDelegateSetter = class_getInstanceMethod(class, @selector(cp_setDelegate:));
    if (originalDelegateSetter && myDelegateSetter) {
        method_exchangeImplementations(originalDelegateSetter, myDelegateSetter);
    }
    
    Method originalDataSourceSetter = class_getInstanceMethod(class, @selector(setDataSource:));
    Method myDataSourceSetter = class_getInstanceMethod(class, @selector(cp_setDataSource:));
    if (originalDataSourceSetter && myDataSourceSetter) {
        method_exchangeImplementations(originalDataSourceSetter, myDataSourceSetter);
    }
}

#pragma mark - Associated Object

- (BOOL)dataDrivenLayoutEnabled {
    return [objc_getAssociatedObject(self, @selector(dataDrivenLayoutEnabled)) boolValue];
}

- (void)setDataDrivenLayoutEnabled:(BOOL)dataDrivenLayoutEnabled {
    objc_setAssociatedObject(self, @selector(dataDrivenLayoutEnabled), @(dataDrivenLayoutEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setDelegate:self.delegate];
    [self setDataSource:self.dataSource];
}

- (_CPTableViewProxy *)tableViewDelegateProxy {
    return objc_getAssociatedObject(self, @selector(tableViewDelegateProxy));
}

- (void)setTableViewDelegateProxy:(_CPTableViewProxy *)tableViewDelegateProxy {
    objc_setAssociatedObject(self, @selector(tableViewDelegateProxy), tableViewDelegateProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_CPTableViewProxy *)tableViewDataSourceProxy {
    return objc_getAssociatedObject(self, @selector(tableViewDataSourceProxy));
}

- (void)setTableViewDataSourceProxy:(_CPTableViewProxy *)tableViewDataSourceProxy {
    objc_setAssociatedObject(self, @selector(tableViewDataSourceProxy), tableViewDataSourceProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<CPDataDrivenLayoutSectionInfo *> *)sections {
    NSArray<CPDataDrivenLayoutSectionInfo *> * sectionArray = objc_getAssociatedObject(self, @selector(sections));
    if (!sectionArray) {
        sectionArray = @[];
    }
    return sectionArray;
}

- (void)setSections:(NSArray<CPDataDrivenLayoutSectionInfo *> *)sections {
    objc_setAssociatedObject(self, @selector(sections), sections?:@[], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Delegate and DataSource Proxy

- (void)cp_setDelegate:(id<UITableViewDelegate>)delegate {
    id delegateProxy;
    if (self.dataDrivenLayoutEnabled) {
        delegateProxy = [[_CPTableViewProxy alloc] initWithTarget:delegate interceptor:self];
        [self cp_setDelegate:delegateProxy];
    }else{
        __weak id target = delegate;
        if ([delegate isKindOfClass:[_CPTableViewProxy class]]) {
            target = [self.tableViewDelegateProxy target];
        }
        [self cp_setDelegate:target];
    }
    [self setTableViewDelegateProxy:delegateProxy];
}

- (void)cp_setDataSource:(id<UITableViewDataSource>)dataSource {
    id dataSourceProxy;
    if (self.dataDrivenLayoutEnabled) {
        dataSourceProxy = [[_CPTableViewProxy alloc] initWithTarget:dataSource interceptor:self];
        [self cp_setDataSource:dataSourceProxy];
    }else{
        __weak id target = dataSource;
        if ([dataSource isKindOfClass:[_CPTableViewProxy class]]) {
            target = [self.tableViewDataSourceProxy target];
        }
        [self cp_setDataSource:target];
    }
    [self setTableViewDataSourceProxy:dataSourceProxy];
}

#pragma mark - Reloading

- (void)cp_reloadSections:(NSArray<CPDataDrivenLayoutSectionInfo *> * _Nonnull)sections {
    if (!self.dataDrivenLayoutEnabled) {
        return;
    }
    [self setSections:sections];
    [self registerCellWithSections:sections];
    [self reloadData];
}

- (void)cp_reloadCellInfo:(CPDataDrivenLayoutCellInfo * _Nonnull)cellInfo atIndexPath:(NSIndexPath * _Nonnull)indexPath {
    CPDataDrivenLayoutSectionInfo *sectionInfo = [self cp_sectionInfoForSection:indexPath.section];
    if (sectionInfo) {
        [sectionInfo setCellInfo:cellInfo atIndex:indexPath.row];
        
        //if cell is visible, reload immediately
        NSArray *indexPaths = [self indexPathsForVisibleRows];
        __weak typeof(self) weakSelf = self;
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj compare:indexPath] == NSOrderedSame) {
                *stop = YES;
                [UIView setAnimationsEnabled:NO];
                [weakSelf beginUpdates];
                [weakSelf reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf endUpdates];
                [UIView setAnimationsEnabled:YES];
            }
        }];
    }
}

#pragma mark - Appending And Inserting

- (void)cp_appendSections:(NSArray<CPDataDrivenLayoutSectionInfo *> * _Nonnull)sections withRowAnimation:(UITableViewRowAnimation)animation {
    NSMutableArray *indexPaths = [NSMutableArray new];
    NSMutableArray *existSections = [self.sections mutableCopy];
    
    __weak typeof(self) weakSelf = self;
    [sections enumerateObjectsUsingBlock:^(CPDataDrivenLayoutSectionInfo * _Nonnull sectionInfo, NSUInteger sectionIdx, BOOL * _Nonnull stop) {
        NSInteger sectionForIndexPath;
        NSInteger rowForIndexPath;
        CPDataDrivenLayoutSectionInfo *existSectionInfo = [weakSelf cp_sectionInfoForSection:sectionIdx];
        if (existSectionInfo) {
            rowForIndexPath = existSectionInfo.numberOfObjects;
            [existSectionInfo appendCellInfos:sectionInfo.cellInfos];
            sectionForIndexPath = [existSections indexOfObject:existSectionInfo];
        }else{
            rowForIndexPath = 0;
            [existSections addObject:sectionInfo];
            sectionForIndexPath = existSections.count-1;
        }
        
        [sectionInfo.cellInfos enumerateObjectsUsingBlock:^(CPDataDrivenLayoutCellInfo * _Nonnull cellInfo, NSUInteger rowIdx, BOOL * _Nonnull stop) {
            [weakSelf registerCellWithCellInfo:cellInfo];
            [indexPaths addObject:[NSIndexPath indexPathForRow:rowForIndexPath+rowIdx inSection:sectionForIndexPath]];
        }];
    }];
    
    [self setSections:[existSections copy]];
    
    animation==UITableViewRowAnimationNone?[UIView setAnimationsEnabled:NO]:nil;
    [self beginUpdates];
    [self insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self endUpdates];
    animation==UITableViewRowAnimationNone?[UIView setAnimationsEnabled:YES]:nil;
}

- (void)cp_insertCellInfos:(NSArray<CPDataDrivenLayoutCellInfo *> * _Nonnull)cellInfos atIndexPaths:(NSArray<NSIndexPath *> * _Nonnull)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    NSMutableDictionary<NSNumber *, NSArray *> *sectionDict = [@{} mutableCopy];
    NSMutableDictionary<NSNumber *, NSArray *> *cellInfosDict = [@{} mutableCopy];
    
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *indexs = [sectionDict[@(indexPath.section)] mutableCopy];
        if (!indexs) {
            indexs = [@[] mutableCopy];
        }
        [indexs addObject:indexPath];
        sectionDict[@(indexPath.section)] = [indexs copy];
        
        NSMutableArray *indexs1 = [cellInfosDict[@(indexPath.section)] mutableCopy];
        if (!indexs1) {
            indexs1 = [@[] mutableCopy];
        }
        [indexs1 addObject:[cellInfos objectAtIndex:idx]];
        cellInfosDict[@(indexPath.section)] = [indexs1 copy];
    }];
    
    __weak typeof(self) weakSelf = self;
    [sectionDict enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull section, NSArray * _Nonnull indexs, BOOL * _Nonnull stop) {
        CPDataDrivenLayoutSectionInfo *sectionInfo = [weakSelf cp_sectionInfoForSection:[section integerValue]];
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        NSArray *cellInfos = cellInfosDict[section];
        
        [indexs enumerateObjectsUsingBlock:^(NSIndexPath *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [indexSet addIndex:obj.row];
            CPDataDrivenLayoutCellInfo *cellInfo = [cellInfos objectAtIndex:idx];
            [weakSelf registerCellWithCellInfo:cellInfo];
        }];
        [sectionInfo insertCellInfos:cellInfos atIndexSet:indexSet];
    }];
    
    animation==UITableViewRowAnimationNone?[UIView setAnimationsEnabled:NO]:nil;
    [self beginUpdates];
    [self insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self endUpdates];
    animation==UITableViewRowAnimationNone?[UIView setAnimationsEnabled:YES]:nil;
}

#pragma mark - Deleting

- (void)cp_deleteCellInfoAtIndexPath:(NSIndexPath * _Nonnull)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
    CPDataDrivenLayoutSectionInfo *sectionInfo = [self cp_sectionInfoForSection:indexPath.section];
    [sectionInfo deleteCellInfo:[self cp_cellInfoForRowAtIndexPath:indexPath]];
    
    if (sectionInfo.cellInfos.count==0) {
        NSMutableArray *newSections = [self.sections mutableCopy];
        [newSections removeObjectAtIndex:indexPath.section];
        [self setSections:[newSections copy]];
    }
    
    animation==UITableViewRowAnimationNone?[UIView setAnimationsEnabled:NO]:nil;
    [self beginUpdates];
    [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
    [self endUpdates];
    animation==UITableViewRowAnimationNone?[UIView setAnimationsEnabled:YES]:nil;
}

- (void)cp_deleteCellInfosInSection:(NSInteger)section atIndexSet:(NSIndexSet * _Nonnull)indexSet withRowAnimation:(UITableViewRowAnimation)animation {
    CPDataDrivenLayoutSectionInfo *sectionInfo = [self cp_sectionInfoForSection:section];
    [sectionInfo deleteCellInfosAtIndexSet:indexSet];
    
    NSMutableArray *indexPaths = [NSMutableArray new];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:section]];
    }];
    
    animation==UITableViewRowAnimationNone?[UIView setAnimationsEnabled:NO]:nil;
    [self beginUpdates];
    [self deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self endUpdates];
    animation==UITableViewRowAnimationNone?[UIView setAnimationsEnabled:YES]:nil;
}

#pragma mark - Get Cell And Section Info

- (CPDataDrivenLayoutCellInfo * _Nullable)cp_cellInfoForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath {
    NSArray *cellInfos = [[self cp_sectionInfoForSection:indexPath.section] cellInfos];
    if (indexPath.row<cellInfos.count) {
        return [cellInfos objectAtIndex:indexPath.row];
    }
    return nil;
}

- (CPDataDrivenLayoutSectionInfo * _Nullable)cp_sectionInfoForSection:(NSInteger)section {
    if (section<self.sections.count) {
        return [self.sections objectAtIndex:section];
    }
    return nil;
}

#pragma mark - Other

- (NSArray<NSString *> * _Nonnull)cp_sectionIndexTitles {
    NSMutableArray *titles = [NSMutableArray new];
    [self.sections enumerateObjectsUsingBlock:^(CPDataDrivenLayoutSectionInfo * _Nonnull sectionInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        if (sectionInfo.indexTitle) {
            [titles addObject:sectionInfo.indexTitle];
        }
    }];
    return titles;
}

#pragma mark - Register Cell

- (void)registerCellWithSections:(NSArray<CPDataDrivenLayoutSectionInfo *> *)sections {
    __weak typeof(self) weakSelf = self;
    [sections enumerateObjectsUsingBlock:^(CPDataDrivenLayoutSectionInfo * _Nonnull sectionInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf registerCellWithCellInfos:sectionInfo.cellInfos];
    }];
}

- (void)registerCellWithCellInfos:(NSArray<CPDataDrivenLayoutCellInfo *> *)cellInfos {
    __weak typeof(self) weakSelf = self;
    [cellInfos enumerateObjectsUsingBlock:^(CPDataDrivenLayoutCellInfo * _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf registerCellWithCellInfo:info];
    }];
}

- (void)registerCellWithCellInfo:(CPDataDrivenLayoutCellInfo * _Nonnull)cellInfo {
    if (cellInfo.nib) {
        [self registerNib:cellInfo.nib forCellReuseIdentifier:cellInfo.cellReuseIdentifier];
    }else{
        [self registerClass:cellInfo.cellClass forCellReuseIdentifier:cellInfo.cellReuseIdentifier];
    }
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    CPDataDrivenLayoutSectionInfo *sectionInfo = [self cp_sectionInfoForSection:section];
    return sectionInfo?sectionInfo.titleForHeaderInSection:nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    CPDataDrivenLayoutSectionInfo *sectionInfo = [self cp_sectionInfoForSection:section];
    return sectionInfo?sectionInfo.titleForFooterInSection:nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self cp_sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:index];
    [tableView scrollToRowAtIndexPath:selectIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    return index;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPDataDrivenLayoutCellInfo *cellInfo = [self cp_cellInfoForRowAtIndexPath:indexPath];
    if (cellInfo.cellWillDisplayCallback) {
        cellInfo.cellWillDisplayCallback(tableView,cell,indexPath,cellInfo.data);
    }
}

/**
 *  override section header text (the section header text is uppercase string by default)
 */
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    NSString *titleForHeaderInSection = [self cp_sectionInfoForSection:section].titleForHeaderInSection;
    if (titleForHeaderInSection && [view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        [view setValue:titleForHeaderInSection forKeyPath:@"_label.text"];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPDataDrivenLayoutCellInfo *cellInfo = [self cp_cellInfoForRowAtIndexPath:indexPath];
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
    
    CPDataDrivenLayoutCellInfo *cellInfo = [self cp_cellInfoForRowAtIndexPath:indexPath];
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
    return self.sections.count>0?self.sections.count:1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CPDataDrivenLayoutSectionInfo *sectionInfo = [self cp_sectionInfoForSection:section];
    if (sectionInfo) {
        return sectionInfo.numberOfObjects;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    CPDataDrivenLayoutCellInfo *cellInfo = [self cp_cellInfoForRowAtIndexPath:indexPath];
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
