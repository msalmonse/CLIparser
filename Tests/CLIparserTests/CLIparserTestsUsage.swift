//
//  OptGetterTestsUsage.swift
//  
//
//  Created by Michael Salmon on 2021-05-21.
//

import XCTest
@testable import CLIparser

extension CLIparserTests {
    // count the number of \n by removing them
    // this may be one less than expected as usage strings have no \n at the end
    func nlCount(_ text: String) -> Int {
        return text.count - text.replacingOccurrences(of: "\n", with: "").count
    }

    func maxLineLength(_ text: String) -> Int {
        let lines = text.components(separatedBy: "\n")
        return lines.map { $0.count }.max() ?? -1
    }

    func testUsage1() {
        let opts = [
            OptToGet(short: "a", long: "adam", usage: "select adam like things", argTag: "<thing>"),
            OptToGet(long: "bertil", usage: "what Bertil does", argTag: "<things bertil does>"),
            OptToGet(long: "hidden", options: [.hidden], usage: "hidden option"),
            OptToGet(short: "d", usage: "set debug flag")
        ]
        let expected = """
            !-a, --adam <thing>     select adam like things
            !--bertil <things bertil does>
            !                       what Bertil does
            !-d                     set debug flag
            """
        let expected0 = expected.replacingOccurrences(of: "!", with: "")
        let expected2 = expected.replacingOccurrences(of: "!", with: "  ")
        let expected4 = expected.replacingOccurrences(of: "!", with: "    ")

        var usage = Usage(tagLeft: 0, textLeft: 23).optUsage(opts)
        XCTAssertEqual(usage, expected0)

        usage = Usage().optUsage(opts)
        XCTAssertEqual(usage, expected2)

        usage = Usage(tagLeft: 4, textLeft: 27).optUsage(opts)
        XCTAssertEqual(usage, expected4)
    }

    func testUsage2() {
        let opts = [
            OptToGet(short: "a", long: "adam", usage: "select adam like things", argTag: "<thing>"),
            OptToGet(long: "bertil", usage: "what Bertil does", argTag: "<things bertil does>"),
            OptToGet(long: "hidden", options: [.hidden], usage: "hidden option"),
            OptToGet(short: "d", usage: "set debug flag")
        ]
        let expected = """
            !--adam, -a <thing>     select adam like things
            !--bertil <things bertil does>
            !                       what Bertil does
            !-d                     set debug flag
            """
        let expected2 = expected.replacingOccurrences(of: "!", with: "  ")

        let usage = Usage().optUsage(opts, options: [.longFirst])
        XCTAssertEqual(usage, expected2)
    }

    func testUsage3() {
        let opts = [
            OptToGet(long: "adam", usage: "long only option\nwith second line")
        ]
        let expected =
            """
              -adam                  long only option
                                     with second line
            """

        let usage = Usage().optUsage(opts, options: [.longOnly])
        XCTAssertEqual(usage, expected)
    }

    func testUsageAKA() {
        let opts = [
            OptToGet(long: "adam", aka: ["eve", "cain", "able"], usage: "long only option")
        ]
        let expected =
            """
              -adam                  long only option
               aka: eve, cain, able
            """

        let usage = Usage().optUsage(opts, options: [.longOnly])
        XCTAssertEqual(usage, expected)
    }

    func testUsageENV () {
        let opts = [
            OptToGet(long: "adam", usage: "long only option", env: "ADAM")
        ]
        let expected =
            """
              -adam                  long only option
               environment variable: ADAM
            """

        let usage = Usage().optUsage(opts, options: [.longOnly])
        XCTAssertEqual(usage, expected)
    }

    func testUsagePositional() {
        let opts = [
            OptToGet(usage: "input file name", argTag: "<input>"),
            OptToGet(usage: "file name", argTag: "<output>")
        ]
        let expected = """
              <input>                input file name
              <output>               file name
            """
        let usage = Usage().positionalUsage(opts)
        // print(usage); print(expected)
        XCTAssertEqual(usage, expected)
    }

    func testWrap() {
        let opts1 = [
            OptToGet(
                long: "veryVeryLongOptionName",
                usage: "this is how to use a veryVeryLongOptionName and argument",
                argTag: "[optional but long option argument]"
            )
        ]

        // check for breaking into 4 lines
        var usage = Usage(tagLeft: 5, textLeft: 15, textRight: 35, gap: 5).optUsage(opts1)
        // print(usage)
        // print(usage.count)
        XCTAssertEqual(usage.count, 167)
        XCTAssertEqual(nlCount(usage), 3)

        // check for breaking into 2 lines
        usage = Usage(tagLeft: 5, textLeft: 15, textRight: 80, gap: 5).optUsage(opts1)
        // print(usage)
        // print(usage.count)
        XCTAssertEqual(usage.count, 137)
        XCTAssertEqual(nlCount(usage), 1)

        let opts2 = [
            OptToGet(
                long: "veryVeryLongOptionName",
                usage: "this is\u{11}how to use a\u{11}veryVeryLongOptionName and argument",
                argTag: "[optional but long option argument]"
            )
        ]

        // check for breaking into 4 lines including on the newline
        // this should break at the second \u{11} character
        usage = Usage(tagLeft: 5, textLeft: 15, textRight: 35, gap: 5).optUsage(opts2)
        // print(usage)
        // print(crc8(usage))
        XCTAssertEqual(crc8(usage), 243)
        XCTAssertEqual(nlCount(usage), 3)

        // check for breaking into 2 lines
        // \u{11} ignored as the string fits between left and right
        usage = Usage(tagLeft: 5, textLeft: 15, textRight: 80, gap: 5).optUsage(opts2)
        // print(usage)
        // print(crc8(usage))
        XCTAssertEqual(crc8(usage), 202)
        XCTAssertEqual(nlCount(usage), 1)
    }

    func testCmdUsage() {
        let cmds = [
            CmdToGet(["adam", "bertil", "zoe"], usage: "this is what adam does with bertil and zoe"),
            CmdToGet(["david"]),
            CmdToGet(["adam"], usage: "this is what adam does"),
            CmdToGet(["cindy"], usage: "cindy does it too"),
            CmdToGet([], usage: "nothing to do")
        ]

        let usage = Usage(tagLeft: 5, textLeft: 15, textRight: 35).cmdUsage(cmds)
        // print(usage)
        // print(crc8(usage))
        XCTAssertEqual(crc8(usage), 111)
    }

    // swiftlint:disable function_body_length
    func testParaWrap() {
        let paras = [
            "Short line!",
            "",
            """
            [32]
            But I must explain to you how all this mistaken idea of reprobating pleasure and extolling pain
            arose. To do so, I will give you a complete account of the system, and expound the actual teachings of
            the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes or
            avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue
            pleasure rationally encounter consequences that are extremely painful. Nor again is there anyone who
            loves or pursues or desires to obtain pain of itself, because it is pain, but occasionally
            circumstances occur in which toil and pain can procure him some great pleasure. To take a trivial
            example, which of us ever undertakes laborious physical exercise, except to obtain some advantage from
            it? But who has any right to find fault with a man who chooses to enjoy a pleasure that has no annoying
            consequences, or one who avoids a pain that produces no resultant pleasure?
            """,
            """
            [33]
            On the other hand, we denounce with righteous indignation and dislike men who are so beguiled and
            demoralized by the charms of pleasure of the moment, so blinded by desire, that they cannot foresee the
            pain and trouble that are bound to ensue; and equal blame belongs to those who fail in their duty
            through weakness of will, which is the same as saying through shrinking from toil and pain. These cases
            are perfectly simple and easy to distinguish. In a free hour, when our power of choice is untrammeled
            and when nothing prevents our being able to do what we like best, every pleasure is to be welcomed and
            every pain avoided. But in certain circumstances and owing to the claims of duty or the obligations of
            business it will frequently occur that pleasures have to be repudiated and annoyances accepted. The
            wise man therefore always holds in these matters to this principle of selection: he rejects pleasures
            to secure other greater pleasures, or else he endures pains to avoid worse pains.
            """,
            "",
            """
            [32]
            Sed ut perspiciatis, unde omnis iste natus error sit voluptatem accusantium doloremque laudantium,
            totam rem aperiam eaque ipsa, quae ab illo inventore veritatis et quasi architecto beatae vitae dicta
            sunt, explicabo. Nemo enim ipsam voluptatem, quia voluptas sit, aspernatur aut odit aut fugit, sed quia
            consequuntur magni dolores eos, qui ratione voluptatem sequi nesciunt, neque porro quisquam est, qui do
            lorem ipsum, quia dolor sit amet consectetur adipisci[ng] velit, sed quia non numquam [do] eius modi
            tempora inci[di]dunt, ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam,
            quis nostrum[d] exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi
            consequatur? [D]Quis autem vel eum iure reprehenderit, qui in ea voluptate velit esse, quam nihil
            molestiae consequatur, vel illum, qui dolorem eum fugiat, quo voluptas nulla pariatur?
            """,
            """
            [33]
            At vero eos et accusamus et iusto odio dignissimos ducimus, qui blanditiis praesentium voluptatum
            deleniti atque corrupti, quos dolores et quas molestias excepturi sint, obcaecati cupiditate non
            provident, similique sunt in culpa, qui officia deserunt mollitia animi, id est laborum et dolorum
            fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis
            est eligendi optio, cumque nihil impedit, quo minus id, quod maxime placeat, facere possimus, omnis
            voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut
            rerum necessitatibus saepe eveniet, ut et voluptates repudiandae sint et molestiae non recusandae.
            Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias
            consequatur aut perferendis doloribus asperiores repellat.
            """
        ]
        var wrapped = Usage(textLeft: 5, textRight: 55).paragraphWrap(paras)
        // print(wrapped)
        // print(crc8(wrapped))
        XCTAssertEqual(crc8(wrapped), 128)
        XCTAssertEqual(nlCount(wrapped), 83)

        wrapped = Usage(textLeft: 0, textRight: 50).paragraphWrap(paras)
        // print(wrapped)
        // print(crc8(wrapped))
        XCTAssertEqual(crc8(wrapped), 19)
        XCTAssertEqual(nlCount(wrapped), 83)
    }
}
