//
//  PFViewController.h
//  ASPayfortClient
//
//  Created by Ahmad Salman on 3/14/14.
//  Copyright (c) 2014 Ahmad Salman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *PSPIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *passphraseTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *currencyTextField;

- (IBAction)payNow:(id)sender;
@end
