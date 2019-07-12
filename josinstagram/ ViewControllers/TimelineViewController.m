//
//  TimelineViewController.m
//  josinstagram
//
//  Created by josemurillo on 7/8/19.
//  Copyright © 2019 josemurillo. All rights reserved.
//

#import "TimelineViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "Parse/Parse.h"
#import "Post.h"
#import "PostCell.h"
#import "DetailsViewController.h"
#import "CameraViewController.h"
#import "FriendsProfileViewController.h"

@interface TimelineViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *postsArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self fetchPosts];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPosts) forControlEvents: UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)fetchPosts {
    
    // construct PFQuery
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    postQuery.limit = 20;
    
    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            self.postsArray = (NSMutableArray *)posts;
            [self.tableView reloadData];
        }
        else {
            NSLog(@"Error getting home timeline: %@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
    }];
}

- (IBAction)clickedLogout:(id)sender {
    
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        
        [self presentViewController:loginViewController animated:NO completion:nil];
    }];
    
    NSLog(@"Logged-out successfully");
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    // Creates an objet to represent a cell
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    
    // Objects to hold each tweet's data
    Post *post = self.postsArray[indexPath.row];
    
    cell.post = post;
    [cell refreshData];
    
    // Sets custom background color when selecting a cell
    UIColor *backColor = [UIColor colorWithRed:0.85 green:0.83 blue:0.83 alpha:1.0];
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = backColor;
    cell.selectedBackgroundView = backgroundView;
    
    cell.delegate = self;
    return cell;
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.postsArray.count;
}

// Uses animation to deselect cell after selecting it
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tapProfile:(nonnull PostCell *)postCell didTap:(nonnull PFUser *)user {
    [self performSegueWithIdentifier:@"profileSegue" sender:user];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"DetailsSegue"]) {
        // Gets appropiate data corresponding to the tweet that the user selected
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Post *post = self.postsArray[indexPath.row];
        
        // Get the new view controller using [segue destinationViewController].
        DetailsViewController *detailsView = [segue destinationViewController];
        
        // Pass the selected object to the new view controller
        detailsView.post = post;
        
    } else {
        FriendsProfileViewController *profileViewController = [segue destinationViewController];
        profileViewController.userFriend = sender;
    }
}

@end
