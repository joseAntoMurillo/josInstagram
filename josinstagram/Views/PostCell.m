//
//  PostCell.m
//  josinstagram
//
//  Created by josemurillo on 7/9/19.
//  Copyright © 2019 josemurillo. All rights reserved.
//

#import "PostCell.h"

@implementation PostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
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
    
    self.postCaption.text = self.post.caption;
    self.postDate.text = [self getDate];
    self.labelLikeCount.text = [NSString stringWithFormat:@"%li", self.post.usersThatLiked.count];
                                
    NSString *username = [@"@" stringByAppendingString: self.post.author.username];
    self.postUser.text = username;
    
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

@end
