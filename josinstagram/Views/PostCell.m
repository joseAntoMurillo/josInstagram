//
//  PostCell.m
//  josinstagram
//
//  Created by josemurillo on 7/9/19.
//  Copyright © 2019 josemurillo. All rights reserved.
//

#import "PostCell.h"
#import "Parse/Parse.h"

@implementation PostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
     UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.postProfileImage addGestureRecognizer:profileTapGestureRecognizer];
    [self.postProfileImage setUserInteractionEnabled:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshData {
    
    [self.post.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!data) {
            return NSLog(@"%@", error);
        }
        // Do something with the image
        self.postImage.image = [UIImage imageWithData:data];
    }];
    
    // Gets information about the post
    self.postCaption.text = self.post.caption;
    self.postDate.text = [self getDate];
    NSString *username = [@"@" stringByAppendingString: self.post.author.username];
    self.postUser.text = username;
    
    // Gets profile picture of the author
    PFUser *user = self.post.author; // from Parse API
    PFFileObject *image = [user objectForKey:@"profileImage"];
    [image getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (!data){
            return NSLog(@"%@", error);
        }
        self.postProfileImage.image = [UIImage imageWithData:data];
    }];
    // Surround image with a circle
    self.postProfileImage.layer.cornerRadius = self.postProfileImage.frame.size.width/2;
    
    // Sets image and count for likes
    self.labelLikeCount.text = [NSString stringWithFormat:@"%li", self.post.usersThatLiked.count];
    [self.heartIcon setSelected:([self.post.usersThatLiked containsObject:[PFUser currentUser].username])];
    [self.heartIcon setImage: [UIImage imageNamed:@"heartEmpty"]
                    forState: UIControlStateNormal];
    [self.heartIcon setImage: [UIImage imageNamed:@"heartFull"]
                    forState: UIControlStateSelected];
}

- (IBAction)didTapLike:(id)sender {
    BOOL didLike = ([self.post.usersThatLiked containsObject:[PFUser currentUser].username]);
    
    [self changeLikeCount:didLike];
    [self refreshData];
}

- (void)changeLikeCount:(BOOL)liked {

    NSNumber *likes = [NSNumber numberWithInt:0];
    // Adds or deletes like if user has already liked the post
    if (liked) {
        [self.post removeObject:[PFUser currentUser].username forKey:@"usersThatLiked"];
        
    } else {
        [self.post addObject:[PFUser currentUser].username forKey:@"usersThatLiked"];
    }
    [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"An error ocurred while uploading image to server");
        }
    }];
    // We don't update like count but rather rely on counting the array
    likes = @(self.post.usersThatLiked.count);
}

- (void) didTapUserProfile:(UITapGestureRecognizer *)sender{
    [self.delegate tapProfile:self didTap:self.post.author];
}

- (NSString *)getDate {
    
    NSDate *createdAt = [self.post createdAt];
    NSDate *todayDate = [NSDate date];
    double ti = [createdAt timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    
    if(ti < 1) {
        return @"never";
    } else  if (ti < 60) {
        return @"less than a minute ago";
    } else if (ti < 120) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%d minute ago", diff];
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%d minutes ago", diff];
    } else if (ti < 7200) {
        int diff = round(ti / 60 / 60);
        return [NSString stringWithFormat:@"%d hour ago", diff];
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        return [NSString stringWithFormat:@"%d hours ago", diff];
    } else if (ti < 172800) {
        int diff = round(ti / 60 / 60 / 24);
        return [NSString stringWithFormat:@"%d days ago", diff];
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        return [NSString stringWithFormat:@"%d days ago", diff];
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
        // Convert Date to String
        return [formatter stringFromDate:createdAt];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
