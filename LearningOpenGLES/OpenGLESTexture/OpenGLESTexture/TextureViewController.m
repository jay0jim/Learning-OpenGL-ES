//
//  TextureViewController.m
//  OpenGLESTexture
//
//  Created by Tony on 2017/2/9.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "TextureViewController.h"

#import <TLGLKContext.h>
#import <TLGLKVertexAttribArrayBuffer.h>

@interface TextureViewController ()

@property (nonatomic) TLGLKContext *context;
@property (nonatomic) TLGLKVertexAttribArrayBuffer *vertexBuffer;

@property (nonatomic) GLKBaseEffect *baseEffect;

@end

@implementation TextureViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _context = [[TLGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    ((GLKView *)self.view).context = _context;
    [TLGLKContext setCurrentContext:_context];
    
    // 设置clearColor
    _context.clearColor = GLKVector4Make(0.0, 0.0, 0.0, 1.0);
    
    _baseEffect = [[GLKBaseEffect alloc] init];
    _baseEffect.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    _baseEffect.useConstantColor = GL_TRUE;
    
    // 123
    _vertexBuffer = [[TLGLKVertexAttribArrayBuffer alloc]
                     initWithAttribStride:sizeof(SceneVertex)
                     numberOfVertices:sizeof(vertices)/sizeof(SceneVertex)
                     data:vertices
                     usage:GL_STATIC_DRAW];
    
    // 使用多重纹理，而非多通道混合
    // 纹理0
    CGImageRef imageRef0 = [[UIImage imageNamed:@"leaves.gif"] CGImage];
    GLKTextureInfo *textureInfo0 = [GLKTextureLoader textureWithCGImage:imageRef0 options:@{GLKTextureLoaderOriginBottomLeft: @(YES)} error:nil];
    _baseEffect.texture2d0.name = textureInfo0.name;
    _baseEffect.texture2d0.target = textureInfo0.target;
    
    // 纹理1
    CGImageRef imageRef1 = [[UIImage imageNamed:@"beetle.png"] CGImage];
    GLKTextureInfo *textureInfo1 = [GLKTextureLoader textureWithCGImage:imageRef1 options:@{GLKTextureLoaderOriginBottomLeft: @(YES)} error:nil];
    _baseEffect.texture2d1.name = textureInfo1.name;
    _baseEffect.texture2d1.target = textureInfo1.target;
    _baseEffect.texture2d1.envMode = GLKTextureEnvModeDecal;
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    [_context clear:GL_COLOR_BUFFER_BIT];
    
    [_baseEffect prepareToDraw];
    
    // 顶点
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, positionCoords) shouldEnable:YES];
    // 纹理0
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords) shouldEnable:YES];
    // 纹理1
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord1 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords) shouldEnable:YES];
    
    [_vertexBuffer drawArrayWithMode:GL_TRIANGLE_FAN startVertexIndex:0 numberOfVertices:4];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end











