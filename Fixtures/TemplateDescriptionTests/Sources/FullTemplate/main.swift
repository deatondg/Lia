import TemplateDescription

let template = Template(
    parameters: {"parameters"},
    key: {"key"},
    identifier: {"identifier"},
    syntax: .init(
        value: .init(open: {"value.open"}, close: {"value.close"}),
        code: .init(open: {"code.open"}, close: {"code.close"}),
        comment: .init(open: {"comment.open"}, close: {"comment.close"})
    )
)
