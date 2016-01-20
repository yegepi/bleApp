//
//  KSDetailController.m
//  
//
//  Created by KS on 5/12/15.
//
//

#import "KSDetailController.h"
#import "UUChart.h"

@interface KSDetailController () <UUChartDataSource>
@property (retain, nonatomic) IBOutlet UIButton *btnNotes;
@property (retain, nonatomic) IBOutlet UIButton *btnSeparator;

@property (retain, nonatomic) IBOutlet UIButton *btnHistory;
@property (retain, nonatomic) IBOutlet UIView *chartView;
@end

@implementation KSDetailController

- (void)viewDidLayoutSubviews {
    [self initChart];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self.btnNotes.layer setMasksToBounds:YES];
    //[self.btnNotes.layer setCornerRadius:2.0];
    //[self.btnNotes.layer setBorderWidth:1.0];
    
    //[self.btnHistory.layer setMasksToBounds:YES];
    //[self.btnHistory.layer setCornerRadius:2.0];
    //[self.btnHistory.layer setBorderWidth:1.0];
    
    [self.btnSeparator.layer setMasksToBounds:YES];
    [self.btnSeparator.layer setBorderWidth:0.5];
    [self.btnSeparator.layer setBorderColor:[UIColor grayColor].CGColor];
    
    //register Notify of temprature
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"valueChanged" object:self];}
    //- (void)postNotificationName:(NSString *)notificationName object:(id)notificationSender userInfo:(NSDictionary *)userInfo
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tempChanged:) name:@"valueChanged" object:nil];
}

- (void)tempChanged:(NSNotification *)notification {
    // update view with latest temprature value
    
    /*
     1、发通知
     NSDictionary *myDictionary = [NSDictionary dictionaryWithObject:@"sendValue" forKey:@"sendKey"];
     [[NSNotificationCenter defaultCenter] postNotificationName:@"myNotice" object:nil userInfo:myDictionary];
     
     2、接受通知
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noticeMethod:) name:@"myNotice" object:nil];
     
     3、调用方法，接受信息。
     - (void)noticeMethod:(NSNotification *)notification
     {
     NSString *getsendValue = [[notification userInfo] valueForKey:@"sendKey"];
     }
     */
    
}

- (IBAction)editProfile:(id)sender {
    
    //push editProfile controller
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *popup = [sb instantiateViewControllerWithIdentifier:@"edit"];
    
    [self.navigationController pushViewController:popup animated:NO];
}

- (void)initChart {
    NSInteger bottom = self.btnNotes.frame.origin.y;
    NSInteger top = self.chartView.frame.origin.y;
    NSInteger w = [UIScreen mainScreen].bounds.size.width;
    NSInteger h = [UIScreen mainScreen].bounds.size.height;
    
    UUChart *chart = [[UUChart alloc] initwithUUChartDataFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.chartView.bounds.size.height )
                                                    withSource:self
                                                    withStyle:UUChartLineStyle];
//    UUChart *chart = [[UUChart alloc] initwithUUChartDataFrame:self.chartView.bounds withSource:self withStyle:UUChartLineStyle];
    [chart showInView:self.chartView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_btnNotes release];
    [_btnHistory release];
    [_chartView release];
    [_btnSeparator release];
    [super dealloc];
}

- (NSArray *)getXTitles:(int)num
{
    NSMutableArray *xTitles = [NSMutableArray array];
    for (int i=0; i<num; i++) {
        NSString * str = [NSString stringWithFormat:@"%d",i];
        [xTitles addObject:str];
    }
    return xTitles;
}

#pragma mark - @required
//横坐标标题数组
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    return [self getXTitles:11];
}

//数值多重数组
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
    NSArray *ary4 = @[@"36",@"37",@"38",@"37",@"39",@"40",@"39",@"40",@"42",@"39",@"37"];
    
    return @[ary4];}

#pragma mark - @optional
//颜色数组
- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    return @[UUGreen,UURed,UUBrown];
}
//显示数值范围
- (CGRange)UUChartChooseRangeInLineChart:(UUChart *)chart
{
return CGRangeMake(45, 30);
}

#pragma mark 折线图专享功能

//标记数值区域
- (CGRange)UUChartMarkRangeInLineChart:(UUChart *)chart
{
    return CGRangeZero;
}

//判断显示横线条
- (BOOL)UUChart:(UUChart *)chart ShowHorizonLineAtIndex:(NSInteger)index
{
    return YES;
}

//判断显示最大最小值
- (BOOL)UUChart:(UUChart *)chart ShowMaxMinAtIndex:(NSInteger)index
{
    return NO;
}
@end
