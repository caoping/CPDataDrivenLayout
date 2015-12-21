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

#import "CPDataDrivenLayoutCellInfo.h"

@implementation CPDataDrivenLayoutCellInfo

#pragma mark - Designated Initializer

- (instancetype _Nonnull)initWithCellClass:(Class _Nonnull)cellClass nib:(UINib * _Nullable)nib cellReuseIdentifier:(NSString * _Nullable)cellReuseIdentifier data:(id _Nullable)data cellDidReuseCallback:(CPDataDrivenLayoutCellInfoCallbackBlock _Nullable)cellDidReuseCallback cellDidSelectCallback:(CPDataDrivenLayoutCellInfoCallbackBlock _Nullable)cellDidSelectCallback
{
    self = [super init];
    if (self) {
        NSParameterAssert(cellClass);
        _cellClass = cellClass;
        _cellReuseIdentifier = cellReuseIdentifier?:[NSStringFromClass(cellClass) stringByAppendingString:@"_ReuseIdentifier"];
        _nib = nib;
        _data = data;
        _rowHeight = UITableViewAutomaticDimension;
        _cellDidReuseCallback = [cellDidReuseCallback copy];
        _cellDidSelectCallback = [cellDidSelectCallback copy];
    }
    return self;
}

#pragma mark - Convenience Initializers

- (instancetype)init {
    self = [self initWithCellClass:[UITableViewCell class] nib:nil cellReuseIdentifier:nil data:nil cellDidReuseCallback:nil cellDidSelectCallback:nil];
    self.rowHeight = 44;
    return self;
}

- (instancetype _Nonnull)initWithCellClass:(Class)cellClass nib:(UINib *)nib cellReuseIdentifier:(NSString * _Nullable)cellReuseIdentifier
{
    return [self initWithCellClass:cellClass nib:nib cellReuseIdentifier:cellReuseIdentifier data:nil cellDidReuseCallback:nil cellDidSelectCallback:nil];
}

- (instancetype _Nonnull)initWithCellClass:(Class _Nonnull)cellClass nib:(UINib * _Nullable)nib cellReuseIdentifier:(NSString * _Nullable)cellReuseIdentifier data:(id _Nullable)data
{
    return [self initWithCellClass:cellClass nib:nib cellReuseIdentifier:cellReuseIdentifier data:data cellDidReuseCallback:nil cellDidSelectCallback:nil];
}

- (instancetype _Nonnull)initWithCellClass:(Class _Nonnull)cellClass nib:(UINib * _Nullable)nib cellReuseIdentifier:(NSString * _Nullable)cellReuseIdentifier data:(id _Nullable)data cellDidReuseCallback:(CPDataDrivenLayoutCellInfoCallbackBlock _Nullable)cellDidReuseCallback
{
    return [self initWithCellClass:cellClass nib:nib cellReuseIdentifier:cellReuseIdentifier data:data cellDidReuseCallback:cellDidReuseCallback cellDidSelectCallback:nil];
}

@end
