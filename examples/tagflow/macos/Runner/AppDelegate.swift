import Cocoa
import FlutterMacOS

final class BenchmarkLaunchAttributionRecorder {
  static let shared = BenchmarkLaunchAttributionRecorder()

  private let appDelegateInitMicros: Int64
  private var didFinishLaunchingMicros: Int64?
  private var flutterViewControllerReadyMicros: Int64?

  private init() {
    appDelegateInitMicros = Self.monotonicMicros()
  }

  func markDidFinishLaunching() {
    didFinishLaunchingMicros = Self.monotonicMicros()
  }

  func markFlutterViewControllerReady() {
    flutterViewControllerReadyMicros = Self.monotonicMicros()
  }

  func payload() -> [String: Any] {
    let requestHandledMicros = Self.monotonicMicros()
    var markers: [String: Any] = [
      "appDelegateInitMicros": appDelegateInitMicros,
      "integrationTestRequestHandledMicros": requestHandledMicros,
    ]
    if let didFinishLaunchingMicros {
      markers["didFinishLaunchingMicros"] = didFinishLaunchingMicros
    }
    if let flutterViewControllerReadyMicros {
      markers["flutterViewControllerReadyMicros"] =
        flutterViewControllerReadyMicros
    }

    var intervals: [String: Any] = [
      "appDelegateInitToIntegrationTestRequestMicros":
        requestHandledMicros - appDelegateInitMicros,
    ]
    if let didFinishLaunchingMicros {
      intervals["appDelegateInitToDidFinishLaunchingMicros"] =
        didFinishLaunchingMicros - appDelegateInitMicros
    }
    if let flutterViewControllerReadyMicros {
      intervals["appDelegateInitToFlutterViewControllerReadyMicros"] =
        flutterViewControllerReadyMicros - appDelegateInitMicros
    }

    return [
      "schemaVersion": 1,
      "status": "available",
      "host": "macos",
      "scope": "local_runner_only",
      "provenance": "macos_app_delegate_uptime_markers_v1",
      "notes":
        "Intervals start at AppDelegate init and are only valid for the "
        + "local macOS example runner.",
      "markers": markers,
      "intervals": intervals,
    ]
  }

  private static func monotonicMicros() -> Int64 {
    Int64(ProcessInfo.processInfo.systemUptime * 1_000_000)
  }
}

@main
class AppDelegate: FlutterAppDelegate {
  override init() {
    _ = BenchmarkLaunchAttributionRecorder.shared
    super.init()
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    BenchmarkLaunchAttributionRecorder.shared.markDidFinishLaunching()
    super.applicationDidFinishLaunching(notification)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
