//
//  NTRViewController.m
//  SecretAnimation
//
//  Created by Natasha Murashev on 4/13/14.
//  Copyright (c) 2014 NatashaTheRobot. All rights reserved.
//

#import "NTRViewController.h"

@interface NTRViewController ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel2;

@property (strong, nonatomic) NSAttributedString *attributedString;
@property (assign, nonatomic) NSUInteger numWhiteCharacters;

@property (strong, nonatomic) UILabel *visibleLabel;
@property (strong, nonatomic) UILabel *hiddenLabel;

@end

@implementation NTRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textLabel.alpha = 0;
    self.textLabel2.alpha = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
    NSString *mySecretMessage = @"This is a my replication of Secret's text animation. It looks like one fancy label, but it's actually two UITextLabels on top of each other! What do you think?";
    
    self.numWhiteCharacters = 0;
    
    NSAttributedString *initialText = [self randomlyFadedAttStringFromString:mySecretMessage];
    self.textLabel.attributedText = initialText;

    self.attributedString = [self randomlyFadedAttStringSecond:initialText];
    self.textLabel2.attributedText = self.attributedString;
    
    [UIView animateWithDuration:0.1 animations:^{
        self.textLabel.alpha = 1;
        self.visibleLabel = self.textLabel;
        self.hiddenLabel = self.textLabel2;
    } completion:^(BOOL finished) {
        [self performAnimation];
    }];
    

}

- (void)performAnimation
{
    self.attributedString = [self randomlyFadedAttStringSecond:self.attributedString];
    self.hiddenLabel.attributedText = self.attributedString;
    
    [UILabel animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.hiddenLabel.alpha = 1;
                     } completion:^(BOOL finished) {
                         UILabel *oldHiddenLabel = self.hiddenLabel;
                         UILabel *oldVisibleLabel = self.visibleLabel;
                         
                         self.visibleLabel.alpha = 0;
                         [self.visibleLabel removeFromSuperview];
                         [self.view insertSubview:oldVisibleLabel belowSubview:self.hiddenLabel];
                         
                         self.hiddenLabel = oldVisibleLabel;
                         self.visibleLabel = oldHiddenLabel;
                         if (self.numWhiteCharacters != [self.attributedString length]) {
                             [self performAnimation];
                         } else {
                             [self.hiddenLabel removeFromSuperview];
                         }
                     }];
}

- (NSAttributedString *)randomlyFadedAttStringFromString:(NSString *)string
{
    NSMutableAttributedString *outString = [[NSMutableAttributedString alloc] initWithString:string];
    
    for (NSUInteger i = 0; i < string.length; i ++) {
        CGFloat alpha = arc4random_uniform(100) / 100.0;
        if (alpha == 1.0) {
            self.numWhiteCharacters++;
        }
        UIColor *color = [UIColor colorWithWhite:1.0 alpha:alpha];
        NSInteger colorIndex = arc4random() % 10;
        if (colorIndex != 0) {
            color = [UIColor clearColor];
        }
        [outString addAttribute:NSForegroundColorAttributeName value:(id)color range:NSMakeRange(i, 1)];
    }
    
    return [outString copy];
}

- (NSAttributedString *)randomlyFadedAttStringSecond:(NSAttributedString *)string
{
    NSMutableAttributedString *mutableString = [string mutableCopy];
    for (NSUInteger i = 0; i < string.length; i ++) {
        [string enumerateAttribute:NSForegroundColorAttributeName
                           inRange:NSMakeRange(i, 1)
                           options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                        usingBlock:^(id value, NSRange range, BOOL *stop) {
                            UIColor *color = value;
                            
                            if ([color isEqual:[UIColor clearColor]])
                            {
                                UIColor *color;
                                NSInteger colorIndex = arc4random() % 4;
                                if (colorIndex != 0) {
                                    color = [UIColor clearColor];
                                } else {
                                    CGFloat alpha = arc4random_uniform(100) / 100.0;
                                    if (alpha == 1.0) {
                                        self.numWhiteCharacters++;
                                    }
                                    
                                    color = [UIColor colorWithWhite:1.0 alpha:alpha];
                                }
                                [mutableString addAttribute:NSForegroundColorAttributeName value:color range:range];
                            } else {
                                CGFloat alpha = CGColorGetAlpha(color.CGColor);
                                if (alpha != 1.0) {
                                    NSInteger random = alpha * 100 + arc4random_uniform(100 - alpha * 100 + 1);
                                    CGFloat randomAlpha = random / 100.0;
                                    if (randomAlpha == 1.0) {
                                        self.numWhiteCharacters++;
                                    }
                                    UIColor *color = [UIColor colorWithWhite:1.0 alpha:randomAlpha];
                                    [mutableString addAttribute:NSForegroundColorAttributeName value:color range:range];
                                }
                            }
                        }];
        
    }
    
    return [mutableString copy];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
