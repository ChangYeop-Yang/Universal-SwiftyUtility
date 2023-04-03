// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

/*
 * Copyright (c) 2023 Universal SystemKit. All rights reserved.
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
import PackageDescription

let package = Package(
    // The name of the Swift package.
    name: InfoPackage.PackageName,
    // The list of minimum versions for platforms supported by the package.
    platforms: [
        // macOS 10.13 (High Sierra) 이상의 운영체제부터 사용이 가능합니다.
        .macOS(SupportedPlatform.MacOSVersion.v10_13),
        
        // iOS 11 이상의 운영체제부터 사용이 가능합니다.
        .iOS(SupportedPlatform.IOSVersion.v11),
    ],
    // Products define the executables and libraries a package produces, and make them visiopble to other packages.
    products: [
        .library(name: InfoPackage.PackageName, targets: [InfoPackage.PackageName]),
    ],
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    dependencies: [
        .package(url: RemotePackage.SwiftLog.path, RemotePackage.SwiftLog.from),
    ],
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    targets: [
        .target(name: InfoPackage.PackageName, dependencies: [RemotePackage.SwiftLog.product], path: InfoPackage.PackagePath),
    ],
    // The list of Swift versions with which this package is compatible.
    swiftLanguageVersions: [.v5]
)

#if swift(>=5.6)
// Add the documentation compiler plugin if possible
package.dependencies.append(
    .package(url: RemotePackage.SwiftDocC.path, RemotePackage.SwiftDocC.from)
)
#endif

// MARK: - Struct
public struct InfoPackage {
    
    public static let PackagePlatform: Array<Platform> = [.iOS, .macOS]
    
    public static let PackageName: String = "SwiftyUtility"
    
    public static let PackagePath: String = "Sources"
}

// MARK: - Protocol
public protocol PackageProtocol {

    var name: String { get }
    var path: String { get }
    
    // A version according to the semantic versioning specification.
    var from: Range<Version> { get }
   
    // The different types of a target's dependency on another entity.
    var product: Target.Dependency { get }
}

// MARK: - Enum
public enum RemotePackage: String, CaseIterable, PackageProtocol {

    /// [SwiftLog - GitHub](https://github.com/apple/swift-log)
    case SwiftLog = "swift-log"
    
    /// [swift-docc-plugin - GitHub](https://github.com/apple/swift-docc-plugin)
    case SwiftDocC = "SwiftDocCPlugin"
    
    public var path: String {
        switch self {
        case .SwiftLog:
            return "https://github.com/apple/swift-log.git"
        case .SwiftDocC:
            return "https://github.com/apple/swift-docc-plugin.git"
        }
    }
    
    public var from: Range<Version> {
        switch self {
        case .SwiftLog:
            return .upToNextMajor(from: "1.0.0")
        case .SwiftDocC:
            return .upToNextMajor(from: "1.1.0")
        }
    }
    
    public var product: Target.Dependency {
        switch self {
        case .SwiftLog:
            let condition = TargetDependencyCondition.when(platforms: InfoPackage.PackagePlatform)
            return .product(name: "Logging", package: self.name, condition: condition)
        case .SwiftDocC:
            let condition = TargetDependencyCondition.when(platforms: InfoPackage.PackagePlatform)
            return .product(name: self.name, package: self.name, condition: condition)
        }
    }
    
    public var name: String { return self.rawValue }
}
