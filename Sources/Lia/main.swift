let file = """
Hello abcdefg {% hello this is
    some code %}
blah {{ a value }}
no this is not a comment {# but this is #}
"""

let (template, remainder) = try Template.parse(from: file)
guard remainder.isEmpty else {
    fatalError()
}
print(template)
