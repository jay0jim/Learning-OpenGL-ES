//
//  TLGLKVertexAttribArrayBuffer.h
//  LearningOpenGLES
//
//  Created by Tony on 2017/2/8.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface TLGLKVertexAttribArrayBuffer : NSObject

@property (nonatomic, readonly) GLsizei stride;
@property (nonatomic, readonly) GLsizeiptr bufferSizeBytes;
@property (nonatomic, readonly) GLuint glName;
@property (nonatomic, readonly) GLenum usage;

- (id)initWithAttribStride:(GLsizei)stride
          numberOfVertices:(GLsizei)count
                      data:(const GLvoid *)dataPtr
                     usage:(GLenum)usage;

- (void)prepareToDrawWithAttrib:(GLuint)index
            numberOfCoordinates:(GLint)count
                   attribOffset:(GLsizeiptr)offset
                   shouldEnable:(BOOL)shouldEnable;

- (void)drawArrayWithMode:(GLenum)mode
         startVertexIndex:(GLint)first
         numberOfVertices:(GLsizei)count;

- (void)reinitWithAttribStride:(GLsizei)stride
              numberOfVertices:(GLsizei)count
                          data:(const GLvoid *)dataPtr;

@end
