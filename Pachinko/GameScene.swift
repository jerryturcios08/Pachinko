//
//  GameScene.swift
//  Pachinko
//
//  Created by Jerry Turcios on 1/14/20.
//  Copyright © 2020 Jerry Turcios. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var editLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var ballAmountLabel: SKLabelNode!
    var heightLimit: SKSpriteNode!
    var resetButton: UIButton!

    let availableBalls = [
        "ballBlue", "ballCyan", "ballGreen",
        "ballGrey", "ballPurple", "ballRed",
        "ballYellow"
    ]

    var editingMode = true {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    var numberOfBallsLeft = 5 {
        didSet {
            ballAmountLabel.text = "Balls left: \(numberOfBallsLeft)"
        }
    }

    var ballIsActive = false

    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -2
        addChild(background)

        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)

        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Done"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)

        resetButton = UIButton()
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setTitle("Reset", for: .normal)
        resetButton.titleLabel?.font = UIFont(name: "Chalkduster", size: 30)
        resetButton.addTarget(self, action: #selector(resetGame), for: .touchUpInside)
        view.addSubview(resetButton)

        NSLayoutConstraint.activate([
            resetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 225),
            resetButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 35)
        ])

        ballAmountLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballAmountLabel.text = "Balls left: 5"
        ballAmountLabel.position = CGPoint(x: 500, y: 700)
        addChild(ballAmountLabel)

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self

        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)

        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))

        let heightLimitLabel = SKLabelNode(text: "Balls are placed above this line")
        heightLimitLabel.fontSize = 40
        heightLimitLabel.zPosition = -1
        heightLimitLabel.position = CGPoint(x: 500, y: 620)
        addChild(heightLimitLabel)

        heightLimit = SKSpriteNode(
            color: UIColor(red: 0, green: 1, blue: 0, alpha: 0.2),
            size: CGSize(width: 2000, height: 10)
        )

        heightLimit.zPosition = -1
        heightLimit.position = CGPoint(x: 500, y: 600)
        addChild(heightLimit)
    }

    @objc func resetGame() {
        numberOfBallsLeft = 5
        score = 0
        editingMode = true

        // FIXME: Decide to keep or destroy all of boxes before a new game
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        let objects = nodes(at: location)

        if objects.contains(editLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                if location.y <= 590 {
                    let size = CGSize(width: Int.random(in: 16...128), height: 16)
                    let box = SKSpriteNode(
                        color: UIColor(
                            red: CGFloat.random(in: 0...1),
                            green: CGFloat.random(in: 0...1),
                            blue: CGFloat.random(in: 0...1),
                            alpha: 1
                        ),
                        size: size
                    )

                    box.zRotation = CGFloat.random(in: 0...3)
                    box.position = location
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody?.isDynamic = false
                    box.name = "box"

                    addChild(box)
                }
            } else if !editingMode && numberOfBallsLeft > 0 && !ballIsActive {
                if location.y >= 610 {
                    let ball = SKSpriteNode(imageNamed: availableBalls.randomElement()!)

                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                    ball.physicsBody?.restitution = 0.4
                    ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                    ball.position = location
                    ball.name = "ball"

                    ballIsActive.toggle()

                    addChild(ball)
                }
            }
        }
    }

    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")

        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false

        addChild(bouncer)
    }

    func makeSlot(at position: CGPoint, isGood: Bool) {
        let slotBase: SKSpriteNode
        let slotGlow: SKSpriteNode

        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }

        slotBase.position = position
        slotGlow.position = position

        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false

        addChild(slotBase)
        addChild(slotGlow)

        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }

    func collision(between ball: SKNode, and object: SKNode) {
        if object.name == "good" {
            destroy(item: ball)

            score += 1
            numberOfBallsLeft += 1
            ballIsActive.toggle()
        } else if object.name == "bad" {
            destroy(item: ball)

            score -= 1
            numberOfBallsLeft -= 1
            ballIsActive.toggle()
        } else if object.name == "box" {
            destroy(item: object)
        }
    }

    func destroy(item: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = item.position
            addChild(fireParticles)
        }

        item.removeFromParent()
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        if nodeA.name == "ball" {
            // If ball hits slot
            collision(between: nodeA, and: nodeB)
        } else if nodeA.name == "box" {
            // If ball hits box
            collision(between: nodeB, and: nodeA)
        } else if nodeB.name == "ball" {
            // If slot hits ball
            collision(between: nodeB, and: nodeA)
        }
    }
}
