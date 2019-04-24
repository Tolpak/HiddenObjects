//
//  HelloWorldLayer.m
//  HiddenObjects
//
//  Created by moyo on 20.04.19.
//  Copyright __MyCompanyName__ 2019. All rights reserved.
//


#import "HelloWorldLayer.h"
#import "XmlParser.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

const float kPinchZoomCoeff = 1.0 / 1000.0f;

#pragma mark - HelloWorldLayer

@implementation HelloWorldLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if( (self=[super init]) ) {
        _startTouches = [[NSMutableSet alloc] init];
        _zoom = 1;
        _fitScale = 1;
        [self setIsTouchEnabled:YES];
		
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/config.xml"];
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        XmlParser *myParser = [[XmlParser alloc] initParser];
        [parser setDelegate:myParser];
        BOOL success = [parser parse];
        if (success) {
            background = [CCSprite spriteWithFile:myParser.room];
            background.anchorPoint = ccp(0,0);
            background.position = ccp(0,0);
            [self addChild:background];
	
            for (NSArray *array in myParser.objects) {
                int rand = arc4random_uniform(array.count);
                NSString *address = [array[rand] valueForKey:@"fileName"];
                CCSprite *object = [CCSprite spriteWithFile:address];
                object.anchorPoint = ccp(0,0);
                object.position = ccp([[array[rand] valueForKey:@"x"] intValue], [[array[rand] valueForKey:@"y"] intValue]);
                [self addChild:object];
            }
        }
        CGSize winSize = [CCDirector sharedDirector].winSize;
		float wScale , hScale;
		wScale = winSize.width / background.contentSize.width;
		hScale = winSize.height / background.contentSize.height;
		if (wScale >= hScale && wScale > 1) {
			self.fitScale = wScale;
		} else if (hScale > 1){
			self.fitScale = hScale;
		} else {
			self.fitScale = 1;
		}
        self.scale = self.fitScale;
        self.position = ccp(fabsf([self boundingBox].origin.x), fabsf([self boundingBox].origin.y));
	}
	return self;
}

- (void) dealloc
{
    [_startTouches release];
	[super dealloc];
}

- (CGPoint)boundLayerPos:(CGPoint)newPos {
    CGPoint retval = newPos;
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGRect screenRect = [self boundingBox];
    CGSize scaleOffset = CGSizeMake((screenRect.size.width - winSize.width) / 2, (screenRect.size.height - winSize.height) / 2);
    retval.x = MIN(retval.x, scaleOffset.width);
    retval.x = MAX(retval.x, -background.contentSize.width * self.scale + winSize.width + scaleOffset.width);
    retval.y = MIN(retval.y, scaleOffset.height);
    retval.y = MAX(retval.y, -background.contentSize.height * self.scale + winSize.height + scaleOffset.height);
    return retval;
}

- (void)panForTranslation:(CGPoint)translation {
    CGPoint newPos = ccpAdd(self.position, translation);
    self.position = [self boundLayerPos:newPos];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.startTouches unionSet:touches];
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
	CGPoint oldTouchLocation = [touch previousLocationInView:[touch view]];
	oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
	oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    if (touches.count > 1) {
        for (UITouch *touch in touches)
        {
            [self pinchZoomWithMovedTouch:touch];
        }
        UITouch *touch1 = [[touches allObjects] firstObject];
        UITouch *touch2 = [[touches allObjects] lastObject];
        CGPoint touchLocation1 = [self convertTouchToNodeSpace:touch1];
        CGPoint touchLocation2 = [self convertTouchToNodeSpace:touch2];
        touchLocation = ccpMidpoint(touchLocation1, touchLocation2);
    }
    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
    [self panForTranslation:translation];
}

- (void) ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.startTouches minusSet:touches];
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.startTouches minusSet:touches];
}

- (void) pinchZoomWithMovedTouch: (UITouch *) movedTouch
{
    CGFloat minDistSqr = CGFLOAT_MAX;
    UITouch *nearestTouch = nil;
    UIView *mainView = [[CCDirector sharedDirector] view];
    CGPoint newLocation = [movedTouch locationInView:mainView];
    for (UITouch *touch in self.startTouches)
    {
        if (touch != movedTouch)
        {
            CGFloat distSqr = sqrOfDistanceBetweenPoints([touch locationInView:mainView],newLocation);
            if (distSqr < minDistSqr)
            {
                minDistSqr = distSqr;
                nearestTouch = touch;
            }
        }
    }
    if (nearestTouch)
    {
        CGFloat prevDistSqr = sqrOfDistanceBetweenPoints([nearestTouch locationInView:mainView],
                                                         [movedTouch previousLocationInView:mainView]);
        CGFloat pinchDiff = sqrtf(minDistSqr) - sqrtf(prevDistSqr);
        self.zoom += pinchDiff * kPinchZoomCoeff;
        if (self.zoom > 1.3) {
            self.zoom = 1.3;
        } else if ( self.zoom < 1) {
            self.zoom = 1;
        }
        self.scale = self.zoom * self.fitScale;
    }
}

CGFloat sqrOfDistanceBetweenPoints(CGPoint p1, CGPoint p2)
{
    CGPoint diff = ccpSub(p1, p2);
    return diff.x * diff.x + diff.y * diff.y;
}

@end
