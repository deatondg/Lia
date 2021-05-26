import LiaDescription

let description = LiaDescription(
    actions: [
        .render(
            bundles: {
                "render_bundle"
                "shared_bundle"
            },
            toPath: {"render_path"}),
        .build(bundles: {
                "package_bundle"
                "shared_bundle"
            },
            toPath: {"package_path"},
            as: .package(name: {"package_name"})),
        .build(bundles: {
                "package_bundle"
                "shared_bundle"
            },
            toPath: {"sources_path"},
            as: .sources())
    ],
    bundles: [
        .bundle(
            name: {"render_bundle"},
            path: {"render_bundle_path"},
            includeSources: {false},
            allowInlineHeaders: {false},
            templateExtension: {"render_template_extension"},
            headerExtension: {"render_header_extension"},
            unknownFileMethod: .error(),
            ignoreDotFiles: {false},
            identifierConversionMethod: .fail(),
            defaultParameters: {"render_default_parameters"},
            defaultSyntax: .init(
                value: .init(open: {"render_value_open"}, close: {"render_value_close"}),
                code: .init(open: {"render_code_open"}, close: {"render_code_close"}),
                comment: .init(open: {"render_comment_open"}, close: {"render_comment_close"})
            )
        ),
        .bundle(
            name: {"package_bundle"},
            path: {"package_bundle_path"},
            includeSources: {true},
            allowInlineHeaders: {true},
            templateExtension: {"package_template_extension"},
            headerExtension: {"package_header_extension"},
            unknownFileMethod: .ignore(),
            ignoreDotFiles: {true},
            identifierConversionMethod: .replaceOrPrefixWithUnderscores(),
            defaultParameters: {"package_default_parameters"},
            defaultSyntax: .init(
                value: .init(open: {"package_value_open"}, close: {"package_value_close"}),
                code: .init(open: {"package_code_open"}, close: {"package_code_close"}),
                comment: .init(open: {"package_comment_open"}, close: {"package_comment_close"})
            )
        ),
        .bundle(
            name: {"shared_bundle"},
            path: {"shared_bundle_path"},
            includeSources: {true},
            allowInlineHeaders: {false},
            templateExtension: .none(),
            headerExtension: .none(),
            unknownFileMethod: .error(),
            ignoreDotFiles: {true},
            identifierConversionMethod: .fail(),
            defaultParameters: {"shared_default_parameters"},
            defaultSyntax: .init(
                value: .init(open: {"shared_value_open"}, close: {"shared_value_close"}),
                code: .init(open: {"shared_code_open"}, close: {"shared_code_close"}),
                comment: .init(open: {"shared_comment_open"}, close: {"shared_comment_close"})
            )
        )
    ]
)
