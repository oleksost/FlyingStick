//
//  MyScene.m
//  JumpingChicken
//
//  Created by Alexey Ostapenko on 22.02.14.
//  Copyright (c) 2014 Alexey Otapenko. All rights reserved.
//

#import "MyScene.h"
@interface MyScene () <SKPhysicsContactDelegate>
{
    SKSpriteNode* _bird;
    SKColor* _skyColor;
    SKAction* flapDown;
    SKAction* flapUp;
    SKTexture* _tree1;
    SKTexture* _tree2;
    SKAction* _moveAndRemovePipes;
    SKSpriteNode* pipePair;
    SKSpriteNode* background;
    SKAction* movveremove;
    SKSpriteNode* dummy2;
    SKAction* addGround;
    SKAction* spawnThenDelayForever;
    
    SKNode* _moving;
    SKNode* pipes;
    SKLabelNode* restart;
    int scoreInt;
    SKLabelNode* score;
}
@end

@implementation MyScene



static const uint32_t birdCategory = 0;
static const uint32_t worldCategory = 1;
static const uint32_t pipeCategory = 2;
static const uint32_t scoringCategory = 2 <<3;

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        self.physicsWorld.contactDelegate = self;
        _moving = [SKNode node];
        [self addChild:_moving];
        pipes=[SKNode node];
        [_moving addChild:pipes];
        SKTexture* backgroundTexture = [SKTexture textureWithImageNamed:@"h"];
        backgroundTexture.filteringMode = SKTextureFilteringNearest;
        background = [SKSpriteNode spriteNodeWithTexture:backgroundTexture];
        [background setScale:1];
        background.position = CGPointMake(self.size.width/2, self.size.height/2);
        restart =[SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        restart.fontSize=32;
        restart.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        restart.zPosition=10;
        
        
        [self addChild:restart];
        
        
        score =[SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        scoreInt=0;
        score.text=[NSString stringWithFormat:@"%d",scoreInt]
        ;
        score.fontSize=42;
        score.position=CGPointMake(self.frame.size.width/2, (self.frame.size.height/5)*4);
        score.zPosition=10;
        [self addChild:score];
        
        self.physicsWorld.gravity = CGVectorMake( 0.0, -5.0 );
        _skyColor = [SKColor colorWithRed:40.0/255.0 green:63.0/255.0 blue:60.0/255.0 alpha:1.0];
        [self setBackgroundColor:_skyColor];
        
        SKTexture* birdTexture1 = [SKTexture textureWithImageNamed:@"Bird1.png"];
        birdTexture1.filteringMode = SKTextureFilteringNearest;
        
        _bird = [SKSpriteNode spriteNodeWithTexture:birdTexture1];
        
        [_bird setScale:0.5];
        _bird.position = CGPointMake(self.frame.size.width / 4, CGRectGetMidY(self.frame));
        
        _bird.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_bird.size.height / 2];
        _bird.physicsBody.dynamic = YES;
        _bird.physicsBody.allowsRotation = NO;
        _bird.physicsBody.categoryBitMask = birdCategory;
        _bird.physicsBody.collisionBitMask = worldCategory | pipeCategory;
        _bird.physicsBody.contactTestBitMask=worldCategory | pipeCategory | scoringCategory;
        [_moving addChild:_bird];
        // Create ground physics container
        SKTexture* Boden = [SKTexture textureWithImageNamed:@"Boden"];

        CGFloat distanceToMoveBD = Boden.size.width*2;
        
        SKAction* mooveBD=[SKAction moveByX:-distanceToMoveBD y:0 duration:0.01*distanceToMoveBD];
        SKAction* moove =[SKAction moveByX:distanceToMoveBD y:0 duration:0];
        SKAction* a =[SKAction sequence:@[mooveBD, moove]];
        SKAction* movement = [SKAction repeatActionForever:a];
        for(int i=0; i<=3; i++)
        {
            
            dummy2 = [SKSpriteNode spriteNodeWithTexture:Boden];
            dummy2.position = CGPointMake(i*dummy2.frame.size.width,60);
            dummy2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(Boden.size.width, 20.0)];
            dummy2.physicsBody.categoryBitMask=worldCategory;
            
            dummy2.physicsBody.dynamic = NO;
            dummy2.zPosition=1;

            
            
            
            [dummy2 runAction:movement];
            
            
            [_moving addChild:dummy2];
            SKAction* blitzer = [SKAction sequence:@[[SKAction waitForDuration:3.0+ arc4random()%5],[SKAction runBlock:^{
                self.backgroundColor=[SKColor whiteColor];
        
    }],[SKAction waitForDuration:0.04], [SKAction runBlock:^{
        self.backgroundColor=_skyColor;
    }]]];
            
            [self runAction:[SKAction repeatActionForever:blitzer]];
            
            
            
        }
        
     
        
        SKTexture* birdTexture2 = [SKTexture textureWithImageNamed:@"Bird2"];
        birdTexture2.filteringMode = SKTextureFilteringNearest;
        flapDown = [SKAction repeatActionForever:[SKAction animateWithTextures:@[ birdTexture2] timePerFrame:0.2]];
        flapUp = [SKAction repeatActionForever:[SKAction animateWithTextures:@[ birdTexture1] timePerFrame:0.2]];
        
        
        //
           _tree1 =[SKTexture textureWithImageNamed:@"Tree1"];
        // _pipeTexture1.filteringMode = SKTextureFilteringNearest;
        _tree2 =[SKTexture textureWithImageNamed:@"Tree2"];
       //  [self spawnPipes];
        //background.zPosition=-10;
        
        //[self addChild:background];
    
       
       

        
        
        CGFloat distanceToMove = self.frame.size.width + (2 * _tree1.size.width);
        SKAction* movePipes = [SKAction moveByX:-distanceToMove y:0 duration:0.01 * distanceToMove];
        //duration:0.01 * distanceToMove - Time - Speed * Distance
        SKAction* removePipes = [SKAction removeFromParent];
        _moveAndRemovePipes = [SKAction sequence:@[movePipes, removePipes]];
        
        SKAction* spawn = [SKAction performSelector:@selector(spawnPipes) onTarget:self];
       
        SKAction* delay = [SKAction waitForDuration:2.0];
        SKAction* spawnThenDelay = [SKAction sequence:@[spawn, delay]];
        

        spawnThenDelayForever = [SKAction repeatActionForever:spawnThenDelay];
     
    
        [self runAction:spawnThenDelayForever];
        NSLog(@"fffff");
       
      

    }
    return self;
}



-(void)didBeginContact:(SKPhysicsContact *)contact{
  
    if (contact.bodyA.categoryBitMask==scoringCategory || contact.bodyB.categoryBitMask==scoringCategory){
        
        scoreInt++;
        score.text=[NSString stringWithFormat:@"%d",scoreInt];

        
    }else{
        if(_moving.speed>0){
            _moving.speed=0;
            [_bird.physicsBody applyImpulse:CGVectorMake(0, -50)];
        }
        SKAction* blick = [SKAction sequence:@[[SKAction runBlock:^{
            self.backgroundColor=[SKColor redColor];    }],[SKAction waitForDuration:0.1],[SKAction runBlock:^{
                self.backgroundColor=_skyColor;
            }]  ] ];
        [self runAction:blick];
               restart.text=@"Press to restart";
    }
    
}





-(void)spawnPipes {
    pipePair = [SKSpriteNode node];
    pipePair.position = CGPointMake( self.frame.size.width + _tree1.size.width, 0 );
    pipePair.zPosition = 10;
    
    CGFloat y = arc4random() % (NSInteger)( self.frame.size.height / 3 );
    
    
    SKSpriteNode* pipe1 = [SKSpriteNode spriteNodeWithTexture:_tree1];
    [pipe1 setScale:1];
    pipe1.position = CGPointMake( 0, y );
    pipe1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe1.size];
    pipe1.physicsBody.dynamic = NO;
    //pipe1.physicsBody.categoryBitMask= worldCategory;
    [pipePair addChild:pipe1];
    
    SKSpriteNode* pipe2 = [SKSpriteNode spriteNodeWithTexture:_tree2];
    [pipe2 setScale:1];
    pipe2.position = CGPointMake( 0, y + pipe1.size.height + kVerticalPipeGap );
    pipe2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe2.size];
    pipe2.physicsBody.dynamic = NO;
    pipe1.physicsBody.categoryBitMask=pipeCategory;
    pipe2.physicsBody.categoryBitMask=pipeCategory;
    pipe1.physicsBody.contactTestBitMask=birdCategory;
    pipe2.physicsBody.contactTestBitMask=birdCategory;
    
    
    [pipePair addChild:pipe2];
    
    SKNode* scoringNote = [SKNode node];
    scoringNote.position=CGPointMake(pipePair.size.width, self.frame.size.height);
    scoringNote.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(1, self.frame.size.height)];
    
    scoringNote.physicsBody.dynamic=NO;
    
    scoringNote.physicsBody.categoryBitMask = scoringCategory;
  //scoringNote.physicsBody.collisionBitMask =birdCategory;
    scoringNote.physicsBody.contactTestBitMask=birdCategory;
    
    
    
    [pipePair addChild:scoringNote];
    [pipes addChild:pipePair];
    
  
    [pipePair runAction:_moveAndRemovePipes];
    

    
}
static NSInteger const kVerticalPipeGap = 115;



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    if(_moving.speed>0){
    _bird.physicsBody.velocity = CGVectorMake(0, 0);
    [_bird.physicsBody applyImpulse:CGVectorMake(0, 10)];
        //[restart removeFromParent];
        
    } else{
        
        [pipes removeAllChildren];
                _moving.speed=1;
        _bird.position=CGPointMake(self.frame.size.width / 4, CGRectGetMidY(self.frame));
        scoreInt=0;
        restart.text=@" ";
      

        
    }
    
}
CGFloat clamp(CGFloat min, CGFloat max, CGFloat value) {
    if( value > max ) {
        return max;
    } else if( value < min ) {
        return min;
    } else {
        return value;
    }
}
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    score.text=[NSString stringWithFormat:@"%d",scoreInt]
    ;

    _bird.zRotation = clamp( -1, 1, _bird.physicsBody.velocity.dy * ( _bird.physicsBody.velocity.dy < 0 ? 0.003 : 0.001 ) );
    if(_bird.physicsBody.velocity.dy >0)
    {
        [_bird runAction:flapUp];
        
    }else{
        [_bird runAction:flapDown];

    }
    
    
    }




@end
