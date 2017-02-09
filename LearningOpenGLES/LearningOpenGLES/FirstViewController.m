//
//  FirstViewController.m
//  LearningOpenGLES
//
//  Created by Tony on 2017/2/6.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "FirstViewController.h"

#import <TLGLKContext.h>
#import <TLGLKVertexAttribArrayBuffer.h>

@interface FirstViewController ()

@property (nonatomic) TLGLKContext *context;
@property (nonatomic) TLGLKVertexAttribArrayBuffer *vertexBuffer;

@end

typedef struct {
    // 位置坐标
    GLKVector3 positionCoords;
    
    // 纹理坐标
    GLKVector2 textureCoords;
} SceneVertex;

static SceneVertex vertices[] = {
    {{-0.5, -0.5, 0.0}, {0.0, 0.0}},
    {{-0.5, 0.5, 0.0}, {0.0, 1.0}},
    {{0.5, -0.5, 0.0}, {1.0, 0.0}}
};

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preferredFramesPerSecond = 60;
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View controller's view is not a GLKView");
    
    _context = [[TLGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    view.context = _context;
    [TLGLKContext setCurrentContext:view.context];
    _context.clearColor = GLKVector4Make(0.0, 0.0, 0.0, 1.0);
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    
    // 包含1 2 3步
    _vertexBuffer = [[TLGLKVertexAttribArrayBuffer alloc]
                     initWithAttribStride:sizeof(SceneVertex)
                     numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)
                     data:vertices
                     usage:GL_STATIC_DRAW];
    
//    glClearColor(0.0, 0.0, 0.0, 1.0);
//    
//    // 1、为缓存生成ID
//    glGenBuffers(1, &vertexBufferID);
//    // 2、绑定缓存
//    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
//    // 3、复制数据到缓存中
//    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // 设置纹理
    CGImageRef imageRef = [[UIImage imageNamed:@"leaves.gif"] CGImage];
    
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef options:nil error:nil];
    glTexParameteri(textureInfo.target, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    [self.baseEffect prepareToDraw];
    
    [_context clear:GL_COLOR_BUFFER_BIT];
    
    // 包含4 5
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                       numberOfCoordinates:3
                              attribOffset:offsetof(SceneVertex, positionCoords)
                              shouldEnable:YES];
    // 纹理
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
                       numberOfCoordinates:2
                              attribOffset:offsetof(SceneVertex, textureCoords)
                              shouldEnable:YES];
    
    // 包含6
    [_vertexBuffer drawArrayWithMode:GL_TRIANGLE_FAN
                    startVertexIndex:0
                    numberOfVertices:3];
    
//    glClear(GL_COLOR_BUFFER_BIT);
//    
//    // 4、启用
//    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    
//    // 5、设置顶点指针(位置信息)
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL);
//    // 纹理信息
//    
//    
//    // 6、画图
//    glDrawArrays(GL_TRIANGLES, 0, 3);
    
}

- (void)update {
    for (int i = 0; i < 3; i++) {
        
        vertices[i].positionCoords.x += 0.01;
        if (vertices[i].positionCoords.x >= 1.0 || vertices[i].positionCoords.x <= -1.0) {
            vertices[i].positionCoords.x = -vertices[i].positionCoords.x;
        }
        vertices[i].positionCoords.y += 0.01;
        if (vertices[i].positionCoords.y >= 1.0 || vertices[i].positionCoords.y <= -1.0) {
            vertices[i].positionCoords.y = -vertices[i].positionCoords.y;
        }
    }
    
    [_vertexBuffer reinitWithAttribStride:sizeof(SceneVertex) numberOfVertices:3 data:vertices];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end












