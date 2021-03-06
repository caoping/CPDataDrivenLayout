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
@property (nonatomic, readonly) NSArray<CPDataDrivenLayoutCellInfo *> * _Nonnull cellInfos;
@property (nonatomic) NSString * _Nullable indexTitle;
@property (nonatomic) NSString * _Nullable titleForHeaderInSection;
@property (nonatomic) NSString * _Nullable titleForFooterInSection;

- (instancetype _Nonnull)initWithCellInfos:(NSArray<CPDataDrivenLayoutCellInfo *> * _Nonnull)cellInfos NS_DESIGNATED_INITIALIZER;

#pragma mark - Appending And Inserting

- (void)appendCellInfos:(NSArray<CPDataDrivenLayoutCellInfo *> * _Nonnull)cellInfos;
- (void)insertCellInfos:(NSArray<CPDataDrivenLayoutCellInfo *> * _Nonnull)cellInfos atIndexSet:(NSIndexSet * _Nonnull)indexSet;

#pragma mark - Update

- (void)updateCellInfo:(CPDataDrivenLayoutCellInfo * _Nonnull)cellInfo atIndex:(NSUInteger)index;

#pragma mark - Deleting

- (void)deleteCellInfosAtIndexSet:(NSIndexSet * _Nonnull)indexSet;
- (void)deleteCellInfo:(CPDataDrivenLayoutCellInfo * _Nonnull)cellInfo;

@end
