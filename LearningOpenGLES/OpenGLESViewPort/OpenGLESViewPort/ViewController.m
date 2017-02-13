//
//  ViewController.m
//  OpenGLESViewPort
//
//  Created by Tony on 2017/2/13.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "ViewController.h"

#import <TLGLKContext.h>
#import <TLGLKVertexAttribArrayBuffer.h>
#import "sphere.h" // 顶点数据

@interface ViewController ()

@property (nonatomic) TLGLKContext *context;
@property (nonatomic) TLGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property (nonatomic) TLGLKVertexAttribArrayBuffer *vertexNormalBuffer;
@property (nonatomic) TLGLKVertexAttribArrayBuffer *vertexTextureCoordBuffer;

@property (nonatomic) GLKBaseEffect *baseEffect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    _context = [[TLGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    view.context= _context;
    // 深度
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    [TLGLKContext setCurrentContext:_context];
    
    // 背景色
    _context.clearColor = GLKVector4Make(0.0, 0.0, 0.0, 1.0);
    
    _baseEffect = [[GLKBaseEffect alloc] init];
    // 使用灯光模拟太阳
    _baseEffect.light0.enabled = GL_TRUE;
    _baseEffect.light0.diffuseColor = GLKVector4Make(0.7, 0.7, 0.7, 1.0);
    _baseEffect.light0.ambientColor = GLKVector4Make(0.2, 0.2, 0.2, 1.0);
    _baseEffect.light0.position = GLKVector4Make(1.0, 0.0, -0.8, 0.0);
    // 设置纹理
    CGImageRef imageRef = [[UIImage imageNamed:@"Earth512x256.jpg"] CGImage];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef options:@{GLKTextureLoaderOriginBottomLeft: @(YES)} error:nil];
    _baseEffect.texture2d0.name = textureInfo.name;
    _baseEffect.texture2d0.target = textureInfo.target;
    
    // 位置buffer
    _vertexPositionBuffer = [[TLGLKVertexAttribArrayBuffer alloc]
                             initWithAttribStride:3 * sizeof(float)
                             numberOfVertices:sizeof(sphereVerts)/(3 * sizeof(float))
                             data:sphereVerts
                             usage:GL_STATIC_DRAW];
    // 法向量buffer
    _vertexNormalBuffer = [[TLGLKVertexAttribArrayBuffer alloc]
                           initWithAttribStride:3 * sizeof(float)
                           numberOfVertices:sizeof(sphereNormals)/(3 * sizeof(float))
                           data:sphereNormals
                           usage:GL_STATIC_DRAW];
    // 纹理buffer
    _vertexTextureCoordBuffer = [[TLGLKVertexAttribArrayBuffer alloc]
                                 initWithAttribStride:2 * sizeof(float)
                                 numberOfVertices:sizeof(sphereTexCoords)/(2*sizeof(float))
                                 data:sphereTexCoords
                                 usage:GL_STATIC_DRAW];
    
    // 开启深度
    glEnable(GL_DEPTH_TEST);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    // clear
    [_context clear:GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT];
    
    [_baseEffect prepareToDraw];
    
    [_vertexPositionBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [_vertexNormalBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [_vertexTextureCoordBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:0 shouldEnable:YES];
    
    // 调整横纵比
    GLfloat aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    _baseEffect.transform.projectionMatrix = GLKMatrix4MakeScale(1.0, aspectRatio, 1.0);
    
    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end












