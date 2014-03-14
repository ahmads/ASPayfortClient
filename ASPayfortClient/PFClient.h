//
//  PFClient.h
//  payfort
//
//  Created by Ahmad Salman on 3/14/14.
//  Copyright (c) 2014 Ahmad Salman. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PFRequestPSPIdKey @"PSPID"
#define PFRequestAmountKey @"AMOUNT"
#define PFRequestCurrencyKey @"CURRENCY"
#define PFRequestOrderIdKey @"ORDERID"
#define PFRequestpassphraseKey @"PASSPHRASE"
#define PFRequestClientNameKey @"CN"
#define PFRequestClientEmailKey @"EMAIL"
#define PFRequestClientCityKey @"OWNERCTY"
#define PFRequestClientPhoneKey @"OWNERTELNO"
#define PFRequestLanguageKey @"LANGUAGE"
#define PFRequestDeviceKey @"DEVICE"

#define PFErrorDomain @"PFErrorDomain"

enum PFPaymentStatus
{
    PFPaymentAuthorized,
    PFUnknown,
    PFPaymentUncertain,
    PFPaymentUnauthorized
};

@interface PFResponse:NSObject

@property NSInteger status;
@property (copy) NSString *orderId;
@property (copy) NSString *paymentId;
@property (copy) NSString *PSPID;
@property (copy) NSString *amout;
@property (copy) NSString *currency;

@end

typedef void (^completionBlock)(NSError *error, PFResponse *response);

@interface PFClient : NSObject

+ (PFClient *)sharedClient;
- (void)showPaymentViewInViewController:(UIViewController *)viewController withOptions:(NSDictionary *)options andCompletion:(completionBlock)completion;

@end
