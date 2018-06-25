//
//  ViewController.m
//  CategoriesTest
//
//  Created by mayiAngel on 2018/6/25.
//  Copyright © 2018年 test. All rights reserved.
//

#import "ViewController.h"
#import "UIView+HXJUtil.h"

@interface ViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.textField registerKeyboardChangeNotification:nil];
    self.textField.delegate = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField endEditing:YES];
    return YES;
}

- (void)dealloc {
    [self.textField unregisterKeyboardChangeNotification];
}

@end
