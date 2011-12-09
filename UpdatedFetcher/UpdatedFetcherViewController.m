//
//  UpdatedFetcherViewController.m
//  UpdatedFetcher
//
//  Created by mrpumba on 12/7/11.
//  Copyright (c) 2011 Pumba Hax. All rights reserved.
//

#import "UpdatedFetcherViewController.h"

@implementation UpdatedFetcherViewController
@synthesize displayData;
@synthesize mySpinner;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setDisplayData:nil];
    [self setDisplayData:nil];
    [self setDisplayData:nil];
    [self setMySpinner:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [mySpinner stopAnimating];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)fetchData:(id)sender {
    
    [mySpinner startAnimating];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("text downloader", NULL);
    
    
    dispatch_async(downloadQueue, ^ {
        
        NSURL *myURL = [NSURL URLWithString:@"http://76.246.4.168/foo.txt"];
        NSData *textData = [NSData dataWithContentsOfURL:myURL];
    
        NSString *myReturnedText = [[NSString alloc] initWithData:textData encoding:NSUTF8StringEncoding];

        
        dispatch_async(dispatch_get_main_queue(), ^ {
            [mySpinner stopAnimating];
            
            
            
            displayData.text = myReturnedText;
        });
        
    });
    dispatch_release(downloadQueue );

    
}

    
@end
