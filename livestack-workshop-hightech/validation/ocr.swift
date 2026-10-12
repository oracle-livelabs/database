import Foundation
import Vision
import AppKit
let root=URL(fileURLWithPath:CommandLine.arguments[1])
let output=URL(fileURLWithPath:CommandLine.arguments[2])
var rows:[[String:Any]]=[]
let files=FileManager.default.enumerator(at:root,includingPropertiesForKeys:nil)!
for case let u as URL in files {
 if u.path.contains("/validation/"){continue}
 if !["png","jpg","jpeg"].contains(u.pathExtension.lowercased()){continue}
 let request=VNRecognizeTextRequest();request.recognitionLevel = .accurate
 do {
  try VNImageRequestHandler(url:u).perform([request])
  let txt=(request.results ?? []).compactMap{$0.topCandidates(1).first?.string}.joined(separator:"\n")
  rows.append(["path":String(u.path.dropFirst(root.path.count+1)),"text":txt])
 }catch{rows.append(["path":u.path,"error":String(describing:error)])}
}
let data=try JSONSerialization.data(withJSONObject:["engine":"macOS Vision accurate","images":rows],options:[.prettyPrinted,.sortedKeys])
try data.write(to:output)
print("OCR complete: \(rows.count) images")
