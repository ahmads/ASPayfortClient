//
//  PFViewController.m
//  ASPayfortClient
//
//  Created by Ahmad Salman on 3/14/14.
//  Copyright (c) 2014 Ahmad Salman. All rights reserved.
//

#import "PFViewController.h"
#import "PFClient.h"

@interface PFViewController ()

@end

@implementation PFViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.nameTextField becomeFirstResponder];
}

- (IBAction)payNow:(id)sender {
    
    NSDictionary *options = @{PFRequestPSPIdKey: self.PSPIDTextField.text,
                              PFRequestpassphraseKey: self.passphraseTextField.text,
                              PFRequestOrderIdKey: [NSNumber numberWithInt:arc4random() % 9999999],
                              PFRequestAmountKey: [NSNumber numberWithInt:[self.amountTextField.text intValue] * 100],
                              PFRequestCurrencyKey: self.currencyTextField.text,
                              PFRequestClientNameKey: self.nameTextField.text};
    
    [[PFClient sharedClient] showPaymentViewInViewController:self withOptions:options
                                               andCompletion:^(NSError *error, PFResponse *response) {
        
        if  (error) {
            
            NSLog(@"Description: %@", error.localizedDescription);
            NSLog(@"Reason: %@", error.localizedFailureReason);
            NSLog(@"Suggestion: %@", error.localizedRecoverySuggestion);
            
            return;
        }
        
        
        if (response.status == PFPaymentAuthorized) {
            
            NSString *msg = [NSString stringWithFormat:@"Payment ID: %@\nPSPID: %@\nOrder Id: %@\nAmount: %@\nCurrency: %@", response.paymentId, @"test", response.orderId,  response.amout, response.currency];
            
            [[[UIAlertView alloc] initWithTitle:@"Success" message:msg delegate:nil cancelButtonTitle:@"Awesome" otherButtonTitles: nil] show];
        }
        
        NSLog(@"Status: %i", (int)response.status);
        NSLog(@"Payment ID: %@", response.paymentId);
        NSLog(@"PSPID: %@", response.PSPID);
        NSLog(@"Order Id: %@", response.orderId);
        NSLog(@"Amount: %@", response.amout);
        NSLog(@"Currency: %@", response.currency);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
