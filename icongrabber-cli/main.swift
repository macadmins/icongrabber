//
//  main.swift
//  icongrabber-cli
//
//  Copyright 2025 Kitzy
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import AppKit

// MARK: - CLI Argument Parser

struct CLIArguments {
    var inputPath: String?
    var outputPath: String?
    var size: Int = 512
    var sizeExplicitlySet: Bool = false  // Track if user explicitly set the size
    var maxFileSize: Int? = nil  // Maximum file size in KB
    var force: Bool = false
    var help: Bool = false
    var version: Bool = false
}

func parseArguments() -> CLIArguments {
    var args = CLIArguments()
    let arguments = CommandLine.arguments
    
    var i = 1
    while i < arguments.count {
        let arg = arguments[i]
        
        switch arg {
        case "-h", "--help":
            args.help = true
        case "-v", "--version":
            args.version = true
        case "-f", "--force":
            args.force = true
        case "-i", "--input":
            i += 1
            if i < arguments.count {
                args.inputPath = arguments[i]
            }
        case "-o", "--output":
            i += 1
            if i < arguments.count {
                args.outputPath = arguments[i]
            }
        case "-s", "--size":
            i += 1
            if i < arguments.count, let size = Int(arguments[i]) {
                args.size = size
                args.sizeExplicitlySet = true
            }
        case "-m", "--max-file-size":
            i += 1
            if i < arguments.count, let maxSize = parseFileSize(arguments[i]) {
                args.maxFileSize = maxSize
            }
        default:
            // Treat as input path if no input specified yet
            if args.inputPath == nil {
                args.inputPath = arg
            }
        }
        i += 1
    }
    
    return args
}

func parseFileSize(_ input: String) -> Int? {
    let trimmed = input.trimmingCharacters(in: .whitespaces).uppercased()
    
    // Extract numeric part and unit part
    var numericString = ""
    var unit = ""
    
    for char in trimmed {
        if char.isNumber || char == "." {
            numericString.append(char)
        } else if char.isLetter {
            unit.append(char)
        }
    }
    
    // Parse the numeric value
    guard let value = Double(numericString), value > 0 else {
        return nil
    }
    
    // Convert to KB based on unit
    let sizeInKB: Int
    switch unit {
    case "MB", "M":
        sizeInKB = Int(value * 1024)
    case "KB", "K", "":
        // Default to KB if no unit specified
        sizeInKB = Int(value)
    default:
        return nil
    }
    
    return sizeInKB
}

func selectOptimalSize(for maxFileSizeKB: Int) -> Int {
    // Select an appropriate icon size based on target file size
    // These are rough estimates based on typical PNG compression
    if maxFileSizeKB >= 2048 {  // >= 2MB
        return 1024
    } else if maxFileSizeKB >= 1024 {  // >= 1MB
        return 512
    } else if maxFileSizeKB >= 512 {  // >= 512KB
        return 512
    } else if maxFileSizeKB >= 256 {  // >= 256KB
        return 256
    } else if maxFileSizeKB >= 128 {  // >= 128KB
        return 256
    } else if maxFileSizeKB >= 64 {   // >= 64KB
        return 128
    } else if maxFileSizeKB >= 32 {   // >= 32KB
        return 128
    } else if maxFileSizeKB >= 16 {   // >= 16KB
        return 64
    } else {  // < 16KB
        return 32
    }
}

// MARK: - CLI Output

func printHelp() {
    print("""
    Icon Grabber CLI - Extract icons from macOS applications
    
    USAGE:
        icongrabber [OPTIONS] <input-app-path>
    
    ARGUMENTS:
        <input-app-path>    Path to the .app file (e.g., /Applications/Safari.app)
    
    OPTIONS:
        -i, --input <path>      Input application path (alternative to positional arg)
        -o, --output <path>     Output file path (default: <AppName>.png)
        -s, --size <pixels>     Icon size in pixels (default: 512)
                                Common sizes: 16, 32, 64, 128, 256, 512, 1024
        -m, --max-file-size <size>   Maximum file size (uses sips to optimize)
                                Formats: 100KB, 100K, 2MB, 2M (case-insensitive)
                                Example: -m 100KB or -m 2M
        -f, --force            Overwrite existing files without prompting
        -h, --help             Show this help message
        -v, --version          Show version information
    
    EXAMPLES:
        # Extract Safari icon at 512x512 (creates Safari.png)
        icongrabber /Applications/Safari.app
        
        # Extract to specific location with custom size
        icongrabber -i /Applications/Safari.app -o ~/Desktop/Safari.png -s 256
        
        # Extract and optimize to be under 100KB
        icongrabber /Applications/Safari.app -m 100KB
        
        # Extract and optimize to be under 2MB
        icongrabber /Applications/Safari.app -m 2M
        
        # Overwrite existing file without prompting
        icongrabber /Applications/Safari.app -f
        
        # Extract multiple sizes
        icongrabber /Applications/Safari.app -s 128 -o safari_small.png
        icongrabber /Applications/Safari.app -s 512 -o safari_large.png
    
    EXIT CODES:
        0    Success
        1    General error
        2    Invalid arguments
        3    Icon extraction failed
    """)
}

func printVersion() {
    print("Icon Grabber CLI version 1.0.0")
}

// MARK: - Icon Extraction (CLI Version)

enum CLIError: Error, LocalizedError {
    case invalidApp(String)
    case iconNotFound(String)
    case exportFailed(String)
    case invalidArguments(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidApp(let path):
            return "Invalid application: \(path)"
        case .iconNotFound(let path):
            return "Could not find icon for: \(path)"
        case .exportFailed(let reason):
            return "Export failed: \(reason)"
        case .invalidArguments(let reason):
            return "Invalid arguments: \(reason)"
        }
    }
}

func extractIcon(from appPath: String, size: Int) throws -> NSImage {
    let url = URL(fileURLWithPath: appPath)
    
    // Verify it's an application bundle
    guard url.pathExtension == "app" else {
        throw CLIError.invalidApp("Not an .app bundle: \(appPath)")
    }
    
    // Verify the app exists
    guard FileManager.default.fileExists(atPath: appPath) else {
        throw CLIError.invalidApp("Application not found: \(appPath)")
    }
    
    // Get the icon for the application
    let icon = NSWorkspace.shared.icon(forFile: url.path)
    
    // Set the size
    let iconSize = NSSize(width: size, height: size)
    icon.size = iconSize
    
    return icon
}

func saveIconAsPNG(_ icon: NSImage, to outputPath: String, size: Int) throws {
    let url = URL(fileURLWithPath: outputPath)
    let iconSize = NSSize(width: size, height: size)
    
    // Create a bitmap representation
    guard let tiffData = icon.tiffRepresentation,
          let _ = NSBitmapImageRep(data: tiffData) else {
        throw CLIError.exportFailed("Could not create bitmap representation")
    }
    
    // Resize to exact dimensions
    let resizedImage = NSImage(size: iconSize)
    resizedImage.lockFocus()
    icon.draw(in: NSRect(origin: .zero, size: iconSize),
             from: NSRect(origin: .zero, size: icon.size),
             operation: .copy,
             fraction: 1.0)
    resizedImage.unlockFocus()
    
    // Convert to PNG
    guard let resizedTiff = resizedImage.tiffRepresentation,
          let resizedBitmap = NSBitmapImageRep(data: resizedTiff),
          let pngData = resizedBitmap.representation(using: .png, properties: [:]) else {
        throw CLIError.exportFailed("Could not create PNG data")
    }
    
    // Ensure output directory exists
    let outputDir = url.deletingLastPathComponent()
    if !FileManager.default.fileExists(atPath: outputDir.path) {
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
    }
    
    try pngData.write(to: url)
}

func optimizeFileSize(_ filePath: String, maxSizeKB: Int) throws {
    let fileURL = URL(fileURLWithPath: filePath)
    
    // Get current file size
    let attributes = try FileManager.default.attributesOfItem(atPath: filePath)
    guard let fileSize = attributes[.size] as? UInt64 else {
        throw CLIError.exportFailed("Could not determine file size")
    }
    
    let fileSizeKB = Int(fileSize / 1024)
    
    // If already under the limit, no optimization needed
    if fileSizeKB <= maxSizeKB {
        print("File size (\(fileSizeKB)KB) is already within limit (\(maxSizeKB)KB)")
        return
    }
    
    print("Optimizing file size from \(fileSizeKB)KB to meet \(maxSizeKB)KB limit...")
    
    // Create temporary file for optimization
    let tempURL = fileURL.deletingLastPathComponent().appendingPathComponent(".\(fileURL.lastPathComponent).tmp")
    
    // Try different compression strategies
    var quality = 90
    var currentSizeKB = fileSizeKB
    
    while quality >= 10 && currentSizeKB > maxSizeKB {
        // Use sips to convert to JPEG with compression, then back to PNG
        // This reduces file size while maintaining reasonable quality
        let jpegTemp = fileURL.deletingLastPathComponent().appendingPathComponent(".\(fileURL.lastPathComponent).jpg")
        
        // Convert to JPEG with quality setting
        let convertProcess = Process()
        convertProcess.executableURL = URL(fileURLWithPath: "/usr/bin/sips")
        convertProcess.arguments = [
            "-s", "format", "jpeg",
            "-s", "formatOptions", "\(quality)",
            filePath,
            "--out", jpegTemp.path
        ]
        
        let convertPipe = Pipe()
        convertProcess.standardError = convertPipe
        try convertProcess.run()
        convertProcess.waitUntilExit()
        
        guard convertProcess.terminationStatus == 0 else {
            throw CLIError.exportFailed("sips JPEG conversion failed")
        }
        
        // Convert back to PNG
        let pngProcess = Process()
        pngProcess.executableURL = URL(fileURLWithPath: "/usr/bin/sips")
        pngProcess.arguments = [
            "-s", "format", "png",
            jpegTemp.path,
            "--out", tempURL.path
        ]
        
        let pngPipe = Pipe()
        pngProcess.standardError = pngPipe
        try pngProcess.run()
        pngProcess.waitUntilExit()
        
        // Clean up JPEG temp file
        try? FileManager.default.removeItem(at: jpegTemp)
        
        guard pngProcess.terminationStatus == 0 else {
            throw CLIError.exportFailed("sips PNG conversion failed")
        }
        
        // Check new file size
        let tempAttributes = try FileManager.default.attributesOfItem(atPath: tempURL.path)
        guard let tempSize = tempAttributes[.size] as? UInt64 else {
            throw CLIError.exportFailed("Could not determine optimized file size")
        }
        
        currentSizeKB = Int(tempSize / 1024)
        
        // If we've met the target, replace original file
        if currentSizeKB <= maxSizeKB {
            try FileManager.default.removeItem(at: fileURL)
            try FileManager.default.moveItem(at: tempURL, to: fileURL)
            print("✓ Optimized to \(currentSizeKB)KB (quality: \(quality)%)")
            return
        }
        
        // Try lower quality
        quality -= 10
    }
    
    // Clean up temp file if it exists
    try? FileManager.default.removeItem(at: tempURL)
    
    // If we couldn't meet the target, throw an error
    if currentSizeKB > maxSizeKB {
        throw CLIError.exportFailed("Could not reduce file size to \(maxSizeKB)KB (final size: \(currentSizeKB)KB). Consider using a smaller icon size with the -s option.")
    }
}

func generateOutputPath(for inputPath: String) -> String {
    let url = URL(fileURLWithPath: inputPath)
    let appName = url.deletingPathExtension().lastPathComponent
    let cleanName = appName.replacingOccurrences(of: " ", with: "")
    return "\(cleanName).png"
}

func promptForOverwrite(path: String) -> Bool {
    // Check if we're in an interactive terminal
    guard isatty(STDIN_FILENO) != 0 else {
        // Non-interactive mode (CI, pipe, etc.) - don't overwrite by default
        fputs("Error: File '\(path)' already exists. Use --force to overwrite.\n", stderr)
        return false
    }
    
    print("File '\(path)' already exists. Overwrite? (y/N): ", terminator: "")
    fflush(stdout)
    
    guard let response = readLine()?.lowercased().trimmingCharacters(in: .whitespaces) else {
        return false
    }
    
    return response == "y" || response == "yes"
}

// MARK: - Main Execution

func main() -> Int32 {
    let args = parseArguments()
    
    // Handle help and version
    if args.help {
        printHelp()
        return 0
    }
    
    if args.version {
        printVersion()
        return 0
    }
    
    // Validate input
    guard let inputPath = args.inputPath else {
        fputs("Error: No input application specified\n", stderr)
        fputs("Use --help for usage information\n", stderr)
        return 2
    }
    
    // Auto-select size based on max file size if user didn't specify size
    var iconSize = args.size
    if let maxSize = args.maxFileSize, !args.sizeExplicitlySet {
        iconSize = selectOptimalSize(for: maxSize)
        print("Auto-selecting \(iconSize)x\(iconSize) icon size for \(maxSize)KB target")
    }
    
    // Validate size
    let validSizes = [16, 32, 64, 128, 256, 512, 1024]
    if !validSizes.contains(iconSize) {
        fputs("Warning: Size \(iconSize) is not a standard icon size. Supported: \(validSizes.map(String.init).joined(separator: ", "))\n", stderr)
    }
    
    do {
        // Expand tilde and resolve relative paths
        let expandedInput = NSString(string: inputPath).expandingTildeInPath
        let resolvedInput = URL(fileURLWithPath: expandedInput).standardizedFileURL.path
        
        // Extract icon
        print("Extracting icon from: \(resolvedInput)")
        let icon = try extractIcon(from: resolvedInput, size: iconSize)
        
        // Determine output path
        let outputPath: String
        if let specifiedOutput = args.outputPath {
            let expandedOutput = NSString(string: specifiedOutput).expandingTildeInPath
            // If output is a directory, generate filename
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: expandedOutput, isDirectory: &isDirectory), isDirectory.boolValue {
                let filename = generateOutputPath(for: resolvedInput)
                outputPath = URL(fileURLWithPath: expandedOutput).appendingPathComponent(filename).path
            } else {
                outputPath = expandedOutput
            }
        } else {
            outputPath = generateOutputPath(for: resolvedInput)
        }
        
        // Check if file exists and prompt if not forced
        if FileManager.default.fileExists(atPath: outputPath) && !args.force {
            if !promptForOverwrite(path: outputPath) {
                // In non-interactive mode, an error message is already printed
                // In interactive mode, user chose not to overwrite
                if isatty(STDIN_FILENO) != 0 {
                    print("Operation cancelled.")
                }
                return 1
            }
        }
        
        // Save icon
        print("Saving \(iconSize)x\(iconSize) icon to: \(outputPath)")
        try saveIconAsPNG(icon, to: outputPath, size: iconSize)
        
        // Optimize file size if requested
        if let maxSize = args.maxFileSize {
            try optimizeFileSize(outputPath, maxSizeKB: maxSize)
        }
        
        print("✓ Icon extracted successfully!")
        return 0
        
    } catch let error as CLIError {
        fputs("Error: \(error.localizedDescription)\n", stderr)
        return 3
    } catch {
        fputs("Error: \(error.localizedDescription)\n", stderr)
        return 1
    }
}

// Run the CLI
exit(main())
