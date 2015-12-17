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

@interface _CPTableViewProxy : NSProxy

@property (nonatomic, weak) id<NSObject> target;
@property (nonatomic, weak) CPTableViewDelegateInterceptor *interceptor;

- (instancetype)initWithTarget:(id<NSObject>)target interceptor:(CPTableViewDelegateInterceptor *)interceptor;

@end

@implementation _CPTableViewProxy

- (instancetype)initWithTarget:(id<NSObject>)target interceptor:(CPTableViewDelegateInterceptor *)interceptor
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
    return ([_interceptor respondsToSelector:aSelector] || [_target respondsToSelector:aSelector]);
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([_interceptor respondsToSelector:aSelector]) {
        return _interceptor;
    }
    
    return [_target respondsToSelector:aSelector] ? _target : nil;
}

@end

@implementation UITableView (CPDataDrivenLayout)

#define DescriptionForAssert [NSString stringWithFormat:@"invoke %@ before must be set dataDrivenLayoutEnabled value to YES",NSStringFromSelector(_cmd)]
#define CPDataDrivenLayoutEnabledAssert() NSAssert(self.dataDrivenLayoutEnabled, DescriptionForAssert)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
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
    });
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

- (CPTableViewDelegateInterceptor *)interceptor {
    id __interceptor = objc_getAssociatedObject(self, @selector(interceptor));
    if (!__interceptor) {
        __interceptor = [CPTableViewDelegateInterceptor new];
        [self setInterceptor:__interceptor];
    }
    return __interceptor;
}

- (void)setInterceptor:(CPTableViewDelegateInterceptor *)interceptor {
    objc_setAssociatedObject(self, @selector(interceptor), interceptor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
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
    if (self.dataDrivenLayoutEnabled) {
        id delegateProxy = [[_CPTableViewProxy alloc] initWithTarget:delegate interceptor:self.interceptor];
        [self cp_setDelegate:delegateProxy];
        [self setTableViewDelegateProxy:delegateProxy];
    }else{
        __weak id originalDelegate = delegate;
        if ([delegate isKindOfClass:[_CPTableViewProxy class]]) {
            originalDelegate = [self.tableViewDelegateProxy target];
        }
        [self cp_setDelegate:originalDelegate];
        [self setTableViewDelegateProxy:nil];
    }
}

- (void)cp_setDataSource:(id<UITableViewDataSource>)dataSource {
    if (self.dataDrivenLayoutEnabled) {
        id dataSourceProxy = [[_CPTableViewProxy alloc] initWithTarget:dataSource interceptor:self.interceptor];
        [self cp_setDataSource:dataSourceProxy];
        [self setTableViewDataSourceProxy:dataSourceProxy];
    }else{
        __weak id originalDataSource = dataSource;
        if ([dataSource isKindOfClass:[_CPTableViewProxy class]]) {
            originalDataSource = [self.tableViewDataSourceProxy target];
        }
        [self cp_setDataSource:originalDataSource];
        [self setTableViewDataSourceProxy:nil];
    }
}

#pragma mark - Reloading

- (void)cp_reloadSections:(NSArray<CPDataDrivenLayoutSectionInfo *> * _Nonnull)sections {
    CPDataDrivenLayoutEnabledAssert();
    
    [self setSections:sections];
    [self registerCellWithSections:sections];
    [self reloadData];
}

- (void)cp_reloadCellInfo:(CPDataDrivenLayoutCellInfo * _Nonnull)cellInfo atIndexPath:(NSIndexPath * _Nonnull)indexPath {
    CPDataDrivenLayoutEnabledAssert();
    
    CPDataDrivenLayoutSectionInfo *sectionInfo = [self cp_sectionInfoForSection:indexPath.section];
    if (sectionInfo && indexPath.row<sectionInfo.numberOfObjects) {
        [sectionInfo updateCellInfo:cellInfo atIndex:indexPath.row];
        [self.fd_indexPathHeightCache invalidateHeightAtIndexPath:indexPath];
        
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
    CPDataDrivenLayoutEnabledAssert();
    
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
    CPDataDrivenLayoutEnabledAssert();
    
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
    CPDataDrivenLayoutEnabledAssert();
    
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
    CPDataDrivenLayoutEnabledAssert();
    
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
    CPDataDrivenLayoutEnabledAssert();
    
    NSArray *cellInfos = [[self cp_sectionInfoForSection:indexPath.section] cellInfos];
    if (indexPath.row<cellInfos.count) {
        return [cellInfos objectAtIndex:indexPath.row];
    }
    return nil;
}

- (CPDataDrivenLayoutSectionInfo * _Nullable)cp_sectionInfoForSection:(NSInteger)section {
    CPDataDrivenLayoutEnabledAssert();
    
    if (section<self.sections.count) {
        return [self.sections objectAtIndex:section];
    }
    return nil;
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

@end
