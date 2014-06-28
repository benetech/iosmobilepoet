//
//  GalleryViewController.m
//  MobilePoet
//
//  Created by Joseph Maag on 6/19/14.
//
//

#import "GalleryViewController.h"
#import "ImageCollectionViewCell.h"
#import "TaskViewController.h"

@interface GalleryViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *fetchedImages;
@property (strong, nonatomic) UIImageView *selectedImage;
@property (strong, nonatomic) NSIndexPath* selectedCellIndexPath;
@property (strong, nonatomic) UIView *selectedCellControls;
@property (strong, nonatomic) UIView *darkView;
@property (strong, nonatomic) UIButton *backButton;
@end

@implementation GalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* CollectionView setup */
	self.collectionView = [[UICollectionView alloc]initWithFrame:self.view.frame collectionViewLayout:[UICollectionViewFlowLayout new]];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.scrollEnabled = YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alpha = 0;
    [self.collectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:@"ImageCell"];
    [self.view addSubview:self.collectionView];
    
    /* Back button setup */
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backButton.frame = CGRectMake(0, 0, 50.0f, 50.0f);
    backButton.center = CGPointMake(30.0f, 33.0f);
    backButton.tintColor = [UIColor colorWithRed:29/255.0f green:42/255.0f blue:99/255.0f alpha:1.0f];
    backButton.alpha = 0;
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton = backButton;
    [self.collectionView addSubview:self.backButton];
    
    /* Fetch images */
    self.fetchedImages = [NSMutableArray new];
    [self fetchImages];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self showCollectionView];
}

-(void)showCollectionView
{
    /* Intro animations */
    self.collectionView.contentOffset = CGPointMake(0, -100.0f);
    [UIView animateWithDuration:0.8f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.collectionView.alpha = 1.0f;
        self.collectionView.contentOffset = CGPointZero;
    }completion:^(BOOL finished){
        if (finished) {
            [UIView animateWithDuration:0.5f animations:^{
                self.backButton.alpha = 1.0f;
            }completion:nil];
        }
    }];
}

-(void)fetchImages
{
    /* For now, 'simulates' fetching images */
    [self.fetchedImages addObjectsFromArray:@[[UIImage imageNamed:@"1.jpg"], [UIImage imageNamed:@"3.jpg"], [UIImage imageNamed:@"1.jpg"], [UIImage imageNamed:@"2.jpg"], [UIImage imageNamed:@"15.jpg"], [UIImage imageNamed:@"4.jpg"]]];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self showStagedViewForCellAtIndexPath:indexPath];
    
}

#pragma mark UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.fetchedImages count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static int i = 1;
    ImageCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    [cell setImage: self.fetchedImages[indexPath.row]];
    cell.title = [NSString stringWithFormat:@"%d", i];
    i++;
    
    return cell;
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *image = [[UIImageView alloc]initWithImage:self.fetchedImages[indexPath.row]];
    if (image.frame.size.width > self.view.frame.size.width) {
        image.transform = CGAffineTransformMakeScale((self.view.frame.size.width - 15.0f)/image.frame.size.width, (self.view.frame.size.width - 15.0f)/image.frame.size.width);
    }
    return image.frame.size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50.0f, 5.0f, 50.0f, 5.0f);
}

#pragma mark Button Action

-(void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Staged View

-(void)showStagedViewForCellAtIndexPath:(NSIndexPath *)indexPath
{
    /* Create a 'staged view' for the selected cell image. Staged View is where the image is put in the center and the user can choose to use the image or not */
    ImageCollectionViewCell *selectedCell = (ImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    /* Create a dark UIView layer to darken the background */
    UIView *darkView = [[UIView alloc]initWithFrame:self.collectionView.frame];
    [darkView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeSelectedCellFromStagedViewAndGoBackToGridView:)]];
    darkView.backgroundColor = [UIColor blackColor];
    darkView.alpha = 0;
    self.darkView = darkView;
    [self.collectionView addSubview:self.darkView];
    
    /* Create a 'duplicate' view of the cell */
    UIImageView *selectedImageView = [[UIImageView alloc]initWithImage:self.fetchedImages[indexPath.row]];
    self.selectedImage = selectedImageView;
    self.selectedCellIndexPath = indexPath;
    selectedImageView.transform = CGAffineTransformMakeScale(selectedCell.frame.size.width/selectedImageView.frame.size.width, selectedCell.frame.size.height/selectedImageView.frame.size.height);
    selectedImageView.center = selectedCell.center;
    [self.view addSubview:selectedImageView];
    
    selectedCell.alpha = 0;
    selectedImageView.layer.shadowOpacity = 0.4f;
    selectedImageView.layer.shadowRadius = 5.0f;
    selectedImageView.layer.shadowOffset = CGSizeZero;
    
    [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        selectedImageView.center = CGPointMake(self.view.frame.size.width/2.0f, self.view.frame.size.height/2.0f);
        self.darkView.alpha = 0.8f;
    }completion:^(BOOL finished){
        if (finished) {
            [self showSelectedCellControls];
        }
    }];
}

-(void)showSelectedCellControls
{
    UIButton *useButton = [UIButton buttonWithType:UIButtonTypeSystem];
    useButton.frame = CGRectMake(0, 0, 150.0f, 50.0f);
    useButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0f];
    useButton.tintColor = [UIColor whiteColor];
    [useButton setTitle:@"Use Image" forState:UIControlStateNormal];
    useButton.center = self.selectedImage.center;
    useButton.alpha = 0.3f;
    [useButton addTarget:self action:@selector(useImageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.selectedCellControls = useButton;
    [self.view insertSubview:useButton belowSubview:self.selectedImage];
    [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.9f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        useButton.center = CGPointMake(useButton.center.x, self.selectedImage.frame.origin.y - useButton.frame.size.height/2.0f);
        useButton.alpha = 1.0f;
    }completion:^(BOOL finished){
        if (finished) {
            ;
        }
    }];
}

-(void)useImageButtonPressed:(id)sender
{
    /* Animate into TaskViewController */
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.collectionView.center = CGPointMake(self.collectionView.center.x, self.collectionView.center.y * 4.0f );
        self.selectedCellControls.alpha = 0;
    }completion:^(BOOL finished){
        if (finished) {
            /* Push task view controller with selected task */
            /* TaskViewController is instantiated through the storyboard because UIKit hates me */
            UIStoryboard *sb = self.storyboard;
            TaskViewController * taskViewController = (TaskViewController *)[sb instantiateViewControllerWithIdentifier:@"taskViewController"];
            [taskViewController setTask:self.selectedImage];
            [self.navigationController pushViewController:taskViewController animated:NO];
            self.collectionView.center = self.view.center;
            self.collectionView.alpha = 0;
            self.darkView.alpha = 0;
            [self.darkView removeFromSuperview];
        }
    }];
}

-(void)removeSelectedCellFromStagedViewAndGoBackToGridView:(UITapGestureRecognizer *)gesture
{
    ImageCollectionViewCell *selectedCell = (ImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.selectedCellIndexPath];
    [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.selectedImage.center = selectedCell.center;
        self.selectedCellControls.center = selectedCell.center;
        self.selectedCellControls.alpha = 0;
        gesture.view.alpha = 0;
    }completion:^(BOOL finished){
        if (finished) {
            [gesture.view removeFromSuperview];
            selectedCell.alpha = 1.0f;
            [self.selectedImage removeFromSuperview];
            [self.selectedCellControls removeFromSuperview];
            self.selectedImage = nil;
            self.selectedCellIndexPath = nil;
            self.selectedCellControls = nil;
        }
    }];
}

@end
