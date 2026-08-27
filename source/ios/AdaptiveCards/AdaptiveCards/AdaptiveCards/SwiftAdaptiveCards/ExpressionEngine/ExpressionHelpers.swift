// MARK: - Objective-C Bridge
//
//  ExpressionHelpers.swift
//  AdaptiveCards
//
//  Created by Rahul Pinjani on 8/12/25.
//

import Foundation

// MARK: - Objective-C Bridge Implementation

@objc public class ObjCExpressionEvaluator: NSObject {

    @objc public static let shared = ObjCExpressionEvaluator()

    private let engine: ExpressionEngineProtocol
    private var expressionEvalEnabled = false
    private var hostFunctions: [FunctionDeclaration] = []

    // Private initializer prevents external instantiation
    private override init() {
        self.engine = ExpressionEngine()
        super.init()
    }

    // MARK: - Configuration

    @objc public static func setExpressionEvalEnabled(_ isEnabled: Bool) {
        shared.expressionEvalEnabled = isEnabled
    }

    @objc public static func isExpressionEvalEnabled() -> Bool {
        return shared.expressionEvalEnabled
    }

    // MARK: - Host Function Registration

    /// Register a host-provided function that expressions can call.
    /// Registered functions are available to all subsequent expression evaluations.
    public static func registerHostFunction(_ declaration: FunctionDeclaration) {
        shared.hostFunctions.removeAll { $0.name == declaration.name }
        shared.hostFunctions.append(declaration)
    }

    /// Register multiple host-provided functions.
    public static func registerHostFunctions(_ declarations: [FunctionDeclaration]) {
        for declaration in declarations {
            shared.hostFunctions.removeAll { $0.name == declaration.name }
            shared.hostFunctions.append(declaration)
        }
    }

    /// Remove all registered host functions.
    @objc public static func removeAllHostFunctions() {
        shared.hostFunctions.removeAll()
    }

    // Static convenience method for backward compatibility
    @objc public static func evaluateExpression(_ expressionString: String, withData data: NSDictionary? = nil, completion: @escaping (NSObject?, NSError?) -> Void) {
        shared.evaluateExpression(expressionString, withData: data, completion: completion)
    }

    /// Instance method for evaluating expressions
    @objc public func evaluateExpression(_ expressionString: String, withData data: NSDictionary? = nil, completion: @escaping (NSObject?, NSError?) -> Void) {

        Task {
            do {
                let expr = try engine.createExpression(expressionString, allowAssignment: false)

                let functions = self.hostFunctions

                let config = EvaluationContextConfig(
                    root: data as? [String: Any],
                    functions: functions
                )
                let context = await EvaluationContext(config: config)

                let result = await expr.evaluateResult(context: context)

                switch result {
                case .success(let value):
                    if let nsObj = value as? NSObject {
                        completion(nsObj, nil)
                    } else if let str = value as? String {
                        completion(str as NSString, nil)
                    } else if let num = value as? NSNumber {
                        completion(num, nil)
                    } else if let arr = value as? [Any] {
                        completion(arr as NSArray, nil)
                    } else if let dict = value as? [String: Any] {
                        completion(dict as NSDictionary, nil)
                    } else if let val = value {
                        completion(String(describing: val) as NSString, nil)
                    } else {
                        completion(nil, nil)
                    }
                case .failure(let error):
                    completion(nil, error as NSError)
                }
            } catch let error as NSError {
                completion(nil, error)
            } catch {
                let nsError = NSError(domain: "ObjCExpressionEvaluator", code: -1, userInfo: [NSLocalizedDescriptionKey: String(describing: error)])
                completion(nil, nsError)
            }
        }
    }
}
