## 0.0.5

 - **FIX**(text_converter): prevent text scale factor from compounding in nested elements.

## 0.0.4

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 0.0.4-dev.0

 - **FIX**(parser): update node validation logic to allow valid empty nodes. ([677c4d48](https://github.com/devaryakjha/tagflow/commit/677c4d48f854555c1340b44d73c934c49ac781e4))
 - **FEAT**(converter): enhance toString method to include custom and built-in converters. ([2f5f5e65](https://github.com/devaryakjha/tagflow/commit/2f5f5e65c7872b8d63ff556ecc9cf7b47347d547))

## 0.0.3+2

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 0.0.3-dev.0+2

 - **FIX**(styled_container): remove unnecessary blank line before container return. ([cf0b4a2d](https://github.com/devaryakjha/tagflow/commit/cf0b4a2d5ce98f6a7dfb193c7bf2b451dd1f82e7))
 - **FIX**(styled_container): refactor _needsContainer method for clarity and improve layout handling. ([93974336](https://github.com/devaryakjha/tagflow/commit/939743362f37203cda5b37845f317c7b4f7fd6d4))

## 0.0.3+1

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 0.0.3-dev.0+1

 - **FIX**(tagflow): remove unnecessary whitespace in _parseHtml method. ([0598eb40](https://github.com/devaryakjha/tagflow/commit/0598eb40bcb351988c2e9dc90d82f8ff51b2b59c))
 - **FIX**(tagflow): streamline HTML parsing by reusing parser instance. ([9f823bd8](https://github.com/devaryakjha/tagflow/commit/9f823bd86016613d76b3026bc9c525bde2857c5a))

## 0.0.3

 - **REFACTOR**(parser): simplify constructor and improve debug handling. ([fa5c05e1](https://github.com/devaryakjha/tagflow/commit/fa5c05e175ffae3cc067f207f92f61d15ed53677))
 - **FIX**: update SDK constraints to require Dart 3.7.0 or higher. ([c3640f90](https://github.com/devaryakjha/tagflow/commit/c3640f909e6139a04b9afda2d50777a9986b31fa))
 - **FIX**(selectable_adapter): add content length and selection range methods. ([00204089](https://github.com/devaryakjha/tagflow/commit/00204089eba01941704938913664ac8e58afb736))
 - **FEAT**(style): add maxTextLines property to TagflowStyle for text element configuration. ([804d8956](https://github.com/devaryakjha/tagflow/commit/804d8956ad2b52bc5f336ca3b392e3eec4e2989e))

## 0.0.2+1

- `TagflowParser` now honors the `debug` flag from `TagflowOptions`

## 0.0.2+1

- Update flutter version to 3.29.2

## 0.0.1+1

- Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 0.0.1-dev.0+1

- **FIX**(style): simplify SizeValue instantiation by removing unit specification. ([8b58622b](https://github.com/devaryakjha/tagflow/commit/8b58622b113098eb08eb69fc1af3fef6e8994c20))
- **FIX**(style): update merge logic to respect inherit property in TagflowStyle. ([739be1f7](https://github.com/devaryakjha/tagflow/commit/739be1f75327d2da51390473b1b02031679ac8db))

## 0.0.1

- Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 0.0.1-dev.17

- **FEAT**(style): enhance size handling with SizeValue integration. ([41c12f9f](https://github.com/devaryakjha/tagflow/commit/41c12f9f92a1e4a9f36030ea16244d497c7d5b76))
- **FEAT**(style): introduce SizeValue class and enhance size parsing. ([cb7a973e](https://github.com/devaryakjha/tagflow/commit/cb7a973ec3ce0589930e8bf7c97fd7051a0fe488))

## 0.0.1-dev.16

- **FEAT**(tagflow_parser): improve node validation to exclude specific tags. ([eb0a566c](https://github.com/devaryakjha/tagflow/commit/eb0a566c86fc66c409af88db10d454eb9e0e3e8f))
- **FEAT**(tagflow_parser): enhance node validation in parseNodes method. ([007d978c](https://github.com/devaryakjha/tagflow/commit/007d978c0e16801e7f73a6e363195541e981d30f))
- **FEAT**(tagflow_node): add hasChildren property to TagflowNode. ([b8fbd4ea](https://github.com/devaryakjha/tagflow/commit/b8fbd4eabafc96d3acce23144cfb073f97c8d55a))
- **FEAT**(text_converter): add support for bold and italic text elements. ([78dc2d3a](https://github.com/devaryakjha/tagflow/commit/78dc2d3a5ef9bdcc6660c0c78bd1cbbf13f42ab3))
- **FEAT**(tagflow): add softWrap property to TagflowStyle for text elements. ([f628170e](https://github.com/devaryakjha/tagflow/commit/f628170ec7a44f1097a016983c9181091d42c12c))

## 0.0.1-dev.15

- **FIX**(list_converter): update padding in StyledContainer and ListView. ([3a0f27ef](https://github.com/devaryakjha/tagflow/commit/3a0f27efe9e251201786fd0a79849079f93f6444))
- **FEAT**(converter): enhance selector matching with pseudo-selectors and improve theme styling. ([9cc6e29d](https://github.com/devaryakjha/tagflow/commit/9cc6e29d9d55687d5d62b750bd540d76509222bb))
- **FEAT**(tagflow): add inherit property to TagflowStyle and update theme handling. ([5bfe2b66](https://github.com/devaryakjha/tagflow/commit/5bfe2b667018901db977b18f052f4c54ad894f26))
- **FEAT**(text_converter): enhance gesture handling for text nodes. ([a5cea0dd](https://github.com/devaryakjha/tagflow/commit/a5cea0dd039924b8ed79bc80a9bce2302fdade9c))

## 0.0.1-dev.14

- **REFACTOR**(element_test): remove percentage value test for element dimensions. ([0ecbc479](https://github.com/devaryakjha/tagflow/commit/0ecbc4794b7974fdc304d0816ea14b7ebf47fee7))
- **REFACTOR**(node_extension_test): improve test readability and update children setter. ([6441b2a1](https://github.com/devaryakjha/tagflow/commit/6441b2a15701f1902567fff457ef3e5189269607))
- **REFACTOR**(table_element): update attribute assignment in TagflowTableElement constructor. ([85d02452](https://github.com/devaryakjha/tagflow/commit/85d024529ab3532027de312e232e62b973a5b969))
- **REFACTOR**(table_parser): optimize table row handling and improve tag checks. ([9bf99dea](https://github.com/devaryakjha/tagflow/commit/9bf99deab807edc8207a6120a33d4c1566b39cde))
- **REFACTOR**(style,theme): replace default TagflowStyle with TagflowStyle.empty. ([a00adaf0](https://github.com/devaryakjha/tagflow/commit/a00adaf0f61fe4f40857504ee0b93057368ad187))
- **REFACTOR**(styles): enhance border and decoration handling in StyledContainer and TableConverter. ([c4d582c8](https://github.com/devaryakjha/tagflow/commit/c4d582c8194e3c562c3adbe3abfe62edfc9c1db6))
- **FIX**(style_parser_test): update percentage value parsing to return null for invalid inputs. ([7e086796](https://github.com/devaryakjha/tagflow/commit/7e086796a0534f30a05fc99daa819f5623e33915))
- **FIX**(tests): update style_extension tests to use TagflowStyle.empty. ([e2781ef5](https://github.com/devaryakjha/tagflow/commit/e2781ef50252d02cd950ee77baf8f0cca1bc6960))
- **FIX**(tagflow_widget): replace Text with SelectableText in error widget. ([0c622c4a](https://github.com/devaryakjha/tagflow/commit/0c622c4a32056790de051e2677fde44ce1866043))
- **FEAT**(docs): add contributing guidelines and enhance README structure. ([579ec3d6](https://github.com/devaryakjha/tagflow/commit/579ec3d695b2af1811dff3ef52d53f9b677001e5))
- **FEAT**(style_parser): add border parsing functionality to StyleParser. ([7e669181](https://github.com/devaryakjha/tagflow/commit/7e669181f46f4f9121c9462305880935bec93c89))
- **FEAT**(table_element): enhance attribute handling and reparenting logic. ([afb723e7](https://github.com/devaryakjha/tagflow/commit/afb723e7bbb80d4a75cb836bec7637fc103b5d06))
- **FEAT**(theme): enhance TagflowTheme style resolution and add default named colors. ([c461e22d](https://github.com/devaryakjha/tagflow/commit/c461e22d68c5a3358f5e10f66c262c4b4d0a4ac1))
- **FEAT**(tests): add unit tests for TagflowTableElement and CellSpan functionality. ([9b18abb6](https://github.com/devaryakjha/tagflow/commit/9b18abb653f4dacdfab87a38077afb2e2f8c2951))
- **FEAT**(tests): add comprehensive tests for TagflowNode and StyleExtension. ([a8de345f](https://github.com/devaryakjha/tagflow/commit/a8de345fc930e525ef3e1f1d5f04455ff4f6a50e))
- **FEAT**(style_parser): enhance CSS value parsing and validation. ([021a2e4e](https://github.com/devaryakjha/tagflow/commit/021a2e4e1bbf72c9aabe9d3809ebdf9bfb8ff5c9))
- **FEAT**(theme): add transparent color to TagflowTheme color map. ([c7943c4c](https://github.com/devaryakjha/tagflow/commit/c7943c4c27313a20592bd30a954490f9c863c691))
- **FEAT**(table_example,table_converter,table_parser): add support for table captions and enhance rendering. ([76ee33fb](https://github.com/devaryakjha/tagflow/commit/76ee33fbfd4369a19a3908e57d8747770f064388))
- **FEAT**(style,converter,theme): enhance style resolution with inheritance support. ([f8c8ac9e](https://github.com/devaryakjha/tagflow/commit/f8c8ac9e99dd23ed811b072b73b3d92640d9f035))
- **FEAT**(table_example,tagflow_table): enhance table examples and rendering logic. ([ab226159](https://github.com/devaryakjha/tagflow/commit/ab226159fc4d07d88b0a8359bb3537a7d3891bb3))
- **FEAT**(table_example): enhance table examples with new HTML structures and rendering improvements. ([89b191bf](https://github.com/devaryakjha/tagflow/commit/89b191bfdd0a89bf710be451cc6cc4c4def6b82c))

## 0.0.1-dev.13

- **REFACTOR**(parser): clean up and enhance TableParser functionality. ([5e2f943d](https://github.com/devaryakjha/tagflow/commit/5e2f943d5b6c9db62d3eabc75cd42b093d78420d))
- **REFACTOR**(element_test): improve parent-child relationship management in tests. ([8bfa6e01](https://github.com/devaryakjha/tagflow/commit/8bfa6e0192bad10a0d2bf08d9243285550bd8b39))
- **REFACTOR**(table): improve table styling and border handling in converters and theme. ([f80edb36](https://github.com/devaryakjha/tagflow/commit/f80edb366a2ca88bf300bfe9c883fb4d0b5cd7f9))
- **REFACTOR**(table): update table structure and styling in examples and converters. ([f31c51cf](https://github.com/devaryakjha/tagflow/commit/f31c51cfd701a51aedd2040387794864cd4336b6))
- **REFACTOR**(converter): clean up logging and improve element properties. ([ccd443ae](https://github.com/devaryakjha/tagflow/commit/ccd443ae450c495a6c80785c3658292959b55884))
- **REFACTOR**(tagflow): update element models and parsers for improved structure. ([3fb10303](https://github.com/devaryakjha/tagflow/commit/3fb10303f67033447c45a9b4b537eb987d50f53b))
- **FIX**(converter): add line length ignore and update TODO comment. ([6550ad2b](https://github.com/devaryakjha/tagflow/commit/6550ad2bc704c909cafe7b6046f2ab466325a507))
- **FEAT**(table): add TableConverter tests and export parser. ([1d12545a](https://github.com/devaryakjha/tagflow/commit/1d12545acbd0c4732e76edeb99589141c0ba8d9d))
- **FEAT**(img_parser): add unit tests for ImgParser functionality. ([4026ee45](https://github.com/devaryakjha/tagflow/commit/4026ee45049f05534487804ae70504216cd84143))
- **FEAT**(table): enhance table styling and structure in converters and examples. ([5b88f481](https://github.com/devaryakjha/tagflow/commit/5b88f48157851d1ea6489633d365bf9fe0d62174))
- **FEAT**(parser): enhance node parsing and attribute handling. ([f7213efd](https://github.com/devaryakjha/tagflow/commit/f7213efd9b2d941d24d9c50b5e852221e50da03e))
- **FEAT**(node): add hasAttribute method to TagflowNode. ([7b15a4d1](https://github.com/devaryakjha/tagflow/commit/7b15a4d1a70a60872011c287d5c9accb974bcf2d))
- **FEAT**(img): introduce TagflowImgElement and update converters. ([97d47762](https://github.com/devaryakjha/tagflow/commit/97d4776244dce5aa2ac2c77df0ad9a1d7ac5f5fb))
- **FEAT**(tagflow): refactor element handling and introduce TagflowNode. ([a6a617f1](https://github.com/devaryakjha/tagflow/commit/a6a617f151023b50793647dacd2455bce535db3d))
- **FEAT**(table): implement TableConverter and update roadmap. ([60047676](https://github.com/devaryakjha/tagflow/commit/6004767657de88468b2c6c4c46f0a2498be90bd5))

## 0.0.1-dev.12

- **REFACTOR**(parser): clean up and enhance TableParser functionality. ([5e2f943d](https://github.com/devaryakjha/tagflow/commit/5e2f943d5b6c9db62d3eabc75cd42b093d78420d))
- **REFACTOR**(element_test): improve parent-child relationship management in tests. ([8bfa6e01](https://github.com/devaryakjha/tagflow/commit/8bfa6e0192bad10a0d2bf08d9243285550bd8b39))
- **REFACTOR**(table): improve table styling and border handling in converters and theme. ([f80edb36](https://github.com/devaryakjha/tagflow/commit/f80edb366a2ca88bf300bfe9c883fb4d0b5cd7f9))
- **REFACTOR**(table): update table structure and styling in examples and converters. ([f31c51cf](https://github.com/devaryakjha/tagflow/commit/f31c51cfd701a51aedd2040387794864cd4336b6))
- **REFACTOR**(converter): clean up logging and improve element properties. ([ccd443ae](https://github.com/devaryakjha/tagflow/commit/ccd443ae450c495a6c80785c3658292959b55884))
- **REFACTOR**(tagflow): update element models and parsers for improved structure. ([3fb10303](https://github.com/devaryakjha/tagflow/commit/3fb10303f67033447c45a9b4b537eb987d50f53b))
- **FIX**(converter): add line length ignore and update TODO comment. ([6550ad2b](https://github.com/devaryakjha/tagflow/commit/6550ad2bc704c909cafe7b6046f2ab466325a507))
- **FEAT**(table): add TableConverter tests and export parser. ([1d12545a](https://github.com/devaryakjha/tagflow/commit/1d12545acbd0c4732e76edeb99589141c0ba8d9d))
- **FEAT**(img_parser): add unit tests for ImgParser functionality. ([4026ee45](https://github.com/devaryakjha/tagflow/commit/4026ee45049f05534487804ae70504216cd84143))
- **FEAT**(table): enhance table styling and structure in converters and examples. ([5b88f481](https://github.com/devaryakjha/tagflow/commit/5b88f48157851d1ea6489633d365bf9fe0d62174))
- **FEAT**(parser): enhance node parsing and attribute handling. ([f7213efd](https://github.com/devaryakjha/tagflow/commit/f7213efd9b2d941d24d9c50b5e852221e50da03e))
- **FEAT**(node): add hasAttribute method to TagflowNode. ([7b15a4d1](https://github.com/devaryakjha/tagflow/commit/7b15a4d1a70a60872011c287d5c9accb974bcf2d))
- **FEAT**(img): introduce TagflowImgElement and update converters. ([97d47762](https://github.com/devaryakjha/tagflow/commit/97d4776244dce5aa2ac2c77df0ad9a1d7ac5f5fb))
- **FEAT**(tagflow): refactor element handling and introduce TagflowNode. ([a6a617f1](https://github.com/devaryakjha/tagflow/commit/a6a617f151023b50793647dacd2455bce535db3d))
- **FEAT**(table): implement TableConverter and update roadmap. ([60047676](https://github.com/devaryakjha/tagflow/commit/6004767657de88468b2c6c4c46f0a2498be90bd5))

## 0.0.1-dev.11

- **FIX**(style_parser): improve percentage handling in parseSize method. ([74333732](https://github.com/devaryakjha/tagflow/commit/74333732fd930f68d8138ea3ccc8ac819129f72e))
- **FIX**(style_parser): update percentage handling in parseSize method. ([bdac976c](https://github.com/devaryakjha/tagflow/commit/bdac976cdcc79ae28d6ee2a718981c1bb7cc7cf7))

## 0.0.1-dev.8

- **REFACTOR**(theme): update background color methods for consistency. ([dce0e447](https://github.com/devaryakjha/tagflow/commit/dce0e4473efbabb6f4dbadcec405a5706d5f1451))
- **REFACTOR**: enhance blockquote handling and styling in ArticleExample and converters. ([f0ea898b](https://github.com/devaryakjha/tagflow/commit/f0ea898b027d948be2a3b1182408de9f683d9794))
- **REFACTOR**: improve whitespace handling and node validation in TagflowParser. ([685f611d](https://github.com/devaryakjha/tagflow/commit/685f611da0ba98d112422d367bb1755025fc15d2))
- **REFACTOR**: simplify StyledContainer by consolidating style application into a single Container. ([f348677f](https://github.com/devaryakjha/tagflow/commit/f348677f380b25494cb0604261d5616d00ec0322))
- **REFACTOR**(tests): remove redundant test for empty node creation in element_test.dart. ([42259a51](https://github.com/devaryakjha/tagflow/commit/42259a5171fa463f1d299c0c018987a8b6422da7))
- **REFACTOR**: improved tests. ([5ed3bd53](https://github.com/devaryakjha/tagflow/commit/5ed3bd536748a152ea414e842b561c6570ea7bb8))
- **REFACTOR**: moved style enums to appropriate directories. ([af6c78f4](https://github.com/devaryakjha/tagflow/commit/af6c78f44c126d8c99e33bbe600490b998e0128a))
- **FIX**: relax dart SDK constraints in pubspec.yaml files. ([269ad7f2](https://github.com/devaryakjha/tagflow/commit/269ad7f2be0f7c1ae9846f2a2bb99a17cfb73e93))
- **FIX**: correct parent tag reference in ListItemConverter. ([a85fdc6e](https://github.com/devaryakjha/tagflow/commit/a85fdc6edf7dfea0100efc55c697008e0a5726d0))
- **FIX**: improve whitespace handling in TagflowParser. ([a6e879ea](https://github.com/devaryakjha/tagflow/commit/a6e879ea6b675ac8d0a15d40202ff07231d7b3f4))
- **FIX**: checkout to head branch wasn't working properly. ([431906a0](https://github.com/devaryakjha/tagflow/commit/431906a0eecdcd6d33efd89a75c70a6566b4d9b7))
- **FIX**: changelogs. ([5ba34a8d](https://github.com/devaryakjha/tagflow/commit/5ba34a8d3bc7d02bee0036ee0bac6f37f7f67329))
- **FIX**: remove background color from HrConverter style. ([c9c86acd](https://github.com/devaryakjha/tagflow/commit/c9c86acd6c967b764d13d3bdbc461f0e320a47f9))
- **FIX**: update README.md link to main repository. ([ef380f57](https://github.com/devaryakjha/tagflow/commit/ef380f57dcc5cd40da539bf3fa4aeb970db99f88))
- **FEAT**: enhance TagflowOptions and add comprehensive tests for TagflowSelectableOptions. ([c53515ef](https://github.com/devaryakjha/tagflow/commit/c53515ef72719bb9ff260e5c6f5aa2d1ba46973f))
- **FEAT**: add comprehensive tests for ListConverter, TagflowElement, StyleParser, and TagflowTheme. ([b867e392](https://github.com/devaryakjha/tagflow/commit/b867e392cb85bc30443113b434b8419ab34693e4))
- **FEAT**: refactor CodeConverter to extend TextConverter and support additional tags. ([af6fb055](https://github.com/devaryakjha/tagflow/commit/af6fb055f1cf9df87a090ddf5bf0e78ac218e521))
- **FEAT**: enhance TagflowTheme with maxWidth support for code styles. ([19d2c04f](https://github.com/devaryakjha/tagflow/commit/19d2c04f134309e11562d708db4163d650ce40c9))
- **FEAT**: enhance TextConverter to support forced widget spans for specific tags. ([d1497247](https://github.com/devaryakjha/tagflow/commit/d149724717985e1782d123784d1e65a9a694b8a5))
- **FEAT**: add list and list item converters to enhance element handling. ([fdff6059](https://github.com/devaryakjha/tagflow/commit/fdff6059f8fc6a115e0cfc37db2e5a79c551da4f))
- **FEAT**: enhance selector handling in ElementConverter to support negation. ([e9f04b29](https://github.com/devaryakjha/tagflow/commit/e9f04b29605b58df3f9df77b8304a8367dc5c9e2))
- **FEAT**: improve blockquote styling and add nested style support in Tagflow. ([f408c96e](https://github.com/devaryakjha/tagflow/commit/f408c96e075d5ef7e69f2e049d3d0887fabfc478))
- **FEAT**: enhance blockquote handling and theme styling in Tagflow. ([d25c51d6](https://github.com/devaryakjha/tagflow/commit/d25c51d6d2090bd71ef0143f04b8c33392f96401))
- **FEAT**: add article example and enhance blockquote handling in Tagflow. ([94017d32](https://github.com/devaryakjha/tagflow/commit/94017d32e6ef40199e14a2d4c6274ccfda93daee))
- **FEAT**: enhance Tagflow styling and text handling. ([e6e323a0](https://github.com/devaryakjha/tagflow/commit/e6e323a098b58636f42a0e84e5aa19e8eb828849))
- **FEAT**: enhance text handling and styling in Tagflow. ([5110c930](https://github.com/devaryakjha/tagflow/commit/5110c930c92a96055dcffa62553d677ac463a79b))
- **FEAT**: add support for anchor tags in TextConverter. ([69d5c11b](https://github.com/devaryakjha/tagflow/commit/69d5c11b9de473b979ae5422357b2f0805a8f8d2))
- **FEAT**: enhance TagflowTheme with inline code margin and improved default styles. ([5ecb55c6](https://github.com/devaryakjha/tagflow/commit/5ecb55c6a09828205054f15d8c1a84892c02c864))
- **FEAT**: refactor Tagflow example app by removing GenericExample and adding TypographyExample. ([37da572b](https://github.com/devaryakjha/tagflow/commit/37da572b83d1f74a2bee2fc3a0445f9757678af0))
- **FEAT**: enhance Tagflow example app with improved HTML content and theming options. ([d2f3194d](https://github.com/devaryakjha/tagflow/commit/d2f3194d662284e5aa22e0bcd614461484f7d635))
- **FEAT**: add Makefile for package creation and update README. ([854129af](https://github.com/devaryakjha/tagflow/commit/854129af0ff8e746de719fcba09e1ddd242a0bbe))
- **FEAT**: enhance Tagflow example app with new example and improved theming. ([94455e3c](https://github.com/devaryakjha/tagflow/commit/94455e3caeb74d6aecd7f2eb1ec9d00558b5b622))
- **DOCS**: update documentation properly. ([28323aa9](https://github.com/devaryakjha/tagflow/commit/28323aa9116eba7f58c679cb221cfc7c7616dabd))

## 0.0.1-dev.7

- **DOCS**: updated documentation to reflect the latest changes. ([28323aa9](https://github.com/devaryakjha/tagflow/commit/28323aa9116eba7f58c679cb221cfc7c7616dabd))

## 0.0.1-dev.6

- **REFACTOR**: enhance blockquote handling and styling in ArticleExample and converters. ([f0ea898b](https://github.com/devaryakjha/tagflow/commit/f0ea898b027d948be2a3b1182408de9f683d9794))
- **REFACTOR**: improve whitespace handling and node validation in TagflowParser. ([685f611d](https://github.com/devaryakjha/tagflow/commit/685f611da0ba98d112422d367bb1755025fc15d2))
- **REFACTOR**: simplify StyledContainer by consolidating style application into a single Container. ([f348677f](https://github.com/devaryakjha/tagflow/commit/f348677f380b25494cb0604261d5616d00ec0322))
- **FIX**: relax dart SDK constraints in pubspec.yaml files. ([269ad7f2](https://github.com/devaryakjha/tagflow/commit/269ad7f2be0f7c1ae9846f2a2bb99a17cfb73e93))
- **FIX**: correct parent tag reference in ListItemConverter. ([a85fdc6e](https://github.com/devaryakjha/tagflow/commit/a85fdc6edf7dfea0100efc55c697008e0a5726d0))
- **FIX**: improve whitespace handling in TagflowParser. ([a6e879ea](https://github.com/devaryakjha/tagflow/commit/a6e879ea6b675ac8d0a15d40202ff07231d7b3f4))
- **FEAT**: enhance TagflowOptions and add comprehensive tests for TagflowSelectableOptions. ([c53515ef](https://github.com/devaryakjha/tagflow/commit/c53515ef72719bb9ff260e5c6f5aa2d1ba46973f))
- **FEAT**: add comprehensive tests for ListConverter, TagflowElement, StyleParser, and TagflowTheme. ([b867e392](https://github.com/devaryakjha/tagflow/commit/b867e392cb85bc30443113b434b8419ab34693e4))
- **FEAT**: refactor CodeConverter to extend TextConverter and support additional tags. ([af6fb055](https://github.com/devaryakjha/tagflow/commit/af6fb055f1cf9df87a090ddf5bf0e78ac218e521))
- **FEAT**: enhance TagflowTheme with maxWidth support for code styles. ([19d2c04f](https://github.com/devaryakjha/tagflow/commit/19d2c04f134309e11562d708db4163d650ce40c9))
- **FEAT**: enhance TextConverter to support forced widget spans for specific tags. ([d1497247](https://github.com/devaryakjha/tagflow/commit/d149724717985e1782d123784d1e65a9a694b8a5))
- **FEAT**: add list and list item converters to enhance element handling. ([fdff6059](https://github.com/devaryakjha/tagflow/commit/fdff6059f8fc6a115e0cfc37db2e5a79c551da4f))
- **FEAT**: enhance selector handling in ElementConverter to support negation. ([e9f04b29](https://github.com/devaryakjha/tagflow/commit/e9f04b29605b58df3f9df77b8304a8367dc5c9e2))
- **FEAT**: improve blockquote styling and add nested style support in Tagflow. ([f408c96e](https://github.com/devaryakjha/tagflow/commit/f408c96e075d5ef7e69f2e049d3d0887fabfc478))
- **FEAT**: enhance blockquote handling and theme styling in Tagflow. ([d25c51d6](https://github.com/devaryakjha/tagflow/commit/d25c51d6d2090bd71ef0143f04b8c33392f96401))
- **FEAT**: add article example and enhance blockquote handling in Tagflow. ([94017d32](https://github.com/devaryakjha/tagflow/commit/94017d32e6ef40199e14a2d4c6274ccfda93daee))
- **FEAT**: enhance Tagflow styling and text handling. ([e6e323a0](https://github.com/devaryakjha/tagflow/commit/e6e323a098b58636f42a0e84e5aa19e8eb828849))
- **FEAT**: enhance text handling and styling in Tagflow. ([5110c930](https://github.com/devaryakjha/tagflow/commit/5110c930c92a96055dcffa62553d677ac463a79b))
- **FEAT**: add support for anchor tags in TextConverter. ([69d5c11b](https://github.com/devaryakjha/tagflow/commit/69d5c11b9de473b979ae5422357b2f0805a8f8d2))
- **FEAT**: enhance TagflowTheme with inline code margin and improved default styles. ([5ecb55c6](https://github.com/devaryakjha/tagflow/commit/5ecb55c6a09828205054f15d8c1a84892c02c864))
- **FEAT**: refactor Tagflow example app by removing GenericExample and adding TypographyExample. ([37da572b](https://github.com/devaryakjha/tagflow/commit/37da572b83d1f74a2bee2fc3a0445f9757678af0))
- **FEAT**: enhance Tagflow example app with improved HTML content and theming options. ([d2f3194d](https://github.com/devaryakjha/tagflow/commit/d2f3194d662284e5aa22e0bcd614461484f7d635))
- **FEAT**: add Makefile for package creation and update README. ([854129af](https://github.com/devaryakjha/tagflow/commit/854129af0ff8e746de719fcba09e1ddd242a0bbe))
- **FEAT**: enhance Tagflow example app with new example and improved theming. ([94455e3c](https://github.com/devaryakjha/tagflow/commit/94455e3caeb74d6aecd7f2eb1ec9d00558b5b622))

## 0.0.1-dev.5

- **REFACTOR**: enhance blockquote handling and styling in ArticleExample and converters. ([f0ea898b](https://github.com/devaryakjha/tagflow/commit/f0ea898b027d948be2a3b1182408de9f683d9794))
- **REFACTOR**: improve whitespace handling and node validation in TagflowParser. ([685f611d](https://github.com/devaryakjha/tagflow/commit/685f611da0ba98d112422d367bb1755025fc15d2))
- **REFACTOR**: simplify StyledContainer by consolidating style application into a single Container. ([f348677f](https://github.com/devaryakjha/tagflow/commit/f348677f380b25494cb0604261d5616d00ec0322))
- **REFACTOR**(tests): remove redundant test for empty node creation in element_test.dart. ([42259a51](https://github.com/devaryakjha/tagflow/commit/42259a5171fa463f1d299c0c018987a8b6422da7))
- **REFACTOR**: improved tests. ([5ed3bd53](https://github.com/devaryakjha/tagflow/commit/5ed3bd536748a152ea414e842b561c6570ea7bb8))
- **FIX**: correct parent tag reference in ListItemConverter. ([a85fdc6e](https://github.com/devaryakjha/tagflow/commit/a85fdc6edf7dfea0100efc55c697008e0a5726d0))
- **FIX**: improve whitespace handling in TagflowParser. ([a6e879ea](https://github.com/devaryakjha/tagflow/commit/a6e879ea6b675ac8d0a15d40202ff07231d7b3f4))
- **FIX**: checkout to head branch wasn't working properly. ([431906a0](https://github.com/devaryakjha/tagflow/commit/431906a0eecdcd6d33efd89a75c70a6566b4d9b7))
- **FIX**: changelogs. ([5ba34a8d](https://github.com/devaryakjha/tagflow/commit/5ba34a8d3bc7d02bee0036ee0bac6f37f7f67329))
- **FEAT**: add comprehensive tests for ListConverter, TagflowElement, StyleParser, and TagflowTheme. ([b867e392](https://github.com/devaryakjha/tagflow/commit/b867e392cb85bc30443113b434b8419ab34693e4))
- **FEAT**: refactor CodeConverter to extend TextConverter and support additional tags. ([af6fb055](https://github.com/devaryakjha/tagflow/commit/af6fb055f1cf9df87a090ddf5bf0e78ac218e521))
- **FEAT**: enhance TagflowTheme with maxWidth support for code styles. ([19d2c04f](https://github.com/devaryakjha/tagflow/commit/19d2c04f134309e11562d708db4163d650ce40c9))
- **FEAT**: enhance TextConverter to support forced widget spans for specific tags. ([d1497247](https://github.com/devaryakjha/tagflow/commit/d149724717985e1782d123784d1e65a9a694b8a5))
- **FEAT**: add list and list item converters to enhance element handling. ([fdff6059](https://github.com/devaryakjha/tagflow/commit/fdff6059f8fc6a115e0cfc37db2e5a79c551da4f))
- **FEAT**: enhance selector handling in ElementConverter to support negation. ([e9f04b29](https://github.com/devaryakjha/tagflow/commit/e9f04b29605b58df3f9df77b8304a8367dc5c9e2))
- **FEAT**: improve blockquote styling and add nested style support in Tagflow. ([f408c96e](https://github.com/devaryakjha/tagflow/commit/f408c96e075d5ef7e69f2e049d3d0887fabfc478))
- **FEAT**: enhance blockquote handling and theme styling in Tagflow. ([d25c51d6](https://github.com/devaryakjha/tagflow/commit/d25c51d6d2090bd71ef0143f04b8c33392f96401))
- **FEAT**: add article example and enhance blockquote handling in Tagflow. ([94017d32](https://github.com/devaryakjha/tagflow/commit/94017d32e6ef40199e14a2d4c6274ccfda93daee))
- **FEAT**: enhance Tagflow styling and text handling. ([e6e323a0](https://github.com/devaryakjha/tagflow/commit/e6e323a098b58636f42a0e84e5aa19e8eb828849))
- **FEAT**: enhance text handling and styling in Tagflow. ([5110c930](https://github.com/devaryakjha/tagflow/commit/5110c930c92a96055dcffa62553d677ac463a79b))
- **FEAT**: add support for anchor tags in TextConverter. ([69d5c11b](https://github.com/devaryakjha/tagflow/commit/69d5c11b9de473b979ae5422357b2f0805a8f8d2))
- **FEAT**: enhance TagflowTheme with inline code margin and improved default styles. ([5ecb55c6](https://github.com/devaryakjha/tagflow/commit/5ecb55c6a09828205054f15d8c1a84892c02c864))
- **FEAT**: refactor Tagflow example app by removing GenericExample and adding TypographyExample. ([37da572b](https://github.com/devaryakjha/tagflow/commit/37da572b83d1f74a2bee2fc3a0445f9757678af0))
- **FEAT**: enhance Tagflow example app with improved HTML content and theming options. ([d2f3194d](https://github.com/devaryakjha/tagflow/commit/d2f3194d662284e5aa22e0bcd614461484f7d635))
- **FEAT**: add Makefile for package creation and update README. ([854129af](https://github.com/devaryakjha/tagflow/commit/854129af0ff8e746de719fcba09e1ddd242a0bbe))
- **FEAT**: enhance Tagflow example app with new example and improved theming. ([94455e3c](https://github.com/devaryakjha/tagflow/commit/94455e3caeb74d6aecd7f2eb1ec9d00558b5b622))

## 0.0.1-dev.4

- Inital version after renaming from `html_to_flutter` to `tagflow`.
