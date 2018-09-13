//
// FacialEmotions.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class FacialEmotionsInput : MLFeatureProvider {
    
    /// outerBrowRaiser as double value
    var outerBrowRaiser: Double
    
    /// browLowerer as double value
    var browLowerer: Double
    
    /// upperLidRaiser as double value
    var upperLidRaiser: Double
    
    /// cheekRaiser as double value
    var cheekRaiser: Double
    
    /// lidTightener as double value
    var lidTightener: Double
    
    /// NoseWrinkler as double value
    var NoseWrinkler: Double
    
    /// lipCornerPuller as double value
    var lipCornerPuller: Double
    
    /// dimpler as double value
    var dimpler: Double
    
    /// lipCornerDeppresser as double value
    var lipCornerDeppresser: Double
    
    /// lowerLipDeppresser as double value
    var lowerLipDeppresser: Double
    
    /// lipStretcher as double value
    var lipStretcher: Double
    
    /// lipTightener as double value
    var lipTightener: Double
    
    /// jawDrop as double value
    var jawDrop: Double
    
    var featureNames: Set<String> {
        get {
            return ["outerBrowRaiser", "browLowerer", "upperLidRaiser", "cheekRaiser", "lidTightener", "NoseWrinkler", "lipCornerPuller", "dimpler", "lipCornerDeppresser", "lowerLipDeppresser", "lipStretcher", "lipTightener", "jawDrop"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "outerBrowRaiser") {
            return MLFeatureValue(double: outerBrowRaiser)
        }
        if (featureName == "browLowerer") {
            return MLFeatureValue(double: browLowerer)
        }
        if (featureName == "upperLidRaiser") {
            return MLFeatureValue(double: upperLidRaiser)
        }
        if (featureName == "cheekRaiser") {
            return MLFeatureValue(double: cheekRaiser)
        }
        if (featureName == "lidTightener") {
            return MLFeatureValue(double: lidTightener)
        }
        if (featureName == "NoseWrinkler") {
            return MLFeatureValue(double: NoseWrinkler)
        }
        if (featureName == "lipCornerPuller") {
            return MLFeatureValue(double: lipCornerPuller)
        }
        if (featureName == "dimpler") {
            return MLFeatureValue(double: dimpler)
        }
        if (featureName == "lipCornerDeppresser") {
            return MLFeatureValue(double: lipCornerDeppresser)
        }
        if (featureName == "lowerLipDeppresser") {
            return MLFeatureValue(double: lowerLipDeppresser)
        }
        if (featureName == "lipStretcher") {
            return MLFeatureValue(double: lipStretcher)
        }
        if (featureName == "lipTightener") {
            return MLFeatureValue(double: lipTightener)
        }
        if (featureName == "jawDrop") {
            return MLFeatureValue(double: jawDrop)
        }
        return nil
    }
    
    init(outerBrowRaiser: Double, browLowerer: Double, upperLidRaiser: Double, cheekRaiser: Double, lidTightener: Double, NoseWrinkler: Double, lipCornerPuller: Double, dimpler: Double, lipCornerDeppresser: Double, lowerLipDeppresser: Double, lipStretcher: Double, lipTightener: Double, jawDrop: Double) {
        self.outerBrowRaiser = outerBrowRaiser
        self.browLowerer = browLowerer
        self.upperLidRaiser = upperLidRaiser
        self.cheekRaiser = cheekRaiser
        self.lidTightener = lidTightener
        self.NoseWrinkler = NoseWrinkler
        self.lipCornerPuller = lipCornerPuller
        self.dimpler = dimpler
        self.lipCornerDeppresser = lipCornerDeppresser
        self.lowerLipDeppresser = lowerLipDeppresser
        self.lipStretcher = lipStretcher
        self.lipTightener = lipTightener
        self.jawDrop = jawDrop
    }
}


/// Model Prediction Output Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class FacialEmotionsOutput : MLFeatureProvider {
    
    /// Predicted emotion as integer value
    let emotions: Int64
    
    var featureNames: Set<String> {
        get {
            return ["emotions"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "emotions") {
            return MLFeatureValue(int64: emotions)
        }
        return nil
    }
    
    init(emotions: Int64) {
        self.emotions = emotions
    }
}


/// Class for model loading and prediction
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class FacialEmotions {
    var model: MLModel
    
    /**
     Construct a model with explicit path to mlmodel file
     - parameters:
     - url: the file url of the model
     - throws: an NSError object that describes the problem
     */
    init(contentsOf url: URL) throws {
        self.model = try MLModel(contentsOf: url)
    }
    
    /// Construct a model that automatically loads the model from the app's bundle
    convenience init() {
        let bundle = Bundle(for: FacialEmotions.self)
        let assetPath = bundle.url(forResource: "FacialEmotions", withExtension:"mlmodelc")
        try! self.init(contentsOf: assetPath!)
    }
    
    convenience init(path: URL) {
        try! self.init(contentsOf: path)
    }
    /**
     Make a prediction using the structured interface
     - parameters:
     - input: the input to the prediction as FacialEmotionsInput
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as FacialEmotionsOutput
     */
    func prediction(input: FacialEmotionsInput) throws -> FacialEmotionsOutput {
        let outFeatures = try model.prediction(from: input)
        let result = FacialEmotionsOutput(emotions: outFeatures.featureValue(for: "emotions")!.int64Value)
        return result
    }
    
    /**
     Make a prediction using the convenience interface
     - parameters:
     - outerBrowRaiser as double value
     - browLowerer as double value
     - upperLidRaiser as double value
     - cheekRaiser as double value
     - lidTightener as double value
     - NoseWrinkler as double value
     - lipCornerPuller as double value
     - dimpler as double value
     - lipCornerDeppresser as double value
     - lowerLipDeppresser as double value
     - lipStretcher as double value
     - lipTightener as double value
     - jawDrop as double value
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as FacialEmotionsOutput
     */
    func prediction(outerBrowRaiser: Double, browLowerer: Double, upperLidRaiser: Double, cheekRaiser: Double, lidTightener: Double, NoseWrinkler: Double, lipCornerPuller: Double, dimpler: Double, lipCornerDeppresser: Double, lowerLipDeppresser: Double, lipStretcher: Double, lipTightener: Double, jawDrop: Double) throws -> FacialEmotionsOutput {
        let input_ = FacialEmotionsInput(outerBrowRaiser: outerBrowRaiser, browLowerer: browLowerer, upperLidRaiser: upperLidRaiser, cheekRaiser: cheekRaiser, lidTightener: lidTightener, NoseWrinkler: NoseWrinkler, lipCornerPuller: lipCornerPuller, dimpler: dimpler, lipCornerDeppresser: lipCornerDeppresser, lowerLipDeppresser: lowerLipDeppresser, lipStretcher: lipStretcher, lipTightener: lipTightener, jawDrop: jawDrop)
        return try self.prediction(input: input_)
    }
}

