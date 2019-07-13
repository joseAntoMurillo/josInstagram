//
//  FriendsProfileViewController.m
//  josinstagram
//
//  Created by josemurillo on 7/11/19.
//  Copyright © 2019 josemurillo. All rights reserved.
//

#import "FriendsProfileViewController.h"
#import <Parse/Parse.h>
#import "Post.h"
#import "PostCollectionCell.h"
#import "PostCell.h"

@interface FriendsProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *userPostsArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UILabel *postsCount;

@end

// I decided to make this file different from ProfileViewController so that if in the future new features are exclusively added to "your profile" or "your freinds' profiles" then they can be implemented in different files. However, I understand that the trade-off of doing this is that there is more reptitive code.

// Considering the similarity between this file and ProfileViewController.m, most comments have been omitted in this file. For additional information please refer to ProfileViewController,m

@implementation FriendsProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self fetchPosts];
    [self fetchProfile];
    [self setCollectionLayout];
    
    self.collectionView.alwaysBounceVertical = YES;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPosts) forControlEvents: UIControlEventValueChanged];
    [self.collectionView insertSubview:self.refreshControl atIndex:0];
}

- (void)fetchPosts {\
    // construct PFQuery
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    [postQuery whereKey:@"author" equalTo:self.userFriend];
    postQuery.limit = 20;
    
    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"author = %f", [PFUser currentUser]];
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            self.userPostsArray = (NSMutableArray *)posts;
            self.postsCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.userPostsArray.count];
            [self.collectionView reloadData];
        }
        else {
            NSLog(@"Error getting home timeline: %@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
    }];
}

- (void)fetchProfile {
    
    PFFileObject *image = [self.userFriend objectForKey:@"profileImage"];
    [image getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (!data){
            return NSLog(@"%@", error);
        }
        self.profileImage.image = [UIImage imageWithData:data];
    }];
    // Set image surrounded by a circle
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2;
    self.profileName.text = [PFUser currentUser].username;
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    // Creates an objet to represent a cell
    PostCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PostCollectionCell" forIndexPath:indexPath];
    
    // Objects to hold each tweet's data
    Post *post = self.userPostsArray[indexPath.row];
    
    [post.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!data) {
            return NSLog(@"%@", error);
        }
        // Do something with the image
        cell.postImage.image = [UIImage imageWithData:data];
    }];
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.userPostsArray.count;
}

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

@end
