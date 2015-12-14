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

#import <Foundation/Foundation.h>
#import "CPDataDrivenLayoutCellInfo.h"

@interface CPDataDrivenLayoutSectionInfo : NSObject

@property (nonatomic, readonly) NSUInteger numberOfObjects;
@property (nonatomic, readonly) NSArray<CPDataDrivenLayoutCellInfo *> *cellInfos;
@property (nonatomic) NSString *indexTitle;
@property (nonatomic) NSString *titleForHeaderInSection;
@property (nonatomic) NSString *titleForFooterInSection;

/**
 *  根据cell info数组初始化 section info对象
 *
 *  @param cellInfos
 *
 *  @return
 */
- (instancetype)initWithCellInfos:(NSArray<CPDataDrivenLayoutCellInfo *> *)cellInfos;

/**
 *  末尾添加
 *
 *  @param cellInfos
 */
- (void)appendCellInfos:(NSArray<CPDataDrivenLayoutCellInfo *> *)cellInfos;

/**
 *  插入
 *
 *  @param cellInfos
 *  @param indexSet
 */
- (void)insertCellInfos:(NSArray<CPDataDrivenLayoutCellInfo *> *)cellInfos atIndexSet:(NSIndexSet *)indexSet;

/**
 *  更新
 *
 *  @param cellInfo
 *  @param index
 */
- (void)setCellInfo:(CPDataDrivenLayoutCellInfo *)cellInfo atIndex:(NSUInteger)index;

/**
 *  删除
 *
 *  @param indexSet
 */
- (void)deleteCellInfosAtIndexSet:(NSIndexSet *)indexSet;

/**
 *  删除
 *
 *  @param cellInfo 
 */
- (void)deleteCellInfo:(CPDataDrivenLayoutCellInfo *)cellInfo;

@end
