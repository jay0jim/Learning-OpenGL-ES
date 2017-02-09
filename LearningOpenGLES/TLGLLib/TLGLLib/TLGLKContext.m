//
//  JMGLKContext.m
//  LearningOpenGLES
//
//  Created by Tony on 2017/2/8.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "TLGLKContext.h"

@implementation TLGLKContext

- (void)setClearColor:(GLKVector4)clearColorRGBA {
    clearColor = clearColorRGBA;
    
    NSAssert(self == [[self class] currentContext], @"Receiving context required to be current context");
    
    glClearColor(clearColorRGBA.r, clearColorRGBA.g, clearColorRGBA.b, clearColorRGBA.a);
}

- (GLKVector4)clearColor {
    return clearColor;
}

- (void)clear:(GLbitfield)mask {
    
    NSAssert(self == [[self class] currentContext], @"Receiving context required to be current context");
    
    glClear(mask);
}

@end















