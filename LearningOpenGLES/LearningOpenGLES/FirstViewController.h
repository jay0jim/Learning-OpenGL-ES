//
//  FirstViewController.h
//  LearningOpenGLES
//
//  Created by Tony on 2017/2/6.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GLKit/GLKit.h>

@interface FirstViewController : GLKViewController {
    GLuint vertexBufferID;
}

@property (nonatomic) GLKBaseEffect *baseEffect;

@end
