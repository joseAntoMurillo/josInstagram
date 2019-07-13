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

@interface TimelineViewController () <UITableViewDataSource, UITableViewDelegate, PostCellDelegate>

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
    
    // Returns instagram posts
    [self fetchPosts];
    
    // Sets a refresh control in the view controller
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPosts) forControlEvents: UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

// Calls server to return posts in feed
- (void)fetchPosts {
    
    // construct PFQuery
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    postQuery.limit = 20;
    
    // Makes querey and saves retrieved data in postsArray
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            self.postsArray = (NSMutableArray *)posts;
            [self.tableView reloadData];
        }
        else {
            // NSLog(@"Error getting home timeline: %@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
    }];
}

// Gives appropiate data to each cell
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    // Creates an objet to represent a cell
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    
    // Objects to hold each tweet's data
    Post *post = self.postsArray[indexPath.row];
    
    cell.post = post;
    // Refresh data updates all the labels, images, and features of the cell
    [cell refreshData];
    
    // Sets custom background color when selecting a cell
    UIColor *backColor = [UIColor colorWithRed:0.85 green:0.83 blue:0.83 alpha:1.0];
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = backColor;
    cell.selectedBackgroundView = backgroundView;
    
    // Delegate for PostCell: protocol when trying to see profiles
    cell.delegate = self;
    
    return cell;
}

// Sets the amount of vells
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.postsArray.count;
}

// Action when user clicks logout
- (IBAction)clickedLogout:(id)sender {
    
    // When user tries to login, will be re-directed to the Login page
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        
        [self presentViewController:loginViewController animated:NO completion:nil];
    }];
    
    // NSLog(@"Logged-out successfully");
}

// Uses animation to deselect cell after selecting it
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Conforms to PostCellProtocol and calls the profileSegue
- (void)tapProfile:(nonnull PostCell *)postCell didTap:(nonnull PFUser *)user {
    [self performSegueWithIdentifier:@"profileSegue" sender:user];
}

// performs two possible segues
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
        
    }
    // Calls profileSegue and re-directs user to a friend's profile page
    else {
        FriendsProfileViewController *profileViewController = [segue destinationViewController];
        profileViewController.userFriend = sender;
    }
}

@end
