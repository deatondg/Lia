let file = """
{#
    name: Davis
    args: file: File, rootIdentifier: SwiftIdentifier
    key: ###
#}
Hello abcdefg
"""

print(try Template.Header.parse(from: file))
