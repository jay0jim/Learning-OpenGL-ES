//
//  LightingViewController.m
//  OpenGLESLighting
//
//  Created by Tony on 2017/2/9.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "LightingViewController.h"

#import <TLGLKContext.h>
#import <TLGLKVertexAttribArrayBuffer.h>

///////////////////////////////////////////////////////////////
// 顶点结构体
typedef struct {
    GLKVector3  position; // 位置坐标
    GLKVector3  normal; // 法向量
} SceneVertex;

///////////////////////////////////////////////////////////////
// 顶点
SceneVertex vertexA = {{-0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}};
SceneVertex vertexB = {{-0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}};
SceneVertex vertexC = {{-0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};
SceneVertex vertexD = {{ 0.0,  0.5, -0.5}, {0.0, 0.0, 1.0}};
SceneVertex vertexE = {{ 0.0,  0.0,  0.0}, {0.0, 0.0, 1.0}};
SceneVertex vertexF = {{ 0.0, -0.5, -0.5}, {0.0, 0.0, 1.0}};
SceneVertex vertexG = {{ 0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}};
SceneVertex vertexH = {{ 0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}};
SceneVertex vertexI = {{ 0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};

///////////////////////////////////////////////////////////////
// 三角形结构体
typedef struct {
    SceneVertex vertices[3];
} SceneTriangle;

///////////////////////////////////////////////////////////////
// C函数预定义
static SceneTriangle SceneTriangleMake(
                                       const SceneVertex v1,
                                       const SceneVertex v2,
                                       const SceneVertex v3);



@interface LightingViewController () {
    SceneTriangle triangles[8];
}

@property (nonatomic) TLGLKContext *context;
@property (nonatomic) TLGLKVertexAttribArrayBuffer *vertexBuffer;

@property (nonatomic) GLKBaseEffect *baseEffect;
@property (nonatomic) GLKBaseEffect *extraEffect;

@end

@implementation LightingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _context = [[TLGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    ((GLKView *)self.view).context = _context;
    [TLGLKContext setCurrentContext:_context];
    // Set clear color
    _context.clearColor = GLKVector4Make(0.0, 0.0, 0.0, 1.0);
    
    // 使用灯光
    _baseEffect = [[GLKBaseEffect alloc] init];
    _baseEffect.light0.enabled = GL_TRUE;
    // 漫反射光颜色
    _baseEffect.light0.diffuseColor = GLKVector4Make(0.7, 0.7, 0.7, 1.0);
    // 灯光位置
    _baseEffect.light0.position = GLKVector4Make(1.0, 1.0, 0.5, 0.0);
    
    // 显示法向量
    _extraEffect = [[GLKBaseEffect alloc] init];
    _extraEffect.useConstantColor = GL_TRUE;
    _extraEffect.constantColor = GLKVector4Make(0.0, 1.0, 0.0, 1.0);
    
    // 旋转视角
    {  // Comment out this block to render the scene top down
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(
                                                            GLKMathDegreesToRadians(-60.0f), 1.0f, 0.0f, 0.0f);
        modelViewMatrix = GLKMatrix4Rotate(
                                           modelViewMatrix,
                                           GLKMathDegreesToRadians(-30.0f), 0.0f, 0.0f, 1.0f);
        modelViewMatrix = GLKMatrix4Translate(
                                              modelViewMatrix,
                                              0.0f, 0.0f, 0.25f);
        
        self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
        self.extraEffect.transform.modelviewMatrix = modelViewMatrix;
    }
    
    [self builtTriangles];
    
    _vertexBuffer = [[TLGLKVertexAttribArrayBuffer alloc]
                     initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(triangles)/sizeof(SceneVertex) data:triangles usage:GL_DYNAMIC_DRAW];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    [_context clear:GL_COLOR_BUFFER_BIT];
    
    [_baseEffect prepareToDraw];
    
    // 位置
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, position) shouldEnable:YES];
    // 法线
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, normal) shouldEnable:YES];
    
    [_vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sizeof(triangles)/sizeof(SceneVertex)];
    
}

#pragma mark - 创建三角形
- (void)builtTriangles {
    triangles[0] = SceneTriangleMake(vertexA, vertexB, vertexD);
    triangles[1] = SceneTriangleMake(vertexB, vertexC, vertexF);
    triangles[2] = SceneTriangleMake(vertexD, vertexB, vertexE);
    triangles[3] = SceneTriangleMake(vertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, vertexE, vertexH);
    triangles[5] = SceneTriangleMake(vertexE, vertexF, vertexH);
    triangles[6] = SceneTriangleMake(vertexG, vertexD, vertexH);
    triangles[7] = SceneTriangleMake(vertexH, vertexF, vertexI);
}

#pragma mark - Slider响应
- (void)changeCenterVertexHeight:(UISlider *)sender {
    
    float height = sender.value;
    vertexE.position.z = height;
    
    triangles[2] = SceneTriangleMake(vertexD, vertexB, vertexE);
    triangles[3] = SceneTriangleMake(vertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, vertexE, vertexH);
    triangles[5] = SceneTriangleMake(vertexE, vertexF, vertexH);
    
    [self updateNormals];
}

- (void)updateNormals {
    
    [_vertexBuffer reinitWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(triangles)/sizeof(SceneVertex) data:triangles];
}

#pragma mark - C函数实现
static SceneTriangle SceneTriangleMake(
                                       const SceneVertex v1,
                                       const SceneVertex v2,
                                       const SceneVertex v3) {
    SceneTriangle triange;
    
    triange.vertices[0] = v1;
    triange.vertices[1] = v2;
    triange.vertices[2] = v3;
    
    return triange;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end











