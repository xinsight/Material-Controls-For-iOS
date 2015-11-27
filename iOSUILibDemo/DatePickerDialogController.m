// The MIT License (MIT)
//
// Copyright (c) 2015 FPT Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "DatePickerDialogController.h"
#import "iOSUILib/Calendar/NSDate+MDExtension.h"
#import "iOSUILib/Calendar/MDDatePickerDialog.h"

@interface DatePickerDialogController () <MDDatePickerDialogDelegate>
@property(weak, nonatomic) IBOutlet UITextField *txtDate;
@property(nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation DatePickerDialogController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    
    self.title = @"MDDatePickerDialog";
}

- (IBAction)btnSelectDate:(id)sender {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = 1980;
    dateComponents.month = 1;
    dateComponents.day = 1;
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    
    MDDatePickerDialog *datePicker = [[MDDatePickerDialog alloc] init];
    // alternate way to set the date
    // datePicker.selectedDateString = @"2014-01-31";
    datePicker.selectedDate = date;
    datePicker.delegate = self;
    [datePicker show];
}

- (void)datePickerDialogDidSelectDate:(NSDate *)date {
    self.dateFormatter.dateFormat = @"dd-MM-yyyy";
    self.txtDate.text = [self.dateFormatter stringFromDate:date];
}

@end
