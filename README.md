## Payfort payment in native iOS apps

An example of using [Payfort](http://payfort.com)'s payment gateway in native iOS apps.

__THIS IS HIGHLY EXPERIMENTAL. NOT AFFILIATED WITH PAYFORT IN ANYWAY. PLEASE DON'T USE IN PRODUCTION.__

![Demo](http://cl.ly/image/3D2M1E3L0429/payfort-ios.gif)

###Example usage
```objective-c
NSDictionary *options = @{
	PFRequestPSPIdKey: @"PSPID, your Payfort username",
	PFRequestpassphraseKey: @"SHA-IN passphrase, NOT your password",
	PFRequestOrderIdKey: @"Merchant's order ID",
	PFRequestAmountKey: @"Amount * 100"
	PFRequestCurrencyKey: @"Currency's 3-letter name"
};

[[PFClient sharedClient] showPaymentViewInViewController:self withOptions:options andCompletion:^(NSError *error, PFResponse *response) {
  
	if  (error) {
	    	
		NSLog(@"Description: %@", error.localizedDescription);
		NSLog(@"Reason: %@", error.localizedFailureReason);
		NSLog(@"Suggestion: %@", error.localizedRecoverySuggestion);

	} else {
	  
		NSLog(@"Status: %i", (int)response.status);
		NSLog(@"Payment ID: %@", response.paymentId);
		NSLog(@"PSPID: %@", response.PSPID);
		NSLog(@"Order Id: %@", response.orderId);
		NSLog(@"Amount: %@", response.amout);
		NSLog(@"Currency: %@", response.currency);
	}
}];
```
