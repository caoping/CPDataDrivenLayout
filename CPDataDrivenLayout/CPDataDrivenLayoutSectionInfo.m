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

#import "CPDataDrivenLayoutSectionInfo.h"

@implementation CPDataDrivenLayoutSectionInfo

- (instancetype)initWithCellInfos:(NSArray<CPDataDrivenLayoutCellInfo *> *)cellInfos {
    self = [super init];
    if (self) {
        NSParameterAssert(cellInfos);
        NSAssert([cellInfos count]>0, @"cellInfos must not be empty");
        _cellInfos = cellInfos;
    }
    return self;
}

- (NSUInteger)numberOfObjects {
    return _cellInfos?_cellInfos.count:0;
}

- (void)appendCellInfos:(NSArray<CPDataDrivenLayoutCellInfo *> *)cellInfos {
    NSMutableArray *infos = [_cellInfos mutableCopy];
    [infos addObjectsFromArray:cellInfos];
    _cellInfos = [infos copy];
}

- (void)insertCellInfos:(NSArray<CPDataDrivenLayoutCellInfo *> *)cellInfos atIndexSet:(NSIndexSet *)indexSet {
    NSAssert(cellInfos.count==indexSet.count, @"cellInfos count must equals to indexSet count");
    
    NSMutableArray *infos = [_cellInfos mutableCopy];
    __block NSUInteger index = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [infos insertObject:cellInfos[index] atIndex:idx];
        index++;
    }];
    
    _cellInfos = [infos copy];
}

- (void)setCellInfo:(CPDataDrivenLayoutCellInfo *)cellInfo atIndex:(NSUInteger)index {
    NSAssert(index<[_cellInfos count], @"index out of cellInfos bounds");
    
    NSMutableArray *infos = [_cellInfos mutableCopy];
    infos[index] = cellInfo;
    _cellInfos = [infos copy];
}

- (void)deleteCellInfosAtIndexSet:(NSIndexSet *)indexSet {
    NSMutableArray *objectsForDelete = [NSMutableArray new];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [objectsForDelete addObject:[self.cellInfos objectAtIndex:idx]];
    }];
    
    NSMutableArray *cellInfos = [_cellInfos mutableCopy];
    [cellInfos removeObjectsInArray:objectsForDelete];
    _cellInfos = [cellInfos copy];
}

- (void)deleteCellInfo:(CPDataDrivenLayoutCellInfo *)cellInfo {
    NSMutableArray *cellInfos = [_cellInfos mutableCopy];
    [cellInfos removeObject:cellInfo];
    _cellInfos = [cellInfos copy];
}

@end
