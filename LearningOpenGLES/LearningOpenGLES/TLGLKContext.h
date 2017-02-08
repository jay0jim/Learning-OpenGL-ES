//
//  JMGLKContext.h
//  LearningOpenGLES
//
//  Created by Tony on 2017/2/8.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface TLGLKContext : EAGLContext {
    GLKVector4 clearColor;
}

@property (nonatomic, assign) GLKVector4 clearColor;

- (void)clear:(GLbitfield)mask;

@end
