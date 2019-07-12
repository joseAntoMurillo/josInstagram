//
//  LoginViewController.m
//  josinstagram
//
//  Created by josemurillo on 7/8/19.
//  Copyright © 2019 josemurillo. All rights reserved.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)clickedLogin:(id)sender {
    [self.usernameField setDelegate:self];
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Login Error" message:@"Something went wrong." preferredStyle:(UIAlertControllerStyleAlert)];
            
            // create a try again action
            UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again!" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
                // function calls itself to try again!
            }];
            
            // add the cancel action to the alertController
            [alert addAction:tryAgainAction];
            
            [self presentViewController:alert animated:YES completion:^{
                
            }];
            
        } else {
            NSLog(@"User logged in successfully");
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
            
            // display view controller that needs to shown after successful login
        }
    }];
}



- (IBAction)usernameEditFinished:(id)sender {
    [sender resignFirstResponder];
}

// Dismiss keyboard after editting
- (IBAction)passwordEditFinished:(id)sender {
    [sender resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
