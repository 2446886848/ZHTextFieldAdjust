//
//  TestViewController.m
//  RACCommandExample
//
//  Created by 吴志和 on 15/10/20.
//  Copyright © 2015年 SHAPE. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UITextField *textField1;
@property (nonatomic, weak) IBOutlet UITextField *textField2;
@property (nonatomic, weak) IBOutlet UITextField *textField3;
@property (nonatomic, weak) IBOutlet UITextField *textField4;
@property (nonatomic, weak) IBOutlet UITextField *textField5;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.scrollView.contentSize = CGSizeMake(200, 720);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.textField5.center = CGPointMake(200, 700);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
