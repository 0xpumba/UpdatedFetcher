//
//  UpdatedFetcherViewController.h
//  UpdatedFetcher
//
//  Created by mrpumba on 12/7/11.
//  Copyright (c) 2011 Pumba Hax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdatedFetcherViewController : UIViewController
- (IBAction)fetchData:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *displayData;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *mySpinner;

@end
