//
//  NoteViewController.m
//  NLP123
//
//  Created by Kristian Borum on 2/27/10.
//  Copyright 2010 Krisb.net. All rights reserved.
//

#import "NoteViewController.h"


@implementation NoteViewController

- (void)keyboardWasShown:(NSNotification*)aNotification {
  if (keyboardShown)
    return;
  self.navItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)] autorelease];
  
  // Get the size of the keyboard.
  NSValue* aValue = [[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey];
  //  CGSize keyboardSize = [aValue CGRectValue].size;
  
  //CGRect keyboardFrame = [self.view convertRect:[aValue CGRectValue] toView:nil];
  CGSize keyboardSize = [self.view convertRect:[aValue CGRectValue] toView:nil].size;
  
  // Resize the scroll view (which is the root view of the window)
  CGRect viewFrame = [self.scrollView frame];
  
  NSLog( @"Keyboard size: %f x %f   swframe: %f %f %f %f ",keyboardSize.width,keyboardSize.height,
        viewFrame.origin.x,viewFrame.origin.y,viewFrame.size.width,viewFrame.size.height);
  
  viewFrame.size.height -= keyboardSize.height;
  
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationBeginsFromCurrentState:YES];
  [UIView setAnimationDuration:.3];
  self.scrollView.frame = viewFrame;
  self.scrollView.contentSize = CGSizeMake(viewFrame.size.width, viewFrame.size.height+41);
  self.textView.frame = CGRectMake(20, 51, viewFrame.size.width-40, viewFrame.size.height-20);
  [UIView commitAnimations];
  
  // Scroll the active text field into view.
  CGRect textFieldRect = [self.activeField frame];
  [self.scrollView scrollRectToVisible:CGRectMake(0, textFieldRect.origin.y-10, viewFrame.size.width, viewFrame.size.height) animated:YES];
}


// Called when the UIKeyboardDidHideNotification is sent
- (void)keyboardWasHidden:(NSNotification*)aNotification {
  self.navItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(done:)] autorelease];
  
  // Get the size of the keyboard.
  NSValue* aValue = [[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey];
  CGSize keyboardSize = [self.view convertRect:[aValue CGRectValue] toView:nil].size;
  
  // Reset the height of the scroll view to its original value
  CGRect viewFrame = [self.scrollView frame];
  viewFrame.size.height += keyboardSize.height;
  
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationBeginsFromCurrentState:YES];
  [UIView setAnimationDuration:.3];
  self.scrollView.frame = viewFrame;
  self.scrollView.contentSize = CGSizeMake(viewFrame.size.width, viewFrame.size.height+41);
  self.textView.frame = CGRectMake(20, 51, viewFrame.size.width-40, viewFrame.size.height-71);
  [UIView commitAnimations];
  
  keyboardShown = NO;
}




- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self.textView becomeFirstResponder];
  return YES;
}

-(IBAction)done:(id)sender {
  if ( keyboardShown ) {
    [self.textView resignFirstResponder];
    [self.textField resignFirstResponder];
  } else {
    NSString* annotationId = [[ContentStore contentStore] annotationIdForPage:self.pageIndexPath];
    if (self.textField.text != nil)
      [[NoteStore noteStore] setTitle:self.textField.text forId:annotationId];
    if (self.textView.text != nil)
      [[NoteStore noteStore] setNote:self.textView.text forId:annotationId];
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}


-(IBAction)cancel:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidLoad {
  [super viewDidLoad];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
  
  NSString* annotationId = [[ContentStore contentStore] annotationIdForPage:self.pageIndexPath];
  
  NSString *title = [[NoteStore noteStore] titleForId:annotationId];
  NSString *contents = [[NoteStore noteStore] noteForId:annotationId];
  if ( title == nil ) title = @"";
  if ( contents == nil ) contents = @"";
  
  self.textField.text = title;
  self.textView.text = contents;
    
    UIColor *borderColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0];
    
    self.textView.layer.borderColor = borderColor.CGColor;
    self.textView.layer.borderWidth = 1.0;
    self.textView.layer.cornerRadius = 5.0;
}

- (void)textFieldDidBeginEditing:(UITextField *)_textField {
  self.activeField = self.textField;
}

- (void)textFieldDidEndEditing:(UITextField *)_textField {
  self.activeField = nil;
}

- (void)textViewDidBeginEditing:(UITextView *)_textView {
  self.activeField = self.textView;
  if (keyboardShown) {
    CGRect viewFrame = [self.scrollView frame];
    [self.scrollView scrollRectToVisible:CGRectMake(0, 41, viewFrame.size.width, viewFrame.size.height) animated:YES];  }
  
}

- (void)textViewDidEndEditing:(UITextView *)_textView {
  self.activeField = nil;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
  [super dealloc];
}


@end
