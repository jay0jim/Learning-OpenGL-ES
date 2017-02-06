//
//  FirstViewController.m
//  LearningOpenGLES
//
//  Created by Tony on 2017/2/6.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

typedef struct {
    GLKVector3 positionCoords;
} SceneVertex;

static const SceneVertex vertices[] = {
    {{-0.5, -0.5, 0.0}},
    {{-0.5, 0.5, 0.0}},
    {{0.5, -0.5, 0.0}}
};

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View controller's view is not a GLKView");
    
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    [EAGLContext setCurrentContext:view.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    
    // 1、为缓存生成ID
    glGenBuffers(1, &vertexBufferID);
    // 2、绑定缓存
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    // 3、复制数据到缓存中
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    [self.baseEffect prepareToDraw];
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 4
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    // 5
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL);
    // 6
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
}

- (void)dealloc {
    
    GLKView *view = (GLKView *)self.view;
    [EAGLContext setCurrentContext:view.context];
    
    if (vertexBufferID != 0) {
        glDeleteBuffers(1, &vertexBufferID);
        vertexBufferID = 0;
    }
    
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end












