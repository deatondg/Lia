import Parsers
import Foundation

struct TemplateHeaderAndBodyParser: ParserFromBuilder {
    typealias Output = (header: String?, body: String)
    enum Failure: Error {
        case noNewlineAfterBeginDelimeter
        case noNewlineBeforeEndDelimeter
        case noNewlineAfterEndDelimeter
        case unexpectedBeginDelimeter
        case incorrectEndDelimeter
        case noEndDelimeter
    }
    
    struct BlankLineParser: ParserFromBuilder {
        typealias Output = ()
        typealias Failure = NoMatchFailure
        
        // TODO: Is this safe?
        let blankLineExpression = try! NSRegularExpression(pattern: #"\s*\n"#, options: [])
        
        var parser: Parser<(), NoMatchFailure> {
            blankLineExpression.prefixParser().ignoreOutputs()
        }
    }
    struct HeaderBeginParser: ParserFromBuilder {
        typealias Output = Int
        enum Failure: Error {
            case noHeader
            case noNewlineAfterBeginDelimeter
        }
        
        // TODO: Is this safe?
        let startExpression = try! NSRegularExpression(pattern: #"\{(#+)"#, options: [])
        
        var parser: Parser<Int, Failure> {
            AllOf {
                startExpression.prefixParser()
                BlankLineParser()
            }
            .map({ (match, _) -> Int in
                let hashtags = match[1]!.count
                assert(hashtags > 0)
                assert(match[1]!.allSatisfy({ $0 == "#" }))
                return hashtags
            })
            .mapFailures({ f -> Failure in
                switch f {
                case .c0:
                    return .noHeader
                case .c1:
                    return .noNewlineAfterBeginDelimeter
                }
            })
        }
    }
    struct NextHeaderEndParser: ParserFromBuilder {
        typealias Output = Substring
        typealias Failure = TemplateHeaderAndBodyParser.Failure
        
        let hashtags: Int
        let endExpression: NSRegularExpression
        init(hashtags: Int) {
            self.hashtags = hashtags
            self.endExpression = try! NSRegularExpression(
                pattern: ##"(?: ( \{ \# {\##(hashtags),} ) | ( \# {\##(hashtags),} \} ) )"##,
                options: [.allowCommentsAndWhitespace]
            )
        }
        
        var parser: Parser<Substring, Failure> {
            AllOf {
                endExpression.nextMatchParser().map({ (content, match) -> Result<Substring, Failure> in
                    assert(match[1...].filter({ $0 != nil}).count == 1)
                    assert( (match.range(at: 2) == nil) == (match[2] == nil) )
                    guard let endRange = match.range(at: 2),
                          let end = match[2]
                    else {
                        return .failure(.unexpectedBeginDelimeter)
                    }
                    guard end.count == hashtags + 1 else {
                        return .failure(.incorrectEndDelimeter)
                    }
                    guard match.string[match.string.index(before: endRange.lowerBound)] == "\n" else {
                        return .failure(.noNewlineBeforeEndDelimeter)
                    }
                    return .success(content)
                })
                BlankLineParser()
            }
            .map(\.0)
            .mapFailures({ f -> Failure in
                switch f {
                case .c0(let f):
                    switch f {
                    case .parseFailure:
                        return .noEndDelimeter
                    case .mapFailure(let f):
                        return f
                    }
                case .c1:
                    return .noNewlineAfterEndDelimeter
                }
            })
        }
    }
    
    var parser: Parser<(header: String?, body: String), Failure> {
        AllOf {
            HeaderBeginParser().flatMap(NextHeaderEndParser.init)
            Parsers.remainder()
        }
        .map({ (header, body) -> (header: String?, body: String) in
            (String(header), String(body))
        })
        .catch({ f -> Result<Parser<(header: String?, body: String), Never>, Failure> in
            switch f {
            case .c0(let f):
                switch f {
                case .outerFailure(.noHeader):
                    return .success(Parsers.remainder().map({ (header: nil, body: String($0)) }))
                case .outerFailure(.noNewlineAfterBeginDelimeter):
                    return .failure(.noNewlineAfterBeginDelimeter)
                case .innerFailure(let f):
                    return .failure(f)
                }
            }
        })
    }
}