//
//  Compose Controller.h
//  UpdatedFetcher
//
//  Created by mrpumba on 12/7/11.
//  Copyright (c) 2011 Pumba Hax. All rights reserved.
//

#import <UIKit/UIKit.h>
enum {
    
    kSendBufferSize = 32768
};
@interface Compose_Controller : UIViewController <UITextFieldDelegate, NSStreamDelegate> {
    uint8_t                     _buffer[kSendBufferSize];
    size_t                      _bufferOffset;
    size_t                      _bufferLimit;
}

@property (strong, nonatomic) IBOutlet UITextView *composeField;
@property  BOOL isSending;
@property (strong, nonatomic) NSOutputStream *networkStream;
@property (strong, nonatomic) NSInputStream *fileStream;
@property (strong, nonatomic) IBOutlet UITextField *urlText;
@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *passWord;
@property (strong, nonatomic) NSString *fileName;
@property (nonatomic, readonly) uint8_t *         buffer;
@property (nonatomic, assign)   size_t            bufferOffset;
@property (nonatomic, assign)   size_t            bufferLimit;



- (IBAction)doneEditing:(id)sender;
-(IBAction)backgroundTouched:(id)sender;
- (IBAction)saveData:(id)sender;
- (IBAction)uploadData:(id)sender;
-(void) stopSendWithStatus;



@end
