//
//  LightingViewController.h
//  OpenGLESLighting
//
//  Created by Tony on 2017/2/9.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface LightingViewController : GLKViewController

@property (weak, nonatomic) IBOutlet UILabel *textureLabel;
@property (weak, nonatomic) IBOutlet UISwitch *textureSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *linesSwitch;

- (IBAction)changeCenterVertexHeight:(UISlider *)sender;
- (IBAction)isDrawNormalsAndLightLines:(UISwitch *)sender;
- (IBAction)shouldUseTexture:(UISwitch *)sender;
- (IBAction)shouldShowTextureDetail:(UISwitch *)sender;

@end
