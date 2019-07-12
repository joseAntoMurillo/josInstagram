//
//  CameraViewController.m
//  josinstagram
//
//  Created by josemurillo on 7/9/19.
//  Copyright © 2019 josemurillo. All rights reserved.
//

#import "CameraViewController.h"
#import "Post.h"
#import "Parse/Parse.h"
#import "TimelineViewController.h"

@interface CameraViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *instaImage;
@property (weak, nonatomic) IBOutlet UITextView *captionField;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *postPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.captionField.text = @"Write caption here";
    self.captionField.textColor = [UIColor lightGrayColor];
    [self.captionField setFont:[UIFont systemFontOfSize:18]];
    self.captionField.delegate = self;
    
    [self hideElements:YES];
}

// This method will be used to hide elements that are unecessary when user has not chosen a picture and hide the "take picture" button after the user has used it.
- (void)hideElements:(BOOL)hide {
    [self.captionField setHidden:hide];
    [self.instaImage setHidden:hide];
    [self.takePhotoButton setHidden:!hide];
    [self.postPhotoButton setHidden:hide];
    [self.cancelButton setHidden:hide];
}

- (IBAction)takePhoto:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    // imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    
    self.instaImage.image = originalImage;
    
    // Do something with the images (based on your use case)
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self hideElements:NO];
    
}

- (IBAction)postImage:(id)sender {

    UIImage *imageToPost = [self resizeImage:self.instaImage.image withSize:CGSizeMake(400, 400)];
    
    [Post postUserImage:imageToPost withCaption:self.captionField.text withCompletion:nil];
    
    
    [self hideElements:YES];

    [self performSegueWithIdentifier:@"TookPhotoSegue" sender:nil];

}

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

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
    self.captionField.text = @"";
    self.captionField.textColor = [UIColor blackColor];
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView {
    
    if(self.captionField.text.length == 0) {
        self.captionField.textColor = [UIColor lightGrayColor];
        self.captionField.text = @"Write caption here";
        [self.captionField resignFirstResponder];
    }
}

-(void) textViewShouldEndEditing:(UITextView *)textView {
    
    if(self.captionField.text.length == 0) {
        self.captionField.textColor = [UIColor lightGrayColor];
        self.captionField.text = @"Write caption here";
        [self.captionField setFont:[UIFont systemFontOfSize:18]];
        [self.captionField resignFirstResponder];
    }
}

- (IBAction)clickCancelPost:(id)sender {
    [self hideElements:YES];
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//
//}


@end
