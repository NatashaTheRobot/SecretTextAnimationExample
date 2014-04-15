//
//  NTRViewController.m
//  SecretAnimation
//
//  Created by Natasha Murashev on 4/13/14.
//  Copyright (c) 2014 NatashaTheRobot. All rights reserved.
//

#import "NTRViewController.h"

@interface NTRViewController ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel1;
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
    
    self.textLabel1.alpha = 0;
    self.textLabel2.alpha = 0;
    
    NSString *mySecretMessage = @"This is a my replication of Secret's text animation. It looks like one fancy label, but it's actually two UITextLabels on top of each other! What do you think?";
    
    self.numWhiteCharacters = 0;
    
    NSAttributedString *initialAttributedText = [self randomlyFadedAttributedStringFromString:mySecretMessage];
    self.textLabel1.attributedText = initialAttributedText;
    
    self.attributedString = [self randomlyFadedAttributedStringFromAttributedString:initialAttributedText];
    self.textLabel2.attributedText = self.attributedString;
    
    __weak NTRViewController *weakSelf = self;
    [UIView animateWithDuration:0.1 animations:^{
        weakSelf.textLabel1.alpha = 1;
    } completion:^(BOOL finished) {
        weakSelf.visibleLabel = self.textLabel1;
        weakSelf.hiddenLabel = self.textLabel2;
        [weakSelf performAnimation];
    }];
}

- (void)performAnimation
{
    __weak NTRViewController *weakSelf = self;
    [UILabel animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         weakSelf.hiddenLabel.alpha = 1;
                     } completion:^(BOOL finished) {
                         [weakSelf resetLabels];
                         
                         // keep performing the animation until all letters are white
                         if (weakSelf.numWhiteCharacters == [weakSelf.attributedString length]) {
                             [weakSelf.hiddenLabel removeFromSuperview];
                         } else {
                             [weakSelf performAnimation];
                         }
                     }];
}

- (void)resetLabels
{
    // the hidden label is now visible, so switch the hidden and visible
    UILabel *oldHiddenLabel = self.hiddenLabel;
    UILabel *oldVisibleLabel = self.visibleLabel;
    
    self.hiddenLabel = oldVisibleLabel;
    self.visibleLabel = oldHiddenLabel;
    
    [self.hiddenLabel removeFromSuperview];
    
    // hide the new hidden label
    self.hiddenLabel.alpha = 0;
    
    // recalculate attributed string with the new white color values
    self.attributedString = [self randomlyFadedAttributedStringFromAttributedString:self.attributedString];
    self.hiddenLabel.attributedText = self.attributedString;
    // make sure the hidden label is now on top
    [self.view insertSubview:self.hiddenLabel belowSubview:self.visibleLabel];

}

- (NSAttributedString *)randomlyFadedAttributedStringFromString:(NSString *)string
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    for (NSUInteger i = 0; i < [string length]; i ++) {
        UIColor *color = [self whiteColorWithClearColorProbability:10];
        [attributedString addAttribute:NSForegroundColorAttributeName value:(id)color range:NSMakeRange(i, 1)];
        [self updateNumWhiteCharactersForColor:color];
    }
    
    return [attributedString copy];
}

- (NSAttributedString *)randomlyFadedAttributedStringFromAttributedString:(NSAttributedString *)attributedString
{
    NSMutableAttributedString *mutableAttributedString = [attributedString mutableCopy];
    
    __weak NTRViewController *weakSelf = self;
    for (NSUInteger i = 0; i < attributedString.length; i ++) {
        [attributedString enumerateAttribute:NSForegroundColorAttributeName
                                     inRange:NSMakeRange(i, 1)
                                     options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                  usingBlock:^(id value, NSRange range, BOOL *stop) {
                                      UIColor *initialColor = value;
                                      UIColor *newColor = [weakSelf whiteColorFromInitialColor:initialColor];
                                      if (newColor) {
                                          [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:newColor range:range];
                                          [weakSelf updateNumWhiteCharactersForColor:newColor];
                                      }
                                  }];
        
    }
    
    return [mutableAttributedString copy];
}

- (void)updateNumWhiteCharactersForColor:(UIColor *)color
{
    CGFloat alpha = CGColorGetAlpha(color.CGColor);
    if (alpha == 1.0) {
        self.numWhiteCharacters++;
    }
}

- (UIColor *)whiteColorFromInitialColor:(UIColor *)initialColor
{
    UIColor *newColor;
    if ([initialColor isEqual:[UIColor clearColor]])
    {
        newColor = [self whiteColorWithClearColorProbability:4];
    } else {
        CGFloat alpha = CGColorGetAlpha(initialColor.CGColor);
        if (alpha != 1.0) {
            newColor = [self whiteColorWithMinAlpha:alpha];
        }
    }
    return newColor;
}

- (UIColor *)whiteColorWithClearColorProbability:(NSInteger)probability
{
    UIColor *color;
    NSInteger colorIndex = arc4random() % probability;
    if (colorIndex != 0) {
        color = [UIColor clearColor];
    } else {
        color = [self whiteColorWithMinAlpha:0];
    }
    return color;
}

- (UIColor *)whiteColorWithMinAlpha:(CGFloat)minAlpha
{
    NSInteger randomNumber = minAlpha * 100 + arc4random_uniform(100 - minAlpha * 100 + 1);
    CGFloat randomAlpha = randomNumber / 100.0;
    return [UIColor colorWithWhite:1.0 alpha:randomAlpha];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
