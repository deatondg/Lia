import TemplateDescription

let template = Template(
    parameters: {"parameters"},
    key: {"key"},
    syntax: .init(
        comment: .init(open: {"comment.open"}, close: {"comment.close"})
    )
)
