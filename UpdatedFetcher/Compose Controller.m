//
//  Compose Controller.m
//  UpdatedFetcher
//
//  Created by mrpumba on 12/7/11.
//  Copyright (c) 2011 Pumba Hax. All rights reserved.
//

#import "Compose Controller.h"


@implementation Compose_Controller

@synthesize composeField;
@synthesize isSending;
@synthesize networkStream;
@synthesize fileStream;
@synthesize urlText;
@synthesize userName;
@synthesize passWord;
@synthesize bufferOffset  = _bufferOffset;
@synthesize bufferLimit   = _bufferLimit;

@synthesize fileName;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/
- (uint8_t *)buffer
{
    return self->_buffer;
}

- (void)viewDidUnload
{
    [self setComposeField:nil];
    [self setUrlText:nil];
    [self setUserName:nil];
    [self setPassWord:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (IBAction)doneEditing:(id)sender {
    [userName resignFirstResponder];
    [urlText resignFirstResponder];
    [passWord resignFirstResponder];
    [composeField resignFirstResponder];
    
        
}

-(IBAction)backgroundTouched:(id)sender {
    
    [composeField resignFirstResponder];
    
}





-(IBAction)saveData:(id)sender {
    

    if ([composeField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must enter something in the text field" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
        [alert show];
    }
    else {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        
        NSString *contentToPutIntoTextFile = composeField.text;
        
        
        NSData *dataToBeWritten = [contentToPutIntoTextFile dataUsingEncoding:NSUTF8StringEncoding];
        
        
        
        fileName = [NSString stringWithFormat:@"%@/foo.txt", documentDirectory];
        
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileName];
        
        if (fileExists) {
            NSFileHandle *aFileHandlee = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
            [aFileHandlee seekToEndOfFile];
            [aFileHandlee writeData:dataToBeWritten];
            [aFileHandlee closeFile];
            
        }
        else {
        
        [contentToPutIntoTextFile  writeToFile:fileName atomically:NO encoding:NSUTF8StringEncoding error:nil];
        }
        
        NSString *checker = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"%@................%@", fileName, checker);
        
    }
}

-(IBAction)uploadData:(id)sender {    
    
        
        
        BOOL success;
        NSURL *url;
        CFWriteStreamRef ftpStream;
    //check file
    NSString *secondChecker = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"%@..........%@",fileName, secondChecker);
        
    assert(fileName!=nil);
        NSString *urlString = self.urlText.text;
        
        url = [NSURL URLWithString:urlString];
        
        self.fileStream = [NSInputStream inputStreamWithFileAtPath:fileName];
        [self.fileStream open];
        
        ftpStream = CFWriteStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url);
        
        self.networkStream = (__bridge NSOutputStream *) ftpStream;
        
        success = [self.networkStream setProperty:self.userName.text forKey:(id)kCFStreamPropertyFTPUserName];
        assert(success);
        success = [self.networkStream setProperty:self.passWord.text forKey:(id)kCFStreamPropertyFTPPassword];
        assert(success);
        
        self.networkStream.delegate = self;
        [self.networkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode   ];
        [self.networkStream open];
        CFRelease(ftpStream);
        
    
 
        
    }
   
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
// An NSStream delegate callback that's called when events happen on our 
// network stream.
{
#pragma unused(aStream)
    assert(aStream == self.networkStream);
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            NSLog(@"Opened connection");
        } break;
        case NSStreamEventHasBytesAvailable: {
            assert(NO);     // should never happen for the output stream
        } break;
        case NSStreamEventHasSpaceAvailable: {
            NSLog(@"Sending");
            
            // If we don't have any data buffered, go read the next chunk of data.
            
            if (self.bufferOffset == self.bufferLimit) {
                NSInteger   bytesRead;
                
                bytesRead = [self.fileStream read:self.buffer maxLength:kSendBufferSize];
                
                if (bytesRead == -1) {
                    NSLog(@"File Read error");
                } else if (bytesRead == 0) {
                    NSLog(@"Bytes read = nil");
                    [self stopSendWithStatus];
                } else {
                    self.bufferOffset = 0;
                    self.bufferLimit  = bytesRead;
                }
            }
            
            // If we're not out of data completely, send the next chunk.
            
            if (self.bufferOffset != self.bufferLimit) {
                NSInteger   bytesWritten;
                bytesWritten = [self.networkStream write:&self.buffer[self.bufferOffset] maxLength:self.bufferLimit - self.bufferOffset];
                assert(bytesWritten != 0);
                if (bytesWritten == -1) {
                    NSLog(@"Network write error");
                } else {
                    self.bufferOffset += bytesWritten;
                }
            }
        } break;
        case NSStreamEventErrorOccurred: {
            NSLog(@"Stream open error");
        } break;
        case NSStreamEventEndEncountered: {
            //ignore
        } break;
        default: {
            assert(NO);
        } break;
    }
}

-(void) stopSendWithStatus {
    
        if (self.networkStream != nil) {
            [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            self.networkStream.delegate = nil;
            [self.networkStream close];
            self.networkStream = nil;
        }
        if (self.fileStream != nil) {
            [self.fileStream close];
            self.fileStream = nil;
        
}
    
}

@end
