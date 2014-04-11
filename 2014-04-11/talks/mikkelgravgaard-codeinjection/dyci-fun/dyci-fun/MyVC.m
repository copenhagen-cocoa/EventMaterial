//
// Created by Mikkel Gravgaard on 27/02/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MyVC.h"
#import "MyCell.h"

static NSString *const kReuseId = @"reuseid2";

@interface MyVC () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSArray *pieces;
@property (nonatomic, strong) NSArray *selection;
@end

@implementation MyVC

- (void)updateOnClassInjection {
    @try{
        [self loadView];

    } @catch (NSException *e){
        NSLog(@"=!=!= EXCEPTION: %@",e);
    }
}

- (void)loadView {
    [super loadView];

    self.selection = @[];
    self.pieces = @[@1,@2,@3,@4,@5,@6,@7,@8];
    self.pieces = [self.pieces arrayByAddingObjectsFromArray:self.pieces];
    self.pieces = [self.pieces sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return (NSComparisonResult) (rand() % 2 - 1);
    }];

    CGFloat dim = 320.0;
    CGRect frame = CGRectMake(0, 50, dim, dim);
    NSInteger nPieces = 16;
    CGFloat pieceDim = (CGFloat) (dim / sqrt(nPieces)) * .9;
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(pieceDim, pieceDim);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame
                                                          collectionViewLayout:layout];
    [self.view addSubview:collectionView];

    collectionView.dataSource = self;
    collectionView.delegate = self;

    [collectionView registerClass:[MyCell class] forCellWithReuseIdentifier:kReuseId];

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 16;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MyCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:kReuseId forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor orangeColor];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.selection.count==2) return;
    MyCell *cell = (MyCell *) [collectionView cellForItemAtIndexPath:indexPath];

    CGFloat duration = 0.3;
    [UIView animateWithDuration:duration animations:^{
        cell.layer.transform = CATransform3DMakeRotation(M_PI / 2.0, 0, 1, 0);
    }                completion:^(BOOL finished) {
        NSNumber *n = self.pieces[(NSUInteger) indexPath.item];
        cell.label.text = [n description];
        self.selection = [self.selection arrayByAddingObject:indexPath];
        [UIView animateWithDuration:duration animations:^{
            cell.label.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
            cell.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
        }                completion:^(BOOL finished) {
            if(self.selection.count==2){
                [self performSelector:@selector(deselect:) withObject:collectionView afterDelay:2];
            }

        }];

    }];

}


- (void)deselect:(UICollectionView *)collectionView {

        [self.selection enumerateObjectsUsingBlock:^(NSIndexPath * obj, NSUInteger idx, BOOL *stop) {
            MyCell *cell = (MyCell *) [collectionView cellForItemAtIndexPath:obj];
            cell.label.text = @"";
            cell.layer.transform = CATransform3DMakeRotation(0, 0, 1, 0);
            NSIndexPath *i1 = self.selection[0];
            NSIndexPath *i2 = self.selection[1];
            if([self.pieces[(NSUInteger) i1.item] isEqualToNumber:self.pieces[(NSUInteger) i2.item]]) {
                [cell removeFromSuperview];
            }
        }];
        self.selection = @[];


}

@end