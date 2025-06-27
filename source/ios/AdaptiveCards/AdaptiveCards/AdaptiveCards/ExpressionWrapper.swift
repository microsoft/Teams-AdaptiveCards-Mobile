//
//  ExpressionWrapper.swift
//  AdaptiveCards
//
//  Created by karthikeyan gopal on 6/25/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

import Foundation

@objc public class ExpressionWrapper: NSObject {
    private var expression: Expression?

    @objc public init(expressionString: String, error: NSErrorPointer) {
        do {
            self.expression = try Expression(expressionString)
        } catch let err as NSError {
            error?.pointee = err
        }
    }

    /// Objective-C friendly async call with completion handler
    @objc public func evaluateWithContext(_ context: EvaluationContext?,
                                          completion: @escaping (EvaluationResult?, NSError?) -> Void) {
        Task {
            do {
                guard let expression = self.expression else {
                    completion(nil, NSError(domain: "ExpressionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Expression is nil"]))
                    return
                }
                let result = try await expression.evaluate(context: context)
                completion(result, nil)
            } catch let error as NSError {
                completion(nil, error)
            }
        }
    }
}

