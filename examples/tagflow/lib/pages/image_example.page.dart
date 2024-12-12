import 'package:tagflow_example/widgets/example_page.dart';

const _html = '''
<h3>Image with default size</h3>
<img src="https://picsum.photos/seed/def/200" alt="Flutter Logo">
<h3>Image with custom size</h3>
<img src="https://picsum.photos/seed/custom/200" alt="Flutter Logo" width="100" height="100">
<h3>Image with custom fit</h3>
<img src="https://picsum.photos/seed/fit/200" alt="Flutter Logo" style="object-fit: cover">
<h3>Image with custom fit and size</h3>
<img src="https://picsum.photos/seed/fitsize/200" alt="Flutter Logo" style="object-fit: cover; width: 100px; height: 100px">
<h3>Image inside a container</h3>
<div style="background-color: red; display: flex; justify-content: center; align-items: center; flex-direction: row; margin-bottom: 16px">
  <img src="https://picsum.photos/seed/containerimg1/200" alt="Flutter Logo" style="object-fit: cover; width: 100px; height: 100px">
  <img src="https://picsum.photos/seed/containerimg2/200" alt="Flutter Logo" style="object-fit: cover; width: 100px; height: 100px">
</div>
''';

final class ImageExample extends ExamplePage {
  const ImageExample({super.key});

  @override
  String get title => 'Image Examples';

  @override
  String get html => _html;
}
