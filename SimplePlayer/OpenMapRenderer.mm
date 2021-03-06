//
//  OpenCubeRenderer.m
//  OSXGLEssentials
//
//  Created by Matthew Doig on 3/19/14.
//
//

#import "OpenMapRenderer.h"

extern "C"
{
    #import "utils/imageUtil.h"
    #import "utils/sourceUtil.h"
}
#import "utils/objloader.hpp"
#import "utils/camera.hpp"
#import "glm/glm.hpp"
#import "glm/gtc/matrix_transform.hpp"
#import <iostream>
#import <fstream>
#import <string>
#import <vector>

#define GetGLError()									\
{														\
	GLenum err = glGetError();							\
	while (err != GL_NO_ERROR) {						\
		NSLog(@"GLError %s set in File:%s Line:%d\n",	\
				GetGLErrorString(err),					\
				__FILE__,								\
				__LINE__);								\
		err = glGetError();								\
	}													\
}

// Toggle this to disable vertex buffer objects
// (i.e. use client-side vertex array objects)
// This must be 1 if using the GL3 Core Profile on the Mac
#define USE_VERTEX_BUFFER_OBJECTS 1

// Indicies to which we will set vertex array attibutes
// See buildVAO and buildProgram
enum {
	POS_ATTRIB_IDX,
	TEXCOORD_ATTRIB_IDX,
    NORMAL_ATTRIB_IDX,
};

#ifndef NULL
#define NULL 0
#endif

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface OpenMapRenderer ()

    @property (nonatomic, assign) GLuint defaultFBOName;

    @property (nonatomic, assign) GLuint characterPrgName;
    @property (nonatomic, assign) GLint mvpUniformIdx;
    @property (nonatomic, assign) GLint modelUniformIdx;
    @property (nonatomic, assign) GLint viewlUniformIdx;
    @property (nonatomic, assign) GLint lightUniformIdx;
    @property (nonatomic, assign) GLuint characterVAOName;
    @property (nonatomic, assign) GLuint characterTexName;

    @property (nonatomic, assign) GLfloat characterX;
    @property (nonatomic, assign) GLfloat characterZ;

    @property (nonatomic, assign) GLuint viewWidth;
    @property (nonatomic, assign) GLuint viewHeight;

    @property (nonatomic, assign) GLboolean useVBOs;

    @property (nonatomic, assign) float transitionTime;

    @property (nonatomic, assign) BOOL canRender;
    @property (nonatomic, assign) BOOL flyTo;
    @property (nonatomic, assign) BOOL flyCnty;

    @property (nonatomic, assign) float red;
    @property (nonatomic, assign) float green;
    @property (nonatomic, assign) float blue;

@end

@implementation OpenMapRenderer

std::vector<glm::vec3> mapPositions;
std::vector<glm::vec2> mapTexcoords;
std::vector<glm::vec3> mapNormals;
std::vector<unsigned int> mapElements;
std::vector<glm::vec3> usaPositions;
std::vector<glm::vec2> usaTexcoords;
std::vector<glm::vec3> usaNormals;
std::vector<unsigned int> usaElements;
std::vector<glm::vec3> caPositions;
std::vector<glm::vec2> caTexcoords;
std::vector<glm::vec3> caNormals;
std::vector<unsigned int> caElements;
std::vector<glm::vec3> tnPositions;
std::vector<glm::vec2> tnTexcoords;
std::vector<glm::vec3> tnNormals;
std::vector<unsigned int> tnElements;
std::vector<glm::vec3> cntyPositions;
std::vector<glm::vec2> cntyTexcoords;
std::vector<glm::vec3> cntyNormals;
std::vector<unsigned int> cntyElements;
glm::vec3 origin;
Camera mapcamera;

- (void) resizeWithWidth:(GLuint)width AndHeight:(GLuint)height
{
	glViewport(0, 0, width, height);
    
	self.viewWidth = width;
	self.viewHeight = height;
}

- (void)setOpacity:(float)opacity
{
    _opacity = 1.0f - opacity;
}

- (void) initCA
{
    self.canRender = NO;
    self.flyTo = NO;
    self.flyCnty = NO;
    origin = glm::vec3(0,0,0);
    
    ////////////////////////////////////////////////
    // Set up camera state that will never change //
    ////////////////////////////////////////////////
    
    mapcamera.setFieldOfView(45.0f);
    mapcamera.setNearAndFarPlanes(0.1f, 1.0f);
    mapcamera.setPosition(glm::vec3(0.1,0.1,0.1));
    mapcamera.lookAt(origin);
    
    //////////////////////////////
    // Load our character model //
    //////////////////////////////
    
    mapPositions.clear();
    for (unsigned int i = 0; i < caPositions.size(); i++) {
        mapPositions.push_back(caPositions[i]);
    }
    mapTexcoords.clear();
    for (unsigned int i = 0; i < caTexcoords.size(); i++) {
        mapTexcoords.push_back(caTexcoords[i]);
    }
    mapNormals.clear();
    for (unsigned int i = 0; i < caNormals.size(); i++) {
        mapNormals.push_back(caNormals[i]);
    }
    mapElements.clear();
    for (unsigned int i = 0; i < caElements.size(); i++) {
        mapElements.push_back(caElements[i]);
    }
    
    // Build Vertex Buffer Objects (VBOs) and Vertex Array Object (VAOs) with our model data
    self.characterVAOName = [self buildVAO];
    
    self.canRender = YES;
}

- (void) initTN
{
    self.canRender = NO;
    self.flyTo = NO;
    self.flyCnty = NO;
    origin = glm::vec3(0,0,0);
    
    ////////////////////////////////////////////////
    // Set up camera state that will never change //
    ////////////////////////////////////////////////
    
    mapcamera.setFieldOfView(45.0f);
    mapcamera.setNearAndFarPlanes(0.01f, 1.0f);
    mapcamera.setPosition(glm::vec3(0.075,0.075,0.075));
    mapcamera.lookAt(glm::vec3(origin));
    
    //////////////////////////////
    // Load our character model //
    //////////////////////////////
    
    mapPositions.clear();
    for (unsigned int i = 0; i < tnPositions.size(); i++) {
        mapPositions.push_back(tnPositions[i]);
    }
    mapTexcoords.clear();
    for (unsigned int i = 0; i < tnTexcoords.size(); i++) {
        mapTexcoords.push_back(tnTexcoords[i]);
    }
    mapNormals.clear();
    for (unsigned int i = 0; i < tnNormals.size(); i++) {
        mapNormals.push_back(tnNormals[i]);
    }
    mapElements.clear();
    for (unsigned int i = 0; i < tnElements.size(); i++) {
        mapElements.push_back(tnElements[i]);
    }
    
    // Build Vertex Buffer Objects (VBOs) and Vertex Array Object (VAOs) with our model data
    self.characterVAOName = [self buildVAO];
    
    self.canRender = YES;
}

- (void) initTNCnty
{
    self.canRender = NO;
    self.flyTo = NO;
    self.flyCnty = YES;
    
    
    //1.517493 0.110000 0.264961
    origin = glm::vec3(1.517493,0,0.264961);
    
    ////////////////////////////////////////////////
    // Set up camera state that will never change //
    ////////////////////////////////////////////////
    
    mapcamera.setFieldOfView(45.0f);
    mapcamera.setNearAndFarPlanes(0.01f, 2.0f);
    mapcamera.setPosition(glm::vec3(1,.75, .75));
    mapcamera.lookAt(origin);
    
    //////////////////////////////
    // Load our character model //
    //////////////////////////////
    
    mapPositions.clear();
    for (unsigned int i = 0; i < cntyPositions.size(); i++) {
        mapPositions.push_back(cntyPositions[i]);
    }
    mapTexcoords.clear();
    for (unsigned int i = 0; i < cntyTexcoords.size(); i++) {
        mapTexcoords.push_back(cntyTexcoords[i]);
    }
    mapNormals.clear();
    for (unsigned int i = 0; i < cntyNormals.size(); i++) {
        mapNormals.push_back(cntyNormals[i]);
    }
    mapElements.clear();
    for (unsigned int i = 0; i < cntyElements.size(); i++) {
        mapElements.push_back(cntyElements[i]);
    }
    
    // Build Vertex Buffer Objects (VBOs) and Vertex Array Object (VAOs) with our model data
    self.characterVAOName = [self buildVAO];
    
    self.canRender = YES;
}

- (void) initUSA
{
    self.canRender = NO;
    self.flyTo = NO;
    self.flyCnty = NO;
    origin = glm::vec3(0,0,0);
    
    ////////////////////////////////////////////////
    // Set up camera state that will never change //
    ////////////////////////////////////////////////
    
    mapcamera.setFieldOfView(45.0f);
    mapcamera.setNearAndFarPlanes(0.1f, 1.0f);
    mapcamera.setPosition(glm::vec3(0.2,0.2,0.2));
    mapcamera.lookAt(origin);
    
    //////////////////////////////
    // Load our character model //
    //////////////////////////////
    
    mapPositions.clear();
    for (unsigned int i = 0; i < usaPositions.size(); i++) {
        mapPositions.push_back(usaPositions[i]);
    }
    mapTexcoords.clear();
    for (unsigned int i = 0; i < usaTexcoords.size(); i++) {
        mapTexcoords.push_back(usaTexcoords[i]);
    }
    mapNormals.clear();
    for (unsigned int i = 0; i < usaNormals.size(); i++) {
        mapNormals.push_back(usaNormals[i]);
    }
    mapElements.clear();
    for (unsigned int i = 0; i < usaElements.size(); i++) {
        mapElements.push_back(usaElements[i]);
    }
    
    // Build Vertex Buffer Objects (VBOs) and Vertex Array Object (VAOs) with our model data
    self.characterVAOName = [self buildVAO];
    
    self.canRender = YES;
}

- (void) initWA
{
    self.canRender = NO;
    self.flyTo = YES;
    self.flyCnty = NO;
    
    ////////////////////////////////////////////////
    // Set up camera state that will never change //
    ////////////////////////////////////////////////
    
    mapcamera.setFieldOfView(45.0f);
    mapcamera.setNearAndFarPlanes(0.1f, 1.0f);
    mapcamera.setPosition(glm::vec3(0.2,0.2,0.2));
    mapcamera.lookAt(glm::vec3(.281552494,0,-.330356687));
    
    //////////////////////////////
    // Load our character model //
    //////////////////////////////
    
    mapPositions.clear();
    for (unsigned int i = 0; i < usaPositions.size(); i++) {
        mapPositions.push_back(usaPositions[i]);
    }
    mapTexcoords.clear();
    for (unsigned int i = 0; i < usaTexcoords.size(); i++) {
        mapTexcoords.push_back(usaTexcoords[i]);
    }
    mapNormals.clear();
    for (unsigned int i = 0; i < usaNormals.size(); i++) {
        mapNormals.push_back(usaNormals[i]);
    }
    mapElements.clear();
    for (unsigned int i = 0; i < usaElements.size(); i++) {
        mapElements.push_back(usaElements[i]);
    }
    
    // Build Vertex Buffer Objects (VBOs) and Vertex Array Object (VAOs) with our model data
    self.characterVAOName = [self buildVAO];
    
    self.canRender = YES;
}

- (void) render
{
    if (!self.canRender) return;
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    float r = self.opacity * self.red;
    float g = self.opacity * self.green;
    float b = self.opacity * self.blue;
    glClearColor(r, g, b, self.opacity);
	
	// Use the program for rendering our character
	glUseProgram(self.characterPrgName);
    
    // Model matrix : an identity matrix (model will be at the origin)
    glm::mat4 model      = glm::mat4(1.0f);  // Changes for each model !
    
    mapcamera.setViewportAspectRatio((float)self.viewWidth / (float)self.viewHeight);
    
    if (self.flyTo) {
        if (mapcamera.position().y > .150) {
            mapcamera.offsetPosition(.0025f * mapcamera.forward());
            mapcamera.offsetPosition(.0025f * -mapcamera.right());
            mapcamera.offsetPosition(.00135f * mapcamera.up());
            mapcamera.lookAt(glm::vec3(0.297853, 0.000001, -0.296011));
        }
    } else {
        if (self.flyCnty) {
            if (mapcamera.position().y > .65) {
                mapcamera.offsetPosition(.00088f * mapcamera.forward());
                mapcamera.offsetPosition(.00143f * mapcamera.right());
                mapcamera.offsetPosition(.00036f * mapcamera.up());
                mapcamera.lookAt(origin);
            } else {
                mapcamera.offsetPosition(.00005f * -mapcamera.up());
                mapcamera.lookAt(origin);
            }
        } else {
            mapcamera.offsetPosition(.0005f * -mapcamera.right());
            mapcamera.lookAt(origin);
        }
    }
    
    glm::mat4 mvp        = mapcamera.matrix() * model;
    
    glm::mat4 view        = mapcamera.view();
    
    glUniformMatrix4fv(self.mvpUniformIdx, 1, GL_FALSE, &mvp[0][0]);
    glUniformMatrix4fv(self.modelUniformIdx, 1, GL_FALSE, &model[0][0]);
    glUniformMatrix4fv(self.viewlUniformIdx, 1, GL_FALSE, &view[0][0]);
    
    glm::vec3 lightPos = glm::vec3(-152,260,-5.8);
    
    glUniform3f(self.lightUniformIdx, lightPos.x, lightPos.y, lightPos.z);
	
    // Bind the texture to be used
	glBindTexture(GL_TEXTURE_2D, self.characterTexName);
    
	// Bind our vertex array object
	glBindVertexArray(self.characterVAOName);
    
    glDrawElements(GL_TRIANGLES, mapElements.size(), GL_UNSIGNED_INT, 0);
    
    self.characterX += .00370464f;
    self.characterZ -= .0043468f;
}

- (GLuint) buildVAO
{
	GLuint vaoName;
	
	// Create a vertex array object (VAO) to cache model parameters
	glGenVertexArrays(1, &vaoName);
	glBindVertexArray(vaoName);
    
    GLuint posBufferName;
    
    // Create a vertex buffer object (VBO) to store positions
    glGenBuffers(1, &posBufferName);
    glBindBuffer(GL_ARRAY_BUFFER, posBufferName);
    
    // Allocate and load position data into the VBO
    glBufferData(GL_ARRAY_BUFFER, mapPositions.size() * sizeof(glm::vec3), &mapPositions[0], GL_STATIC_DRAW);
    
    // Enable the position attribute for this VAO
    glEnableVertexAttribArray(POS_ATTRIB_IDX);
    
    // Set up parmeters for position attribute in the VAO including,
    //  size, type, stride, and offset in the currenly bound VAO
    // This also attaches the position VBO to the VAO
    glVertexAttribPointer(POS_ATTRIB_IDX,		// What attibute index will this array feed in the vertex shader (see buildProgram)
                          3,	// How many elements are there per position?
                          GL_FLOAT,	// What is the type of this data?
                          GL_FALSE,				// Do we want to normalize this data (0-1 range for fixed-pont types)
                          0, // What is the stride (i.e. bytes between positions)?
                          BUFFER_OFFSET(0));	// What is the offset in the VBO to the position data?
    
    GLuint texcoordBufferName;
    
    // Create a vertex buffer object (VBO) to store positions
    glGenBuffers(1, &texcoordBufferName);
    glBindBuffer(GL_ARRAY_BUFFER, texcoordBufferName);
    
    // Allocate and load color data into the VBO
    glBufferData(GL_ARRAY_BUFFER, mapTexcoords.size() * sizeof(glm::vec2), &mapTexcoords[0], GL_STATIC_DRAW);
    
    // Enable the position attribute for this VAO
    glEnableVertexAttribArray(TEXCOORD_ATTRIB_IDX);
    
    // Set up parmeters for position attribute in the VAO including,
    //  size, type, stride, and offset in the currenly bound VAO
    // This also attaches the position VBO to the VAO
    glVertexAttribPointer(TEXCOORD_ATTRIB_IDX,		// What attibute index will this array feed in the vertex shader (see buildProgram)
                          2,	// How many elements are there per position?
                          GL_FLOAT,	// What is the type of this data?
                          GL_FALSE,				// Do we want to normalize this data (0-1 range for fixed-pont types)
                          0, // What is the stride (i.e. bytes between positions)?
                          BUFFER_OFFSET(0));	// What is the offset in the VBO to the position data?
    
    GLuint normalBufferName;
    
    // Create a vertex buffer object (VBO) to store positions
    glGenBuffers(1, &normalBufferName);
    glBindBuffer(GL_ARRAY_BUFFER, normalBufferName);
    
    // Allocate and load normal data into the VBO
    glBufferData(GL_ARRAY_BUFFER, mapNormals.size() * sizeof(glm::vec3), &mapNormals[0], GL_STATIC_DRAW);
    
    // Enable the normal attribute for this VAO
    glEnableVertexAttribArray(NORMAL_ATTRIB_IDX);
    
    // Set up parmeters for position attribute in the VAO including,
    //   size, type, stride, and offset in the currenly bound VAO
    // This also attaches the position VBO to the VAO
    glVertexAttribPointer(NORMAL_ATTRIB_IDX,	// What attibute index will this array feed in the vertex shader (see buildProgram)
                          3,	// How many elements are there per normal?
                          GL_FLOAT,	// What is the type of this data?
                          GL_FALSE,				// Do we want to normalize this data (0-1 range for fixed-pont types)
                          0, // What is the stride (i.e. bytes between normals)?
                          BUFFER_OFFSET(0));	// What is the offset in the VBO to the normal data?


    GLuint elementBufferName;
    
    // Create a VBO to vertex array elements
    // This also attaches the element array buffer to the VAO
    glGenBuffers(1, &elementBufferName);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elementBufferName);
    
    // Allocate and load vertex array element data into VBO
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, mapElements.size() * sizeof(unsigned int), &mapElements[0] , GL_STATIC_DRAW);

	GetGLError();
	
	return vaoName;
}

-(void)destroyVAO:(GLuint) vaoName
{
     GLuint index;
     GLuint bufName;
     
     // Bind the VAO so we can get data from it
     glBindVertexArray(vaoName);
     
     // For every possible attribute set in the VAO
     for(index = 0; index < 16; index++)
     {
         // Get the VBO set for that attibute
         glGetVertexAttribiv(index , GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING, (GLint*)&bufName);
     
         // If there was a VBO set...
         if(bufName)
         {
             //...delete the VBO
             glDeleteBuffers(1, &bufName);
         }
     }
     
     // Get any element array VBO set in the VAO
     glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, (GLint*)&bufName);
     
     // If there was a element array VBO set in the VAO
     if(bufName)
     {
         //...delete the VBO
         glDeleteBuffers(1, &bufName);
     }
     
     // Finally, delete the VAO
     glDeleteVertexArrays(1, &vaoName);
     
     GetGLError();
}

-(GLuint) buildTexture:(demoImage*) image
{
	GLuint texName;
	
	// Create a texture object to apply to model
	glGenTextures(1, &texName);
	glBindTexture(GL_TEXTURE_2D, texName);
	
	// Set up filter and wrap modes for this texture object
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	
	// Indicate that pixel rows are tightly packed
	//  (defaults to stride of 4 which is kind of only good for
	//  RGBA or FLOAT data types)
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	
	// Allocate and load image data into texture
	glTexImage2D(GL_TEXTURE_2D, 0, image->format, image->width, image->height, 0,
				 image->format, image->type, image->data);
    
	// Create mipmaps for this texture for better image quality
	glGenerateMipmap(GL_TEXTURE_2D);
	
	GetGLError();
	
	return texName;
}

-(GLuint) buildProgramWithVertexSource:(demoSource*)vertexSource
					withFragmentSource:(demoSource*)fragmentSource
{
	GLuint prgName;
	
	GLint logLength, status;
	
	// String to pass to glShaderSource
	GLchar* sourceString = NULL;
	
	// Determine if GLSL version 140 is supported by this context.
	//  We'll use this info to generate a GLSL shader source string
	//  with the proper version preprocessor string prepended
	float  glLanguageVersion;
	
#if ESSENTIAL_GL_PRACTICES_IOS
	sscanf((char *)glGetString(GL_SHADING_LANGUAGE_VERSION), "OpenGL ES GLSL ES %f", &glLanguageVersion);
#else
	sscanf((char *)glGetString(GL_SHADING_LANGUAGE_VERSION), "%f", &glLanguageVersion);
#endif
	
	// GL_SHADING_LANGUAGE_VERSION returns the version standard version form
	//  with decimals, but the GLSL version preprocessor directive simply
	//  uses integers (thus 1.10 should 110 and 1.40 should be 140, etc.)
	//  We multiply the floating point number by 100 to get a proper
	//  number for the GLSL preprocessor directive
	GLuint version = 100 * glLanguageVersion;
	
	// Get the size of the version preprocessor string info so we know
	//  how much memory to allocate for our sourceString
	const GLsizei versionStringSize = sizeof("#version 123\n");
	
	// Create a program object
	prgName = glCreateProgram();
	
	// Indicate the attribute indicies on which vertex arrays will be
	//  set with glVertexAttribPointer
	//  See buildVAO to see where vertex arrays are actually set
	glBindAttribLocation(prgName, POS_ATTRIB_IDX, "vertpos_modelspace");
    
    glBindAttribLocation(prgName, TEXCOORD_ATTRIB_IDX, "vertuv");

	glBindAttribLocation(prgName, NORMAL_ATTRIB_IDX, "vertnormal_modelspace");

	//////////////////////////////////////
	// Specify and compile VertexShader //
	//////////////////////////////////////
	
	// Allocate memory for the source string including the version preprocessor information
	sourceString = (char *)malloc(vertexSource->byteSize + versionStringSize);
	
	// Prepend our vertex shader source string with the supported GLSL version so
	//  the shader will work on ES, Legacy, and OpenGL 3.2 Core Profile contexts
	sprintf(sourceString, "#version %d\n%s", version, vertexSource->string);
    
	GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
	glShaderSource(vertexShader, 1, (const GLchar **)&(sourceString), NULL);
	glCompileShader(vertexShader);
	glGetShaderiv(vertexShader, GL_INFO_LOG_LENGTH, &logLength);
	
	if (logLength > 0)
	{
		GLchar *log = (GLchar*) malloc(logLength);
		glGetShaderInfoLog(vertexShader, logLength, &logLength, log);
		NSLog(@"Vtx Shader compile log:%s\n", log);
		free(log);
	}
	
	glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &status);
	if (status == 0)
	{
		NSLog(@"Failed to compile vtx shader:\n%s\n", sourceString);
		return 0;
	}
	
	free(sourceString);
	sourceString = NULL;
	
	// Attach the vertex shader to our program
	glAttachShader(prgName, vertexShader);
	
	// Delete the vertex shader since it is now attached
	// to the program, which will retain a reference to it
	glDeleteShader(vertexShader);
	
	/////////////////////////////////////////
	// Specify and compile Fragment Shader //
	/////////////////////////////////////////
	
	// Allocate memory for the source string including the version preprocessor	 information
	sourceString = (char *)malloc(fragmentSource->byteSize + versionStringSize);
	
	// Prepend our fragment shader source string with the supported GLSL version so
	//  the shader will work on ES, Legacy, and OpenGL 3.2 Core Profile contexts
	sprintf(sourceString, "#version %d\n%s", version, fragmentSource->string);
	
	GLuint fragShader = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(fragShader, 1, (const GLchar **)&(sourceString), NULL);
	glCompileShader(fragShader);
	glGetShaderiv(fragShader, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0)
	{
		GLchar *log = (GLchar*)malloc(logLength);
		glGetShaderInfoLog(fragShader, logLength, &logLength, log);
		NSLog(@"Frag Shader compile log:\n%s\n", log);
		free(log);
	}
	
	glGetShaderiv(fragShader, GL_COMPILE_STATUS, &status);
	if (status == 0)
	{
		NSLog(@"Failed to compile frag shader:\n%s\n", sourceString);
		return 0;
	}
	
	free(sourceString);
	sourceString = NULL;
	
	// Attach the fragment shader to our program
	glAttachShader(prgName, fragShader);
	
	// Delete the fragment shader since it is now attached
	// to the program, which will retain a reference to it
	glDeleteShader(fragShader);
	
	//////////////////////
	// Link the program //
	//////////////////////
	
	glLinkProgram(prgName);
	glGetProgramiv(prgName, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0)
	{
		GLchar *log = (GLchar*)malloc(logLength);
		glGetProgramInfoLog(prgName, logLength, &logLength, log);
		NSLog(@"Program link log:\n%s\n", log);
		free(log);
	}
	
	glGetProgramiv(prgName, GL_LINK_STATUS, &status);
	if (status == 0)
	{
		NSLog(@"Failed to link program");
		return 0;
	}
	
	glValidateProgram(prgName);
	glGetProgramiv(prgName, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0)
	{
		GLchar *log = (GLchar*)malloc(logLength);
		glGetProgramInfoLog(prgName, logLength, &logLength, log);
		NSLog(@"Program validate log:\n%s\n", log);
		free(log);
	}
	
	glGetProgramiv(prgName, GL_VALIDATE_STATUS, &status);
	if (status == 0)
	{
		NSLog(@"Failed to validate program");
		return 0;
	}
	
	
	glUseProgram(prgName);
	
	///////////////////////////////////////
	// Setup common program input points //
	///////////////////////////////////////
    
	
	GLint samplerLoc = glGetUniformLocation(prgName, "diffuseTexture");
	
	// Indicate that the diffuse texture will be bound to texture unit 0
	GLint unit = 0;
	glUniform1i(samplerLoc, unit);
	
	GetGLError();
	
	return prgName;
	
}

- (id) initWithDefaultFBO: (GLuint) defaultFBOName
{
	if((self = [super init]))
	{
		NSLog(@"%s %s", glGetString(GL_RENDERER), glGetString(GL_VERSION));
        
        ////////////////////////////////////////////////////
		// Build all of our and setup initial state here  //
		// Don't wait until our real time run loop begins //
		////////////////////////////////////////////////////
		
		self.defaultFBOName = defaultFBOName;
		
		self.viewWidth = 100;
		self.viewHeight = 100;
        
        self.characterX = 0;
        self.characterZ = 0;
		
		self.useVBOs = USE_VERTEX_BUFFER_OBJECTS;
        
        NSString* filePathName = nil;
        
        //////////////////////////////
		// Load our character models //
		//////////////////////////////
        
        filePathName = [[NSBundle mainBundle] pathForResource:@"ca" ofType:@"obj"];
        const char * capath = [filePathName cStringUsingEncoding:NSASCIIStringEncoding];
        
        // Read our .obj file
        bool cares = loadAssImpMesh(capath, caElements, caPositions, caTexcoords, caNormals);
        if(!cares)
		{
			NSLog(@"Could not load obj file");
		}
        
        filePathName = [[NSBundle mainBundle] pathForResource:@"tn" ofType:@"obj"];
        const char * tnpath = [filePathName cStringUsingEncoding:NSASCIIStringEncoding];
        
        // Read our .obj file
        bool tnres = loadAssImpMesh(tnpath, tnElements, tnPositions, tnTexcoords, tnNormals);
        if(!tnres)
		{
			NSLog(@"Could not load obj file");
		}
        
        filePathName = [[NSBundle mainBundle] pathForResource:@"tn_cnty" ofType:@"obj"];
        const char * cntypath = [filePathName cStringUsingEncoding:NSASCIIStringEncoding];
        
        // Read our .obj file
        bool cntyres = loadAssImpMesh(cntypath, cntyElements, cntyPositions, cntyTexcoords, cntyNormals);
        if(!cntyres)
		{
			NSLog(@"Could not load obj file");
		}
        
        filePathName = [[NSBundle mainBundle] pathForResource:@"usa" ofType:@"obj"];
        const char * usapath = [filePathName cStringUsingEncoding:NSASCIIStringEncoding];
        
        // Read our .obj file
        bool usares = loadAssImpMesh(usapath, usaElements, usaPositions, usaTexcoords, usaNormals);
        if(!usares)
		{
			NSLog(@"Could not load obj file");
		}
        
        mapPositions.clear();
        for (unsigned int i = 0; i < usaPositions.size(); i++) {
            mapPositions.push_back(usaPositions[i]);
        }
        mapTexcoords.clear();
        for (unsigned int i = 0; i < usaTexcoords.size(); i++) {
            mapTexcoords.push_back(usaTexcoords[i]);
        }
        mapNormals.clear();
        for (unsigned int i = 0; i < usaNormals.size(); i++) {
            mapNormals.push_back(usaNormals[i]);
        }
        mapElements.clear();
        for (unsigned int i = 0; i < usaElements.size(); i++) {
            mapElements.push_back(usaElements[i]);
        }
        
        // Build Vertex Buffer Objects (VBOs) and Vertex Array Object (VAOs) with our model data
		self.characterVAOName = [self buildVAO];
        
        ////////////////////////////////////
		// Load texture for our character //
		////////////////////////////////////
		
		filePathName = [[NSBundle mainBundle] pathForResource:@"redbluewhite_128" ofType:@"png"];
		demoImage *image = imgLoadImage([filePathName cStringUsingEncoding:NSASCIIStringEncoding], false);
		
		// Build a texture object with our image data
		self.characterTexName = [self buildTexture:image];
		
		// We can destroy the image once it's loaded into GL
		imgDestroyImage(image);
		
		////////////////////////////////////////////////////
		// Load and Setup shaders for character rendering //
		////////////////////////////////////////////////////
		
		demoSource *vtxSource = NULL;
		demoSource *frgSource = NULL;
		
		filePathName = [[NSBundle mainBundle] pathForResource:@"shade" ofType:@"vsh"];
		vtxSource = srcLoadSource([filePathName cStringUsingEncoding:NSASCIIStringEncoding]);
		
		filePathName = [[NSBundle mainBundle] pathForResource:@"shade" ofType:@"fsh"];
		frgSource = srcLoadSource([filePathName cStringUsingEncoding:NSASCIIStringEncoding]);
		
		// Build Program
		self.characterPrgName = [self buildProgramWithVertexSource:vtxSource
                                                withFragmentSource:frgSource];
		
		srcDestroySource(vtxSource);
		srcDestroySource(frgSource);
		
        self.mvpUniformIdx = glGetUniformLocation(self.characterPrgName, "mvp");
		if(self.mvpUniformIdx < 0)
		{
			NSLog(@"No model in camera shader");
		}
		self.modelUniformIdx = glGetUniformLocation(self.characterPrgName, "model");
		if(self.modelUniformIdx < 0)
		{
			NSLog(@"No model in camera shader");
		}
        self.viewlUniformIdx = glGetUniformLocation(self.characterPrgName, "view");
		if(self.viewlUniformIdx < 0)
		{
			NSLog(@"No camera in camera shader");
		}
        self.lightUniformIdx = glGetUniformLocation(self.characterPrgName, "lightpos_worldspace");
		if(self.lightUniformIdx < 0)
		{
			NSLog(@"No light in camera shader");
		}
        
        ////////////////////////////////////////////////
		// Set up OpenGL state that will never change //
		////////////////////////////////////////////////
		
		// Depth test will always be enabled
		glEnable(GL_DEPTH_TEST);
        
		// We will always cull back faces for better performance
		glEnable(GL_CULL_FACE);
		
		// Always use this clear color
		//glClearColor(0.0f, 0.0f, 0.4f, 0.0f);
        self.red = 135.0f/255.0f;
        self.green = 206.0f/255.0f;
        self.blue = 250.0f/255.0f;
        self.opacity = 0.0f;
		glClearColor(self.red, self.green, self.blue, self.opacity);
        
        origin = glm::vec3(0,0,0);
        
		// Draw our scene once without presenting the rendered image.
		//   This is done in order to pre-warm OpenGL
		// We don't need to present the buffer since we don't actually want the 
		//   user to see this, we're only drawing as a pre-warm stage
		[self render];
		
		// Check for errors to make sure all of our setup went ok
		GetGLError();
	}
	
	return self;
}


- (void) dealloc
{
    // Cleanup all OpenGL objects and
	glDeleteTextures(1, &_characterTexName);
    
	[self destroyVAO:_characterVAOName];
    
	glDeleteProgram(_characterPrgName);
}

@end
