import Flutter
import UIKit
import PDFKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let pdfChannelName = "com.keepremind.app/pdf_renderer"
  private let legacyPdfChannelName = "com.keepmate.app/pdf_renderer"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    if let controller = window?.rootViewController as? FlutterViewController {
      setupPdfChannel(messenger: controller.binaryMessenger)
    }
    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  private func setupPdfChannel(messenger: FlutterBinaryMessenger) {
    let handler: FlutterMethodCallHandler = { [weak self] (call, result) in
      guard let self = self else { return }
      if call.method == "renderPages" {
        guard let args = call.arguments as? [String: Any],
              let pdfPath = args["path"] as? String else {
          result(FlutterError(code: "INVALID_PATH", message: "Path is null", details: nil))
          return
        }
        let maxPages = args["maxPages"] as? Int ?? 4
        let rendered = self.renderPdfPages(pdfPath: pdfPath, maxPages: maxPages)
        result(rendered)
      } else if call.method == "renderFirstPage" {
        guard let args = call.arguments as? [String: Any],
              let pdfPath = args["path"] as? String else {
          result(FlutterError(code: "INVALID_PATH", message: "Path is null", details: nil))
          return
        }
        let pages = self.renderPdfPages(pdfPath: pdfPath, maxPages: 1)
        result(pages.first)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    let channel = FlutterMethodChannel(name: pdfChannelName, binaryMessenger: messenger)
    channel.setMethodCallHandler(handler)
    let legacyChannel = FlutterMethodChannel(name: legacyPdfChannelName, binaryMessenger: messenger)
    legacyChannel.setMethodCallHandler(handler)
  }

  private func renderPdfPages(pdfPath: String, maxPages: Int) -> [String] {
    let fileURL = URL(fileURLWithPath: pdfPath)
    guard let document = PDFDocument(url: fileURL) else { return [] }
    let count = min(document.pageCount, maxPages)
    if count == 0 { return [] }

    var renderedPaths: [String] = []
    let timestamp = Int(Date().timeIntervalSince1970 * 1000)

    for i in 0..<count {
      guard let page = document.page(at: i) else { continue }
      let pageRect = page.bounds(for: .mediaBox)
      let scale: CGFloat = 2.0
      let targetSize = CGSize(width: pageRect.width * scale, height: pageRect.height * scale)

      let renderer = UIGraphicsImageRenderer(size: targetSize)
      let image = renderer.image { ctx in
        UIColor.white.set()
        ctx.fill(CGRect(origin: .zero, size: targetSize))
        ctx.cgContext.translateBy(x: 0.0, y: targetSize.height)
        ctx.cgContext.scaleBy(x: scale, y: -scale)
        page.draw(with: .mediaBox, to: ctx.cgContext)
      }

      if let data = image.jpegData(compressionQuality: 0.92) {
        let tempPath = (NSTemporaryDirectory() as NSString).appendingPathComponent("pdf_render_\(timestamp)_page_\(i).jpg")
        do {
          try data.write(to: URL(fileURLWithPath: tempPath))
          renderedPaths.append(tempPath)
        } catch {
          NSLog("[AppDelegate] Failed to write rendered page: %@", error.localizedDescription)
        }
      }
    }
    return renderedPaths
  }
}
