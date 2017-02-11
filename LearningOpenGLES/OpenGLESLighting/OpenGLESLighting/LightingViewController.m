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
#pragma mark - // C函数预定义
// 构造三角形
static SceneTriangle SceneTriangleMake(
                                       const SceneVertex v1,
                                       const SceneVertex v2,
                                       const SceneVertex v3);

// 给定两个向量，计算法向量并使其模为1（标准化）
static GLKVector3 calculateNormal(
                                  const GLKVector3 v1,
                                  const GLKVector3 v2);

// 计算三角形的法向量并标准化
static GLKVector3 calculateTriangleFaceNormal(const SceneTriangle triangle);

// 计算每个三角形的法向量
void updateTriangleFaceNormal(SceneTriangle *triangles);


///////////////////////////////////////////////////////////////
#pragma mark -
@interface LightingViewController () {
    SceneTriangle triangles[8];
    GLKVector3 normalLineVertice[50];
}

@property (nonatomic) TLGLKContext *context;
@property (nonatomic) TLGLKVertexAttribArrayBuffer *vertexBuffer;
@property (nonatomic) TLGLKVertexAttribArrayBuffer *extraBuffer;

@property (nonatomic) GLKBaseEffect *baseEffect;
@property (nonatomic) GLKBaseEffect *extraEffect;

@property (nonatomic, assign) BOOL isDrawLines;

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
    
    // 图形buffer
    _vertexBuffer = [[TLGLKVertexAttribArrayBuffer alloc]
                     initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(triangles)/sizeof(SceneVertex) data:triangles usage:GL_DYNAMIC_DRAW];
    // 法向量线buffer
    _extraBuffer = [[TLGLKVertexAttribArrayBuffer alloc]
                    initWithAttribStride:sizeof(GLKVector3)
                    numberOfVertices:sizeof(normalLineVertice)/sizeof(GLKVector3)
                    data:normalLineVertice
                    usage:GL_DYNAMIC_DRAW];
    
    // 更新法向量
    [self updateNormals];
    
    // 默认显示法向量线
    _isDrawLines = YES;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    [_context clear:GL_COLOR_BUFFER_BIT];
    
    ////////////////////////////////////////////////////////////
    // 绘制图形
    [_baseEffect prepareToDraw];
    
    // 位置
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, position) shouldEnable:YES];
    // 法线
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, normal) shouldEnable:YES];
    
    [_vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sizeof(triangles)/sizeof(SceneVertex)];
    
    ////////////////////////////////////////////////////////////
    // 绘制法向量线
    if (_isDrawLines) {
        
        [self drawNormalsAndLightLines];
    }
    
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

#pragma mark - UI响应
- (void)changeCenterVertexHeight:(UISlider *)sender {
    
    float height = sender.value;
    vertexE.position.z = height;
    
    triangles[2] = SceneTriangleMake(vertexD, vertexB, vertexE);
    triangles[3] = SceneTriangleMake(vertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, vertexE, vertexH);
    triangles[5] = SceneTriangleMake(vertexE, vertexF, vertexH);
    
    [self updateNormals];
}

- (void)isDrawNormalsAndLightLines:(UISwitch *)sender {
    _isDrawLines = sender.isOn;
}

#pragma mark - 绘制法向量线和光线
// 计算每条法向量线坐标
- (void)calculateNormalLinesVertex {
    
    int count = 0;
    
    for (int i = 0; i < 8; i++) {
        
        for (int j = 0; j < 3; j++) {
            // 法向量线起点，赋值后count自增
            normalLineVertice[count++] = triangles[i].vertices[j].position;
            
            GLKVector3 v1 = triangles[i].vertices[j].position;
            GLKVector3 v2 = triangles[i].vertices[j].normal;
            
            // 法向量线终点，赋值后count自增
            normalLineVertice[count++] = GLKVector3Add(v1, v2);
        }
    }
    
    // 光线
    normalLineVertice[count++] = GLKVector3Make(0.0, 0.0, 0.0);
    normalLineVertice[count] = GLKVector3MakeWithArray(_baseEffect.light0.position.v);
}

- (void)drawNormalsAndLightLines {
    
    // 计算法向量线两端坐标
    [self calculateNormalLinesVertex];
    
    // 法向量线
    [_extraBuffer reinitWithAttribStride:sizeof(GLKVector3) numberOfVertices:50 data:normalLineVertice];
    [_extraBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    
    _extraEffect.useConstantColor = GL_TRUE;
    _extraEffect.constantColor = GLKVector4Make(0.0, 1.0, 0.0, 1.0);
    [_extraEffect prepareToDraw];
    [_extraBuffer drawArrayWithMode:GL_LINES startVertexIndex:0 numberOfVertices:48];
    
    // 光线
    _extraEffect.constantColor = GLKVector4Make(1.0, 1.0, 0.0, 1.0);
    [_extraEffect prepareToDraw];
    [_extraBuffer drawArrayWithMode:GL_LINES startVertexIndex:48 numberOfVertices:2];
}

#pragma mark - 法向量计算
- (void)updateNormals {
    
    // 计算每个三角形面的法向量
//    [self updateTriangleFaceNormal];
    updateTriangleFaceNormal(triangles);
    
    [_vertexBuffer reinitWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(triangles)/sizeof(SceneVertex) data:triangles];
}

// 给定两个向量，计算法向量并使其模为1（标准化）
- (GLKVector3)calculateNormalWithVectorA:(GLKVector3)v1 VectorB:(GLKVector3)v2 {
    
    return GLKVector3Normalize(GLKVector3CrossProduct(v1, v2));
}

// 计算三角形的法向量并标准化
- (GLKVector3)calculateTriangleFaceNormal:(SceneTriangle)triangle {
    
    GLKVector3 v1 = GLKVector3Subtract(triangle.vertices[1].position, triangle.vertices[0].position);
    GLKVector3 v2 = GLKVector3Subtract(triangle.vertices[2].position, triangle.vertices[0].position);
    
    GLKVector3 faceNormal = [self calculateNormalWithVectorA:v1 VectorB:v2];
    
    return faceNormal;
}

// 计算每个三角形的法向量
- (void)updateTriangleFaceNormal {
    
    for (int i = 0; i < 8; i++) {
        GLKVector3 faceNormal = [self calculateTriangleFaceNormal:triangles[i]];
        
        triangles[i].vertices[0].normal = faceNormal;
        triangles[i].vertices[1].normal = faceNormal;
        triangles[i].vertices[2].normal = faceNormal;
    }
}

#pragma mark - C函数实现
// 构造三角形
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

// 给定两个向量，计算法向量并使其模为1（标准化）
static GLKVector3 calculateNormal(
                                  const GLKVector3 v1,
                                  const GLKVector3 v2) {
    
    return GLKVector3Normalize(GLKVector3CrossProduct(v1, v2));
}

// 计算三角形的法向量并标准化
static GLKVector3 calculateTriangleFaceNormal(const SceneTriangle triangle) {
    GLKVector3 v1 = GLKVector3Subtract(triangle.vertices[1].position, triangle.vertices[0].position);
    GLKVector3 v2 = GLKVector3Subtract(triangle.vertices[2].position, triangle.vertices[0].position);
    
    GLKVector3 faceNormal = calculateNormal(v1, v2);
    
    return faceNormal;
}

// 计算每个三角形的法向量
void updateTriangleFaceNormal(SceneTriangle *triangles) {
    for (int i = 0; i < 8; i++) {
        
        GLKVector3 faceNormal = calculateTriangleFaceNormal(triangles[i]);
        
        triangles[i].vertices[0].normal = faceNormal;
        triangles[i].vertices[1].normal = faceNormal;
        triangles[i].vertices[2].normal = faceNormal;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end











