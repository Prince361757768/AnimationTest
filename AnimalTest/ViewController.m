//
//  ViewController.m
//  AnimalTest
//
//  Created by Y杨定甲 on 16/8/1.
//  Copyright © 2016年 damai. All rights reserved.
//

#import "ViewController.h"
#define kAnimationDuration 0.4


@interface ViewController ()
@property (assign,nonatomic)BOOL isOn;
@property (strong,nonatomic)UIButton *bottomBtn;
@property (nonatomic ,strong)NSMutableArray *btns;
@property (nonatomic, strong)CAGradientLayer *gradientLayer;

@property (weak, nonatomic) IBOutlet UILabel *aUILabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isOn = NO;
    self.btns = [[NSMutableArray alloc] init];
    
    [self initBtn];
}
- (void)initBtn{
    self.bottomBtn = [[UIButton alloc] initWithFrame:CGRectMake(135, 400, 50, 50)];
//    [self.bottomBtn setImage:[UIImage imageNamed:@"icon3"] forState:UIControlStateNormal];
    [self.bottomBtn setBackgroundImage:[UIImage imageNamed:@"icon3"] forState:UIControlStateNormal];
    [self.bottomBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bottomBtn];
    
    for (int i = 0; i< 3; i++) {
        
        UIButton *pushBtn = [UIButton new];
        pushBtn.tag = 100+i;
        pushBtn.frame = CGRectMake(140, 405, 40, 40);
        NSString *name = [NSString stringWithFormat:@"SC%d",i];
        [pushBtn setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
        
        [self.btns addObject:pushBtn];
    }
    
}
- (void)btnClick{
    if (_isOn) {
        _isOn = NO;
        //打开
        [self.bottomBtn setBackgroundImage:[UIImage imageNamed:@"icon3"] forState:UIControlStateNormal];
        
        
        for (int i = 0; i< _btns.count; i++) {
            UIButton *btn = _btns[i];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05*i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //将point相对于superView中的坐标转换为btn中的坐标
                //            是指将p相对aView的坐标转换为相对btnView的坐标
                //btn (5 -45; 40 40)   point = (x = 125, y = 125)
                //p点事0，0转换后20 70      -23 -5      63 -5
                CGPoint p = [self.view convertPoint:self.bottomBtn.center toView:btn];
                //这里其实point点是没有用到的
                [self animationWithBtn:btn Point:p];
                
            });
        }
        
        
    }else{
        _isOn = YES;
        [self.bottomBtn setBackgroundImage:[UIImage imageNamed:@"icon2"] forState:UIControlStateNormal];
        self.bottomBtn.enabled = NO;

        
        for (int i = 0; i< _btns.count; i++) {
            //        320-80*3  /4 = 20  间距为20
            //三个btn的起点分别为20，120，220
            CGFloat x = 100*i - 100;
            CGFloat y = -200;
            UIButton *pushBtn = _btns[i];
            
            
            [self.view addSubview:pushBtn];
            [self.view bringSubviewToFront:self.bottomBtn];
            
//            UIViewAnimationOptionAllowUserInteraction //动画时允许用户交流，比如触摸
            
            //弹簧效果  IOS 7之后的新方法  usingSpringWithDamping 的范围为 0.0f 到 1.0f ，数值越小「弹簧」的振动效果越明显。     initialSpringVelocity 则表示初始的速度，数值越大一开始移动越快。
            //UIViewAnimationOptionCurveLinear 时间曲线函数，匀速  没什么影响
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:1.0 delay:0.1*i usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    //创建一个平移的变化 btn的原始frame会加上x,y平移
                    pushBtn.transform = CGAffineTransformMakeTranslation(x, y);
                    //组合动画
                    pushBtn.transform = CGAffineTransformScale(pushBtn.transform, 2, 2);
                } completion:^(BOOL finished) {
                    
                    self.bottomBtn.enabled = YES;
                }];
            });
        }
    }
}

//文本动画1
-(void)startAnimationIfNeeded{
    //取消、停止所有的动画
    [self.aUILabel.layer removeAllAnimations];
    CGSize textSize = [self.aUILabel.text sizeWithFont:self.aUILabel.font];
    CGRect lframe = self.aUILabel.frame;
    lframe.size.width = textSize.width;
    self.aUILabel.frame = lframe;
    const float oriWidth = 100;
    if (textSize.width > oriWidth) {
        float offset = textSize.width - oriWidth;
        [UIView animateWithDuration:3.0
                              delay:0
                            options:UIViewAnimationOptionRepeat //动画重复的主开关
         |UIViewAnimationOptionAutoreverse //动画重复自动反向，需要和上面这个一起用
         |UIViewAnimationOptionCurveLinear //动画的时间曲线，滚动字幕线性比较合理
                         animations:^{
                             self.aUILabel.transform = CGAffineTransformMakeTranslation(-offset, 0);
                         }
                         completion:^(BOOL finished) {
                             
                         }
         ];
    }
}
//文本动画2
- (void)textAnimationTwo{
    
    // 疑问：label只是用来做文字裁剪，能否不添加到view上。
    // 必须要把Label添加到view上，如果不添加到view上，label的图层就不会调用drawRect方法绘制文字，也就没有文字裁剪了。
    // 如何验证，自定义Label,重写drawRect方法，看是否调用,发现不添加上去，就不会调用
//    [self.view addSubview:label];
    
    // 创建渐变层
    _gradientLayer = [CAGradientLayer layer];
    
    _gradientLayer.frame = self.aUILabel.frame;
    
    // 设置渐变层的颜色，随机颜色渐变
    _gradientLayer.colors = @[(id)[self randomColor].CGColor, (id)[self randomColor].CGColor,(id)[self randomColor].CGColor];
    
    // 疑问:渐变层能不能加在label上
    // 不能，mask原理：默认会显示mask层底部的内容，如果渐变层放在mask层上，就不会显示了
    
    // 添加渐变层到控制器的view图层上
    [self.view.layer addSublayer:_gradientLayer];
    
    // mask层工作原理:按照透明度裁剪，只保留非透明部分，文字就是非透明的，因此除了文字，其他都被裁剪掉，这样就只会显示文字下面渐变层的内容，相当于留了文字的区域，让渐变层去填充文字的颜色。
    // 设置渐变层的裁剪层
    _gradientLayer.mask = self.aUILabel.layer;
    
    // 注意:一旦把label层设置为mask层，label层就不能显示了,会直接从父层中移除，然后作为渐变层的mask层，且label层的父层会指向渐变层，这样做的目的：以渐变层为坐标系，方便计算裁剪区域，如果以其他层为坐标系，还需要做点的转换，需要把别的坐标系上的点，转换成自己坐标系上点，判断当前点在不在裁剪范围内，比较麻烦。
    
    
    // 父层改了，坐标系也就改了，需要重新设置label的位置，才能正确的设置裁剪区域。
    self.aUILabel.frame = _gradientLayer.bounds;
    
    // 利用定时器，快速的切换渐变颜色，就有文字颜色变化效果
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(textColorChange)];
    
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}
// 随机颜色方法
-(UIColor *)randomColor{
    CGFloat r = arc4random_uniform(256) / 255.0;
    CGFloat g = arc4random_uniform(256) / 255.0;
    CGFloat b = arc4random_uniform(256) / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}
// 定时器触发方法
-(void)textColorChange {
    _gradientLayer.colors = @[(id)[self randomColor].CGColor,
                              (id)[self randomColor].CGColor,
                              (id)[self randomColor].CGColor,
                              (id)[self randomColor].CGColor,
                              (id)[self randomColor].CGColor];
}
//btn动画1
- (void)btnAnimation{
    CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation new];
    keyAnimation.keyPath = @"position.x";
//    @() 还可以接受 int 字面量或 int 变量作为参数  否则int无法作为变量
    keyAnimation.values = @[@(0),@(30),@(-30),@(0)];
    //注意这个keyTimes只能跟values结合使用。如果没有value数组则不生效
    //设定每个关键帧的时长，如果没有显式地设置，则默认每个帧的时间=总duration/(values.count - 1)
    keyAnimation.keyTimes = @[[NSNumber numberWithFloat:0.2],
                               [NSNumber numberWithFloat:1.0], [NSNumber numberWithFloat:0.8],
                               [NSNumber numberWithFloat:2]];
    keyAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    
//    additive设置为true是使Core Animation 在更新 presentation layer 之前将动画的值添加到 model layer 中去。可以看到上面的values是0，10，-10，0. 没有设置的话values=layer.position.x+0, layer.position.x+10, layer.position.x-10
    keyAnimation.additive = YES;
    keyAnimation.duration = 3;
    keyAnimation.repeatCount = 5;
    
    CAKeyframeAnimation *keyAnimation2 = [CAKeyframeAnimation new];
    keyAnimation2.keyPath = @"position";
    CGRect boundRect = CGRectMake(_bottomBtn.frame.origin.x, _bottomBtn.frame.origin.y, 100, 100);
    keyAnimation2.path = CGPathCreateWithRect(boundRect, nil);
    keyAnimation2.autoreverses = NO;
    keyAnimation2.duration = 4;
    keyAnimation2.repeatCount = HUGE;
    
    //其值为kCAAnimationPaced，保证动画向被驱动的对象施加一个恒定速度，不管路径的各个线段有多长，并且无视我们已经设置的keyTimes
    keyAnimation2.calculationMode = kCAAnimationPaced;
    //kCAAnimationRotateAuto，确定其沿着路径旋转（具体要自己来体验，这里难解释）这个属性主要关系到layer运行起来以后控件的状态。具体自己试试效果
    keyAnimation2.rotationMode = kCAAnimationRotateAutoReverse;
    
    
    [self.bottomBtn.layer addAnimation:keyAnimation forKey:@"keyAnimation"];
}

/*
//演员--->CALayer，规定电影的主角是谁
//剧本--->CAAnimation，规定电影该怎么演，怎么走，怎么变换
//开拍--->AddAnimation，开始执行
  Layer是绘图的画板，Bezier是画图的画笔，Animation是画图的动作
//http://blog.csdn.net/smking/article/details/8424245  动画Demo
 CABasicAnimation正在进行动画的时候，点击了Home按钮后再回到app的时候，动画会被清空。
*/
-(void)animationWithBtn:(UIButton*)btn Point:(CGPoint)point{
    
    CABasicAnimation *rotation = [CABasicAnimation new];
    rotation.keyPath = @"transform.rotation";
    rotation.toValue = @(5 * M_PI);
    
    CABasicAnimation *scale = [CABasicAnimation new];
    scale.keyPath = @"transform.scale";
    scale.beginTime = 0.2;
    scale.duration = kAnimationDuration - scale.beginTime;
    scale.removedOnCompletion = YES;
    scale.fromValue = [NSNumber numberWithFloat:1];
    scale.toValue = [NSNumber numberWithFloat:0.5];
    
    //透明度动画
    CABasicAnimation
    *animation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue=[NSNumber
                         numberWithFloat:1.0];
    animation.toValue=[NSNumber
                       numberWithFloat:0.4];
    animation.repeatCount=0;
    animation.duration=0.4;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    //设定动画的速度变化 动画先加速后减速
    animation.timingFunction=[CAMediaTimingFunction
                              functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //执行动画回路,前提是设置动画无限重复
    animation.autoreverses=YES;
    
    
    
    CABasicAnimation *trans = [CABasicAnimation new];
    trans.keyPath = @"transform";
    //获取一个标准默认的CATransform3D仿射变换矩阵  恢复默认形状
    trans.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    trans.beginTime = 0.2;
    trans.duration = kAnimationDuration - trans.beginTime;
    
    
    
    CAAnimationGroup *group = [CAAnimationGroup new];
    group.animations = @[rotation,trans];
    group.duration = kAnimationDuration;
    //以下两行代码 动画终了后不返回初始状态 动画结束保留最终动画点的状态，不恢复到起点
    group.removedOnCompletion = NO;
    group.fillMode = @"forwards";
//    捕获动画开始时和终了时的事件 实现协议方法即可
    group.delegate = self; // 指定委托对象
    
    
    [btn.layer addAnimation:group forKey:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(group.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //重置
        btn.transform = CGAffineTransformIdentity;
        [btn.layer removeAllAnimations];
        [btn removeFromSuperview];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)callTestApp:(id)sender {
    
    [self btnAnimation];
    
    
//    NSString *customURL = @"yydjIosTestApp://?token=123abct&registered=1";
//    
//    if ([[UIApplication sharedApplication]
//         canOpenURL:[NSURL URLWithString:customURL]])
//    {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:customURL]];
//    }
//    else
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL error"
//                                                        message:[NSString stringWithFormat:
//                                                                 @"No custom URL defined for %@", customURL]
//                                                       delegate:self cancelButtonTitle:@"Ok"
//                                              otherButtonTitles:nil]; 
//        [alert show]; 
//    }
    
}

@end
