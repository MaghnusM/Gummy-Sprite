//
//  GameScene.swift
//  Gummy-Sprite
//
//  Created by Maghnus Mareneck on 7/5/15.
//  Copyright (c) 2015 The Whatever Labs. All rights reserved.
//

import SpriteKit
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var otherCircles : [SKShapeNode] = [SKShapeNode]()
    var otherCirlcesSpringJoints : [SKPhysicsJointSpring] = [SKPhysicsJointSpring]()
    var mainCircle : SKShapeNode = SKShapeNode()
    var yourLine : SKShapeNode = SKShapeNode()
    
    enum SpriteType: UInt32 {
        case character = 1
        case ground = 3
        case noCollisions = 0
    }
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.gravity = CGVectorMake(0, -10)
        self.physicsWorld.contactDelegate = self
        
        createGround()
        createCirclesAndSpringJointsWithCenter(centerX : CGRectGetMidX(self.frame), centerY : CGRectGetMidY(self.frame))
        
    }
    
    func createCirclesAndSpringJointsWithCenter(#centerX : CGFloat, centerY : CGFloat) {
        mainCircle = SKShapeNode(circleOfRadius: 50)
        mainCircle.position = CGPointMake(centerX, centerY)
        mainCircle.physicsBody = SKPhysicsBody(circleOfRadius: mainCircle.frame.width/2)
        mainCircle.physicsBody?.affectedByGravity = false
        mainCircle.physicsBody?.mass = 1
        self.addChild(mainCircle)
        
        var angle : Double = 0
        while(angle <= (2*M_PI)) {
            var distance : Double?
            AppendOuterCircleAndSpringJointWithAngleAndOffset(angle: angle, mainCircle: mainCircle, r: Double(mainCircle.frame.width/2))
            angle = angle + (M_PI/2)
        }
        
        for(var x = 0; x < otherCircles.count; x++) {
            var t : Int?
            var t2 : Int?
            if(x == (otherCircles.count - 1)) {
                t = 0
            }
            else {
                t = x + 1
            }
            if(x == 0) {
                t2 = otherCircles.count - 1
            }
            else {
                t2 = x - 1
            }
            AppendSpringJointToOtherCirclesForOuterCircleWithPosition(keyFrom : x, keyTo : t!, keyTo2 : t2!)
        }
    }
    
    func AppendOuterCircleAndSpringJointWithAngleAndOffset(#angle : Double, mainCircle : SKShapeNode, r : Double) {
        var circle = SKShapeNode(circleOfRadius: 1)
        var distance = r + 50
        circle.position = CGPointMake(mainCircle.position.x + CGFloat(cos(angle) * distance), mainCircle.position.y + CGFloat(sin(angle) * distance))
        circle.physicsBody = SKPhysicsBody(circleOfRadius: circle.frame.width/2)
        circle.physicsBody?.affectedByGravity = true
        circle.physicsBody?.mass = 100
        self.addChild(circle)
        otherCircles.append(circle)
        
        AppendSpringJointToCenterForOuterCircleWithPosition(mainCircle : mainCircle, outerCircle : circle)
    }
    
    
    func AppendSpringJointToCenterForOuterCircleWithPosition(#mainCircle : SKShapeNode, outerCircle : SKShapeNode) {
        
        var springJoint = SKPhysicsJointSpring.jointWithBodyA(mainCircle.physicsBody, bodyB: outerCircle.physicsBody, anchorA: mainCircle.position, anchorB: outerCircle.position)
        springJoint.frequency = 100
        self.physicsWorld.addJoint(springJoint)
    }
    
    func AppendSpringJointToOtherCirclesForOuterCircleWithPosition(#keyFrom : Int, keyTo : Int, keyTo2 : Int) {
        //var connectedCircles : [SKShapeNode] = [SKShapeNode]()
        let fromCircle = otherCircles[keyFrom]
        let toCircle = otherCircles[keyTo]
        let toCircle2 = otherCircles[keyTo2]
        
        var springJoint = SKPhysicsJointSpring.jointWithBodyA(fromCircle.physicsBody, bodyB: toCircle.physicsBody, anchorA: fromCircle.position, anchorB: toCircle.position)
        var springJoint2 = SKPhysicsJointSpring.jointWithBodyA(fromCircle.physicsBody, bodyB: toCircle2.physicsBody, anchorA: fromCircle.position, anchorB: toCircle2.position)
        springJoint.frequency = 100
        springJoint2.frequency = 100
        self.physicsWorld.addJoint(springJoint)
        self.physicsWorld.addJoint(springJoint2)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for(var x = 0; x < otherCircles.count; x++) {
            otherCircles[x].physicsBody?.affectedByGravity = true
            otherCircles[x].physicsBody?.mass = 1
        }
        if let touch : UITouch = touches.first as? UITouch {
            mainCircle.physicsBody?.affectedByGravity = false
            mainCircle.position.y = (touch.locationInView(self.view).y * -1) + self.frame.height
            mainCircle.position.x = touch.locationInView(self.view).x
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        for(var x = 0; x < otherCircles.count; x++) {
            otherCircles[x].physicsBody?.affectedByGravity = true
            otherCircles[x].physicsBody?.mass = 50
        }
        mainCircle.physicsBody?.affectedByGravity = true
    }
    
    override func update(currentTime: NSTimeInterval) {
        var positions : [CGPoint] = [CGPoint]()
        for(var x = 0; x < otherCircles.count; x++) {
            positions.append(otherCircles[x].position)
        }
        what(rectangle: CGRectSmallestWithCGPoints(pointsArray : positions, numberOfPoints: positions.count))
    }
    
    
    func createGround() {
        //make the character and give it a name
        let ground = SKSpriteNode(color: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1), size: CGSizeMake(self.frame.width * 2, 20))
        ground.name = "ground"
        
        //set the position
        ground.position = CGPointMake(CGRectGetMidX(self.frame), 10)
        ground.zPosition = 1
        
        //set the ground physics body and define its characteristics
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.collisionBitMask = SpriteType.noCollisions.rawValue
        ground.physicsBody?.categoryBitMask = SpriteType.ground.rawValue
        ground.physicsBody?.contactTestBitMask = SpriteType.character.rawValue
        
        self.addChild(ground)
    }
    
    
    func what(#rectangle : CGRect) {
        yourLine.removeFromParent()
        yourLine = SKShapeNode()
        var pathToDraw = CGPathCreateMutable()
        CGPathAddRect(pathToDraw, nil, rectangle)
        yourLine.path = pathToDraw
        yourLine.strokeColor = UIColor.redColor()
        self.addChild(yourLine)
    }
    
    func CGRectSmallestWithCGPoints(#pointsArray : [CGPoint], numberOfPoints : Int) -> CGRect {
        var greatestXValue : CGFloat = pointsArray[0].x
        var greatestYValue : CGFloat = pointsArray[0].y
        var smallestXValue : CGFloat  = pointsArray[0].x
        var smallestYValue : CGFloat  = pointsArray[0].y
    
        for(var i = 1; i < numberOfPoints; i++) {
            var point : CGPoint = pointsArray[i];
            greatestXValue = max(greatestXValue, point.x);
            greatestYValue = max(greatestYValue, point.y);
            smallestXValue = min(smallestXValue, point.x);
            smallestYValue = min(smallestYValue, point.y);
        }
    
        let rect = CGRectMake(smallestXValue, smallestYValue, (greatestXValue - smallestXValue), (greatestYValue - smallestYValue))
        return rect;
    }
}

