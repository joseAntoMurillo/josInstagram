//
//  ProfileViewController.m
//  josinstagram
//
//  Created by josemurillo on 7/10/19.
//  Copyright © 2019 josemurillo. All rights reserved.
//

#import "ProfileViewController.h"
#import "PostCollectionCell.h"
#import "Post.h"
#import "Parse/Parse.h"
#import "DetailsViewController.h"


@interface ProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *userPostsArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UILabel *postsCount;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    // Gets posts and information of the user
    [self fetchPosts];
    [self fetchProfile];
    
    // Function that sets layout for collectionView
    [self setCollectionLayout];
    
    // Adds a refresh control
    self.collectionView.alwaysBounceVertical = YES;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPosts) forControlEvents: UIControlEventValueChanged];
    [self.collectionView insertSubview:self.refreshControl atIndex:0];
}

// Makes querey to server to get posts that the user has made
- (void)fetchPosts {
    
    // construct PFQuery
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    [postQuery whereKey:@"author" equalTo:[PFUser currentUser]];
    postQuery.limit = 20;
    
    // Makes querey and changes controller features accordingly
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            self.userPostsArray = (NSMutableArray *)posts;
            self.postsCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.userPostsArray.count];
            [self.collectionView reloadData];
        }
        else {
            // NSLog(@"Error getting home timeline: %@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
    }];
}

// Makes query and gets information about the user
- (void)fetchProfile {
    PFUser *user = [PFUser currentUser];
    PFFileObject *image = [user objectForKey:@"profileImage"];
    
    // Gets profile image of the user
    [image getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (!data){
            return NSLog(@"%@", error);
        }
        self.profileImage.image = [UIImage imageWithData:data];
    }];
    // Set image surrounded by a circle
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2;
    
    // Adds username to profile page
    self.profileName.text = [PFUser currentUser].username;
}


// Gets data - an image for each post - for each cell in the collection view
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // Creates an objet to represent a cell
    PostCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PostCollectionCell" forIndexPath:indexPath];
    
    // Objects to hold each tweet's data
    Post *post = self.userPostsArray[indexPath.row];
    
    // Query to get image for a post and set it in the cell
    [post.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!data) {
            return NSLog(@"%@", error);
        }
        cell.postImage.image = [UIImage imageWithData:data];
    }];
    return cell;
}

// Sets the amount of cells in the collection view
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.userPostsArray.count;
}

// Sets spacing and margins between the cells in the collection view
- (void)setCollectionLayout {
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    // Sets margins between posts, view, and other posts
    layout.minimumInteritemSpacing = 7;
    layout.minimumLineSpacing = 7;
    CGFloat margins = 14;
    
    // Sets amount of posters per line
    CGFloat postersPerLine = 3;
    
    // Sets post width and height, based on previous values
    CGFloat itemWidth = (self.collectionView.frame.size.width - margins - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake (itemWidth, itemHeight);
}


// Action triggered when user tries to change profile picture
- (IBAction)changeImage:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    // Shows view controller to let user pick an image
    [self presentViewController:imagePickerVC animated:YES completion:nil];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        // NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
}

// Sets image if user has finished picking one
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *imageToPost = [self resizeImage:originalImage withSize:CGSizeMake(400, 400)];
    
    self.profileImage.image = originalImage;
    
    NSData *imageData = UIImageJPEGRepresentation(imageToPost, 1);
    PFFileObject *imageFile = [PFFileObject fileObjectWithName:@"image.png" data: imageData];
    // [imageFile saveInBackground];
    
    PFUser *user = [PFUser currentUser];
    [user setObject:imageFile forKey:@"profileImage"];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // NSLog(@"An error ocurred while uploading image to server");
        }
    }];

    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Resize image for it to fit server conditions
- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
    Post *post = self.userPostsArray[indexPath.row];
    
    // Get the new view controller using [segue destinationViewController].
    DetailsViewController *detailsViewController = [segue destinationViewController];
    
    // Pass the selected object to the new view controller
    detailsViewController.post = post;
}

@end
