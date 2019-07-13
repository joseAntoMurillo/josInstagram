//
//  RegisterViewController.m
//  josinstagram
//
//  Created by josemurillo on 7/8/19.
//  Copyright © 2019 josemurillo. All rights reserved.
//

#import "RegisterViewController.h"
#import "Parse/Parse.h"
#import "UIImageView+AFNetworking.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

// Action called when user tries to register
- (IBAction)clickedRegister:(id)sender {
    // initialize a user object
    PFUser *newUser = [PFUser user];
    
    // set user properties
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    newUser.email = self.emailField.text;
    
    // Check that fields are not empty
    if (![newUser.username  isEqual: @""] && ![newUser.password  isEqual: @""]  && ![newUser.email  isEqual: @""] ) {
        // Input credentials are verified before allowing user to register and login
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            // Error and alert if credentials are wrong
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign Up Error" message:@"Cannot create this account." preferredStyle:(UIAlertControllerStyleAlert)];
                
                // create a try again action
                UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again!" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
                    // function calls itself to try again!
                }];
                
                // add the cancel action to the alertController
                [alert addAction:tryAgainAction];
                
                [self presentViewController:alert animated:YES completion:^{
                    
                }];
            } else {
                NSLog(@"User registered successfully");
                [self performSegueWithIdentifier:@"registerSegue" sender:nil];
                
                // Sets a default profile image for the user
                // UIImage *defaultProfileImage = [self resizeImage:[UIImage imageNamed:@"profilePic"] withSize:CGSizeMake(400, 400)];
                NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"profilePic"], 1);
                PFFileObject *imageFile = [PFFileObject fileObjectWithName:@"DefaultImage.png" data: imageData];
                PFUser *user = [PFUser currentUser];
                [user setObject:imageFile forKey:@"profileImage"];
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                       // NSLog(@"An error ocurred while uploading image to server");
                    }
                }];
            }
        }];
        
    }
    // if the text fields are empty, give an error and let user try again
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign Up Error" message:@"Make sure fields are not empty!" preferredStyle:(UIAlertControllerStyleAlert)];
        
        // create a try again action
        UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again!" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
            // function calls itself to try again!
        }];
        
        // add the cancel action to the alertController
        [alert addAction:tryAgainAction];
        
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }
    
}


// Back to login
- (IBAction)clickedBackLogin:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Dismiss keyboard when finishing editing
- (IBAction)emailFinishedEdit:(id)sender {
    [sender resignFirstResponder];
}
- (IBAction)usernameFinishedEdit:(id)sender {
    [sender resignFirstResponder];
}
- (IBAction)passwordFinishedEdit:(id)sender {
    [sender resignFirstResponder];
}


// Segue to timeline
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
