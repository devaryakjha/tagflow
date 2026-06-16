import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    let registrar = flutterViewController.registrar(
      forPlugin: "TagflowBenchmarkLaunchAttribution")
    let launchChannel = FlutterMethodChannel(
      name: "dev.arya.tagflow/benchmark_launch_attribution",
      binaryMessenger: registrar.messenger)
    launchChannel.setMethodCallHandler { call, result in
      guard call.method == "getLaunchAttribution" else {
        result(FlutterMethodNotImplemented)
        return
      }
      result(BenchmarkLaunchAttributionRecorder.shared.payload())
    }
    BenchmarkLaunchAttributionRecorder.shared.markFlutterViewControllerReady()

    super.awakeFromNib()
  }
}
