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

#import <Foundation/Foundation.h>
#import "MDButton.h"
#import "MDDatePickerDialog.h"
#import "UIView+MDExtension.h"
#import "UIFontHelper.h"
#import "MDDeviceHelper.h"
#import "MDCalendar.h"
#import "MDCalendarDateHeader.h"

#define kCalendarHeaderHeight                                                  \
  (([[UIScreen mainScreen] bounds].size.width > 320) ? 190 : 160)
#define kCalendarActionBarHeight 50

@interface MDDatePickerDialog ()
@property(strong, nonatomic) UIFont *buttonFont UI_APPEARANCE_SELECTOR;
@property(nonatomic) MDCalendarDateHeader *header;
@property(nonatomic) MDCalendar *calendar;

@property(nonatomic) MDButton *buttonOk;
@property(nonatomic) MDButton *buttonCancel;

@property(nonatomic) NSString *okTitle;
@property (nonatomic) NSString *cancelTitle;
@end

@implementation MDDatePickerDialog {
  UIView *popupHolder;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    UIView *view = [MDDeviceHelper getMainView];
    [self setFrame:view.bounds];

    popupHolder = [[UIView alloc] init];
    popupHolder.layer.shadowOpacity = 0.5;
    popupHolder.layer.shadowRadius = 8;
    popupHolder.layer.shadowColor = [[UIColor blackColor] CGColor];
    popupHolder.layer.shadowOffset = CGSizeMake(0, 2.5);

    int vSpacing = view.bounds.size.height * 0.05;
    int hSpacing = view.bounds.size.width * 0.1;

    [popupHolder
        setFrame:CGRectMake(hSpacing, vSpacing, self.mdWidth - 2 * hSpacing,
                            self.mdHeight - 2 * vSpacing)];

    _header = [[MDCalendarDateHeader alloc]
        initWithFrame:CGRectMake(0, 0, popupHolder.mdWidth,
                                 kCalendarHeaderHeight)];
    [popupHolder addSubview:_header];

    MDCalendar *calendar = [[MDCalendar alloc]
        initWithFrame:CGRectMake(0, kCalendarHeaderHeight, popupHolder.mdWidth,
                                 popupHolder.mdHeight - kCalendarHeaderHeight -
                                     kCalendarActionBarHeight)];
    calendar.dateHeader = _header;
    [popupHolder addSubview:calendar];
    self.calendar = calendar;
    self.calendar.theme = MDCalendarThemeLight;

    [self setBackgroundColor:self.calendar.backgroundColor];

    _buttonFont = [UIFontHelper robotoFontWithName:@"roboto-bold" size:15];

    MDButton *buttonOk = [[MDButton alloc]
        initWithFrame:CGRectMake(
                          popupHolder.mdWidth - 2 * kCalendarActionBarHeight,
                          popupHolder.mdHeight - kCalendarActionBarHeight,
                          2 * kCalendarActionBarHeight * 3.0 / 4.0,
                          kCalendarActionBarHeight * 3.0 / 4.0)
                 type:MDButtonTypeFlat
          rippleColor:nil];
      
      
    [buttonOk setTitleColor:[UIColor blueColor] forState:normal];
    [buttonOk addTarget:self action:@selector(doOK:) forControlEvents:UIControlEventTouchUpInside];
    [buttonOk.titleLabel setFont:_buttonFont];
    [popupHolder addSubview:buttonOk];
    self.buttonOk = buttonOk;

    MDButton *buttonCancel = [[MDButton alloc]
        initWithFrame:CGRectMake(
                          popupHolder.mdWidth - 4 * kCalendarActionBarHeight,
                          popupHolder.mdHeight - kCalendarActionBarHeight,
                          2 * kCalendarActionBarHeight * 3.0 / 4.0,
                          kCalendarActionBarHeight * 3.0 / 4.0)
                 type:MDButtonTypeFlat
          rippleColor:nil];
    [buttonCancel setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [buttonCancel addTarget:self action:@selector(doCancel:) forControlEvents:UIControlEventTouchUpInside];
    [buttonCancel.titleLabel setFont:_buttonFont];
    [popupHolder addSubview:buttonCancel];
    self.buttonCancel = buttonCancel;

    [self setTitleOk:NSLocalizedString(@"OK", @"") andTitleCancel:NSLocalizedString(@"CANCEL", @"")];
      
    UIColor *color = self.calendar.titleColors[@(MDCalendarCellStateButton)];
    [self.buttonCancel setTitleColor:color forState:UIControlStateNormal];
    [self.buttonOk setTitleColor:color forState:UIControlStateNormal];
    [self addTarget:self action:@selector(doRemove:) forControlEvents:UIControlEventTouchUpInside];

    [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];

    [self addSubview:popupHolder];
      
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(deviceOrientationDidChange:)
               name:UIDeviceOrientationDidChangeNotification
             object:nil];
  }
  return self;
}

-(NSDate*)selectedDate;
{
    return self.calendar.selectedDate;
}

-(void)setSelectedDate:(NSDate *)selectedDate;
{
    self.calendar.selectedDate = selectedDate;
}

-(void)setTitleOk: (nonnull NSString *) okTitle andTitleCancel: (nonnull NSString *) cancelTitle {
    _okTitle =  okTitle;
    _cancelTitle = cancelTitle;
    
    [_buttonOk setTitle:_okTitle forState:normal];
    [_buttonCancel setTitle:_cancelTitle forState:normal];
}

- (void) setSelectedDateString:(NSString *)dateString;
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [dateFormatter dateFromString:dateString];
    self.selectedDate = date;
}

- (void)addSelfToMainWindow {
  UIView *view = [MDDeviceHelper getMainView];
  [self setFrame:view.bounds];
  [view addSubview:self];
}

- (void)doRemove:(id)sender;
{
    [self removeFromSuperview];
}

- (void)layoutSubviews {
  [super layoutSubviews];

  UIView *view = [MDDeviceHelper getMainView];
  int vSpacing = view.bounds.size.height * 0.05;
  int hSpacing = view.bounds.size.width * 0.1;
  if ([[UIScreen mainScreen] bounds].size.width > 320) {

  } else {
    vSpacing /= 2;
    hSpacing /= 2;
  }

  [popupHolder
      setFrame:CGRectMake(hSpacing, vSpacing, self.mdWidth - 2 * hSpacing,
                          self.mdHeight - 2 * vSpacing)];

  UIInterfaceOrientation orientation =
      [[UIApplication sharedApplication] statusBarOrientation];
  switch (orientation) {
  case UIInterfaceOrientationPortrait:
  case UIInterfaceOrientationPortraitUpsideDown: {
    // load the portrait view
    _header.frame =
        CGRectMake(0, 0, popupHolder.mdWidth, kCalendarHeaderHeight);
    _calendar.frame = CGRectMake(0, kCalendarHeaderHeight, popupHolder.mdWidth,
                                 popupHolder.mdHeight - kCalendarHeaderHeight -
                                     kCalendarActionBarHeight);
  }

  break;
  case UIInterfaceOrientationLandscapeLeft:
  case UIInterfaceOrientationLandscapeRight: {
    if (view.bounds.size.height > view.bounds.size.width) {
      // http://stackoverflow.com/questions/26037472/uiwindow-with-wrong-size-when-using-landscape-orientation
      self.frame =
          CGRectMake(0, 0, view.bounds.size.height, view.bounds.size.width);
      [popupHolder setFrame:CGRectMake(hSpacing, vSpacing,
                                       view.bounds.size.height - 2 * hSpacing,
                                       view.bounds.size.width - 2 * vSpacing)];
    }
    // load the landscape view
    float headerWidthRatio = 0.5;
    if ([[UIScreen mainScreen] bounds].size.width <= 320)
      headerWidthRatio = 0.4;
    _header.frame = CGRectMake(0, 0, popupHolder.mdWidth * headerWidthRatio,
                               popupHolder.mdHeight - kCalendarActionBarHeight);
    _calendar.frame =
        CGRectMake(popupHolder.mdWidth * headerWidthRatio, 0,
                   popupHolder.mdWidth * (1.0 - headerWidthRatio),
                   popupHolder.mdHeight - kCalendarActionBarHeight);
  } break;
  case UIInterfaceOrientationUnknown:
    break;
  }

  _buttonCancel.mdLeft = popupHolder.mdWidth - 4 * kCalendarActionBarHeight;
  _buttonCancel.mdTop = popupHolder.mdHeight - kCalendarActionBarHeight;
  _buttonOk.mdLeft = popupHolder.mdWidth - 2 * kCalendarActionBarHeight;
  _buttonOk.mdTop = popupHolder.mdHeight - kCalendarActionBarHeight;

  [popupHolder setBackgroundColor:_calendar.backgroundColor];
}

- (void)show {
  [self addSelfToMainWindow];
}

- (void)doOK:(id)sender {
    [self.delegate datePickerDialogDidSelectDate:_calendar.selectedDate];
    [self removeFromSuperview];
}

- (void)doCancel:(id)sender {
    [self removeFromSuperview];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
  UIInterfaceOrientation orientation =
      [[UIApplication sharedApplication] statusBarOrientation];
  UIView *view = [MDDeviceHelper getMainView];
  switch (orientation) {
  case UIInterfaceOrientationPortrait:
  case UIInterfaceOrientationPortraitUpsideDown:
  case UIInterfaceOrientationLandscapeLeft:
  case UIInterfaceOrientationLandscapeRight: {
    self.frame =
        CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
  } break;
  case UIInterfaceOrientationUnknown:
    break;
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end