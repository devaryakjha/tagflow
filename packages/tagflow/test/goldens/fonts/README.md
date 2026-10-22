# Golden test fonts

Golden tests render with these bundled fonts instead of Flutter's default
`FlutterTest` block font, so text in the baselines is legible and identical
on every machine running the pinned Flutter version.

| Family      | Files                                  | Source                                   | License    |
| ----------- | -------------------------------------- | ---------------------------------------- | ---------- |
| `Roboto`    | `Roboto-*.ttf`                         | Flutter SDK `material_fonts` artifact    | Apache 2.0 |
| `monospace` | `JetBrainsMono-Regular.ttf`, `-Bold`   | https://github.com/JetBrains/JetBrainsMono | Apache 2.0 |

`monospace` is registered under that generic name because the built-in code
components request `fontFamily: 'monospace'`.

See `LICENSE-Apache-2.0.txt` for the license text.
