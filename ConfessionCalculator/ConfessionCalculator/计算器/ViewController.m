//
//  ViewController.m
//  计算器
//
//  Created by 薛林 on 15/4/26.
//  Copyright © 2015年 薛林. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()<UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *showBaby;
//one图片
@property (weak, nonatomic) IBOutlet UIView *cacuView;
@property (weak, nonatomic) IBOutlet UIButton *everyDel;
//清除的按钮
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScroll;
//显示结果的label
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
//定义一个可变字符串，保存用户点击的按钮上的文字
@property (copy,nonatomic) NSMutableString *resStr;
@property (nonatomic, strong) CAEmitterLayer *caELayer;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UIImageView *heartView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //调用方法
    [self clearButton];
    [self creatCaculatorBtn];
    
    //初始换可变数组
    _resStr = [NSMutableString string];
    //设置滚动范围
    self.imageScroll.contentSize = CGSizeMake(320, 725);
    //设置上方向的偏移量
    self.imageScroll.contentInset = UIEdgeInsetsMake(400, 0, 0, 0);
    //指定代理
    self.imageScroll.delegate = self;
    
    _heartView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart"]];
    _heartView.frame = CGRectMake(0, 0, 80, 180);
    _heartView.center = self.showBaby.center;
    _heartView.userInteractionEnabled = YES;
    _heartView.alpha = 0;
    [_heartView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeartView)]];
    [self.view addSubview:_heartView];
}

//创建计算器数字按钮,并给按钮赋tag值
- (void)creatCaculatorBtn {
    CGFloat numBtnW = self.cacuView.frame.size.width / 4;
    CGFloat numBtnH = numBtnW;
    //确定总列数
    int colNum = 3;
    for (int i = 0; i < 9; i++) {
        //确定每个按钮所在的行数和列数
        int col = i % colNum;
        int row = i / colNum;
        UIButton *numBtn = [[UIButton alloc]init];
        //确定X值和Y值
        CGFloat numBtnX = numBtnW * col;
        CGFloat numBtnY = numBtnH + numBtnH * row;
        //确定位置、文字颜色、背景
        numBtn.frame = CGRectMake(numBtnX, numBtnY, numBtnW, numBtnH);
        [numBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        //背景图片
        UIImage *image = [UIImage imageNamed:@"bj"];
        [numBtn setBackgroundImage:image forState:UIControlStateNormal];
        numBtn.alpha = 1;
        //添加点击事件
        //        [numBtn addTarget:self action:@selector(changeAlpha:) forControlEvents:UIControlEventTouchDown];
        [numBtn addTarget:self action:@selector(showResult:) forControlEvents:UIControlEventTouchUpInside];
        //去除高亮状态
        numBtn.adjustsImageWhenHighlighted = NO;
        NSString *numStr = [NSString stringWithFormat:@"%d",i + 1];
        [numBtn setTitle:numStr forState:UIControlStateNormal];
        //设置tag值
        numBtn.tag = i;
        //添加到控件
        [self.cacuView addSubview:numBtn];
    }
    
}
//设置清除按钮圆角
- (void)clearButton {
    //设置按钮圆角
    self.clearBtn.layer.cornerRadius = 25;
    //去除多余部分
    self.clearBtn.layer.masksToBounds = YES;
    
    self.everyDel.layer.cornerRadius = 25;
    //去除多余部分
    self.everyDel.layer.masksToBounds = YES;
    [self.clearBtn addTarget:self action:@selector(changeAlpha) forControlEvents:UIControlEventTouchUpInside];
}
//设置tag值 零:100、加:10、减:11、乘:12、除:13、点:14、等于:15、删除:16、清零:20
//取出按钮上的文字赋给可变字符串
- (IBAction)showResult:(UIButton *)btn {
    //将按钮的文字添加到字符串中
    NSString *tempStr = [btn titleForState:UIControlStateNormal];
    //添加到可变数组中
    [_resStr appendString:tempStr];
    [self showNum];
    [self caculator:btn];
    if ([_resStr containsString:@"520"]) {
        [self heartbeatAnimation];
    }
    
}

- (void)showText {
    if (self.index == 0) {
        [_resStr appendString:@"我"];
    } else if(self.index == 1){
        [_resStr appendString:@"喜"];
    } else if(self.index == 2){
        [_resStr appendString:@"欢"];
    } else if(self.index == 3){
        [_resStr appendString:@"你"];
    }
    self.index++;
    if (self.index == 4) {
        [self.timer invalidate];
    }
    [self showNum];
}

//一个一个删除输入的内容
- (IBAction)deletNum {
    //声明一个临时字符串
    NSMutableString *tempStr = [NSMutableString string];
    tempStr = self.resStr;
    if (tempStr.length > 0) {
        //删除字符串的最后一个字符
        [tempStr deleteCharactersInRange:NSMakeRange(tempStr.length - 1, 1)];
        //将修改后的字符串赋回去
        _resStr = tempStr;
        //在Label上显示
        [self showNum];
    }else{
        return;
    }
    
}

- (void)tapHeartView {
    self.heartView.hidden = YES;
    _resStr = @"".mutableCopy;
    [self setupAtmosphere];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showText) userInfo:nil repeats:YES];
}

//显示结果的Label上
- (void)showNum {
    self.resultLabel.text = self.resStr;
}
//将Label清零
- (IBAction)clearAllNum {
    //将Label清零
    self.resultLabel.text = nil;
    //赋值给临时字符串并删除所有字符
    NSMutableString *str = self.resStr;
    for (int i = 0; i < str.length; i++) {
        [str deleteCharactersInRange:NSMakeRange(0, str.length)];
    }
    //将空字符串再赋值回去
    _resStr = str;
}

//根据符号截取字符串，再将字符串转成double进行运算，运算完毕后
- (void)caculator:(UIButton *)btn {
    NSInteger tag = btn.tag;
    //当用户数去=的时候进去语句块
    if (tag == 15) {
        NSString *str = self.resStr;
        //遍历字符串以+-*/进行截取字符串
        for (int i = 0; i < str.length; i++) {
            
            if ([str characterAtIndex:i] == '+') {
                //以+截取字符串
                NSString *num1 = [str substringToIndex:i];
                NSString *num2 = [str substringWithRange:NSMakeRange(i+1, str.length-i-1)];
                //相加
                double resu = [num1 doubleValue] + [num2 doubleValue];
                NSString *tempStr = [NSString stringWithFormat:@"%.03lf",resu];
                [_resStr appendString:tempStr];
                [self showNum];
            }
            if ([str characterAtIndex:i] == '-') {
                //以+截取字符串
                NSString *num1 = [str substringToIndex:i];
                NSString *num2 = [str substringWithRange:NSMakeRange(i+1, str.length-i-1)];
                //相加
                double resu = [num1 doubleValue] - [num2 doubleValue];
                NSString *tempStr = [NSString stringWithFormat:@"%.03lf",resu];
                [_resStr appendString:tempStr];
                [self showNum];
            }
            if ([str characterAtIndex:i] == 'x') {
                //以+截取字符串
                NSString *num1 = [str substringToIndex:i];
                NSString *num2 = [str substringWithRange:NSMakeRange(i+1, str.length-i-1)];
                //相加
                double resu = [num1 doubleValue] * [num2 doubleValue];
                NSString *tempStr = [NSString stringWithFormat:@"%.03lf",resu];
                [_resStr appendString:tempStr];
                [self showNum];
            }
            if ([str characterAtIndex:i] == '/') {
                //以+截取字符串
                NSString *num1 = [str substringToIndex:i];
                NSString *num2 = [str substringWithRange:NSMakeRange(i+1, str.length-i-1)];
                //相加
                double resu = [num1 doubleValue] / [num2 doubleValue];
                NSString *tempStr = [NSString stringWithFormat:@"%.03lf",resu];
                [_resStr appendString:tempStr];
                [self showNum];
            }
            
        }
    }
    
}

//开始滚动时调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //设置frame
    self.showBaby.frame = CGRectMake(0, 0, 320, 568);
    //设置透明度
    self.showBaby.alpha = 1;
    //设置图片
    self.showBaby.image = [UIImage imageNamed:@"img_08"];
}

- (void)heartbeatAnimation {
    
    [UIView animateWithDuration:1.0 animations:^{
        self.heartView.alpha = 1.0;
    }];
 
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    CGFloat duration = 1.f;
    CGFloat height = 7.f;
    CGFloat currentY = self.heartView.transform.ty;
    animation.duration = duration;
    animation.values = @[@(currentY),@(currentY - height/4),@(currentY - height/4*2),@(currentY - height/4*3),@(currentY - height),@(currentY - height/ 4*3),@(currentY - height/4*2),@(currentY - height/4),@(currentY)];
    animation.keyTimes = @[ @(0), @(0.025), @(0.085), @(0.2), @(0.5), @(0.8), @(0.915), @(0.975), @(1) ];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.repeatCount = HUGE_VALF;
    [self.heartView.layer addAnimation:animation forKey:@"kViewShakerAnimationKey"];
}

// 氛围
- (void)setupAtmosphere {
    self.caELayer                   = [CAEmitterLayer layer];
    // 发射源
    self.caELayer.emitterPosition   = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height - 50);
    // 发射源尺寸大小
    self.caELayer.emitterSize       = CGSizeMake(50, 0);
    // 发射源模式
    self.caELayer.emitterMode       = kCAEmitterLayerOutline;
    // 发射源的形状
    self.caELayer.emitterShape      = kCAEmitterLayerLine;
    // 渲染模式
    self.caELayer.renderMode        = kCAEmitterLayerAdditive;
    // 发射方向
    self.caELayer.velocity          = 1;
    // 随机产生粒子
    self.caELayer.seed              = (arc4random() % 100) + 1;
    
    // cell
    CAEmitterCell *cell             = [CAEmitterCell emitterCell];
    // 速率
    cell.birthRate                  = 1.0;
    // 发射的角度
    cell.emissionRange              = 0.11 * M_PI;
    // 速度
    cell.velocity                   = 300;
    // 范围
    cell.velocityRange              = 150;
    // Y轴 加速度分量
    cell.yAcceleration              = 75;
    // 声明周期
    cell.lifetime                   = 2.04;
    //是个CGImageRef的对象,既粒子要展现的图片
    cell.contents                   = (id)[[UIImage imageNamed:@"FFRing"] CGImage];
    // 缩放比例
    cell.scale                      = 0.2;
    // 粒子的颜色
    cell.color                      = [[UIColor colorWithRed:0.6
                                                       green:0.6
                                                        blue:0.6
                                                       alpha:1.0] CGColor];
    // 一个粒子的颜色green 能改变的范围
    cell.greenRange                 = 1.0;
    // 一个粒子的颜色red 能改变的范围
    cell.redRange                   = 1.0;
    // 一个粒子的颜色blue 能改变的范围
    cell.blueRange                  = 1.0;
    // 子旋转角度范围
    cell.spinRange                  = M_PI;
    
    // 爆炸
    CAEmitterCell *burst            = [CAEmitterCell emitterCell];
    // 粒子产生系数
    burst.birthRate                 = 1.0;
    // 速度
    burst.velocity                  = 0;
    // 缩放比例
    burst.scale                     = 2.5;
    // shifting粒子red在生命周期内的改变速度
    burst.redSpeed                  = -1.5;
    // shifting粒子blue在生命周期内的改变速度
    burst.blueSpeed                 = +1.5;
    // shifting粒子green在生命周期内的改变速度
    burst.greenSpeed                = +1.0;
    //生命周期
    burst.lifetime                  = 0.35;
    
    
    // 火花 and finally, the sparks
    CAEmitterCell *spark            = [CAEmitterCell emitterCell];
    //粒子产生系数，默认为1.0
    spark.birthRate                 = 400;
    //速度
    spark.velocity                  = 125;
    // 360 deg//周围发射角度
    spark.emissionRange             = 2 * M_PI;
    // gravity//y方向上的加速度分量
    spark.yAcceleration             = 75;
    //粒子生命周期
    spark.lifetime                  = 3;
    //是个CGImageRef的对象,既粒子要展现的图片
    spark.contents                  = (id)
    [[UIImage imageNamed:@"FFTspark"] CGImage];
    //缩放比例速度
    spark.scaleSpeed                = -0.2;
    //粒子green在生命周期内的改变速度
    spark.greenSpeed                = -0.1;
    //粒子red在生命周期内的改变速度
    spark.redSpeed                  = 0.4;
    //粒子blue在生命周期内的改变速度
    spark.blueSpeed                 = -0.1;
    //粒子透明度在生命周期内的改变速度
    spark.alphaSpeed                = -0.25;
    //子旋转角度
    spark.spin                      = 2* M_PI;
    //子旋转角度范围
    spark.spinRange                 = 2* M_PI;
    

    self.caELayer.emitterCells = [NSArray arrayWithObject:cell];
    cell.emitterCells = [NSArray arrayWithObjects:burst, nil];
    burst.emitterCells = [NSArray arrayWithObject:spark];
    [self.showBaby.layer addSublayer:self.caELayer];
}

- (void)changeAlpha {
    [UIView animateWithDuration:0.5 animations:^{
        self.clearBtn.alpha = 0.6;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.clearBtn.alpha = 0.1;
        }];
    }];
}
@end
