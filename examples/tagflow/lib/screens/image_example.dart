import 'package:tagflow_example/widgets/example_page.dart';

const _html = '''
<h1>Images in TagFlow</h1>
<p>TagFlow provides robust support for displaying images in your Flutter applications. Here are various examples of image usage:</p>

<h2>1. Basic Image</h2>
<p>A simple image with src and alt attributes:</p>
<img src="https://picsum.photos/400/300" alt="A random landscape image">

<h2>2. Image with Title</h2>
<p>Image with a title attribute that shows on hover:</p>
<img src="https://picsum.photos/400/300?random=2" alt="Mountain landscape" title="Beautiful mountain landscape">

<h2>3. Images with Different Sizes</h2>
<div>
  <img src="https://picsum.photos/200/200?random=3" alt="Small square image" style="margin: 10px">
  <img src="https://picsum.photos/300/200?random=4" alt="Medium rectangular image" style="margin: 10px">
  <img src="https://picsum.photos/400/200?random=5" alt="Large rectangular image" style="margin: 10px">
</div>

<h2>4. Image with Border and Styling</h2>
<img src="https://picsum.photos/400/300?random=6" alt="Styled image" style="border: 2px solid

<h2>5. Image in Text Flow</h2>
<p>
  <img src="https://picsum.photos/100/100?random=9" alt="Small inline image" style="float: left; margin: 0 10px 10px 0;">
  This paragraph demonstrates how text flows around an image when using float styling. The text wraps naturally around the image, creating an integrated layout that combines both textual and visual elements effectively.
</p>
''';

final class ImageExample extends ExamplePage {
  const ImageExample({super.key, super.title = 'Images'});

  @override
  String get html => _html;
}
