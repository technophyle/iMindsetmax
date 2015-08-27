//
//  NoteViewController.h
//  NLP123
//
//  Created by Kristian Borum on 2/27/10.
//  Copyright 2010 Krisb.net. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NoteViewController : UIViewController {

  bool keyboardShown;

}

@property (nonatomic,retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic,retain) IBOutlet UITextView   *textView;
@property (nonatomic,retain) IBOutlet UITextField *textField;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *rightButton;
@property (nonatomic,retain) IBOutlet UINavigationItem *navItem;

@property (nonatomic,retain)          UIView  *activeField;

@property (nonatomic,retain) NSIndexPath* pageIndexPath;




-(IBAction)done:(id)sender;
-(IBAction)cancel:(id)sender;

@end
