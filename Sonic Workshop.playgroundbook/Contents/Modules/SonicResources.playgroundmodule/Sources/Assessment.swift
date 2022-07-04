import Foundation
import PlaygroundSupport
import SPCAssessment
import SPCScene

public class AssessmentManager {
    
    let learningTrails = LearningTrailsProxy()
    let fileFinder = UserModuleFileFinder()
    let mainFile = ContentsChecker(contents: PlaygroundPage.current.text)
    var caveGlitterFile: ContentsChecker
    var crystalsFile: ContentsChecker
    var graphicClusterFile: ContentsChecker
    var graphicLoopsFile: ContentsChecker
    
    public init() {
        caveGlitterFile = ContentsChecker(contents: fileFinder.getContents(ofFile: "CaveGlitter", module: "MyFiles"))
        crystalsFile = ContentsChecker(contents: fileFinder.getContents(ofFile: "Crystals", module: "MyFiles"))
        graphicClusterFile = ContentsChecker(contents: fileFinder.getContents(ofFile: "GraphicCluster", module: "MyFiles"))
        graphicLoopsFile = ContentsChecker(contents: fileFinder.getContents(ofFile: "GraphicLoops", module: "MyFiles"))
    }
    
    public func runAssessmentPage00(scene: Scene) {
        // Sound Crystal
        if learningTrails.currentStep == "firstGraphic" {
            if mainFile.calledFunctions.contains("Graphic") && mainFile.calledFunctions.contains("scene.place") {
                learningTrails.sendMessageOnce("firstGraphic-success")
                learningTrails.setAssessment("firstGraphic", passed: true)
            } else {
                learningTrails.sendMessageOnce("firstGraphic-hint")
            }
        }


        // Playing a Sound
        if learningTrails.currentStep == "firstSound" {
            if mainFile.functionCallCount(containing: "playSound") > 0 {
                learningTrails.sendMessageOnce("firstSound-success")
                learningTrails.setAssessment("firstSound", passed: true)
            } else {
                learningTrails.sendMessageOnce("firstSound-hint")
            }
        }

        // Add Visual Falir
        var step4Passed = false
        var glowCalledStep4 = false
        var shakeCalledStep4 = false
        var scaleCalledStep4 = false
        if mainFile.functionCallCount(containing: "glow") > 0 {
            glowCalledStep4 = true
            learningTrails.setTask("glow", completed: true)
        }

        if mainFile.functionCallCount(containing: "shake") > 0 {
            shakeCalledStep4 = true
            learningTrails.setTask("shake", completed: true)
        }

        if mainFile.variableAccessCount(containing: "scale") > 0 {
            scaleCalledStep4 = true
            learningTrails.setTask("scale", completed: true)
        }

        step4Passed = glowCalledStep4 || shakeCalledStep4 || scaleCalledStep4

        if learningTrails.currentStep == "flair" {
            if step4Passed {
                learningTrails.sendMessageOnce("flair-success")
                learningTrails.setAssessment("flair", passed: true)
            } else {
                learningTrails.sendMessageOnce("flair-hint")
            }
        }


        // Experiment with the Code
        var step5Passed = false
        var moreGraphicsStep5 = false
        var colorGraphicsStep5 = false
        var backgroundMusicChangedStep5 = false
        var backgroundImageChangedStep5 = false

        // TODO: Because we have proxy graphics here, we really don't have access to their properties (like their onTouchHandler... NON IPC would work far better for this.
        // Ideally, we'd check to see if both graphics have an onTouchHandler set.
        if scene.placedGraphics.count > 1 && mainFile.accessedVariables.filter { $0.contains("setOnTouchHandler") }.count > 1 {
            moreGraphicsStep5 = true
            learningTrails.setTask("moreGraphics", completed: true)
        }

        if mainFile.functionCallCount(containing: "setTintColor") > 0 {
            colorGraphicsStep5 = true
            learningTrails.setTask("colorGraphics", completed: true)
        }

        if !mainFile.passedArguments(forCall: "playMusic").contains(".cave") {
            backgroundMusicChangedStep5 = true
            learningTrails.setTask("backgroundMusic", completed: true)
        }

        if scene.backgroundImage != #imageLiteral(resourceName: "caveBackground") {
            backgroundImageChangedStep5 = true
            learningTrails.setTask("backgroundImage", completed: true)
        }

        step5Passed = moreGraphicsStep5 || colorGraphicsStep5 || backgroundMusicChangedStep5 || backgroundImageChangedStep5

        if learningTrails.currentStep == "experiments" {
            if step5Passed {
                learningTrails.sendMessageOnce("experiments-success")
                learningTrails.setAssessment("experiments", passed: true)
            } else {
                learningTrails.sendMessageOnce("experiments-hint")
            }
        }

    }

    public func runAssessmentPage01(scene: Scene) {
        // Create Crystal Function
        if learningTrails.currentStep == "createCrystal" {
            if mainFile.functionCallCount(containing: "createCrystal") > 0 && mainFile.functionCallCount(containing: "place") > 0 && scene.placedGraphics.count > 0 {
                learningTrails.sendMessageOnce("createCrystal-success")
                learningTrails.setAssessment("createCrystal", passed: true)
            } else {
                learningTrails.sendMessageOnce("createCrystal-hint")
            }
        }

        // Make Some Noise
        if learningTrails.currentStep == "makeSomeNoise" {
            if crystalsFile.functionCallCount(containing: "setOnTouchHandler") > 0 || crystalsFile.variableAccessCount(containing: "setOnTouchHandler") > 0 && crystalsFile.functionCallCount(forName: "playSound") > 0 {
                learningTrails.sendMessageOnce("makeSomeNoise-success")
                learningTrails.setAssessment("makeSomeNoise", passed: true)
            } else {
                learningTrails.sendMessageOnce("makeSomeNoise-hint")
            }
        }
        
        if learningTrails.currentStep == "createMoreCrystal" {
            if mainFile.functionCallCount(containing: "createCrystal") > 1 && mainFile.functionCallCount(containing: "place") > 1 && scene.placedGraphics.count > 1 {
                learningTrails.sendMessageOnce("createMoreCrystal-success")
                learningTrails.setAssessment("createMoreCrystal", passed: true)
            } else {
                learningTrails.sendMessageOnce("createMoreCrystal-hint")
            }
        }
        
    }
    
    public func runAssessmentPage02(scene: Scene) {
        // Starting Your Function
        if learningTrails.currentStep == "startingYourFunction" {
            if crystalsFile.customFunctions.count > 1 {
                if mainFile.passedArguments.filter { $0.contains("image") }.count > 0 && scene.placedGraphics.count > 0  {
                    learningTrails.sendMessageOnce("startingYourFunction-success")
                    learningTrails.setAssessment("startingYourFunction", passed: true)
                } else {
                    learningTrails.sendMessageOnce("startingYourFunction-hint2")
                }
               
            } else {
                learningTrails.sendMessageOnce("startingYourFunction-hint1")
            }
        }


        // Add a Touch Moved Handler
        if learningTrails.currentStep == "touchMoved" {
            if crystalsFile.variableAccessCount(containing: "setOnTouchMovedHandler") > 0 {
                if crystalsFile.functionCallCount(containing: "setTintColor") > 0 {
                    learningTrails.sendMessageOnce("touchMoved-success")
                    learningTrails.setAssessment("touchMoved", passed: true)
                } else {
                    learningTrails.sendMessageOnce("touchMoved-hint2")
                }
               
            } else {
                learningTrails.sendMessageOnce("touchMoved-hint1")
            }
        }


        // Add a Touch Handler
        if learningTrails.currentStep == "touchHandler" {
            
            var step4Passed = false
            var step4NotPassed = false
            var addedTouchHandlerStep4 = false
            var playedSoundStep4 = false
            var playedInstrumentStep4 = false
            var playedMusicStep4 = false
            
            var createCrystalTouchHandler = false
            
            if crystalsFile.variablesInFunctionDefinition(named: "createCrystal").contains("setOnTouchHandler") {
                createCrystalTouchHandler = true
            }
            
            if createCrystalTouchHandler {
                if crystalsFile.variableAccessCount(containing: "setOnTouchHandler") > 1 {
                    addedTouchHandlerStep4 = true
                }
            } else {
                if crystalsFile.variableAccessCount(containing: "setOnTouchHandler") > 0 {
                    addedTouchHandlerStep4 = true
                }
            }
            
            let playSoundsCalledInCreateCrystal = crystalsFile.functionCallsInFunctionDefinition(named: "createCrystal").filter { $0.contains("playSound") }.count
            
            if crystalsFile.functionCallCount(forName: "playSound") > playSoundsCalledInCreateCrystal {
                playedSoundStep4 = true
                learningTrails.setTask("playSound", completed: true)
            }
            
            if crystalsFile.functionCallCount(forName: "playInstrument") > 0 {
                playedInstrumentStep4 = true
                learningTrails.setTask("playInstrument", completed: true)
            }
            
            if crystalsFile.functionCallCount(forName: "playMusic") > 0 {
                playedMusicStep4 = true
                learningTrails.setTask("playMusic", completed: true)
            }
            
            step4Passed =  playedSoundStep4 || playedInstrumentStep4 || playedMusicStep4
            
            if addedTouchHandlerStep4 {
                if step4Passed {
                    learningTrails.sendMessageOnce("touchHandler-success")
                    learningTrails.setAssessment("touchHandler", passed: true)
                } else {
                    learningTrails.sendMessageOnce("touchHandler-hint2")
                }
            } else {
                learningTrails.sendMessageOnce("touchHandler-hint1")
            }
        }


        // Looping Sounds
        if learningTrails.currentStep == "loop" {
            if crystalsFile.variableAccessCount(forName: "loop") > 0 && crystalsFile.functionCallCount(containing: "toggle") > 0 {
                learningTrails.sendMessageOnce("loop-success")
                learningTrails.setAssessment("loop", passed: true)
            } else {
                learningTrails.sendMessageOnce("loop-hint")
                
            }
        }

        // Add Visual Flair
        if learningTrails.currentStep == "moreFlair" {
            var step6Passed = false
            var glowCalledStep6 = false
            var shakeCalledStep6 = false
            var scaleCalledStep6 = false
            
            let glowsCalledInCreateCrystal = crystalsFile.functionCallsInFunctionDefinition(named: "createCrystal").filter { $0.contains("glow") }.count
            
            if crystalsFile.functionCallCount(containing: "glow") > glowsCalledInCreateCrystal {
                glowCalledStep6 = true
                learningTrails.setTask("flairGlow", completed: true)
            }
            
            if crystalsFile.functionCallCount(containing: "shake") > 0 {
                shakeCalledStep6 = true
                learningTrails.setTask("flairShake", completed: true)
            }
            
            if crystalsFile.variableAccessCount(containing: "scale") > 0 {
                scaleCalledStep6 = true
                learningTrails.setTask("flairScale", completed: true)
            }
            
            step6Passed = glowCalledStep6 || shakeCalledStep6 || scaleCalledStep6
            
            if step6Passed {
                learningTrails.sendMessageOnce("moreFlair-success")
                learningTrails.setAssessment("moreFlair", passed: true)
            } else {
                learningTrails.sendMessageOnce("moreFlair-hint")
            }
        }
    }
    
    public func runAssessmentPage03(scene: Scene) {
        // Cave Glitter
        if learningTrails.currentStep == "caveGlitter" {
            if mainFile.functionCallCount(forName: "addCaveGlitter") > 0 {
                learningTrails.sendMessageOnce("caveGlitter-success")
                learningTrails.setAssessment("caveGlitter", passed: true)
            } else {
                learningTrails.sendMessageOnce("caveGlitter-hint")
            }
        }

        // Graphic Cluster
        if learningTrails.currentStep == "graphicCluster" {
            if mainFile.functionCallCount(forName: "addGraphicCluster") > 0 {
                learningTrails.sendMessageOnce("graphicCluster-success")
                learningTrails.setAssessment("graphicCluster", passed: true)
            } else {
                learningTrails.sendMessageOnce("graphicCluster-hint")
            }
        }


        // Graphic Loops
        if learningTrails.currentStep == "graphicLoops" {
            if mainFile.functionCallCount(forName: "addGraphicLoops") > 0 {
                learningTrails.sendMessageOnce("graphicLoops-success")
                learningTrails.setAssessment("graphicLoops", passed: true)
            } else {
                learningTrails.sendMessageOnce("graphicLoops-hint")
            }
        }


        // Add Tones
        if learningTrails.currentStep == "addTones" {
            if mainFile.functionCallCount(forName: "addTones") > 0 {
                learningTrails.sendMessageOnce("addTones-success")
                learningTrails.setAssessment("addTones", passed: true)
            } else {
                learningTrails.sendMessageOnce("addTones-hint")
            }
        }
    }
    
    
}
