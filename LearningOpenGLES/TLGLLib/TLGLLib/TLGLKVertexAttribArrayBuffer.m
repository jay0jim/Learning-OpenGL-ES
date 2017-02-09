//
//  TLGLKVertexAttribArrayBuffer.m
//  LearningOpenGLES
//
//  Created by Tony on 2017/2/8.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "TLGLKVertexAttribArrayBuffer.h"

@implementation TLGLKVertexAttribArrayBuffer

- (id)initWithAttribStride:(GLsizei)stride numberOfVertices:(GLsizei)count data:(const GLvoid *)dataPtr usage:(GLenum)usage {
    
    if (self = [super init]) {
        _stride = stride;
        _bufferSizeBytes = _stride * count;
        _usage = usage;
        
        // 1
        glGenBuffers(1, &_glName);
        
        // 2
        glBindBuffer(GL_ARRAY_BUFFER, _glName);
        
        // 3
        glBufferData(GL_ARRAY_BUFFER, _bufferSizeBytes, dataPtr, _usage);

    }
    
    return self;
    
}

- (void)prepareToDrawWithAttrib:(GLuint)index numberOfCoordinates:(GLint)count attribOffset:(GLsizeiptr)offset shouldEnable:(BOOL)shouldEnable {
    
    // 2
    glBindBuffer(GL_ARRAY_BUFFER, _glName);
    
    if (shouldEnable) {
        // 4
        glEnableVertexAttribArray(index);
    }
    
    // 5
    glVertexAttribPointer(index, count, GL_FLOAT, GL_FALSE, _stride, NULL+offset);
}

- (void)drawArrayWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count {
    
    // 6
    glDrawArrays(mode, first, count);
}

- (void)reinitWithAttribStride:(GLsizei)stride numberOfVertices:(GLsizei)count data:(const GLvoid *)dataPtr {
    
    _stride = stride;
    _bufferSizeBytes = _stride * count;
    
    // 2
    glBindBuffer(GL_ARRAY_BUFFER, _glName);
    // 3
    glBufferData(GL_ARRAY_BUFFER, _bufferSizeBytes, dataPtr, _usage);
}

- (void)dealloc {
    if (_glName != 0) {
        glDeleteBuffers(1, &_glName);
        _glName = 0;
    }
}

@end













