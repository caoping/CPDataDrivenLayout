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

- (instancetype)initWithCellClass:(Class)cellClass nib:(UINib *)nib
{
    self = [super init];
    if (self) {
        NSParameterAssert(cellClass);
        _cellClass = cellClass;
        _cellReuseIdentifier = [NSStringFromClass(cellClass) stringByAppendingString:@"_Identifier"];
        _nib = nib;
        _rowHeight = UITableViewAutomaticDimension;
    }
    return self;
}

- (instancetype)initWithCellClass:(Class)cellClass nib:(UINib *)nib data:(id)data
{
    self = [self initWithCellClass:cellClass nib:nib];
    if (self) {
        self.data = data;
    }
    return self;
}

- (instancetype)initWithCellClass:(Class)cellClass
                              nib:(UINib *)nib
                             data:(id)data
             cellDidReuseCallback:(CPDataDrivenLayoutCellInfoCallbackBlock)cellDidReuseCallback
{
    self = [self initWithCellClass:cellClass nib:nib data:data];
    if (self) {
        _cellDidReuseCallback = [cellDidReuseCallback copy];
    }
    return self;
}

- (instancetype)initWithCellClass:(Class)cellClass
                              nib:(UINib *)nib
                             data:(id)data
             cellDidReuseCallback:(CPDataDrivenLayoutCellInfoCallbackBlock)cellDidReuseCallback
            cellDidSelectCallback:(CPDataDrivenLayoutCellInfoCallbackBlock)cellDidSelectCallback
{
    self = [self initWithCellClass:cellClass nib:nib data:data cellDidReuseCallback:cellDidReuseCallback];
    if (self) {
        _cellDidSelectCallback = [cellDidSelectCallback copy];
    }
    return self;
}

@end
