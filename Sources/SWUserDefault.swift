/*
 * Copyright (c) 2023 Universal-SwiftyUtility. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

// swiftlint:disable all
#if os(iOS) || os(macOS)
import Foundation

@propertyWrapper
public struct SWUserDefault<Value> {
    
    public static let label: String = "com.SwiftyUtility.SWUserDefault"
    public static let identifier: String = "F83F639D-DC65-414D-A69C-0EC829DE53A1"
    
    // MARK: - Struct Properties
    private let forKey: String
    private let defaultValue: Optional<Value>
    
    // Property Wrapper 필수 구현 Property
    public var wrappedValue: Optional<Value> {
        get { UserDefaults.standard.object(forKey: self.forKey) as? Value ?? self.defaultValue }
        set { UserDefaults.standard.setValue(newValue, forKey: self.forKey) }
    }
    
    // MARK: - Initalize
    public init(forKey: String, defaultValue: Optional<Value> = nil) {
        
        #if DEBUG
            NSLog("[%@][%@] Initalize", SWUserDefault.label, SWUserDefault.identifier)
        #endif
        
        self.forKey = forKey
        self.defaultValue = defaultValue
    }
}
#endif
