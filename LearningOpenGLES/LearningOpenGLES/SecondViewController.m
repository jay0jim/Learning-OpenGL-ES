//
//  SecondViewController.m
//  LearningOpenGLES
//
//  Created by Tony on 2017/2/8.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "SecondViewController.h"

#import <TLGLKContext.h>
#import <TLGLKVertexAttribArrayBuffer.h>

@interface SecondViewController ()

@property (nonatomic) GLKBaseEffect *baseEffect;

@property (nonatomic) TLGLKVertexAttribArrayBuffer *vertexBuffer;
@property (nonatomic) TLGLKContext *context;

@property (nonatomic) GLKTextureInfo *textureInfo0;
@property (nonatomic) GLKTextureInfo *textureInfo1;

@end

typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
} SceneVertex;

static const SceneVertex vertices[] = {
    {{-1.0f, -0.67f, 0.0f}, {0.0f, 0.0f}},
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},
    {{ 1.0f,  0.67f, 0.0f}, {1.0f, 1.0f}},
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
};

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View controller's view is not a GLKView");
    
    _context = [[TLGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    view.context = _context;
    [TLGLKContext setCurrentContext:_context];
    [_context setClearColor:GLKVector4Make(0.0, 0.0, 0.0, 1.0)];
    
    _baseEffect = [[GLKBaseEffect alloc] init];
    _baseEffect.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    _baseEffect.useConstantColor = GL_TRUE;
    
    _vertexBuffer = [[TLGLKVertexAttribArrayBuffer alloc]
                     initWithAttribStride:sizeof(SceneVertex)
                     numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)
                     data:vertices
                     usage:GL_STATIC_DRAW];
    
    // Setup texture0
    CGImageRef imageRef0 = [[UIImage imageNamed:@"leaves.gif"] CGImage];
    _textureInfo0 = [GLKTextureLoader textureWithCGImage:imageRef0 options:@{GLKTextureLoaderOriginBottomLeft: @(YES)} error:nil];
    
    // Setup texture1
    CGImageRef imageRef1 = [[UIImage imageNamed:@"beetle.png"] CGImage];
    _textureInfo1 = [GLKTextureLoader textureWithCGImage:imageRef1 options:@{GLKTextureLoaderOriginBottomLeft: @(YES)} error:nil];
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    [_context clear:GL_COLOR_BUFFER_BIT];
    
    // 位置属性
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, positionCoords) shouldEnable:YES];
    // 纹理属性
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords) shouldEnable:YES];
    
    // 绘制
    // 纹理0
    _baseEffect.texture2d0.name = _textureInfo0.name;
    _baseEffect.texture2d0.target = _textureInfo0.target;
    [_baseEffect prepareToDraw];
    [_vertexBuffer drawArrayWithMode:GL_TRIANGLE_FAN startVertexIndex:0 numberOfVertices:4];

    // 纹理1
    _baseEffect.texture2d0.name = _textureInfo1.name;
    _baseEffect.texture2d0.target = _textureInfo1.target;
    [_baseEffect prepareToDraw];
    [_vertexBuffer drawArrayWithMode:GL_TRIANGLE_FAN startVertexIndex:0 numberOfVertices:4];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end














