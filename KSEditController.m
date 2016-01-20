//
//  KSEditController.m
//  
//
//  Created by KS on 13/12/15.
//
//

#import "KSEditController.h"
#import "KSDetailController.h"

@interface KSEditController ()

@end

@implementation KSEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancel:(id)sender {
    KSDetailController *detail = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    //[self.navigationController popToViewController:detail animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
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
