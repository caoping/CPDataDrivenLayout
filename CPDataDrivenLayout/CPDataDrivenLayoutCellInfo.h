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
#import <UIKit/UIKit.h>

typedef void (^CPDataDrivenLayoutCellInfoCallbackBlock)(UITableView * _Nonnull tableView, id _Nonnull cell, NSIndexPath * _Nonnull indexPath, id _Nullable data);

@interface CPDataDrivenLayoutCellInfo : NSObject

@property (nonatomic, readonly) Class _Nonnull cellClass;
@property (nonatomic, readonly) NSString * _Nonnull cellReuseIdentifier;
@property (nonatomic, readonly) UINib * _Nullable nib;//can be nil
@property (nonatomic) NSString * _Nullable identifier;//string used to identify cell info
@property (nonatomic) CGFloat rowHeight;//default value is UITableViewAutomaticDimension,mean use autolayout to calculate row height
@property (nonatomic) id _Nullable data;
@property (nonatomic, copy) CPDataDrivenLayoutCellInfoCallbackBlock _Nullable cellDidReuseCallback;
@property (nonatomic, copy) CPDataDrivenLayoutCellInfoCallbackBlock _Nullable cellDidSelectCallback;

#pragma mark - Designated Initializer

- (instancetype _Nonnull)initWithCellClass:(Class _Nonnull)cellClass nib:(UINib * _Nullable)nib data:(id _Nullable)data cellDidReuseCallback:(CPDataDrivenLayoutCellInfoCallbackBlock _Nullable)cellDidReuseCallback cellDidSelectCallback:(CPDataDrivenLayoutCellInfoCallbackBlock _Nullable)cellDidSelectCallback NS_DESIGNATED_INITIALIZER;

#pragma mark - Convenience Initializers

- (instancetype _Nonnull)initWithCellClass:(Class _Nonnull)cellClass nib:(UINib * _Nullable)nib;
- (instancetype _Nonnull)initWithCellClass:(Class _Nonnull)cellClass nib:(UINib * _Nullable)nib data:(id _Nullable)data;
- (instancetype _Nonnull)initWithCellClass:(Class _Nonnull)cellClass nib:(UINib * _Nullable)nib data:(id _Nullable)data cellDidReuseCallback:(CPDataDrivenLayoutCellInfoCallbackBlock _Nullable)cellDidReuseCallback;


@end
