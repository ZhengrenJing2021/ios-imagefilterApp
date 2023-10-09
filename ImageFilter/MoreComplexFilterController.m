//
//  MoreComplexFilterController.m
//  ImageFilter
//
//  Implement scale and shake effects with two shader programs.
//

#import "MoreComplexFilterController.h"
#import <GLKit/GLKit.h>
#import "FilterBar.h"
typedef struct {
    GLKVector3 positionCoord;//(xyz) position
    GLKVector2 textureCoord;//(u,v)texture
}SenceVertex;

@interface MoreComplexFilterController ()<FilterBarDelegate>
@property (assign, nonatomic) SenceVertex *verTices;
@property (strong, nonatomic) EAGLContext *context;
@property (assign, nonatomic) GLuint myProgram;
@property (assign, nonatomic) GLuint vertexBuffer;
@property (assign, nonatomic) GLuint textureId;
@property (strong, nonatomic) CADisplayLink *displayLink;
@property (assign, nonatomic) NSInteger startTimeStamp;
@property (nonatomic, strong) UIButton *backBtn;
@end

@implementation MoreComplexFilterController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // invalidate Timer
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}
- (UIButton *)backBtn{
    if (_backBtn == nil){
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(20, 20, 100, 44)];
        [btn setTitle:@"back" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _backBtn = btn;
    }
    return _backBtn;
}
- (void)backBtnClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}
// Timer
- (void)startFilerAnimation {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    self.startTimeStamp = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeAction)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop]
                           forMode:NSRunLoopCommonModes];
}

//2. animation
- (void)timeAction {
    if (self.startTimeStamp == 0) {
        self.startTimeStamp = self.displayLink.timestamp;
    }
    glUseProgram(self.myProgram);
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
    CGFloat currentTime = self.displayLink.timestamp - self.startTimeStamp;
    GLuint time = glGetUniformLocation(self.myProgram, "Time");
    glUniform1f(time, currentTime);
    
    // clear layer
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(1, 1, 1, 1);
    // redraw
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    // render layer
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
    
}
- (void)setupFilterBar {
    CGFloat filterBarWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat filterBarHeight = 50;
    CGFloat filterBarY = [UIScreen mainScreen].bounds.size.height - filterBarHeight-200;
    FilterBar *filerBar = [[FilterBar alloc] initWithFrame:CGRectMake(0, filterBarY, filterBarWidth, filterBarHeight)];
    filerBar.delegate = self;
    [self.view addSubview:filerBar];
    NSArray *dataSource = @[@"None",@"Scale",@"Shake"];
    filerBar.itemList = dataSource;
}
- (void)filterBar:(FilterBar *)filterBar didScrollToIndex:(NSUInteger)index{
    NSArray *filterArr = @[@"Namal",@"Scale",@"Shake"];
    if (index < filterArr.count) {
        [self setupShaderProgramWithName:filterArr[index]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.backBtn];
    self.view.backgroundColor = UIColor.whiteColor;
    [self setupFilterBar];
    
    self.verTices = malloc(sizeof(SenceVertex) * 4);
    self.verTices[0] = (SenceVertex){{-1, 1, 0}, {0, 1}};
    self.verTices[1] = (SenceVertex){{-1, -1, 0}, {0, 0}};
    self.verTices[2] = (SenceVertex){{1, 1, 0}, {1, 1}};
    self.verTices[3] = (SenceVertex){{1, -1, 0}, {1, 0}};
    
    [self setupContext];
    
    // set layer
    CAEAGLLayer *layer = [[CAEAGLLayer alloc]init];
    layer.frame = CGRectMake(20, 100, self.view.frame.size.width - 40, self.view.frame.size.width - 40);
    layer.contentsScale = [[UIScreen mainScreen] scale];
    [self.view.layer addSublayer:layer];
    
    //layer binding with frame buffer
    [self bindRenderAndFrameBuffer:layer];
    
    UIImage *image = _originalImage;
    // transfer image to texture
    GLuint textureID = [self loadTexture:image];
    // binding with textureID
    self.textureId = textureID;
    
    [self renderLayer];
    
    [self setupShaderProgramWithName:@"Namal"];
    
    [self startFilerAnimation];
}

// init context
-(void)setupContext{
    EAGLContext *context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context) {
        NSLog(@"creat context failed");
    }
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"set current context failed");
    }
    self.context= context;
}

-(void)renderLayer{
    // config window
    glViewport(0, 0, self.drawableWidth, self.drawableHeight);
    
    //8. config vertex buffer
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr bufferSizeBytes = sizeof(SenceVertex) * 4;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.verTices, GL_STATIC_DRAW);
    
    //10.save vertex buffer
    self.vertexBuffer = vertexBuffer;
}

-(void)bindRenderAndFrameBuffer:(CALayer<EAGLDrawable> *)layer{
    // define render buffer and framebuffer
    GLuint renderBuffer,frameBuffer;
    
    // get ID of buffer
    glGenRenderbuffers(1, &renderBuffer);
    // bind render buffer
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    
    //// make relationship with render buffer and layer
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    // get if of frame buffer
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    // attach render buffer with frame buffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
    
}


-(GLuint)loadTexture:(UIImage *)image{
    //uiimage -> CGImageRef
    CGImageRef spriteImage = image.CGImage;
    if (!spriteImage) {
        NSLog(@"failed");
        exit(1);
    }
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte *spriteData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // get color space
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(spriteImage);
    // create context to redraw image
    CGContextRef context = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    
    // get bitmap
    CGContextDrawImage(context, rect, spriteImage);
    GLuint textureID;
    // get textureID
    glGenTextures(1, &textureID);
    // binding textureID
    glBindTexture(GL_TEXTURE_2D, textureID);
    
    float fw = width,fh = height;
    // load texture data
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    // config filter of texture
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    // bind data
    glBindBuffer(GL_TEXTURE_2D, 0);
    //9.release all data
    CGContextRelease(context);
    free(spriteData);
    return textureID;
}

-(void)setupShaderProgramWithName:(NSString *)shaderName{
    // get shader program
    GLuint program = [self programShaderName:shaderName];
    
    // user this program
    glUseProgram(program);
    
    GLuint positionSolt = glGetAttribLocation(program, "position");
    GLuint textureCoordSolt = glGetAttribLocation(program, "textureCoord");
    GLuint textureSolt = glGetAttribLocation(program, "Texture");
    
    glActiveTexture(self.textureId);
    glBindTexture(GL_TEXTURE_2D, self.textureId);
    
    // texture sampling
    glUniform1f(textureSolt, 0);
    
    glEnableVertexAttribArray(positionSolt);
    // inpute vertex coor
    glVertexAttribPointer(positionSolt, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    
    glEnableVertexAttribArray(textureCoordSolt);
    
    glVertexAttribPointer(textureCoordSolt, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
    
    self.myProgram = program;
    
}

// compile shader
-(GLuint)comlipeShader:(NSString *)name type:(GLenum)type{
    
    NSString *shaderPath = [[NSBundle mainBundle]pathForResource:name ofType:type == GL_VERTEX_SHADER ? @"vsh" :@"fsh"];
    
    NSError *error = nil;
    NSString *shaderStr = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"failed to read shader program");
        exit(1);
    }
    
    GLuint shader = glCreateShader(type);
    const char *shaderSourceUTF8 = [shaderStr UTF8String];
    int shaderStrLength = (int)[shaderStr length];
    //get shader source
    glShaderSource(shader, 1, &shaderSourceUTF8, &shaderStrLength);
    
    // compile shader
    glCompileShader(shader);
    
    // get result of compile
    GLint compileResult;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileResult);
    if (compileResult == GL_FALSE) {
        NSLog(@"failed to compile shader program");
        exit(1);
    }
    return shader;
}
// link vertex shader program and fragment shader program
-(GLuint)programShaderName:(NSString *)shaderName{
    GLuint vertexShader = [self comlipeShader:shaderName type:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self comlipeShader:shaderName type:GL_FRAGMENT_SHADER];
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    // program link
    glLinkProgram(program);
    
    // link result
    GLint linkResult;
    glGetProgramiv(program, GL_LINK_STATUS, &linkResult);
    if (linkResult == GL_FALSE) {
        NSLog(@"link program failed");
        exit(1);
    }
    
    return program;
}


- (GLint)drawableWidth {
    GLint backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    return backingWidth;
}

- (GLint)drawableHeight {
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    return backingHeight;
}

@end
