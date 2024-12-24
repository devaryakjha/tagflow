import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_example/widgets/example_page.dart';

const articleHtml = r'''
<article>
<h1>Building Modern Web Applications</h1>

<p>Modern web development has evolved significantly over the past decade. Today's web applications need to be fast, responsive, and provide an excellent user experience across all devices.</p>

<h2>Key Technologies</h2>

<p>Several key technologies form the foundation of modern web development:</p>

<ul>
  <li><strong>HTML5</strong> - Provides semantic structure and new APIs</li>
  <li><strong>CSS3</strong> - Enables responsive layouts and animations</li>
  <li><mark>JavaScript</mark> - Powers interactive functionality</li>
</ul>

<h2>Best Practices</h2>

<p>When building web applications, following these best practices is crucial:</p>

<ol>
  <li>Use semantic HTML for better accessibility</li>
  <li>Implement responsive design principles</li>
  <li>Optimize performance and loading times</li>
</ol>

<h3>Code Example</h3>

<pre><code>// Simple React component
function Welcome(props) {
  return React.createElement('h1', null, `Hello, ${props.name}`);
}</code></pre>

<p>The above code demonstrates a basic React component using <i>JSX syntax</i>. Components like this form the building blocks of modern web applications.</p>

<blockquote>
  <p>"Any application that can be written in JavaScript, will eventually be written in JavaScript."</p>
  <footer><em>Atwood's Law</em></footer>
</blockquote>

<h3>Learn More</h3>

<p>For more information, check out these resources:</p>

<ul>
  <li><a href="https://developer.mozilla.org">MDN Web Docs</a></li>
  <li><a href="https://web.dev">web.dev</a></li>
</ul>
</article>
''';

final class ArticleExample extends ExamplePage {
  const ArticleExample({super.key, super.title = 'Article'});

  @override
  TagflowTheme createTheme(BuildContext context) {
    final theme = Theme.of(context);
    final codeTextTheme = GoogleFonts.spaceMonoTextTheme(theme.textTheme);
    return TagflowTheme.article(
      baseTextStyle: theme.textTheme.bodyMedium!,
      headingTextStyle: theme.textTheme.headlineMedium!,
      codeTextStyle: codeTextTheme.bodyMedium,
      resolveAdditionalStyles: (theme) {
        final blockquoteStyle =
            theme.styles['blockquote'] ?? const TagflowStyle();
        final footerStyle = theme.styles['footer'] ?? const TagflowStyle();

        final effectiveQuoteStyle = blockquoteStyle.merge(
          const TagflowStyle(
            padding: EdgeInsets.symmetric(horizontal: 8),
          ),
        );

        return {
          'blockquote': effectiveQuoteStyle,
          'q': effectiveQuoteStyle,
          'footer': footerStyle.merge(
            const TagflowStyle(
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
              textStyle: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          // TODO: Add support for this kind of nested styles
          'blockquote p': const TagflowStyle(
            margin: EdgeInsets.only(bottom: 8),
          ),
        };
      },
    );
  }

  @override
  String get html => articleHtml;
}
