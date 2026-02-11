import Vision
import Combine

class SignLanguageRecognizer: ObservableObject {
    @Published var recognizedText: String = ""
    @Published var currentGesture: String = ""
    @Published var confidence: Float = 0.0
    @Published var isActive: Bool = false
    @Published var translatedSentence: String = ""

    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    private var frameCount = 0
    private let processEveryNFrames = 3
    private var lastRecognizedSign: String = ""
    private var signStabilityCount: Int = 0
    private let requiredStableFrames = 4
    private var lastSignTime: Date = .distantPast
    private let minSignInterval: TimeInterval = 1.2

    func process(buffer: CVPixelBuffer) {
        guard isActive else {
            DispatchQueue.main.async {
                if !self.recognizedText.isEmpty || self.confidence != 0.0 ||
                   !self.currentGesture.isEmpty || !self.translatedSentence.isEmpty {
                    self.recognizedText = ""
                    self.currentGesture = ""
                    self.confidence = 0.0
                    self.translatedSentence = ""
                }
            }
            return
        }

        frameCount += 1
        guard frameCount % processEveryNFrames == 0 else { return }

        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up, options: [:])

        do {
            try handler.perform([handPoseRequest])

            let results = handPoseRequest.results ?? []

            if results.isEmpty {
                DispatchQueue.main.async {
                    self.currentGesture = "Waiting for hand..."
                    if !self.recognizedText.isEmpty {
                        self.recognizedText = ""
                    }
                    self.confidence = 0
                }
                return
            }

            let gesture = analyzeGesture(observations: results)
            let (sign, conf) = gesture

            DispatchQueue.main.async {
                self.currentGesture = sign.isEmpty ? "Hand detected — try a sign" : sign
                self.confidence = conf

                if !sign.isEmpty {
                    if sign == self.lastRecognizedSign {
                        self.signStabilityCount += 1
                        if self.signStabilityCount >= self.requiredStableFrames {
                            let now = Date()
                            if now.timeIntervalSince(self.lastSignTime) >= self.minSignInterval {
                                self.appendToSentence(sign)
                                self.lastSignTime = now
                            }
                        }
                    } else {
                        self.lastRecognizedSign = sign
                        self.signStabilityCount = 1
                    }
                } else {
                    self.lastRecognizedSign = ""
                    self.signStabilityCount = 0
                }
            }
        } catch {
            print("Vision request failed: \(error.localizedDescription)")
        }
    }

    func appendToSentence(_ sign: String) {
        let trimmed = sign.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        if translatedSentence.isEmpty {
            translatedSentence = trimmed
        } else {
            translatedSentence += " " + trimmed
        }
        recognizedText = translatedSentence
    }

    func clearSentence() {
        translatedSentence = ""
        recognizedText = ""
        lastRecognizedSign = ""
        signStabilityCount = 0
    }

    private func analyzeGesture(observations: [VNHumanHandPoseObservation]) -> (String, Float) {
        let minConfidence: Float = 0.25

        for observation in observations {
            guard observation.confidence > minConfidence else { continue }

            let sign = matchGesture(observation: observation)
            if !sign.isEmpty {
                return (sign, observation.confidence)
            }
        }

        if observations.count == 2 {
            let sign = matchTwoHandGesture(left: observations[0], right: observations[1])
            if !sign.isEmpty {
                return (sign, max(observations[0].confidence, observations[1].confidence))
            }
        }

        return ("", 0)
    }

    private func matchGesture(observation: VNHumanHandPoseObservation) -> String {
        guard let thumbTip = try? observation.recognizedPoint(.thumbTip),
              let indexTip = try? observation.recognizedPoint(.indexTip),
              let middleTip = try? observation.recognizedPoint(.middleTip),
              let ringTip = try? observation.recognizedPoint(.ringTip),
              let littleTip = try? observation.recognizedPoint(.littleTip),
              let wrist = try? observation.recognizedPoint(.wrist),
              let thumbIP = try? observation.recognizedPoint(.thumbIP),
              let indexPIP = try? observation.recognizedPoint(.indexPIP),
              let middlePIP = try? observation.recognizedPoint(.middlePIP) else {
            return ""
        }

        let minConf: Float = 0.2
        guard thumbTip.confidence > minConf, indexTip.confidence > minConf else { return "" }

        let tips = [thumbTip, indexTip, middleTip, ringTip, littleTip]
        let extendedCount = countExtendedFingers(tips: tips, wrist: wrist)

        let handCenterY = (wrist.y + indexTip.y) / 2
        let handCenterX = (wrist.x + indexTip.x) / 2

        let thumbExtended = thumbTip.y > thumbIP.y - 0.05
        let indexExtended = indexTip.y > indexPIP.y - 0.05
        let middleExtended = middleTip.y > middlePIP.y - 0.05

        let thumbToIndex = hypot(Float(thumbTip.x - indexTip.x), Float(thumbTip.y - indexTip.y))
        let indexToMiddle = hypot(Float(indexTip.x - middleTip.x), Float(indexTip.y - middleTip.y))
        let handOpenness = max(thumbToIndex, indexToMiddle)

        if handCenterY > 0.7 && extendedCount >= 4 && handOpenness > 0.15 {
            return "Hello"
        }

        if handCenterY > 0.55 && handCenterY < 0.85 && handCenterX > 0.35 && handCenterX < 0.65 {
            if extendedCount >= 4 && thumbExtended {
                return "Thank You"
            }
        }

        if !indexExtended && middleExtended && thumbExtended && extendedCount <= 2 {
            if handCenterY < 0.6 && thumbToIndex < 0.2 {
                return "Dog"
            }
        }

        if extendedCount >= 4 && handCenterY > 0.5 {
            if middleExtended && ringTip.y > middleTip.y - 0.08 {
                return "Tree"
            }
        }

        // Help: thumb up (common simplified gesture)
        if handCenterY > 0.4 && handCenterY < 0.75 && thumbExtended && !indexExtended &&
           extendedCount <= 2 {
            return "Help"
        }

        // Happy: open hand at chest level
        if handCenterY > 0.35 && handCenterY < 0.7 && extendedCount >= 4 {
            return "Happy"
        }

        // Hospital: two fingers (index+middle) extended, hand lower
        if handCenterY < 0.6 && extendedCount == 2 && indexExtended && middleExtended {
            return "Hospital"
        }

        return ""
    }

    private func matchTwoHandGesture(left: VNHumanHandPoseObservation, right: VNHumanHandPoseObservation) -> String {
        guard let lWrist = try? left.recognizedPoint(.wrist),
              let rWrist = try? right.recognizedPoint(.wrist),
              let lIndex = try? left.recognizedPoint(.indexTip),
              let rIndex = try? right.recognizedPoint(.indexTip),
              let lMiddle = try? left.recognizedPoint(.middleTip),
              let rMiddle = try? right.recognizedPoint(.middleTip) else {
            return ""
        }

        let leftY = (lWrist.y + lIndex.y) / 2
        let rightY = (rWrist.y + rIndex.y) / 2

        if leftY > 0.4 && rightY > 0.4 {
            let lExtended = countExtendedFingersLeft(left)
            let rExtended = countExtendedFingersLeft(right)
            if lExtended >= 4 && rExtended >= 4 {
                return "Happy"
            }
        }

        return ""
    }

    private func countExtendedFingers(tips: [VNRecognizedPoint], wrist: VNRecognizedPoint) -> Int {
        var count = 0
        for tip in tips {
            if tip.y > wrist.y + 0.05 || tip.x > wrist.x + 0.05 ||
               abs(tip.y - wrist.y) > 0.03 {
                count += 1
            }
        }
        return count
    }

    private func countExtendedFingersLeft(_ obs: VNHumanHandPoseObservation) -> Int {
        guard let wrist = try? obs.recognizedPoint(.wrist),
              let thumb = try? obs.recognizedPoint(.thumbTip),
              let index = try? obs.recognizedPoint(.indexTip),
              let middle = try? obs.recognizedPoint(.middleTip),
              let ring = try? obs.recognizedPoint(.ringTip),
              let little = try? obs.recognizedPoint(.littleTip) else { return 0 }
        return countExtendedFingers(tips: [thumb, index, middle, ring, little], wrist: wrist)
    }

    private func hypot(_ x: Float, _ y: Float) -> Float {
        sqrt(x * x + y * y)
    }
}

private extension VNRecognizedPoint {
    func isConfident(_ min: Float) -> Bool {
        confidence > min
    }
}
