//
//  PFClient.m
//  payfort
//
//  Created by Ahmad Salman on 3/14/14.
//  Copyright (c) 2014 Ahmad Salman. All rights reserved.
//

#import "PFClient.h"
#import <CommonCrypto/CommonDigest.h>

#define PF_FORM_URL @"about:blank"
#define PF_ORDER_URL @"https://secure.payfort.com/ncol/test/orderstandard.asp"
#define PF_PROCESSED_URL @"https://secure.payfort.com/ncol/test/order_Agree.asp"

#define PFRequestHashKey @"SHASIGN"

#define PF_DEFAULT_LANGUAGE @"en_US"
#define PF_DEFAULT_DEVICE @"mobile"

#define PFResponseOrderIdKey @"orderID"
#define PFResponsePaymentIdKey @"PAYID"
#define PFResponsePSPIdKey @"PSPID"
#define PFResponseAmountKey @"amount"
#define PFResponseCurrencyKey @"currency"


@implementation PFResponse
@end

@interface PFClient () <UIWebViewDelegate>

@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) UIWebView *webView;

@property (strong, nonatomic) completionBlock completionBlock;

- (NSMutableDictionary *)addDefaults:(NSMutableDictionary *)options;
- (NSMutableDictionary *)addHash:(NSMutableDictionary *)options;
- (NSString *)buildHTMLWithOptions:(NSMutableDictionary *)options;
- (NSString *)sha1Encode:(NSString *)input;

@end


@implementation PFClient

- (PFClient *)init {
    
    self = [super init];
    
    if (self) {
        
        self.navigationController = [[UINavigationController alloc] init];
        self.viewController = [[UIViewController alloc] init];
        
        [self.navigationController addChildViewController:self.viewController];
        
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelPaymet:)];
        
        self.viewController.navigationItem.leftBarButtonItem = cancelButton;
        self.viewController.navigationController.navigationBarHidden = NO;

        self.webView = [[UIWebView alloc] initWithFrame:self.viewController.view.frame];
        self.webView.delegate = self;
        
        [self.viewController.view addSubview:self.webView];
    }
    
    return self;
}

+ (PFClient *)sharedClient {
    
    static PFClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [[PFClient alloc] init];
    });
    
    return _sharedClient;
}

- (void)showPaymentViewInViewController:(UIViewController *)viewController withOptions:(NSDictionary *)options andCompletion:(completionBlock)completion {
    
    [self setupWebViewWithOptions:options];
    self.completionBlock = completion;
    
    [viewController presentViewController:self.navigationController animated:YES completion:nil];
}

- (void)setupWebViewWithOptions:(NSDictionary *)options {
    
    [self.webView loadHTMLString:[self createHTMLWithOptions:options] baseURL:nil];
}

- (NSString *)createHTMLWithOptions:(NSDictionary *)options {
    
    NSMutableDictionary *mutableOption = [options mutableCopy];
    
    mutableOption = [self addDefaults:mutableOption];
    mutableOption = [self addHash:mutableOption];
    
    return [self buildHTMLWithOptions:mutableOption];
}

- (NSMutableDictionary *)addDefaults:(NSMutableDictionary *)options {
    
    if([options valueForKey:PFRequestLanguageKey] == nil) {
        options[PFRequestLanguageKey] = PF_DEFAULT_LANGUAGE;
    }
    
    if([options valueForKey:PFRequestDeviceKey] == nil) {
        options[PFRequestDeviceKey] = PF_DEFAULT_DEVICE;
    }

    return options;
}

- (NSMutableDictionary *)addHash:(NSMutableDictionary *)options {
    
    NSString *unhashed = @"";
    NSString *passphrase = options[PFRequestpassphraseKey];
    
    if (passphrase == nil);
    
    [options removeObjectsForKeys:@[PFRequestpassphraseKey]];
    
    NSArray *keys = [options allKeys];
    
    keys = [[keys mutableCopy] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for (NSString *key in keys) {
        
        id value = options[key];
        unhashed = [unhashed stringByAppendingString:[NSString stringWithFormat:@"%@=%@%@", key, value, passphrase]];
    }
    
    NSString *hashed = [self sha1Encode:unhashed];
    
    options[PFRequestHashKey] = [hashed uppercaseString];

    return options;
}

- (NSString *)buildHTMLWithOptions:(NSMutableDictionary *)options {
    
    NSString *HTML = [NSString stringWithFormat: @"<!DOCTYPE html><html><head></head><body><form method='post' action='%@' id=form1 name=form1>", PF_ORDER_URL];
    
    for (NSString *key in options) {
        
        id value = options[key];
        
        NSString *input = [NSString stringWithFormat:@"<input type='hidden' name='%@' value='%@'>", key, value];
        HTML = [HTML stringByAppendingString:input];
    }
    
    HTML = [HTML stringByAppendingString:@"<input type='submit' style='display:none' value='Pay Now' id='submit1' name='submit1'></form></body></html>"];
    
    return HTML;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    
    NSString *url = [NSString stringWithFormat:@"%@", webView.request.URL];
    NSString *source = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    
    
    if ([url isEqualToString:PF_FORM_URL]) {
        
//        NSLog(@"from view");
        
        [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('submit1').click()"];
        
    } else if ([url isEqualToString:PF_ORDER_URL]) {
        
//        NSLog(@"order view");
        
        NSRange errorRange = [source rangeOfString:@"An error has occurred"];
        
        if ((int)errorRange.location > 0) {
            
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to load Payment page.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"wrong Options.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check error logs in Payfor backoffice", nil)
                                       };
            
            NSError *error = [NSError errorWithDomain:PFErrorDomain
                                                 code:-1
                                             userInfo:userInfo];
            
            
            return [self.navigationController dismissViewControllerAnimated:YES completion:^{
                self.completionBlock(error, nil);
            }];
        }
        
    } else if ([url isEqualToString:PF_PROCESSED_URL]) {
        
//        NSLog(@"success");
        
        PFResponse *response = [[PFResponse alloc] init];
        
        response.status = [[webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName('STATUS')[0].value"] intValue];
        response.orderId = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName('orderID')[0].value"];
        response.paymentId = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName('PAYID')[0].value"];
        response.PSPID = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName('PSPID')[0].value"];
        response.amout = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName('amount')[0].value"];
        response.currency = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName('currency')[0].value"];
        
        return [self.navigationController dismissViewControllerAnimated:YES completion:^{
            self.completionBlock(nil, response);
        }];
        
    } else {
        
        NSLog(@"I don't know what happened");
        NSLog(@"request: %@", webView.request.URL);
        NSLog(@"source: %@", source);
    }
}

- (void)cancelPaymet:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (NSString*)sha1Encode:(NSString*)input {
    
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (int)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}



@end
