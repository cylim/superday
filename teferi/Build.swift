import Foundation
import Darwin

let file = "Constants.swift"
let variablesToBeReplaced = [ "HOCKEY_APP_IDENTIFIER" ]

enum ConstantReplacingError : Error
{
    case noEnvironmentVar(variable: String)
}

func getEnvironmentVariable(forVariable variable: String) throws -> String
{
    guard let value = getenv(variable) else
    {
        throw ConstantReplacingError.noEnvironmentVar(variable: variable)
    }
    
    return String(validatingUTF8: value)!
}

func replaceEnvironmentVariables(fromFile fileName: String) -> String
{
    var fileContent : String = try! String(contentsOfFile: fileName, encoding: String.Encoding.utf8)
    
    variablesToBeReplaced.forEach { variable in fileContent = fileContent.replacingOccurrences(of: variable, with: try! getEnvironmentVariable(forVariable: variable), options: String.CompareOptions.literal, range: nil) }
    
    return fileContent
}

let newFile = replaceEnvironmentVariables(fromFile: file)

try! newFile.write(to: URL(fileURLWithPath: file), atomically: false, encoding: String.Encoding.utf8)
