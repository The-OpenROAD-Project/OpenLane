# This is a load-only version of pyyaml so the tools under dependencies can run without PIP.

# Copyright (c) 2017-2021 Ingy döt Net
# Copyright (c) 2006-2016 Kirill Simonov
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
import codecs, collections.abc, datetime, base64, binascii, re, sys, types

__version__ = "6.0-flattened"

## error.py
class Mark:
    def __init__(self, name, index, line, column, buffer, pointer):
        self.name = name
        self.index = index
        self.line = line
        self.column = column
        self.buffer = buffer
        self.pointer = pointer

    def get_snippet(self, indent=4, max_length=75):
        if self.buffer is None:
            return None
        head = ""
        start = self.pointer
        while start > 0 and self.buffer[start - 1] not in "\0\r\n\x85\u2028\u2029":
            start -= 1
            if self.pointer - start > max_length / 2 - 1:
                head = " ... "
                start += 5
                break
        tail = ""
        end = self.pointer
        while (
            end < len(self.buffer) and self.buffer[end] not in "\0\r\n\x85\u2028\u2029"
        ):
            end += 1
            if end - self.pointer > max_length / 2 - 1:
                tail = " ... "
                end -= 5
                break
        snippet = self.buffer[start:end]
        return (
            " " * indent
            + head
            + snippet
            + tail
            + "\n"
            + " " * (indent + self.pointer - start + len(head))
            + "^"
        )

    def __str__(self):
        snippet = self.get_snippet()
        where = '  in "%s", line %d, column %d' % (
            self.name,
            self.line + 1,
            self.column + 1,
        )
        if snippet is not None:
            where += ":\n" + snippet
        return where


class YAMLError(Exception):
    pass


class MarkedYAMLError(YAMLError):
    def __init__(
        self,
        context=None,
        context_mark=None,
        problem=None,
        problem_mark=None,
        note=None,
    ):
        self.context = context
        self.context_mark = context_mark
        self.problem = problem
        self.problem_mark = problem_mark
        self.note = note

    def __str__(self):
        lines = []
        if self.context is not None:
            lines.append(self.context)
        if self.context_mark is not None and (
            self.problem is None
            or self.problem_mark is None
            or self.context_mark.name != self.problem_mark.name
            or self.context_mark.line != self.problem_mark.line
            or self.context_mark.column != self.problem_mark.column
        ):
            lines.append(str(self.context_mark))
        if self.problem is not None:
            lines.append(self.problem)
        if self.problem_mark is not None:
            lines.append(str(self.problem_mark))
        if self.note is not None:
            lines.append(self.note)
        return "\n".join(lines)


## nodes.py


class Node(object):
    def __init__(self, tag, value, start_mark, end_mark):
        self.tag = tag
        self.value = value
        self.start_mark = start_mark
        self.end_mark = end_mark

    def __repr__(self):
        value = self.value
        # if isinstance(value, list):
        #    if len(value) == 0:
        #        value = '<empty>'
        #    elif len(value) == 1:
        #        value = '<1 item>'
        #    else:
        #        value = '<%d items>' % len(value)
        # else:
        #    if len(value) > 75:
        #        value = repr(value[:70]+u' ... ')
        #    else:
        #        value = repr(value)
        value = repr(value)
        return "%s(tag=%r, value=%s)" % (self.__class__.__name__, self.tag, value)


class ScalarNode(Node):
    id = "scalar"

    def __init__(self, tag, value, start_mark=None, end_mark=None, style=None):
        self.tag = tag
        self.value = value
        self.start_mark = start_mark
        self.end_mark = end_mark
        self.style = style


class CollectionNode(Node):
    def __init__(self, tag, value, start_mark=None, end_mark=None, flow_style=None):
        self.tag = tag
        self.value = value
        self.start_mark = start_mark
        self.end_mark = end_mark
        self.flow_style = flow_style


class SequenceNode(CollectionNode):
    id = "sequence"


class MappingNode(CollectionNode):
    id = "mapping"


## tokens.py


class Token(object):
    def __init__(self, start_mark, end_mark):
        self.start_mark = start_mark
        self.end_mark = end_mark

    def __repr__(self):
        attributes = [key for key in self.__dict__ if not key.endswith("_mark")]
        attributes.sort()
        arguments = ", ".join(
            ["%s=%r" % (key, getattr(self, key)) for key in attributes]
        )
        return "%s(%s)" % (self.__class__.__name__, arguments)


# class BOMToken(Token):
#    id = '<byte order mark>'


class DirectiveToken(Token):
    id = "<directive>"

    def __init__(self, name, value, start_mark, end_mark):
        self.name = name
        self.value = value
        self.start_mark = start_mark
        self.end_mark = end_mark


class DocumentStartToken(Token):
    id = "<document start>"


class DocumentEndToken(Token):
    id = "<document end>"


class StreamStartToken(Token):
    id = "<stream start>"

    def __init__(self, start_mark=None, end_mark=None, encoding=None):
        self.start_mark = start_mark
        self.end_mark = end_mark
        self.encoding = encoding


class StreamEndToken(Token):
    id = "<stream end>"


class BlockSequenceStartToken(Token):
    id = "<block sequence start>"


class BlockMappingStartToken(Token):
    id = "<block mapping start>"


class BlockEndToken(Token):
    id = "<block end>"


class FlowSequenceStartToken(Token):
    id = "["


class FlowMappingStartToken(Token):
    id = "{"


class FlowSequenceEndToken(Token):
    id = "]"


class FlowMappingEndToken(Token):
    id = "}"


class KeyToken(Token):
    id = "?"


class ValueToken(Token):
    id = ":"


class BlockEntryToken(Token):
    id = "-"


class FlowEntryToken(Token):
    id = ","


class AliasToken(Token):
    id = "<alias>"

    def __init__(self, value, start_mark, end_mark):
        self.value = value
        self.start_mark = start_mark
        self.end_mark = end_mark


class AnchorToken(Token):
    id = "<anchor>"

    def __init__(self, value, start_mark, end_mark):
        self.value = value
        self.start_mark = start_mark
        self.end_mark = end_mark


class TagToken(Token):
    id = "<tag>"

    def __init__(self, value, start_mark, end_mark):
        self.value = value
        self.start_mark = start_mark
        self.end_mark = end_mark


class ScalarToken(Token):
    id = "<scalar>"

    def __init__(self, value, plain, start_mark, end_mark, style=None):
        self.value = value
        self.plain = plain
        self.start_mark = start_mark
        self.end_mark = end_mark
        self.style = style


## events.py


# Abstract classes.


class Event(object):
    def __init__(self, start_mark=None, end_mark=None):
        self.start_mark = start_mark
        self.end_mark = end_mark

    def __repr__(self):
        attributes = [
            key for key in ["anchor", "tag", "implicit", "value"] if hasattr(self, key)
        ]
        arguments = ", ".join(
            ["%s=%r" % (key, getattr(self, key)) for key in attributes]
        )
        return "%s(%s)" % (self.__class__.__name__, arguments)


class NodeEvent(Event):
    def __init__(self, anchor, start_mark=None, end_mark=None):
        self.anchor = anchor
        self.start_mark = start_mark
        self.end_mark = end_mark


class CollectionStartEvent(NodeEvent):
    def __init__(
        self, anchor, tag, implicit, start_mark=None, end_mark=None, flow_style=None
    ):
        self.anchor = anchor
        self.tag = tag
        self.implicit = implicit
        self.start_mark = start_mark
        self.end_mark = end_mark
        self.flow_style = flow_style


class CollectionEndEvent(Event):
    pass


# Implementations.


class StreamStartEvent(Event):
    def __init__(self, start_mark=None, end_mark=None, encoding=None):
        self.start_mark = start_mark
        self.end_mark = end_mark
        self.encoding = encoding


class StreamEndEvent(Event):
    pass


class DocumentStartEvent(Event):
    def __init__(
        self, start_mark=None, end_mark=None, explicit=None, version=None, tags=None
    ):
        self.start_mark = start_mark
        self.end_mark = end_mark
        self.explicit = explicit
        self.version = version
        self.tags = tags


class DocumentEndEvent(Event):
    def __init__(self, start_mark=None, end_mark=None, explicit=None):
        self.start_mark = start_mark
        self.end_mark = end_mark
        self.explicit = explicit


class AliasEvent(NodeEvent):
    pass


class ScalarEvent(NodeEvent):
    def __init__(
        self, anchor, tag, implicit, value, start_mark=None, end_mark=None, style=None
    ):
        self.anchor = anchor
        self.tag = tag
        self.implicit = implicit
        self.value = value
        self.start_mark = start_mark
        self.end_mark = end_mark
        self.style = style


class SequenceStartEvent(CollectionStartEvent):
    pass


class SequenceEndEvent(CollectionEndEvent):
    pass


class MappingStartEvent(CollectionStartEvent):
    pass


class MappingEndEvent(CollectionEndEvent):
    pass


## reader.py
class ReaderError(YAMLError):
    def __init__(self, name, position, character, encoding, reason):
        self.name = name
        self.character = character
        self.position = position
        self.encoding = encoding
        self.reason = reason

    def __str__(self):
        if isinstance(self.character, bytes):
            return (
                "'%s' codec can't decode byte #x%02x: %s\n"
                '  in "%s", position %d'
                % (
                    self.encoding,
                    ord(self.character),
                    self.reason,
                    self.name,
                    self.position,
                )
            )
        else:
            return "unacceptable character #x%04x: %s\n" '  in "%s", position %d' % (
                self.character,
                self.reason,
                self.name,
                self.position,
            )


class Reader(object):
    # Reader:
    # - determines the data encoding and converts it to a unicode string,
    # - checks if characters are in allowed range,
    # - adds '\0' to the end.

    # Reader accepts
    #  - a `bytes` object,
    #  - a `str` object,
    #  - a file-like object with its `read` method returning `str`,
    #  - a file-like object with its `read` method returning `unicode`.

    # Yeah, it's ugly and slow.

    def __init__(self, stream):
        self.name = None
        self.stream = None
        self.stream_pointer = 0
        self.eof = True
        self.buffer = ""
        self.pointer = 0
        self.raw_buffer = None
        self.raw_decode = None
        self.encoding = None
        self.index = 0
        self.line = 0
        self.column = 0
        if isinstance(stream, str):
            self.name = "<unicode string>"
            self.check_printable(stream)
            self.buffer = stream + "\0"
        elif isinstance(stream, bytes):
            self.name = "<byte string>"
            self.raw_buffer = stream
            self.determine_encoding()
        else:
            self.stream = stream
            self.name = getattr(stream, "name", "<file>")
            self.eof = False
            self.raw_buffer = None
            self.determine_encoding()

    def peek(self, index=0):
        try:
            return self.buffer[self.pointer + index]
        except IndexError:
            self.update(index + 1)
            return self.buffer[self.pointer + index]

    def prefix(self, length=1):
        if self.pointer + length >= len(self.buffer):
            self.update(length)
        return self.buffer[self.pointer : self.pointer + length]

    def forward(self, length=1):
        if self.pointer + length + 1 >= len(self.buffer):
            self.update(length + 1)
        while length:
            ch = self.buffer[self.pointer]
            self.pointer += 1
            self.index += 1
            if ch in "\n\x85\u2028\u2029" or (
                ch == "\r" and self.buffer[self.pointer] != "\n"
            ):
                self.line += 1
                self.column = 0
            elif ch != "\uFEFF":
                self.column += 1
            length -= 1

    def get_mark(self):
        if self.stream is None:
            return Mark(
                self.name, self.index, self.line, self.column, self.buffer, self.pointer
            )
        else:
            return Mark(self.name, self.index, self.line, self.column, None, None)

    def determine_encoding(self):
        while not self.eof and (self.raw_buffer is None or len(self.raw_buffer) < 2):
            self.update_raw()
        if isinstance(self.raw_buffer, bytes):
            if self.raw_buffer.startswith(codecs.BOM_UTF16_LE):
                self.raw_decode = codecs.utf_16_le_decode
                self.encoding = "utf-16-le"
            elif self.raw_buffer.startswith(codecs.BOM_UTF16_BE):
                self.raw_decode = codecs.utf_16_be_decode
                self.encoding = "utf-16-be"
            else:
                self.raw_decode = codecs.utf_8_decode
                self.encoding = "utf-8"
        self.update(1)

    NON_PRINTABLE = re.compile(
        "[^\x09\x0A\x0D\x20-\x7E\x85\xA0-\uD7FF\uE000-\uFFFD\U00010000-\U0010ffff]"
    )

    def check_printable(self, data):
        match = self.NON_PRINTABLE.search(data)
        if match:
            character = match.group()
            position = self.index + (len(self.buffer) - self.pointer) + match.start()
            raise ReaderError(
                self.name,
                position,
                ord(character),
                "unicode",
                "special characters are not allowed",
            )

    def update(self, length):
        if self.raw_buffer is None:
            return
        self.buffer = self.buffer[self.pointer :]
        self.pointer = 0
        while len(self.buffer) < length:
            if not self.eof:
                self.update_raw()
            if self.raw_decode is not None:
                try:
                    data, converted = self.raw_decode(
                        self.raw_buffer, "strict", self.eof
                    )
                except UnicodeDecodeError as exc:
                    character = self.raw_buffer[exc.start]
                    if self.stream is not None:
                        position = (
                            self.stream_pointer - len(self.raw_buffer) + exc.start
                        )
                    else:
                        position = exc.start
                    raise ReaderError(
                        self.name, position, character, exc.encoding, exc.reason
                    )
            else:
                data = self.raw_buffer
                converted = len(data)
            self.check_printable(data)
            self.buffer += data
            self.raw_buffer = self.raw_buffer[converted:]
            if self.eof:
                self.buffer += "\0"
                self.raw_buffer = None
                break

    def update_raw(self, size=4096):
        data = self.stream.read(size)
        if self.raw_buffer is None:
            self.raw_buffer = data
        else:
            self.raw_buffer += data
        self.stream_pointer += len(data)
        if not data:
            self.eof = True


## scanner.py
class ScannerError(MarkedYAMLError):
    pass


class SimpleKey:
    # See below simple keys treatment.

    def __init__(self, token_number, required, index, line, column, mark):
        self.token_number = token_number
        self.required = required
        self.index = index
        self.line = line
        self.column = column
        self.mark = mark


class Scanner:
    def __init__(self):
        """Initialize the scanner."""
        # It is assumed that Scanner and Reader will have a common descendant.
        # Reader do the dirty work of checking for BOM and converting the
        # input data to Unicode. It also adds NUL to the end.
        #
        # Reader supports the following methods
        #   self.peek(i=0)       # peek the next i-th character
        #   self.prefix(l=1)     # peek the next l characters
        #   self.forward(l=1)    # read the next l characters and move the pointer.

        # Had we reached the end of the stream?
        self.done = False

        # The number of unclosed '{' and '['. `flow_level == 0` means block
        # context.
        self.flow_level = 0

        # List of processed tokens that are not yet emitted.
        self.tokens = []

        # Add the STREAM-START token.
        self.fetch_stream_start()

        # Number of tokens that were emitted through the `get_token` method.
        self.tokens_taken = 0

        # The current indentation level.
        self.indent = -1

        # Past indentation levels.
        self.indents = []

        # Variables related to simple keys treatment.

        # A simple key is a key that is not denoted by the '?' indicator.
        # Example of simple keys:
        #   ---
        #   block simple key: value
        #   ? not a simple key:
        #   : { flow simple key: value }
        # We emit the KEY token before all keys, so when we find a potential
        # simple key, we try to locate the corresponding ':' indicator.
        # Simple keys should be limited to a single line and 1024 characters.

        # Can a simple key start at the current position? A simple key may
        # start:
        # - at the beginning of the line, not counting indentation spaces
        #       (in block context),
        # - after '{', '[', ',' (in the flow context),
        # - after '?', ':', '-' (in the block context).
        # In the block context, this flag also signifies if a block collection
        # may start at the current position.
        self.allow_simple_key = True

        # Keep track of possible simple keys. This is a dictionary. The key
        # is `flow_level`; there can be no more that one possible simple key
        # for each level. The value is a SimpleKey record:
        #   (token_number, required, index, line, column, mark)
        # A simple key may start with ALIAS, ANCHOR, TAG, SCALAR(flow),
        # '[', or '{' tokens.
        self.possible_simple_keys = {}

    # Public methods.

    def check_token(self, *choices):
        # Check if the next token is one of the given types.
        while self.need_more_tokens():
            self.fetch_more_tokens()
        if self.tokens:
            if not choices:
                return True
            for choice in choices:
                if isinstance(self.tokens[0], choice):
                    return True
        return False

    def peek_token(self):
        # Return the next token, but do not delete if from the queue.
        # Return None if no more tokens.
        while self.need_more_tokens():
            self.fetch_more_tokens()
        if self.tokens:
            return self.tokens[0]
        else:
            return None

    def get_token(self):
        # Return the next token.
        while self.need_more_tokens():
            self.fetch_more_tokens()
        if self.tokens:
            self.tokens_taken += 1
            return self.tokens.pop(0)

    # Private methods.

    def need_more_tokens(self):
        if self.done:
            return False
        if not self.tokens:
            return True
        # The current token may be a potential simple key, so we
        # need to look further.
        self.stale_possible_simple_keys()
        if self.next_possible_simple_key() == self.tokens_taken:
            return True

    def fetch_more_tokens(self):

        # Eat whitespaces and comments until we reach the next token.
        self.scan_to_next_token()

        # Remove obsolete possible simple keys.
        self.stale_possible_simple_keys()

        # Compare the current indentation and column. It may add some tokens
        # and decrease the current indentation level.
        self.unwind_indent(self.column)

        # Peek the next character.
        ch = self.peek()

        # Is it the end of stream?
        if ch == "\0":
            return self.fetch_stream_end()

        # Is it a directive?
        if ch == "%" and self.check_directive():
            return self.fetch_directive()

        # Is it the document start?
        if ch == "-" and self.check_document_start():
            return self.fetch_document_start()

        # Is it the document end?
        if ch == "." and self.check_document_end():
            return self.fetch_document_end()

        # TODO: support for BOM within a stream.
        # if ch == '\uFEFF':
        #    return self.fetch_bom()    <-- issue BOMToken

        # Note: the order of the following checks is NOT significant.

        # Is it the flow sequence start indicator?
        if ch == "[":
            return self.fetch_flow_sequence_start()

        # Is it the flow mapping start indicator?
        if ch == "{":
            return self.fetch_flow_mapping_start()

        # Is it the flow sequence end indicator?
        if ch == "]":
            return self.fetch_flow_sequence_end()

        # Is it the flow mapping end indicator?
        if ch == "}":
            return self.fetch_flow_mapping_end()

        # Is it the flow entry indicator?
        if ch == ",":
            return self.fetch_flow_entry()

        # Is it the block entry indicator?
        if ch == "-" and self.check_block_entry():
            return self.fetch_block_entry()

        # Is it the key indicator?
        if ch == "?" and self.check_key():
            return self.fetch_key()

        # Is it the value indicator?
        if ch == ":" and self.check_value():
            return self.fetch_value()

        # Is it an alias?
        if ch == "*":
            return self.fetch_alias()

        # Is it an anchor?
        if ch == "&":
            return self.fetch_anchor()

        # Is it a tag?
        if ch == "!":
            return self.fetch_tag()

        # Is it a literal scalar?
        if ch == "|" and not self.flow_level:
            return self.fetch_literal()

        # Is it a folded scalar?
        if ch == ">" and not self.flow_level:
            return self.fetch_folded()

        # Is it a single quoted scalar?
        if ch == "'":
            return self.fetch_single()

        # Is it a double quoted scalar?
        if ch == '"':
            return self.fetch_double()

        # It must be a plain scalar then.
        if self.check_plain():
            return self.fetch_plain()

        # No? It's an error. Let's produce a nice error message.
        raise ScannerError(
            "while scanning for the next token",
            None,
            "found character %r that cannot start any token" % ch,
            self.get_mark(),
        )

    # Simple keys treatment.

    def next_possible_simple_key(self):
        # Return the number of the nearest possible simple key. Actually we
        # don't need to loop through the whole dictionary. We may replace it
        # with the following code:
        #   if not self.possible_simple_keys:
        #       return None
        #   return self.possible_simple_keys[
        #           min(self.possible_simple_keys.keys())].token_number
        min_token_number = None
        for level in self.possible_simple_keys:
            key = self.possible_simple_keys[level]
            if min_token_number is None or key.token_number < min_token_number:
                min_token_number = key.token_number
        return min_token_number

    def stale_possible_simple_keys(self):
        # Remove entries that are no longer possible simple keys. According to
        # the YAML specification, simple keys
        # - should be limited to a single line,
        # - should be no longer than 1024 characters.
        # Disabling this procedure will allow simple keys of any length and
        # height (may cause problems if indentation is broken though).
        for level in list(self.possible_simple_keys):
            key = self.possible_simple_keys[level]
            if key.line != self.line or self.index - key.index > 1024:
                if key.required:
                    raise ScannerError(
                        "while scanning a simple key",
                        key.mark,
                        "could not find expected ':'",
                        self.get_mark(),
                    )
                del self.possible_simple_keys[level]

    def save_possible_simple_key(self):
        # The next token may start a simple key. We check if it's possible
        # and save its position. This function is called for
        #   ALIAS, ANCHOR, TAG, SCALAR(flow), '[', and '{'.

        # Check if a simple key is required at the current position.
        required = not self.flow_level and self.indent == self.column

        # The next token might be a simple key. Let's save it's number and
        # position.
        if self.allow_simple_key:
            self.remove_possible_simple_key()
            token_number = self.tokens_taken + len(self.tokens)
            key = SimpleKey(
                token_number,
                required,
                self.index,
                self.line,
                self.column,
                self.get_mark(),
            )
            self.possible_simple_keys[self.flow_level] = key

    def remove_possible_simple_key(self):
        # Remove the saved possible key position at the current flow level.
        if self.flow_level in self.possible_simple_keys:
            key = self.possible_simple_keys[self.flow_level]

            if key.required:
                raise ScannerError(
                    "while scanning a simple key",
                    key.mark,
                    "could not find expected ':'",
                    self.get_mark(),
                )

            del self.possible_simple_keys[self.flow_level]

    # Indentation functions.

    def unwind_indent(self, column):

        ## In flow context, tokens should respect indentation.
        ## Actually the condition should be `self.indent >= column` according to
        ## the spec. But this condition will prohibit intuitively correct
        ## constructions such as
        ## key : {
        ## }
        # if self.flow_level and self.indent > column:
        #    raise ScannerError(None, None,
        #            "invalid indentation or unclosed '[' or '{'",
        #            self.get_mark())

        # In the flow context, indentation is ignored. We make the scanner less
        # restrictive then specification requires.
        if self.flow_level:
            return

        # In block context, we may need to issue the BLOCK-END tokens.
        while self.indent > column:
            mark = self.get_mark()
            self.indent = self.indents.pop()
            self.tokens.append(BlockEndToken(mark, mark))

    def add_indent(self, column):
        # Check if we need to increase indentation.
        if self.indent < column:
            self.indents.append(self.indent)
            self.indent = column
            return True
        return False

    # Fetchers.

    def fetch_stream_start(self):
        # We always add STREAM-START as the first token and STREAM-END as the
        # last token.

        # Read the token.
        mark = self.get_mark()

        # Add STREAM-START.
        self.tokens.append(StreamStartToken(mark, mark, encoding=self.encoding))

    def fetch_stream_end(self):

        # Set the current indentation to -1.
        self.unwind_indent(-1)

        # Reset simple keys.
        self.remove_possible_simple_key()
        self.allow_simple_key = False
        self.possible_simple_keys = {}

        # Read the token.
        mark = self.get_mark()

        # Add STREAM-END.
        self.tokens.append(StreamEndToken(mark, mark))

        # The steam is finished.
        self.done = True

    def fetch_directive(self):

        # Set the current indentation to -1.
        self.unwind_indent(-1)

        # Reset simple keys.
        self.remove_possible_simple_key()
        self.allow_simple_key = False

        # Scan and add DIRECTIVE.
        self.tokens.append(self.scan_directive())

    def fetch_document_start(self):
        self.fetch_document_indicator(DocumentStartToken)

    def fetch_document_end(self):
        self.fetch_document_indicator(DocumentEndToken)

    def fetch_document_indicator(self, TokenClass):

        # Set the current indentation to -1.
        self.unwind_indent(-1)

        # Reset simple keys. Note that there could not be a block collection
        # after '---'.
        self.remove_possible_simple_key()
        self.allow_simple_key = False

        # Add DOCUMENT-START or DOCUMENT-END.
        start_mark = self.get_mark()
        self.forward(3)
        end_mark = self.get_mark()
        self.tokens.append(TokenClass(start_mark, end_mark))

    def fetch_flow_sequence_start(self):
        self.fetch_flow_collection_start(FlowSequenceStartToken)

    def fetch_flow_mapping_start(self):
        self.fetch_flow_collection_start(FlowMappingStartToken)

    def fetch_flow_collection_start(self, TokenClass):

        # '[' and '{' may start a simple key.
        self.save_possible_simple_key()

        # Increase the flow level.
        self.flow_level += 1

        # Simple keys are allowed after '[' and '{'.
        self.allow_simple_key = True

        # Add FLOW-SEQUENCE-START or FLOW-MAPPING-START.
        start_mark = self.get_mark()
        self.forward()
        end_mark = self.get_mark()
        self.tokens.append(TokenClass(start_mark, end_mark))

    def fetch_flow_sequence_end(self):
        self.fetch_flow_collection_end(FlowSequenceEndToken)

    def fetch_flow_mapping_end(self):
        self.fetch_flow_collection_end(FlowMappingEndToken)

    def fetch_flow_collection_end(self, TokenClass):

        # Reset possible simple key on the current level.
        self.remove_possible_simple_key()

        # Decrease the flow level.
        self.flow_level -= 1

        # No simple keys after ']' or '}'.
        self.allow_simple_key = False

        # Add FLOW-SEQUENCE-END or FLOW-MAPPING-END.
        start_mark = self.get_mark()
        self.forward()
        end_mark = self.get_mark()
        self.tokens.append(TokenClass(start_mark, end_mark))

    def fetch_flow_entry(self):

        # Simple keys are allowed after ','.
        self.allow_simple_key = True

        # Reset possible simple key on the current level.
        self.remove_possible_simple_key()

        # Add FLOW-ENTRY.
        start_mark = self.get_mark()
        self.forward()
        end_mark = self.get_mark()
        self.tokens.append(FlowEntryToken(start_mark, end_mark))

    def fetch_block_entry(self):

        # Block context needs additional checks.
        if not self.flow_level:

            # Are we allowed to start a new entry?
            if not self.allow_simple_key:
                raise ScannerError(
                    None, None, "sequence entries are not allowed here", self.get_mark()
                )

            # We may need to add BLOCK-SEQUENCE-START.
            if self.add_indent(self.column):
                mark = self.get_mark()
                self.tokens.append(BlockSequenceStartToken(mark, mark))

        # It's an error for the block entry to occur in the flow context,
        # but we let the parser detect this.
        else:
            pass

        # Simple keys are allowed after '-'.
        self.allow_simple_key = True

        # Reset possible simple key on the current level.
        self.remove_possible_simple_key()

        # Add BLOCK-ENTRY.
        start_mark = self.get_mark()
        self.forward()
        end_mark = self.get_mark()
        self.tokens.append(BlockEntryToken(start_mark, end_mark))

    def fetch_key(self):

        # Block context needs additional checks.
        if not self.flow_level:

            # Are we allowed to start a key (not necessary a simple)?
            if not self.allow_simple_key:
                raise ScannerError(
                    None, None, "mapping keys are not allowed here", self.get_mark()
                )

            # We may need to add BLOCK-MAPPING-START.
            if self.add_indent(self.column):
                mark = self.get_mark()
                self.tokens.append(BlockMappingStartToken(mark, mark))

        # Simple keys are allowed after '?' in the block context.
        self.allow_simple_key = not self.flow_level

        # Reset possible simple key on the current level.
        self.remove_possible_simple_key()

        # Add KEY.
        start_mark = self.get_mark()
        self.forward()
        end_mark = self.get_mark()
        self.tokens.append(KeyToken(start_mark, end_mark))

    def fetch_value(self):

        # Do we determine a simple key?
        if self.flow_level in self.possible_simple_keys:

            # Add KEY.
            key = self.possible_simple_keys[self.flow_level]
            del self.possible_simple_keys[self.flow_level]
            self.tokens.insert(
                key.token_number - self.tokens_taken, KeyToken(key.mark, key.mark)
            )

            # If this key starts a new block mapping, we need to add
            # BLOCK-MAPPING-START.
            if not self.flow_level:
                if self.add_indent(key.column):
                    self.tokens.insert(
                        key.token_number - self.tokens_taken,
                        BlockMappingStartToken(key.mark, key.mark),
                    )

            # There cannot be two simple keys one after another.
            self.allow_simple_key = False

        # It must be a part of a complex key.
        else:

            # Block context needs additional checks.
            # (Do we really need them? They will be caught by the parser
            # anyway.)
            if not self.flow_level:

                # We are allowed to start a complex value if and only if
                # we can start a simple key.
                if not self.allow_simple_key:
                    raise ScannerError(
                        None,
                        None,
                        "mapping values are not allowed here",
                        self.get_mark(),
                    )

            # If this value starts a new block mapping, we need to add
            # BLOCK-MAPPING-START.  It will be detected as an error later by
            # the parser.
            if not self.flow_level:
                if self.add_indent(self.column):
                    mark = self.get_mark()
                    self.tokens.append(BlockMappingStartToken(mark, mark))

            # Simple keys are allowed after ':' in the block context.
            self.allow_simple_key = not self.flow_level

            # Reset possible simple key on the current level.
            self.remove_possible_simple_key()

        # Add VALUE.
        start_mark = self.get_mark()
        self.forward()
        end_mark = self.get_mark()
        self.tokens.append(ValueToken(start_mark, end_mark))

    def fetch_alias(self):

        # ALIAS could be a simple key.
        self.save_possible_simple_key()

        # No simple keys after ALIAS.
        self.allow_simple_key = False

        # Scan and add ALIAS.
        self.tokens.append(self.scan_anchor(AliasToken))

    def fetch_anchor(self):

        # ANCHOR could start a simple key.
        self.save_possible_simple_key()

        # No simple keys after ANCHOR.
        self.allow_simple_key = False

        # Scan and add ANCHOR.
        self.tokens.append(self.scan_anchor(AnchorToken))

    def fetch_tag(self):

        # TAG could start a simple key.
        self.save_possible_simple_key()

        # No simple keys after TAG.
        self.allow_simple_key = False

        # Scan and add TAG.
        self.tokens.append(self.scan_tag())

    def fetch_literal(self):
        self.fetch_block_scalar(style="|")

    def fetch_folded(self):
        self.fetch_block_scalar(style=">")

    def fetch_block_scalar(self, style):

        # A simple key may follow a block scalar.
        self.allow_simple_key = True

        # Reset possible simple key on the current level.
        self.remove_possible_simple_key()

        # Scan and add SCALAR.
        self.tokens.append(self.scan_block_scalar(style))

    def fetch_single(self):
        self.fetch_flow_scalar(style="'")

    def fetch_double(self):
        self.fetch_flow_scalar(style='"')

    def fetch_flow_scalar(self, style):

        # A flow scalar could be a simple key.
        self.save_possible_simple_key()

        # No simple keys after flow scalars.
        self.allow_simple_key = False

        # Scan and add SCALAR.
        self.tokens.append(self.scan_flow_scalar(style))

    def fetch_plain(self):

        # A plain scalar could be a simple key.
        self.save_possible_simple_key()

        # No simple keys after plain scalars. But note that `scan_plain` will
        # change this flag if the scan is finished at the beginning of the
        # line.
        self.allow_simple_key = False

        # Scan and add SCALAR. May change `allow_simple_key`.
        self.tokens.append(self.scan_plain())

    # Checkers.

    def check_directive(self):

        # DIRECTIVE:        ^ '%' ...
        # The '%' indicator is already checked.
        if self.column == 0:
            return True

    def check_document_start(self):

        # DOCUMENT-START:   ^ '---' (' '|'\n')
        if self.column == 0:
            if self.prefix(3) == "---" and self.peek(3) in "\0 \t\r\n\x85\u2028\u2029":
                return True

    def check_document_end(self):

        # DOCUMENT-END:     ^ '...' (' '|'\n')
        if self.column == 0:
            if self.prefix(3) == "..." and self.peek(3) in "\0 \t\r\n\x85\u2028\u2029":
                return True

    def check_block_entry(self):

        # BLOCK-ENTRY:      '-' (' '|'\n')
        return self.peek(1) in "\0 \t\r\n\x85\u2028\u2029"

    def check_key(self):

        # KEY(flow context):    '?'
        if self.flow_level:
            return True

        # KEY(block context):   '?' (' '|'\n')
        else:
            return self.peek(1) in "\0 \t\r\n\x85\u2028\u2029"

    def check_value(self):

        # VALUE(flow context):  ':'
        if self.flow_level:
            return True

        # VALUE(block context): ':' (' '|'\n')
        else:
            return self.peek(1) in "\0 \t\r\n\x85\u2028\u2029"

    def check_plain(self):

        # A plain scalar may start with any non-space character except:
        #   '-', '?', ':', ',', '[', ']', '{', '}',
        #   '#', '&', '*', '!', '|', '>', '\'', '\"',
        #   '%', '@', '`'.
        #
        # It may also start with
        #   '-', '?', ':'
        # if it is followed by a non-space character.
        #
        # Note that we limit the last rule to the block context (except the
        # '-' character) because we want the flow context to be space
        # independent.
        ch = self.peek()
        return ch not in "\0 \t\r\n\x85\u2028\u2029-?:,[]{}#&*!|>'\"%@`" or (
            self.peek(1) not in "\0 \t\r\n\x85\u2028\u2029"
            and (ch == "-" or (not self.flow_level and ch in "?:"))
        )

    # Scanners.

    def scan_to_next_token(self):
        # We ignore spaces, line breaks and comments.
        # If we find a line break in the block context, we set the flag
        # `allow_simple_key` on.
        # The byte order mark is stripped if it's the first character in the
        # stream. We do not yet support BOM inside the stream as the
        # specification requires. Any such mark will be considered as a part
        # of the document.
        #
        # TODO: We need to make tab handling rules more sane. A good rule is
        #   Tabs cannot precede tokens
        #   BLOCK-SEQUENCE-START, BLOCK-MAPPING-START, BLOCK-END,
        #   KEY(block), VALUE(block), BLOCK-ENTRY
        # So the checking code is
        #   if <TAB>:
        #       self.allow_simple_keys = False
        # We also need to add the check for `allow_simple_keys == True` to
        # `unwind_indent` before issuing BLOCK-END.
        # Scanners for block, flow, and plain scalars need to be modified.

        if self.index == 0 and self.peek() == "\uFEFF":
            self.forward()
        found = False
        while not found:
            while self.peek() == " ":
                self.forward()
            if self.peek() == "#":
                while self.peek() not in "\0\r\n\x85\u2028\u2029":
                    self.forward()
            if self.scan_line_break():
                if not self.flow_level:
                    self.allow_simple_key = True
            else:
                found = True

    def scan_directive(self):
        # See the specification for details.
        start_mark = self.get_mark()
        self.forward()
        name = self.scan_directive_name(start_mark)
        value = None
        if name == "YAML":
            value = self.scan_yaml_directive_value(start_mark)
            end_mark = self.get_mark()
        elif name == "TAG":
            value = self.scan_tag_directive_value(start_mark)
            end_mark = self.get_mark()
        else:
            end_mark = self.get_mark()
            while self.peek() not in "\0\r\n\x85\u2028\u2029":
                self.forward()
        self.scan_directive_ignored_line(start_mark)
        return DirectiveToken(name, value, start_mark, end_mark)

    def scan_directive_name(self, start_mark):
        # See the specification for details.
        length = 0
        ch = self.peek(length)
        while "0" <= ch <= "9" or "A" <= ch <= "Z" or "a" <= ch <= "z" or ch in "-_":
            length += 1
            ch = self.peek(length)
        if not length:
            raise ScannerError(
                "while scanning a directive",
                start_mark,
                "expected alphabetic or numeric character, but found %r" % ch,
                self.get_mark(),
            )
        value = self.prefix(length)
        self.forward(length)
        ch = self.peek()
        if ch not in "\0 \r\n\x85\u2028\u2029":
            raise ScannerError(
                "while scanning a directive",
                start_mark,
                "expected alphabetic or numeric character, but found %r" % ch,
                self.get_mark(),
            )
        return value

    def scan_yaml_directive_value(self, start_mark):
        # See the specification for details.
        while self.peek() == " ":
            self.forward()
        major = self.scan_yaml_directive_number(start_mark)
        if self.peek() != ".":
            raise ScannerError(
                "while scanning a directive",
                start_mark,
                "expected a digit or '.', but found %r" % self.peek(),
                self.get_mark(),
            )
        self.forward()
        minor = self.scan_yaml_directive_number(start_mark)
        if self.peek() not in "\0 \r\n\x85\u2028\u2029":
            raise ScannerError(
                "while scanning a directive",
                start_mark,
                "expected a digit or ' ', but found %r" % self.peek(),
                self.get_mark(),
            )
        return (major, minor)

    def scan_yaml_directive_number(self, start_mark):
        # See the specification for details.
        ch = self.peek()
        if not ("0" <= ch <= "9"):
            raise ScannerError(
                "while scanning a directive",
                start_mark,
                "expected a digit, but found %r" % ch,
                self.get_mark(),
            )
        length = 0
        while "0" <= self.peek(length) <= "9":
            length += 1
        value = int(self.prefix(length))
        self.forward(length)
        return value

    def scan_tag_directive_value(self, start_mark):
        # See the specification for details.
        while self.peek() == " ":
            self.forward()
        handle = self.scan_tag_directive_handle(start_mark)
        while self.peek() == " ":
            self.forward()
        prefix = self.scan_tag_directive_prefix(start_mark)
        return (handle, prefix)

    def scan_tag_directive_handle(self, start_mark):
        # See the specification for details.
        value = self.scan_tag_handle("directive", start_mark)
        ch = self.peek()
        if ch != " ":
            raise ScannerError(
                "while scanning a directive",
                start_mark,
                "expected ' ', but found %r" % ch,
                self.get_mark(),
            )
        return value

    def scan_tag_directive_prefix(self, start_mark):
        # See the specification for details.
        value = self.scan_tag_uri("directive", start_mark)
        ch = self.peek()
        if ch not in "\0 \r\n\x85\u2028\u2029":
            raise ScannerError(
                "while scanning a directive",
                start_mark,
                "expected ' ', but found %r" % ch,
                self.get_mark(),
            )
        return value

    def scan_directive_ignored_line(self, start_mark):
        # See the specification for details.
        while self.peek() == " ":
            self.forward()
        if self.peek() == "#":
            while self.peek() not in "\0\r\n\x85\u2028\u2029":
                self.forward()
        ch = self.peek()
        if ch not in "\0\r\n\x85\u2028\u2029":
            raise ScannerError(
                "while scanning a directive",
                start_mark,
                "expected a comment or a line break, but found %r" % ch,
                self.get_mark(),
            )
        self.scan_line_break()

    def scan_anchor(self, TokenClass):
        # The specification does not restrict characters for anchors and
        # aliases. This may lead to problems, for instance, the document:
        #   [ *alias, value ]
        # can be interpreted in two ways, as
        #   [ "value" ]
        # and
        #   [ *alias , "value" ]
        # Therefore we restrict aliases to numbers and ASCII letters.
        start_mark = self.get_mark()
        indicator = self.peek()
        if indicator == "*":
            name = "alias"
        else:
            name = "anchor"
        self.forward()
        length = 0
        ch = self.peek(length)
        while "0" <= ch <= "9" or "A" <= ch <= "Z" or "a" <= ch <= "z" or ch in "-_":
            length += 1
            ch = self.peek(length)
        if not length:
            raise ScannerError(
                "while scanning an %s" % name,
                start_mark,
                "expected alphabetic or numeric character, but found %r" % ch,
                self.get_mark(),
            )
        value = self.prefix(length)
        self.forward(length)
        ch = self.peek()
        if ch not in "\0 \t\r\n\x85\u2028\u2029?:,]}%@`":
            raise ScannerError(
                "while scanning an %s" % name,
                start_mark,
                "expected alphabetic or numeric character, but found %r" % ch,
                self.get_mark(),
            )
        end_mark = self.get_mark()
        return TokenClass(value, start_mark, end_mark)

    def scan_tag(self):
        # See the specification for details.
        start_mark = self.get_mark()
        ch = self.peek(1)
        if ch == "<":
            handle = None
            self.forward(2)
            suffix = self.scan_tag_uri("tag", start_mark)
            if self.peek() != ">":
                raise ScannerError(
                    "while parsing a tag",
                    start_mark,
                    "expected '>', but found %r" % self.peek(),
                    self.get_mark(),
                )
            self.forward()
        elif ch in "\0 \t\r\n\x85\u2028\u2029":
            handle = None
            suffix = "!"
            self.forward()
        else:
            length = 1
            use_handle = False
            while ch not in "\0 \r\n\x85\u2028\u2029":
                if ch == "!":
                    use_handle = True
                    break
                length += 1
                ch = self.peek(length)
            handle = "!"
            if use_handle:
                handle = self.scan_tag_handle("tag", start_mark)
            else:
                handle = "!"
                self.forward()
            suffix = self.scan_tag_uri("tag", start_mark)
        ch = self.peek()
        if ch not in "\0 \r\n\x85\u2028\u2029":
            raise ScannerError(
                "while scanning a tag",
                start_mark,
                "expected ' ', but found %r" % ch,
                self.get_mark(),
            )
        value = (handle, suffix)
        end_mark = self.get_mark()
        return TagToken(value, start_mark, end_mark)

    def scan_block_scalar(self, style):
        # See the specification for details.

        if style == ">":
            folded = True
        else:
            folded = False

        chunks = []
        start_mark = self.get_mark()

        # Scan the header.
        self.forward()
        chomping, increment = self.scan_block_scalar_indicators(start_mark)
        self.scan_block_scalar_ignored_line(start_mark)

        # Determine the indentation level and go to the first non-empty line.
        min_indent = self.indent + 1
        if min_indent < 1:
            min_indent = 1
        if increment is None:
            breaks, max_indent, end_mark = self.scan_block_scalar_indentation()
            indent = max(min_indent, max_indent)
        else:
            indent = min_indent + increment - 1
            breaks, end_mark = self.scan_block_scalar_breaks(indent)
        line_break = ""

        # Scan the inner part of the block scalar.
        while self.column == indent and self.peek() != "\0":
            chunks.extend(breaks)
            leading_non_space = self.peek() not in " \t"
            length = 0
            while self.peek(length) not in "\0\r\n\x85\u2028\u2029":
                length += 1
            chunks.append(self.prefix(length))
            self.forward(length)
            line_break = self.scan_line_break()
            breaks, end_mark = self.scan_block_scalar_breaks(indent)
            if self.column == indent and self.peek() != "\0":

                # Unfortunately, folding rules are ambiguous.
                #
                # This is the folding according to the specification:

                if (
                    folded
                    and line_break == "\n"
                    and leading_non_space
                    and self.peek() not in " \t"
                ):
                    if not breaks:
                        chunks.append(" ")
                else:
                    chunks.append(line_break)

                # This is Clark Evans's interpretation (also in the spec
                # examples):
                #
                # if folded and line_break == '\n':
                #    if not breaks:
                #        if self.peek() not in ' \t':
                #            chunks.append(' ')
                #        else:
                #            chunks.append(line_break)
                # else:
                #    chunks.append(line_break)
            else:
                break

        # Chomp the tail.
        if chomping is not False:
            chunks.append(line_break)
        if chomping is True:
            chunks.extend(breaks)

        # We are done.
        return ScalarToken("".join(chunks), False, start_mark, end_mark, style)

    def scan_block_scalar_indicators(self, start_mark):
        # See the specification for details.
        chomping = None
        increment = None
        ch = self.peek()
        if ch in "+-":
            if ch == "+":
                chomping = True
            else:
                chomping = False
            self.forward()
            ch = self.peek()
            if ch in "0123456789":
                increment = int(ch)
                if increment == 0:
                    raise ScannerError(
                        "while scanning a block scalar",
                        start_mark,
                        "expected indentation indicator in the range 1-9, but found 0",
                        self.get_mark(),
                    )
                self.forward()
        elif ch in "0123456789":
            increment = int(ch)
            if increment == 0:
                raise ScannerError(
                    "while scanning a block scalar",
                    start_mark,
                    "expected indentation indicator in the range 1-9, but found 0",
                    self.get_mark(),
                )
            self.forward()
            ch = self.peek()
            if ch in "+-":
                if ch == "+":
                    chomping = True
                else:
                    chomping = False
                self.forward()
        ch = self.peek()
        if ch not in "\0 \r\n\x85\u2028\u2029":
            raise ScannerError(
                "while scanning a block scalar",
                start_mark,
                "expected chomping or indentation indicators, but found %r" % ch,
                self.get_mark(),
            )
        return chomping, increment

    def scan_block_scalar_ignored_line(self, start_mark):
        # See the specification for details.
        while self.peek() == " ":
            self.forward()
        if self.peek() == "#":
            while self.peek() not in "\0\r\n\x85\u2028\u2029":
                self.forward()
        ch = self.peek()
        if ch not in "\0\r\n\x85\u2028\u2029":
            raise ScannerError(
                "while scanning a block scalar",
                start_mark,
                "expected a comment or a line break, but found %r" % ch,
                self.get_mark(),
            )
        self.scan_line_break()

    def scan_block_scalar_indentation(self):
        # See the specification for details.
        chunks = []
        max_indent = 0
        end_mark = self.get_mark()
        while self.peek() in " \r\n\x85\u2028\u2029":
            if self.peek() != " ":
                chunks.append(self.scan_line_break())
                end_mark = self.get_mark()
            else:
                self.forward()
                if self.column > max_indent:
                    max_indent = self.column
        return chunks, max_indent, end_mark

    def scan_block_scalar_breaks(self, indent):
        # See the specification for details.
        chunks = []
        end_mark = self.get_mark()
        while self.column < indent and self.peek() == " ":
            self.forward()
        while self.peek() in "\r\n\x85\u2028\u2029":
            chunks.append(self.scan_line_break())
            end_mark = self.get_mark()
            while self.column < indent and self.peek() == " ":
                self.forward()
        return chunks, end_mark

    def scan_flow_scalar(self, style):
        # See the specification for details.
        # Note that we loose indentation rules for quoted scalars. Quoted
        # scalars don't need to adhere indentation because " and ' clearly
        # mark the beginning and the end of them. Therefore we are less
        # restrictive then the specification requires. We only need to check
        # that document separators are not included in scalars.
        if style == '"':
            double = True
        else:
            double = False
        chunks = []
        start_mark = self.get_mark()
        quote = self.peek()
        self.forward()
        chunks.extend(self.scan_flow_scalar_non_spaces(double, start_mark))
        while self.peek() != quote:
            chunks.extend(self.scan_flow_scalar_spaces(double, start_mark))
            chunks.extend(self.scan_flow_scalar_non_spaces(double, start_mark))
        self.forward()
        end_mark = self.get_mark()
        return ScalarToken("".join(chunks), False, start_mark, end_mark, style)

    ESCAPE_REPLACEMENTS = {
        "0": "\0",
        "a": "\x07",
        "b": "\x08",
        "t": "\x09",
        "\t": "\x09",
        "n": "\x0A",
        "v": "\x0B",
        "f": "\x0C",
        "r": "\x0D",
        "e": "\x1B",
        " ": "\x20",
        '"': '"',
        "\\": "\\",
        "/": "/",
        "N": "\x85",
        "_": "\xA0",
        "L": "\u2028",
        "P": "\u2029",
    }

    ESCAPE_CODES = {
        "x": 2,
        "u": 4,
        "U": 8,
    }

    def scan_flow_scalar_non_spaces(self, double, start_mark):
        # See the specification for details.
        chunks = []
        while True:
            length = 0
            while self.peek(length) not in "'\"\\\0 \t\r\n\x85\u2028\u2029":
                length += 1
            if length:
                chunks.append(self.prefix(length))
                self.forward(length)
            ch = self.peek()
            if not double and ch == "'" and self.peek(1) == "'":
                chunks.append("'")
                self.forward(2)
            elif (double and ch == "'") or (not double and ch in '"\\'):
                chunks.append(ch)
                self.forward()
            elif double and ch == "\\":
                self.forward()
                ch = self.peek()
                if ch in self.ESCAPE_REPLACEMENTS:
                    chunks.append(self.ESCAPE_REPLACEMENTS[ch])
                    self.forward()
                elif ch in self.ESCAPE_CODES:
                    length = self.ESCAPE_CODES[ch]
                    self.forward()
                    for k in range(length):
                        if self.peek(k) not in "0123456789ABCDEFabcdef":
                            raise ScannerError(
                                "while scanning a double-quoted scalar",
                                start_mark,
                                "expected escape sequence of %d hexadecimal numbers, but found %r"
                                % (length, self.peek(k)),
                                self.get_mark(),
                            )
                    code = int(self.prefix(length), 16)
                    chunks.append(chr(code))
                    self.forward(length)
                elif ch in "\r\n\x85\u2028\u2029":
                    self.scan_line_break()
                    chunks.extend(self.scan_flow_scalar_breaks(double, start_mark))
                else:
                    raise ScannerError(
                        "while scanning a double-quoted scalar",
                        start_mark,
                        "found unknown escape character %r" % ch,
                        self.get_mark(),
                    )
            else:
                return chunks

    def scan_flow_scalar_spaces(self, double, start_mark):
        # See the specification for details.
        chunks = []
        length = 0
        while self.peek(length) in " \t":
            length += 1
        whitespaces = self.prefix(length)
        self.forward(length)
        ch = self.peek()
        if ch == "\0":
            raise ScannerError(
                "while scanning a quoted scalar",
                start_mark,
                "found unexpected end of stream",
                self.get_mark(),
            )
        elif ch in "\r\n\x85\u2028\u2029":
            line_break = self.scan_line_break()
            breaks = self.scan_flow_scalar_breaks(double, start_mark)
            if line_break != "\n":
                chunks.append(line_break)
            elif not breaks:
                chunks.append(" ")
            chunks.extend(breaks)
        else:
            chunks.append(whitespaces)
        return chunks

    def scan_flow_scalar_breaks(self, double, start_mark):
        # See the specification for details.
        chunks = []
        while True:
            # Instead of checking indentation, we check for document
            # separators.
            prefix = self.prefix(3)
            if (prefix == "---" or prefix == "...") and self.peek(
                3
            ) in "\0 \t\r\n\x85\u2028\u2029":
                raise ScannerError(
                    "while scanning a quoted scalar",
                    start_mark,
                    "found unexpected document separator",
                    self.get_mark(),
                )
            while self.peek() in " \t":
                self.forward()
            if self.peek() in "\r\n\x85\u2028\u2029":
                chunks.append(self.scan_line_break())
            else:
                return chunks

    def scan_plain(self):
        # See the specification for details.
        # We add an additional restriction for the flow context:
        #   plain scalars in the flow context cannot contain ',' or '?'.
        # We also keep track of the `allow_simple_key` flag here.
        # Indentation rules are loosed for the flow context.
        chunks = []
        start_mark = self.get_mark()
        end_mark = start_mark
        indent = self.indent + 1
        # We allow zero indentation for scalars, but then we need to check for
        # document separators at the beginning of the line.
        # if indent == 0:
        #    indent = 1
        spaces = []
        while True:
            length = 0
            if self.peek() == "#":
                break
            while True:
                ch = self.peek(length)
                if (
                    ch in "\0 \t\r\n\x85\u2028\u2029"
                    or (
                        ch == ":"
                        and self.peek(length + 1)
                        in "\0 \t\r\n\x85\u2028\u2029"
                        + (",[]{}" if self.flow_level else "")
                    )
                    or (self.flow_level and ch in ",?[]{}")
                ):
                    break
                length += 1
            if length == 0:
                break
            self.allow_simple_key = False
            chunks.extend(spaces)
            chunks.append(self.prefix(length))
            self.forward(length)
            end_mark = self.get_mark()
            spaces = self.scan_plain_spaces(indent, start_mark)
            if (
                not spaces
                or self.peek() == "#"
                or (not self.flow_level and self.column < indent)
            ):
                break
        return ScalarToken("".join(chunks), True, start_mark, end_mark)

    def scan_plain_spaces(self, indent, start_mark):
        # See the specification for details.
        # The specification is really confusing about tabs in plain scalars.
        # We just forbid them completely. Do not use tabs in YAML!
        chunks = []
        length = 0
        while self.peek(length) in " ":
            length += 1
        whitespaces = self.prefix(length)
        self.forward(length)
        ch = self.peek()
        if ch in "\r\n\x85\u2028\u2029":
            line_break = self.scan_line_break()
            self.allow_simple_key = True
            prefix = self.prefix(3)
            if (prefix == "---" or prefix == "...") and self.peek(
                3
            ) in "\0 \t\r\n\x85\u2028\u2029":
                return
            breaks = []
            while self.peek() in " \r\n\x85\u2028\u2029":
                if self.peek() == " ":
                    self.forward()
                else:
                    breaks.append(self.scan_line_break())
                    prefix = self.prefix(3)
                    if (prefix == "---" or prefix == "...") and self.peek(
                        3
                    ) in "\0 \t\r\n\x85\u2028\u2029":
                        return
            if line_break != "\n":
                chunks.append(line_break)
            elif not breaks:
                chunks.append(" ")
            chunks.extend(breaks)
        elif whitespaces:
            chunks.append(whitespaces)
        return chunks

    def scan_tag_handle(self, name, start_mark):
        # See the specification for details.
        # For some strange reasons, the specification does not allow '_' in
        # tag handles. I have allowed it anyway.
        ch = self.peek()
        if ch != "!":
            raise ScannerError(
                "while scanning a %s" % name,
                start_mark,
                "expected '!', but found %r" % ch,
                self.get_mark(),
            )
        length = 1
        ch = self.peek(length)
        if ch != " ":
            while (
                "0" <= ch <= "9" or "A" <= ch <= "Z" or "a" <= ch <= "z" or ch in "-_"
            ):
                length += 1
                ch = self.peek(length)
            if ch != "!":
                self.forward(length)
                raise ScannerError(
                    "while scanning a %s" % name,
                    start_mark,
                    "expected '!', but found %r" % ch,
                    self.get_mark(),
                )
            length += 1
        value = self.prefix(length)
        self.forward(length)
        return value

    def scan_tag_uri(self, name, start_mark):
        # See the specification for details.
        # Note: we do not check if URI is well-formed.
        chunks = []
        length = 0
        ch = self.peek(length)
        while (
            "0" <= ch <= "9"
            or "A" <= ch <= "Z"
            or "a" <= ch <= "z"
            or ch in "-;/?:@&=+$,_.!~*'()[]%"
        ):
            if ch == "%":
                chunks.append(self.prefix(length))
                self.forward(length)
                length = 0
                chunks.append(self.scan_uri_escapes(name, start_mark))
            else:
                length += 1
            ch = self.peek(length)
        if length:
            chunks.append(self.prefix(length))
            self.forward(length)
            length = 0
        if not chunks:
            raise ScannerError(
                "while parsing a %s" % name,
                start_mark,
                "expected URI, but found %r" % ch,
                self.get_mark(),
            )
        return "".join(chunks)

    def scan_uri_escapes(self, name, start_mark):
        # See the specification for details.
        codes = []
        mark = self.get_mark()
        while self.peek() == "%":
            self.forward()
            for k in range(2):
                if self.peek(k) not in "0123456789ABCDEFabcdef":
                    raise ScannerError(
                        "while scanning a %s" % name,
                        start_mark,
                        "expected URI escape sequence of 2 hexadecimal numbers, but found %r"
                        % self.peek(k),
                        self.get_mark(),
                    )
            codes.append(int(self.prefix(2), 16))
            self.forward(2)
        try:
            value = bytes(codes).decode("utf-8")
        except UnicodeDecodeError as exc:
            raise ScannerError("while scanning a %s" % name, start_mark, str(exc), mark)
        return value

    def scan_line_break(self):
        # Transforms:
        #   '\r\n'      :   '\n'
        #   '\r'        :   '\n'
        #   '\n'        :   '\n'
        #   '\x85'      :   '\n'
        #   '\u2028'    :   '\u2028'
        #   '\u2029     :   '\u2029'
        #   default     :   ''
        ch = self.peek()
        if ch in "\r\n\x85":
            if self.prefix(2) == "\r\n":
                self.forward(2)
            else:
                self.forward()
            return "\n"
        elif ch in "\u2028\u2029":
            self.forward()
            return ch
        return ""


## parser.py
class ParserError(MarkedYAMLError):
    pass


class Parser:
    # Since writing a recursive-descendant parser is a straightforward task, we
    # do not give many comments here.

    DEFAULT_TAGS = {
        "!": "!",
        "!!": "tag:yaml.org,2002:",
    }

    def __init__(self):
        self.current_event = None
        self.yaml_version = None
        self.tag_handles = {}
        self.states = []
        self.marks = []
        self.state = self.parse_stream_start

    def dispose(self):
        # Reset the state attributes (to clear self-references)
        self.states = []
        self.state = None

    def check_event(self, *choices):
        # Check the type of the next event.
        if self.current_event is None:
            if self.state:
                self.current_event = self.state()
        if self.current_event is not None:
            if not choices:
                return True
            for choice in choices:
                if isinstance(self.current_event, choice):
                    return True
        return False

    def peek_event(self):
        # Get the next event.
        if self.current_event is None:
            if self.state:
                self.current_event = self.state()
        return self.current_event

    def get_event(self):
        # Get the next event and proceed further.
        if self.current_event is None:
            if self.state:
                self.current_event = self.state()
        value = self.current_event
        self.current_event = None
        return value

    # stream    ::= STREAM-START implicit_document? explicit_document* STREAM-END
    # implicit_document ::= block_node DOCUMENT-END*
    # explicit_document ::= DIRECTIVE* DOCUMENT-START block_node? DOCUMENT-END*

    def parse_stream_start(self):

        # Parse the stream start.
        token = self.get_token()
        event = StreamStartEvent(
            token.start_mark, token.end_mark, encoding=token.encoding
        )

        # Prepare the next state.
        self.state = self.parse_implicit_document_start

        return event

    def parse_implicit_document_start(self):

        # Parse an implicit document.
        if not self.check_token(DirectiveToken, DocumentStartToken, StreamEndToken):
            self.tag_handles = self.DEFAULT_TAGS
            token = self.peek_token()
            start_mark = end_mark = token.start_mark
            event = DocumentStartEvent(start_mark, end_mark, explicit=False)

            # Prepare the next state.
            self.states.append(self.parse_document_end)
            self.state = self.parse_block_node

            return event

        else:
            return self.parse_document_start()

    def parse_document_start(self):

        # Parse any extra document end indicators.
        while self.check_token(DocumentEndToken):
            self.get_token()

        # Parse an explicit document.
        if not self.check_token(StreamEndToken):
            token = self.peek_token()
            start_mark = token.start_mark
            version, tags = self.process_directives()
            if not self.check_token(DocumentStartToken):
                raise ParserError(
                    None,
                    None,
                    "expected '<document start>', but found %r" % self.peek_token().id,
                    self.peek_token().start_mark,
                )
            token = self.get_token()
            end_mark = token.end_mark
            event = DocumentStartEvent(
                start_mark, end_mark, explicit=True, version=version, tags=tags
            )
            self.states.append(self.parse_document_end)
            self.state = self.parse_document_content
        else:
            # Parse the end of the stream.
            token = self.get_token()
            event = StreamEndEvent(token.start_mark, token.end_mark)
            assert not self.states
            assert not self.marks
            self.state = None
        return event

    def parse_document_end(self):

        # Parse the document end.
        token = self.peek_token()
        start_mark = end_mark = token.start_mark
        explicit = False
        if self.check_token(DocumentEndToken):
            token = self.get_token()
            end_mark = token.end_mark
            explicit = True
        event = DocumentEndEvent(start_mark, end_mark, explicit=explicit)

        # Prepare the next state.
        self.state = self.parse_document_start

        return event

    def parse_document_content(self):
        if self.check_token(
            DirectiveToken, DocumentStartToken, DocumentEndToken, StreamEndToken
        ):
            event = self.process_empty_scalar(self.peek_token().start_mark)
            self.state = self.states.pop()
            return event
        else:
            return self.parse_block_node()

    def process_directives(self):
        self.yaml_version = None
        self.tag_handles = {}
        while self.check_token(DirectiveToken):
            token = self.get_token()
            if token.name == "YAML":
                if self.yaml_version is not None:
                    raise ParserError(
                        None, None, "found duplicate YAML directive", token.start_mark
                    )
                major, minor = token.value
                if major != 1:
                    raise ParserError(
                        None,
                        None,
                        "found incompatible YAML document (version 1.* is required)",
                        token.start_mark,
                    )
                self.yaml_version = token.value
            elif token.name == "TAG":
                handle, prefix = token.value
                if handle in self.tag_handles:
                    raise ParserError(
                        None, None, "duplicate tag handle %r" % handle, token.start_mark
                    )
                self.tag_handles[handle] = prefix
        if self.tag_handles:
            value = self.yaml_version, self.tag_handles.copy()
        else:
            value = self.yaml_version, None
        for key in self.DEFAULT_TAGS:
            if key not in self.tag_handles:
                self.tag_handles[key] = self.DEFAULT_TAGS[key]
        return value

    # block_node_or_indentless_sequence ::= ALIAS
    #               | properties (block_content | indentless_block_sequence)?
    #               | block_content
    #               | indentless_block_sequence
    # block_node    ::= ALIAS
    #                   | properties block_content?
    #                   | block_content
    # flow_node     ::= ALIAS
    #                   | properties flow_content?
    #                   | flow_content
    # properties    ::= TAG ANCHOR? | ANCHOR TAG?
    # block_content     ::= block_collection | flow_collection | SCALAR
    # flow_content      ::= flow_collection | SCALAR
    # block_collection  ::= block_sequence | block_mapping
    # flow_collection   ::= flow_sequence | flow_mapping

    def parse_block_node(self):
        return self.parse_node(block=True)

    def parse_flow_node(self):
        return self.parse_node()

    def parse_block_node_or_indentless_sequence(self):
        return self.parse_node(block=True, indentless_sequence=True)

    def parse_node(self, block=False, indentless_sequence=False):
        if self.check_token(AliasToken):
            token = self.get_token()
            event = AliasEvent(token.value, token.start_mark, token.end_mark)
            self.state = self.states.pop()
        else:
            anchor = None
            tag = None
            start_mark = end_mark = tag_mark = None
            if self.check_token(AnchorToken):
                token = self.get_token()
                start_mark = token.start_mark
                end_mark = token.end_mark
                anchor = token.value
                if self.check_token(TagToken):
                    token = self.get_token()
                    tag_mark = token.start_mark
                    end_mark = token.end_mark
                    tag = token.value
            elif self.check_token(TagToken):
                token = self.get_token()
                start_mark = tag_mark = token.start_mark
                end_mark = token.end_mark
                tag = token.value
                if self.check_token(AnchorToken):
                    token = self.get_token()
                    end_mark = token.end_mark
                    anchor = token.value
            if tag is not None:
                handle, suffix = tag
                if handle is not None:
                    if handle not in self.tag_handles:
                        raise ParserError(
                            "while parsing a node",
                            start_mark,
                            "found undefined tag handle %r" % handle,
                            tag_mark,
                        )
                    tag = self.tag_handles[handle] + suffix
                else:
                    tag = suffix
            # if tag == '!':
            #    raise ParserError("while parsing a node", start_mark,
            #            "found non-specific tag '!'", tag_mark,
            #            "Please check 'http://pyyaml.org/wiki/YAMLNonSpecificTag' and share your opinion.")
            if start_mark is None:
                start_mark = end_mark = self.peek_token().start_mark
            event = None
            implicit = tag is None or tag == "!"
            if indentless_sequence and self.check_token(BlockEntryToken):
                end_mark = self.peek_token().end_mark
                event = SequenceStartEvent(anchor, tag, implicit, start_mark, end_mark)
                self.state = self.parse_indentless_sequence_entry
            else:
                if self.check_token(ScalarToken):
                    token = self.get_token()
                    end_mark = token.end_mark
                    if (token.plain and tag is None) or tag == "!":
                        implicit = (True, False)
                    elif tag is None:
                        implicit = (False, True)
                    else:
                        implicit = (False, False)
                    event = ScalarEvent(
                        anchor,
                        tag,
                        implicit,
                        token.value,
                        start_mark,
                        end_mark,
                        style=token.style,
                    )
                    self.state = self.states.pop()
                elif self.check_token(FlowSequenceStartToken):
                    end_mark = self.peek_token().end_mark
                    event = SequenceStartEvent(
                        anchor, tag, implicit, start_mark, end_mark, flow_style=True
                    )
                    self.state = self.parse_flow_sequence_first_entry
                elif self.check_token(FlowMappingStartToken):
                    end_mark = self.peek_token().end_mark
                    event = MappingStartEvent(
                        anchor, tag, implicit, start_mark, end_mark, flow_style=True
                    )
                    self.state = self.parse_flow_mapping_first_key
                elif block and self.check_token(BlockSequenceStartToken):
                    end_mark = self.peek_token().start_mark
                    event = SequenceStartEvent(
                        anchor, tag, implicit, start_mark, end_mark, flow_style=False
                    )
                    self.state = self.parse_block_sequence_first_entry
                elif block and self.check_token(BlockMappingStartToken):
                    end_mark = self.peek_token().start_mark
                    event = MappingStartEvent(
                        anchor, tag, implicit, start_mark, end_mark, flow_style=False
                    )
                    self.state = self.parse_block_mapping_first_key
                elif anchor is not None or tag is not None:
                    # Empty scalars are allowed even if a tag or an anchor is
                    # specified.
                    event = ScalarEvent(
                        anchor, tag, (implicit, False), "", start_mark, end_mark
                    )
                    self.state = self.states.pop()
                else:
                    if block:
                        node = "block"
                    else:
                        node = "flow"
                    token = self.peek_token()
                    raise ParserError(
                        "while parsing a %s node" % node,
                        start_mark,
                        "expected the node content, but found %r" % token.id,
                        token.start_mark,
                    )
        return event

    # block_sequence ::= BLOCK-SEQUENCE-START (BLOCK-ENTRY block_node?)* BLOCK-END

    def parse_block_sequence_first_entry(self):
        token = self.get_token()
        self.marks.append(token.start_mark)
        return self.parse_block_sequence_entry()

    def parse_block_sequence_entry(self):
        if self.check_token(BlockEntryToken):
            token = self.get_token()
            if not self.check_token(BlockEntryToken, BlockEndToken):
                self.states.append(self.parse_block_sequence_entry)
                return self.parse_block_node()
            else:
                self.state = self.parse_block_sequence_entry
                return self.process_empty_scalar(token.end_mark)
        if not self.check_token(BlockEndToken):
            token = self.peek_token()
            raise ParserError(
                "while parsing a block collection",
                self.marks[-1],
                "expected <block end>, but found %r" % token.id,
                token.start_mark,
            )
        token = self.get_token()
        event = SequenceEndEvent(token.start_mark, token.end_mark)
        self.state = self.states.pop()
        self.marks.pop()
        return event

    # indentless_sequence ::= (BLOCK-ENTRY block_node?)+

    def parse_indentless_sequence_entry(self):
        if self.check_token(BlockEntryToken):
            token = self.get_token()
            if not self.check_token(
                BlockEntryToken, KeyToken, ValueToken, BlockEndToken
            ):
                self.states.append(self.parse_indentless_sequence_entry)
                return self.parse_block_node()
            else:
                self.state = self.parse_indentless_sequence_entry
                return self.process_empty_scalar(token.end_mark)
        token = self.peek_token()
        event = SequenceEndEvent(token.start_mark, token.start_mark)
        self.state = self.states.pop()
        return event

    # block_mapping     ::= BLOCK-MAPPING_START
    #                       ((KEY block_node_or_indentless_sequence?)?
    #                       (VALUE block_node_or_indentless_sequence?)?)*
    #                       BLOCK-END

    def parse_block_mapping_first_key(self):
        token = self.get_token()
        self.marks.append(token.start_mark)
        return self.parse_block_mapping_key()

    def parse_block_mapping_key(self):
        if self.check_token(KeyToken):
            token = self.get_token()
            if not self.check_token(KeyToken, ValueToken, BlockEndToken):
                self.states.append(self.parse_block_mapping_value)
                return self.parse_block_node_or_indentless_sequence()
            else:
                self.state = self.parse_block_mapping_value
                return self.process_empty_scalar(token.end_mark)
        if not self.check_token(BlockEndToken):
            token = self.peek_token()
            raise ParserError(
                "while parsing a block mapping",
                self.marks[-1],
                "expected <block end>, but found %r" % token.id,
                token.start_mark,
            )
        token = self.get_token()
        event = MappingEndEvent(token.start_mark, token.end_mark)
        self.state = self.states.pop()
        self.marks.pop()
        return event

    def parse_block_mapping_value(self):
        if self.check_token(ValueToken):
            token = self.get_token()
            if not self.check_token(KeyToken, ValueToken, BlockEndToken):
                self.states.append(self.parse_block_mapping_key)
                return self.parse_block_node_or_indentless_sequence()
            else:
                self.state = self.parse_block_mapping_key
                return self.process_empty_scalar(token.end_mark)
        else:
            self.state = self.parse_block_mapping_key
            token = self.peek_token()
            return self.process_empty_scalar(token.start_mark)

    # flow_sequence     ::= FLOW-SEQUENCE-START
    #                       (flow_sequence_entry FLOW-ENTRY)*
    #                       flow_sequence_entry?
    #                       FLOW-SEQUENCE-END
    # flow_sequence_entry   ::= flow_node | KEY flow_node? (VALUE flow_node?)?
    #
    # Note that while production rules for both flow_sequence_entry and
    # flow_mapping_entry are equal, their interpretations are different.
    # For `flow_sequence_entry`, the part `KEY flow_node? (VALUE flow_node?)?`
    # generate an inline mapping (set syntax).

    def parse_flow_sequence_first_entry(self):
        token = self.get_token()
        self.marks.append(token.start_mark)
        return self.parse_flow_sequence_entry(first=True)

    def parse_flow_sequence_entry(self, first=False):
        if not self.check_token(FlowSequenceEndToken):
            if not first:
                if self.check_token(FlowEntryToken):
                    self.get_token()
                else:
                    token = self.peek_token()
                    raise ParserError(
                        "while parsing a flow sequence",
                        self.marks[-1],
                        "expected ',' or ']', but got %r" % token.id,
                        token.start_mark,
                    )

            if self.check_token(KeyToken):
                token = self.peek_token()
                event = MappingStartEvent(
                    None, None, True, token.start_mark, token.end_mark, flow_style=True
                )
                self.state = self.parse_flow_sequence_entry_mapping_key
                return event
            elif not self.check_token(FlowSequenceEndToken):
                self.states.append(self.parse_flow_sequence_entry)
                return self.parse_flow_node()
        token = self.get_token()
        event = SequenceEndEvent(token.start_mark, token.end_mark)
        self.state = self.states.pop()
        self.marks.pop()
        return event

    def parse_flow_sequence_entry_mapping_key(self):
        token = self.get_token()
        if not self.check_token(ValueToken, FlowEntryToken, FlowSequenceEndToken):
            self.states.append(self.parse_flow_sequence_entry_mapping_value)
            return self.parse_flow_node()
        else:
            self.state = self.parse_flow_sequence_entry_mapping_value
            return self.process_empty_scalar(token.end_mark)

    def parse_flow_sequence_entry_mapping_value(self):
        if self.check_token(ValueToken):
            token = self.get_token()
            if not self.check_token(FlowEntryToken, FlowSequenceEndToken):
                self.states.append(self.parse_flow_sequence_entry_mapping_end)
                return self.parse_flow_node()
            else:
                self.state = self.parse_flow_sequence_entry_mapping_end
                return self.process_empty_scalar(token.end_mark)
        else:
            self.state = self.parse_flow_sequence_entry_mapping_end
            token = self.peek_token()
            return self.process_empty_scalar(token.start_mark)

    def parse_flow_sequence_entry_mapping_end(self):
        self.state = self.parse_flow_sequence_entry
        token = self.peek_token()
        return MappingEndEvent(token.start_mark, token.start_mark)

    # flow_mapping  ::= FLOW-MAPPING-START
    #                   (flow_mapping_entry FLOW-ENTRY)*
    #                   flow_mapping_entry?
    #                   FLOW-MAPPING-END
    # flow_mapping_entry    ::= flow_node | KEY flow_node? (VALUE flow_node?)?

    def parse_flow_mapping_first_key(self):
        token = self.get_token()
        self.marks.append(token.start_mark)
        return self.parse_flow_mapping_key(first=True)

    def parse_flow_mapping_key(self, first=False):
        if not self.check_token(FlowMappingEndToken):
            if not first:
                if self.check_token(FlowEntryToken):
                    self.get_token()
                else:
                    token = self.peek_token()
                    raise ParserError(
                        "while parsing a flow mapping",
                        self.marks[-1],
                        "expected ',' or '}', but got %r" % token.id,
                        token.start_mark,
                    )
            if self.check_token(KeyToken):
                token = self.get_token()
                if not self.check_token(
                    ValueToken, FlowEntryToken, FlowMappingEndToken
                ):
                    self.states.append(self.parse_flow_mapping_value)
                    return self.parse_flow_node()
                else:
                    self.state = self.parse_flow_mapping_value
                    return self.process_empty_scalar(token.end_mark)
            elif not self.check_token(FlowMappingEndToken):
                self.states.append(self.parse_flow_mapping_empty_value)
                return self.parse_flow_node()
        token = self.get_token()
        event = MappingEndEvent(token.start_mark, token.end_mark)
        self.state = self.states.pop()
        self.marks.pop()
        return event

    def parse_flow_mapping_value(self):
        if self.check_token(ValueToken):
            token = self.get_token()
            if not self.check_token(FlowEntryToken, FlowMappingEndToken):
                self.states.append(self.parse_flow_mapping_key)
                return self.parse_flow_node()
            else:
                self.state = self.parse_flow_mapping_key
                return self.process_empty_scalar(token.end_mark)
        else:
            self.state = self.parse_flow_mapping_key
            token = self.peek_token()
            return self.process_empty_scalar(token.start_mark)

    def parse_flow_mapping_empty_value(self):
        self.state = self.parse_flow_mapping_key
        return self.process_empty_scalar(self.peek_token().start_mark)

    def process_empty_scalar(self, mark):
        return ScalarEvent(None, None, (True, False), "", mark, mark)


## composer.py
class ComposerError(MarkedYAMLError):
    pass


class Composer:
    def __init__(self):
        self.anchors = {}

    def check_node(self):
        # Drop the STREAM-START event.
        if self.check_event(StreamStartEvent):
            self.get_event()

        # If there are more documents available?
        return not self.check_event(StreamEndEvent)

    def get_node(self):
        # Get the root node of the next document.
        if not self.check_event(StreamEndEvent):
            return self.compose_document()

    def get_single_node(self):
        # Drop the STREAM-START event.
        self.get_event()

        # Compose a document if the stream is not empty.
        document = None
        if not self.check_event(StreamEndEvent):
            document = self.compose_document()

        # Ensure that the stream contains no more documents.
        if not self.check_event(StreamEndEvent):
            event = self.get_event()
            raise ComposerError(
                "expected a single document in the stream",
                document.start_mark,
                "but found another document",
                event.start_mark,
            )

        # Drop the STREAM-END event.
        self.get_event()

        return document

    def compose_document(self):
        # Drop the DOCUMENT-START event.
        self.get_event()

        # Compose the root node.
        node = self.compose_node(None, None)

        # Drop the DOCUMENT-END event.
        self.get_event()

        self.anchors = {}
        return node

    def compose_node(self, parent, index):
        if self.check_event(AliasEvent):
            event = self.get_event()
            anchor = event.anchor
            if anchor not in self.anchors:
                raise ComposerError(
                    None, None, "found undefined alias %r" % anchor, event.start_mark
                )
            return self.anchors[anchor]
        event = self.peek_event()
        anchor = event.anchor
        if anchor is not None:
            if anchor in self.anchors:
                raise ComposerError(
                    "found duplicate anchor %r; first occurrence" % anchor,
                    self.anchors[anchor].start_mark,
                    "second occurrence",
                    event.start_mark,
                )
        self.descend_resolver(parent, index)
        if self.check_event(ScalarEvent):
            node = self.compose_scalar_node(anchor)
        elif self.check_event(SequenceStartEvent):
            node = self.compose_sequence_node(anchor)
        elif self.check_event(MappingStartEvent):
            node = self.compose_mapping_node(anchor)
        self.ascend_resolver()
        return node

    def compose_scalar_node(self, anchor):
        event = self.get_event()
        tag = event.tag
        if tag is None or tag == "!":
            tag = self.resolve(ScalarNode, event.value, event.implicit)
        node = ScalarNode(
            tag, event.value, event.start_mark, event.end_mark, style=event.style
        )
        if anchor is not None:
            self.anchors[anchor] = node
        return node

    def compose_sequence_node(self, anchor):
        start_event = self.get_event()
        tag = start_event.tag
        if tag is None or tag == "!":
            tag = self.resolve(SequenceNode, None, start_event.implicit)
        node = SequenceNode(
            tag, [], start_event.start_mark, None, flow_style=start_event.flow_style
        )
        if anchor is not None:
            self.anchors[anchor] = node
        index = 0
        while not self.check_event(SequenceEndEvent):
            node.value.append(self.compose_node(node, index))
            index += 1
        end_event = self.get_event()
        node.end_mark = end_event.end_mark
        return node

    def compose_mapping_node(self, anchor):
        start_event = self.get_event()
        tag = start_event.tag
        if tag is None or tag == "!":
            tag = self.resolve(MappingNode, None, start_event.implicit)
        node = MappingNode(
            tag, [], start_event.start_mark, None, flow_style=start_event.flow_style
        )
        if anchor is not None:
            self.anchors[anchor] = node
        while not self.check_event(MappingEndEvent):
            # key_event = self.peek_event()
            item_key = self.compose_node(node, None)
            # if item_key in node.value:
            #    raise ComposerError("while composing a mapping", start_event.start_mark,
            #            "found duplicate key", key_event.start_mark)
            item_value = self.compose_node(node, item_key)
            # node.value[item_key] = item_value
            node.value.append((item_key, item_value))
        end_event = self.get_event()
        node.end_mark = end_event.end_mark
        return node


## constructor.py


class ConstructorError(MarkedYAMLError):
    pass


class BaseConstructor:

    yaml_constructors = {}
    yaml_multi_constructors = {}

    def __init__(self):
        self.constructed_objects = {}
        self.recursive_objects = {}
        self.state_generators = []
        self.deep_construct = False

    def check_data(self):
        # If there are more documents available?
        return self.check_node()

    def check_state_key(self, key):
        """Block special attributes/methods from being set in a newly created
        object, to prevent user-controlled methods from being called during
        deserialization"""
        if self.get_state_keys_blacklist_regexp().match(key):
            raise ConstructorError(
                None,
                None,
                "blacklisted key '%s' in instance state found" % (key,),
                None,
            )

    def get_data(self):
        # Construct and return the next document.
        if self.check_node():
            return self.construct_document(self.get_node())

    def get_single_data(self):
        # Ensure that the stream contains a single document and construct it.
        node = self.get_single_node()
        if node is not None:
            return self.construct_document(node)
        return None

    def construct_document(self, node):
        data = self.construct_object(node)
        while self.state_generators:
            state_generators = self.state_generators
            self.state_generators = []
            for generator in state_generators:
                for dummy in generator:
                    pass
        self.constructed_objects = {}
        self.recursive_objects = {}
        self.deep_construct = False
        return data

    def construct_object(self, node, deep=False):
        if node in self.constructed_objects:
            return self.constructed_objects[node]
        if deep:
            old_deep = self.deep_construct
            self.deep_construct = True
        if node in self.recursive_objects:
            raise ConstructorError(
                None, None, "found unconstructable recursive node", node.start_mark
            )
        self.recursive_objects[node] = None
        constructor = None
        tag_suffix = None
        if node.tag in self.yaml_constructors:
            constructor = self.yaml_constructors[node.tag]
        else:
            for tag_prefix in self.yaml_multi_constructors:
                if tag_prefix is not None and node.tag.startswith(tag_prefix):
                    tag_suffix = node.tag[len(tag_prefix) :]
                    constructor = self.yaml_multi_constructors[tag_prefix]
                    break
            else:
                if None in self.yaml_multi_constructors:
                    tag_suffix = node.tag
                    constructor = self.yaml_multi_constructors[None]
                elif None in self.yaml_constructors:
                    constructor = self.yaml_constructors[None]
                elif isinstance(node, ScalarNode):
                    constructor = self.__class__.construct_scalar
                elif isinstance(node, SequenceNode):
                    constructor = self.__class__.construct_sequence
                elif isinstance(node, MappingNode):
                    constructor = self.__class__.construct_mapping
        if tag_suffix is None:
            data = constructor(self, node)
        else:
            data = constructor(self, tag_suffix, node)
        if isinstance(data, types.GeneratorType):
            generator = data
            data = next(generator)
            if self.deep_construct:
                for dummy in generator:
                    pass
            else:
                self.state_generators.append(generator)
        self.constructed_objects[node] = data
        del self.recursive_objects[node]
        if deep:
            self.deep_construct = old_deep
        return data

    def construct_scalar(self, node):
        if not isinstance(node, ScalarNode):
            raise ConstructorError(
                None,
                None,
                "expected a scalar node, but found %s" % node.id,
                node.start_mark,
            )
        return node.value

    def construct_sequence(self, node, deep=False):
        if not isinstance(node, SequenceNode):
            raise ConstructorError(
                None,
                None,
                "expected a sequence node, but found %s" % node.id,
                node.start_mark,
            )
        return [self.construct_object(child, deep=deep) for child in node.value]

    def construct_mapping(self, node, deep=False):
        if not isinstance(node, MappingNode):
            raise ConstructorError(
                None,
                None,
                "expected a mapping node, but found %s" % node.id,
                node.start_mark,
            )
        mapping = {}
        for key_node, value_node in node.value:
            key = self.construct_object(key_node, deep=deep)
            if not isinstance(key, collections.abc.Hashable):
                raise ConstructorError(
                    "while constructing a mapping",
                    node.start_mark,
                    "found unhashable key",
                    key_node.start_mark,
                )
            value = self.construct_object(value_node, deep=deep)
            mapping[key] = value
        return mapping

    def construct_pairs(self, node, deep=False):
        if not isinstance(node, MappingNode):
            raise ConstructorError(
                None,
                None,
                "expected a mapping node, but found %s" % node.id,
                node.start_mark,
            )
        pairs = []
        for key_node, value_node in node.value:
            key = self.construct_object(key_node, deep=deep)
            value = self.construct_object(value_node, deep=deep)
            pairs.append((key, value))
        return pairs

    @classmethod
    def add_constructor(cls, tag, constructor):
        if not "yaml_constructors" in cls.__dict__:
            cls.yaml_constructors = cls.yaml_constructors.copy()
        cls.yaml_constructors[tag] = constructor

    @classmethod
    def add_multi_constructor(cls, tag_prefix, multi_constructor):
        if not "yaml_multi_constructors" in cls.__dict__:
            cls.yaml_multi_constructors = cls.yaml_multi_constructors.copy()
        cls.yaml_multi_constructors[tag_prefix] = multi_constructor


class SafeConstructor(BaseConstructor):
    def construct_scalar(self, node):
        if isinstance(node, MappingNode):
            for key_node, value_node in node.value:
                if key_node.tag == "tag:yaml.org,2002:value":
                    return self.construct_scalar(value_node)
        return super().construct_scalar(node)

    def flatten_mapping(self, node):
        merge = []
        index = 0
        while index < len(node.value):
            key_node, value_node = node.value[index]
            if key_node.tag == "tag:yaml.org,2002:merge":
                del node.value[index]
                if isinstance(value_node, MappingNode):
                    self.flatten_mapping(value_node)
                    merge.extend(value_node.value)
                elif isinstance(value_node, SequenceNode):
                    submerge = []
                    for subnode in value_node.value:
                        if not isinstance(subnode, MappingNode):
                            raise ConstructorError(
                                "while constructing a mapping",
                                node.start_mark,
                                "expected a mapping for merging, but found %s"
                                % subnode.id,
                                subnode.start_mark,
                            )
                        self.flatten_mapping(subnode)
                        submerge.append(subnode.value)
                    submerge.reverse()
                    for value in submerge:
                        merge.extend(value)
                else:
                    raise ConstructorError(
                        "while constructing a mapping",
                        node.start_mark,
                        "expected a mapping or list of mappings for merging, but found %s"
                        % value_node.id,
                        value_node.start_mark,
                    )
            elif key_node.tag == "tag:yaml.org,2002:value":
                key_node.tag = "tag:yaml.org,2002:str"
                index += 1
            else:
                index += 1
        if merge:
            node.value = merge + node.value

    def construct_mapping(self, node, deep=False):
        if isinstance(node, MappingNode):
            self.flatten_mapping(node)
        return super().construct_mapping(node, deep=deep)

    def construct_yaml_null(self, node):
        self.construct_scalar(node)
        return None

    bool_values = {
        "yes": True,
        "no": False,
        "true": True,
        "false": False,
        "on": True,
        "off": False,
    }

    def construct_yaml_bool(self, node):
        value = self.construct_scalar(node)
        return self.bool_values[value.lower()]

    def construct_yaml_int(self, node):
        value = self.construct_scalar(node)
        value = value.replace("_", "")
        sign = +1
        if value[0] == "-":
            sign = -1
        if value[0] in "+-":
            value = value[1:]
        if value == "0":
            return 0
        elif value.startswith("0b"):
            return sign * int(value[2:], 2)
        elif value.startswith("0x"):
            return sign * int(value[2:], 16)
        elif value[0] == "0":
            return sign * int(value, 8)
        elif ":" in value:
            digits = [int(part) for part in value.split(":")]
            digits.reverse()
            base = 1
            value = 0
            for digit in digits:
                value += digit * base
                base *= 60
            return sign * value
        else:
            return sign * int(value)

    inf_value = 1e300
    while inf_value != inf_value * inf_value:
        inf_value *= inf_value
    nan_value = -inf_value / inf_value  # Trying to make a quiet NaN (like C99).

    def construct_yaml_float(self, node):
        value = self.construct_scalar(node)
        value = value.replace("_", "").lower()
        sign = +1
        if value[0] == "-":
            sign = -1
        if value[0] in "+-":
            value = value[1:]
        if value == ".inf":
            return sign * self.inf_value
        elif value == ".nan":
            return self.nan_value
        elif ":" in value:
            digits = [float(part) for part in value.split(":")]
            digits.reverse()
            base = 1
            value = 0.0
            for digit in digits:
                value += digit * base
                base *= 60
            return sign * value
        else:
            return sign * float(value)

    def construct_yaml_binary(self, node):
        try:
            value = self.construct_scalar(node).encode("ascii")
        except UnicodeEncodeError as exc:
            raise ConstructorError(
                None,
                None,
                "failed to convert base64 data into ascii: %s" % exc,
                node.start_mark,
            )
        try:
            if hasattr(base64, "decodebytes"):
                return base64.decodebytes(value)
            else:
                return base64.decodestring(value)
        except binascii.Error as exc:
            raise ConstructorError(
                None, None, "failed to decode base64 data: %s" % exc, node.start_mark
            )

    timestamp_regexp = re.compile(
        r"""^(?P<year>[0-9][0-9][0-9][0-9])
                -(?P<month>[0-9][0-9]?)
                -(?P<day>[0-9][0-9]?)
                (?:(?:[Tt]|[ \t]+)
                (?P<hour>[0-9][0-9]?)
                :(?P<minute>[0-9][0-9])
                :(?P<second>[0-9][0-9])
                (?:\.(?P<fraction>[0-9]*))?
                (?:[ \t]*(?P<tz>Z|(?P<tz_sign>[-+])(?P<tz_hour>[0-9][0-9]?)
                (?::(?P<tz_minute>[0-9][0-9]))?))?)?$""",
        re.X,
    )

    def construct_yaml_timestamp(self, node):
        value = self.construct_scalar(node)
        match = self.timestamp_regexp.match(node.value)
        values = match.groupdict()
        year = int(values["year"])
        month = int(values["month"])
        day = int(values["day"])
        if not values["hour"]:
            return datetime.date(year, month, day)
        hour = int(values["hour"])
        minute = int(values["minute"])
        second = int(values["second"])
        fraction = 0
        tzinfo = None
        if values["fraction"]:
            fraction = values["fraction"][:6]
            while len(fraction) < 6:
                fraction += "0"
            fraction = int(fraction)
        if values["tz_sign"]:
            tz_hour = int(values["tz_hour"])
            tz_minute = int(values["tz_minute"] or 0)
            delta = datetime.timedelta(hours=tz_hour, minutes=tz_minute)
            if values["tz_sign"] == "-":
                delta = -delta
            tzinfo = datetime.timezone(delta)
        elif values["tz"]:
            tzinfo = datetime.timezone.utc
        return datetime.datetime(
            year, month, day, hour, minute, second, fraction, tzinfo=tzinfo
        )

    def construct_yaml_omap(self, node):
        # Note: we do not check for duplicate keys, because it's too
        # CPU-expensive.
        omap = []
        yield omap
        if not isinstance(node, SequenceNode):
            raise ConstructorError(
                "while constructing an ordered map",
                node.start_mark,
                "expected a sequence, but found %s" % node.id,
                node.start_mark,
            )
        for subnode in node.value:
            if not isinstance(subnode, MappingNode):
                raise ConstructorError(
                    "while constructing an ordered map",
                    node.start_mark,
                    "expected a mapping of length 1, but found %s" % subnode.id,
                    subnode.start_mark,
                )
            if len(subnode.value) != 1:
                raise ConstructorError(
                    "while constructing an ordered map",
                    node.start_mark,
                    "expected a single mapping item, but found %d items"
                    % len(subnode.value),
                    subnode.start_mark,
                )
            key_node, value_node = subnode.value[0]
            key = self.construct_object(key_node)
            value = self.construct_object(value_node)
            omap.append((key, value))

    def construct_yaml_pairs(self, node):
        # Note: the same code as `construct_yaml_omap`.
        pairs = []
        yield pairs
        if not isinstance(node, SequenceNode):
            raise ConstructorError(
                "while constructing pairs",
                node.start_mark,
                "expected a sequence, but found %s" % node.id,
                node.start_mark,
            )
        for subnode in node.value:
            if not isinstance(subnode, MappingNode):
                raise ConstructorError(
                    "while constructing pairs",
                    node.start_mark,
                    "expected a mapping of length 1, but found %s" % subnode.id,
                    subnode.start_mark,
                )
            if len(subnode.value) != 1:
                raise ConstructorError(
                    "while constructing pairs",
                    node.start_mark,
                    "expected a single mapping item, but found %d items"
                    % len(subnode.value),
                    subnode.start_mark,
                )
            key_node, value_node = subnode.value[0]
            key = self.construct_object(key_node)
            value = self.construct_object(value_node)
            pairs.append((key, value))

    def construct_yaml_set(self, node):
        data = set()
        yield data
        value = self.construct_mapping(node)
        data.update(value)

    def construct_yaml_str(self, node):
        return self.construct_scalar(node)

    def construct_yaml_seq(self, node):
        data = []
        yield data
        data.extend(self.construct_sequence(node))

    def construct_yaml_map(self, node):
        data = {}
        yield data
        value = self.construct_mapping(node)
        data.update(value)

    def construct_yaml_object(self, node, cls):
        data = cls.__new__(cls)
        yield data
        if hasattr(data, "__setstate__"):
            state = self.construct_mapping(node, deep=True)
            data.__setstate__(state)
        else:
            state = self.construct_mapping(node)
            data.__dict__.update(state)

    def construct_undefined(self, node):
        raise ConstructorError(
            None,
            None,
            "could not determine a constructor for the tag %r" % node.tag,
            node.start_mark,
        )


SafeConstructor.add_constructor(
    "tag:yaml.org,2002:null", SafeConstructor.construct_yaml_null
)

SafeConstructor.add_constructor(
    "tag:yaml.org,2002:bool", SafeConstructor.construct_yaml_bool
)

SafeConstructor.add_constructor(
    "tag:yaml.org,2002:int", SafeConstructor.construct_yaml_int
)

SafeConstructor.add_constructor(
    "tag:yaml.org,2002:float", SafeConstructor.construct_yaml_float
)

SafeConstructor.add_constructor(
    "tag:yaml.org,2002:binary", SafeConstructor.construct_yaml_binary
)

SafeConstructor.add_constructor(
    "tag:yaml.org,2002:timestamp", SafeConstructor.construct_yaml_timestamp
)

SafeConstructor.add_constructor(
    "tag:yaml.org,2002:omap", SafeConstructor.construct_yaml_omap
)

SafeConstructor.add_constructor(
    "tag:yaml.org,2002:pairs", SafeConstructor.construct_yaml_pairs
)

SafeConstructor.add_constructor(
    "tag:yaml.org,2002:set", SafeConstructor.construct_yaml_set
)

SafeConstructor.add_constructor(
    "tag:yaml.org,2002:str", SafeConstructor.construct_yaml_str
)

SafeConstructor.add_constructor(
    "tag:yaml.org,2002:seq", SafeConstructor.construct_yaml_seq
)

SafeConstructor.add_constructor(
    "tag:yaml.org,2002:map", SafeConstructor.construct_yaml_map
)

SafeConstructor.add_constructor(None, SafeConstructor.construct_undefined)


class FullConstructor(SafeConstructor):
    # 'extend' is blacklisted because it is used by
    # construct_python_object_apply to add `listitems` to a newly generate
    # python instance
    def get_state_keys_blacklist(self):
        return ["^extend$", "^__.*__$"]

    def get_state_keys_blacklist_regexp(self):
        if not hasattr(self, "state_keys_blacklist_regexp"):
            self.state_keys_blacklist_regexp = re.compile(
                "(" + "|".join(self.get_state_keys_blacklist()) + ")"
            )
        return self.state_keys_blacklist_regexp

    def construct_python_str(self, node):
        return self.construct_scalar(node)

    def construct_python_unicode(self, node):
        return self.construct_scalar(node)

    def construct_python_bytes(self, node):
        try:
            value = self.construct_scalar(node).encode("ascii")
        except UnicodeEncodeError as exc:
            raise ConstructorError(
                None,
                None,
                "failed to convert base64 data into ascii: %s" % exc,
                node.start_mark,
            )
        try:
            if hasattr(base64, "decodebytes"):
                return base64.decodebytes(value)
            else:
                return base64.decodestring(value)
        except binascii.Error as exc:
            raise ConstructorError(
                None, None, "failed to decode base64 data: %s" % exc, node.start_mark
            )

    def construct_python_long(self, node):
        return self.construct_yaml_int(node)

    def construct_python_complex(self, node):
        return complex(self.construct_scalar(node))

    def construct_python_tuple(self, node):
        return tuple(self.construct_sequence(node))

    def find_python_module(self, name, mark, unsafe=False):
        if not name:
            raise ConstructorError(
                "while constructing a Python module",
                mark,
                "expected non-empty name appended to the tag",
                mark,
            )
        if unsafe:
            try:
                __import__(name)
            except ImportError as exc:
                raise ConstructorError(
                    "while constructing a Python module",
                    mark,
                    "cannot find module %r (%s)" % (name, exc),
                    mark,
                )
        if name not in sys.modules:
            raise ConstructorError(
                "while constructing a Python module",
                mark,
                "module %r is not imported" % name,
                mark,
            )
        return sys.modules[name]

    def find_python_name(self, name, mark, unsafe=False):
        if not name:
            raise ConstructorError(
                "while constructing a Python object",
                mark,
                "expected non-empty name appended to the tag",
                mark,
            )
        if "." in name:
            module_name, object_name = name.rsplit(".", 1)
        else:
            module_name = "builtins"
            object_name = name
        if unsafe:
            try:
                __import__(module_name)
            except ImportError as exc:
                raise ConstructorError(
                    "while constructing a Python object",
                    mark,
                    "cannot find module %r (%s)" % (module_name, exc),
                    mark,
                )
        if module_name not in sys.modules:
            raise ConstructorError(
                "while constructing a Python object",
                mark,
                "module %r is not imported" % module_name,
                mark,
            )
        module = sys.modules[module_name]
        if not hasattr(module, object_name):
            raise ConstructorError(
                "while constructing a Python object",
                mark,
                "cannot find %r in the module %r" % (object_name, module.__name__),
                mark,
            )
        return getattr(module, object_name)

    def construct_python_name(self, suffix, node):
        value = self.construct_scalar(node)
        if value:
            raise ConstructorError(
                "while constructing a Python name",
                node.start_mark,
                "expected the empty value, but found %r" % value,
                node.start_mark,
            )
        return self.find_python_name(suffix, node.start_mark)

    def construct_python_module(self, suffix, node):
        value = self.construct_scalar(node)
        if value:
            raise ConstructorError(
                "while constructing a Python module",
                node.start_mark,
                "expected the empty value, but found %r" % value,
                node.start_mark,
            )
        return self.find_python_module(suffix, node.start_mark)

    def make_python_instance(
        self, suffix, node, args=None, kwds=None, newobj=False, unsafe=False
    ):
        if not args:
            args = []
        if not kwds:
            kwds = {}
        cls = self.find_python_name(suffix, node.start_mark)
        if not (unsafe or isinstance(cls, type)):
            raise ConstructorError(
                "while constructing a Python instance",
                node.start_mark,
                "expected a class, but found %r" % type(cls),
                node.start_mark,
            )
        if newobj and isinstance(cls, type):
            return cls.__new__(cls, *args, **kwds)
        else:
            return cls(*args, **kwds)

    def set_python_instance_state(self, instance, state, unsafe=False):
        if hasattr(instance, "__setstate__"):
            instance.__setstate__(state)
        else:
            slotstate = {}
            if isinstance(state, tuple) and len(state) == 2:
                state, slotstate = state
            if hasattr(instance, "__dict__"):
                if not unsafe and state:
                    for key in state.keys():
                        self.check_state_key(key)
                instance.__dict__.update(state)
            elif state:
                slotstate.update(state)
            for key, value in slotstate.items():
                if not unsafe:
                    self.check_state_key(key)
                setattr(instance, key, value)

    def construct_python_object(self, suffix, node):
        # Format:
        #   !!python/object:module.name { ... state ... }
        instance = self.make_python_instance(suffix, node, newobj=True)
        yield instance
        deep = hasattr(instance, "__setstate__")
        state = self.construct_mapping(node, deep=deep)
        self.set_python_instance_state(instance, state)

    def construct_python_object_apply(self, suffix, node, newobj=False):
        # Format:
        #   !!python/object/apply       # (or !!python/object/new)
        #   args: [ ... arguments ... ]
        #   kwds: { ... keywords ... }
        #   state: ... state ...
        #   listitems: [ ... listitems ... ]
        #   dictitems: { ... dictitems ... }
        # or short format:
        #   !!python/object/apply [ ... arguments ... ]
        # The difference between !!python/object/apply and !!python/object/new
        # is how an object is created, check make_python_instance for details.
        if isinstance(node, SequenceNode):
            args = self.construct_sequence(node, deep=True)
            kwds = {}
            state = {}
            listitems = []
            dictitems = {}
        else:
            value = self.construct_mapping(node, deep=True)
            args = value.get("args", [])
            kwds = value.get("kwds", {})
            state = value.get("state", {})
            listitems = value.get("listitems", [])
            dictitems = value.get("dictitems", {})
        instance = self.make_python_instance(suffix, node, args, kwds, newobj)
        if state:
            self.set_python_instance_state(instance, state)
        if listitems:
            instance.extend(listitems)
        if dictitems:
            for key in dictitems:
                instance[key] = dictitems[key]
        return instance

    def construct_python_object_new(self, suffix, node):
        return self.construct_python_object_apply(suffix, node, newobj=True)


FullConstructor.add_constructor(
    "tag:yaml.org,2002:python/none", FullConstructor.construct_yaml_null
)

FullConstructor.add_constructor(
    "tag:yaml.org,2002:python/bool", FullConstructor.construct_yaml_bool
)

FullConstructor.add_constructor(
    "tag:yaml.org,2002:python/str", FullConstructor.construct_python_str
)

FullConstructor.add_constructor(
    "tag:yaml.org,2002:python/unicode", FullConstructor.construct_python_unicode
)

FullConstructor.add_constructor(
    "tag:yaml.org,2002:python/bytes", FullConstructor.construct_python_bytes
)

FullConstructor.add_constructor(
    "tag:yaml.org,2002:python/int", FullConstructor.construct_yaml_int
)

FullConstructor.add_constructor(
    "tag:yaml.org,2002:python/long", FullConstructor.construct_python_long
)

FullConstructor.add_constructor(
    "tag:yaml.org,2002:python/float", FullConstructor.construct_yaml_float
)

FullConstructor.add_constructor(
    "tag:yaml.org,2002:python/complex", FullConstructor.construct_python_complex
)

FullConstructor.add_constructor(
    "tag:yaml.org,2002:python/list", FullConstructor.construct_yaml_seq
)

FullConstructor.add_constructor(
    "tag:yaml.org,2002:python/tuple", FullConstructor.construct_python_tuple
)

FullConstructor.add_constructor(
    "tag:yaml.org,2002:python/dict", FullConstructor.construct_yaml_map
)

FullConstructor.add_multi_constructor(
    "tag:yaml.org,2002:python/name:", FullConstructor.construct_python_name
)


class UnsafeConstructor(FullConstructor):
    def find_python_module(self, name, mark):
        return super(UnsafeConstructor, self).find_python_module(
            name, mark, unsafe=True
        )

    def find_python_name(self, name, mark):
        return super(UnsafeConstructor, self).find_python_name(name, mark, unsafe=True)

    def make_python_instance(self, suffix, node, args=None, kwds=None, newobj=False):
        return super(UnsafeConstructor, self).make_python_instance(
            suffix, node, args, kwds, newobj, unsafe=True
        )

    def set_python_instance_state(self, instance, state):
        return super(UnsafeConstructor, self).set_python_instance_state(
            instance, state, unsafe=True
        )


UnsafeConstructor.add_multi_constructor(
    "tag:yaml.org,2002:python/module:", UnsafeConstructor.construct_python_module
)

UnsafeConstructor.add_multi_constructor(
    "tag:yaml.org,2002:python/object:", UnsafeConstructor.construct_python_object
)

UnsafeConstructor.add_multi_constructor(
    "tag:yaml.org,2002:python/object/new:",
    UnsafeConstructor.construct_python_object_new,
)

UnsafeConstructor.add_multi_constructor(
    "tag:yaml.org,2002:python/object/apply:",
    UnsafeConstructor.construct_python_object_apply,
)

# Constructor is same as UnsafeConstructor. Need to leave this in place in case
# people have extended it directly.
class Constructor(UnsafeConstructor):
    pass


## resolver.py
class ResolverError(YAMLError):
    pass


class BaseResolver:

    DEFAULT_SCALAR_TAG = "tag:yaml.org,2002:str"
    DEFAULT_SEQUENCE_TAG = "tag:yaml.org,2002:seq"
    DEFAULT_MAPPING_TAG = "tag:yaml.org,2002:map"

    yaml_implicit_resolvers = {}
    yaml_path_resolvers = {}

    def __init__(self):
        self.resolver_exact_paths = []
        self.resolver_prefix_paths = []

    @classmethod
    def add_implicit_resolver(cls, tag, regexp, first):
        if not "yaml_implicit_resolvers" in cls.__dict__:
            implicit_resolvers = {}
            for key in cls.yaml_implicit_resolvers:
                implicit_resolvers[key] = cls.yaml_implicit_resolvers[key][:]
            cls.yaml_implicit_resolvers = implicit_resolvers
        if first is None:
            first = [None]
        for ch in first:
            cls.yaml_implicit_resolvers.setdefault(ch, []).append((tag, regexp))

    @classmethod
    def add_path_resolver(cls, tag, path, kind=None):
        # Note: `add_path_resolver` is experimental.  The API could be changed.
        # `new_path` is a pattern that is matched against the path from the
        # root to the node that is being considered.  `node_path` elements are
        # tuples `(node_check, index_check)`.  `node_check` is a node class:
        # `ScalarNode`, `SequenceNode`, `MappingNode` or `None`.  `None`
        # matches any kind of a node.  `index_check` could be `None`, a boolean
        # value, a string value, or a number.  `None` and `False` match against
        # any _value_ of sequence and mapping nodes.  `True` matches against
        # any _key_ of a mapping node.  A string `index_check` matches against
        # a mapping value that corresponds to a scalar key which content is
        # equal to the `index_check` value.  An integer `index_check` matches
        # against a sequence value with the index equal to `index_check`.
        if not "yaml_path_resolvers" in cls.__dict__:
            cls.yaml_path_resolvers = cls.yaml_path_resolvers.copy()
        new_path = []
        for element in path:
            if isinstance(element, (list, tuple)):
                if len(element) == 2:
                    node_check, index_check = element
                elif len(element) == 1:
                    node_check = element[0]
                    index_check = True
                else:
                    raise ResolverError("Invalid path element: %s" % element)
            else:
                node_check = None
                index_check = element
            if node_check is str:
                node_check = ScalarNode
            elif node_check is list:
                node_check = SequenceNode
            elif node_check is dict:
                node_check = MappingNode
            elif (
                node_check not in [ScalarNode, SequenceNode, MappingNode]
                and not isinstance(node_check, str)
                and node_check is not None
            ):
                raise ResolverError("Invalid node checker: %s" % node_check)
            if not isinstance(index_check, (str, int)) and index_check is not None:
                raise ResolverError("Invalid index checker: %s" % index_check)
            new_path.append((node_check, index_check))
        if kind is str:
            kind = ScalarNode
        elif kind is list:
            kind = SequenceNode
        elif kind is dict:
            kind = MappingNode
        elif kind not in [ScalarNode, SequenceNode, MappingNode] and kind is not None:
            raise ResolverError("Invalid node kind: %s" % kind)
        cls.yaml_path_resolvers[tuple(new_path), kind] = tag

    def descend_resolver(self, current_node, current_index):
        if not self.yaml_path_resolvers:
            return
        exact_paths = {}
        prefix_paths = []
        if current_node:
            depth = len(self.resolver_prefix_paths)
            for path, kind in self.resolver_prefix_paths[-1]:
                if self.check_resolver_prefix(
                    depth, path, kind, current_node, current_index
                ):
                    if len(path) > depth:
                        prefix_paths.append((path, kind))
                    else:
                        exact_paths[kind] = self.yaml_path_resolvers[path, kind]
        else:
            for path, kind in self.yaml_path_resolvers:
                if not path:
                    exact_paths[kind] = self.yaml_path_resolvers[path, kind]
                else:
                    prefix_paths.append((path, kind))
        self.resolver_exact_paths.append(exact_paths)
        self.resolver_prefix_paths.append(prefix_paths)

    def ascend_resolver(self):
        if not self.yaml_path_resolvers:
            return
        self.resolver_exact_paths.pop()
        self.resolver_prefix_paths.pop()

    def check_resolver_prefix(self, depth, path, kind, current_node, current_index):
        node_check, index_check = path[depth - 1]
        if isinstance(node_check, str):
            if current_node.tag != node_check:
                return
        elif node_check is not None:
            if not isinstance(current_node, node_check):
                return
        if index_check is True and current_index is not None:
            return
        if (index_check is False or index_check is None) and current_index is None:
            return
        if isinstance(index_check, str):
            if not (
                isinstance(current_index, ScalarNode)
                and index_check == current_index.value
            ):
                return
        elif isinstance(index_check, int) and not isinstance(index_check, bool):
            if index_check != current_index:
                return
        return True

    def resolve(self, kind, value, implicit):
        if kind is ScalarNode and implicit[0]:
            if value == "":
                resolvers = self.yaml_implicit_resolvers.get("", [])
            else:
                resolvers = self.yaml_implicit_resolvers.get(value[0], [])
            wildcard_resolvers = self.yaml_implicit_resolvers.get(None, [])
            for tag, regexp in resolvers + wildcard_resolvers:
                if regexp.match(value):
                    return tag
            implicit = implicit[1]
        if self.yaml_path_resolvers:
            exact_paths = self.resolver_exact_paths[-1]
            if kind in exact_paths:
                return exact_paths[kind]
            if None in exact_paths:
                return exact_paths[None]
        if kind is ScalarNode:
            return self.DEFAULT_SCALAR_TAG
        elif kind is SequenceNode:
            return self.DEFAULT_SEQUENCE_TAG
        elif kind is MappingNode:
            return self.DEFAULT_MAPPING_TAG


class Resolver(BaseResolver):
    pass


Resolver.add_implicit_resolver(
    "tag:yaml.org,2002:bool",
    re.compile(
        r"""^(?:yes|Yes|YES|no|No|NO
                    |true|True|TRUE|false|False|FALSE
                    |on|On|ON|off|Off|OFF)$""",
        re.X,
    ),
    list("yYnNtTfFoO"),
)

Resolver.add_implicit_resolver(
    "tag:yaml.org,2002:float",
    re.compile(
        r"""^(?:[-+]?(?:[0-9][0-9_]*)\.[0-9_]*(?:[eE][-+][0-9]+)?
                    |\.[0-9][0-9_]*(?:[eE][-+][0-9]+)?
                    |[-+]?[0-9][0-9_]*(?::[0-5]?[0-9])+\.[0-9_]*
                    |[-+]?\.(?:inf|Inf|INF)
                    |\.(?:nan|NaN|NAN))$""",
        re.X,
    ),
    list("-+0123456789."),
)

Resolver.add_implicit_resolver(
    "tag:yaml.org,2002:int",
    re.compile(
        r"""^(?:[-+]?0b[0-1_]+
                    |[-+]?0[0-7_]+
                    |[-+]?(?:0|[1-9][0-9_]*)
                    |[-+]?0x[0-9a-fA-F_]+
                    |[-+]?[1-9][0-9_]*(?::[0-5]?[0-9])+)$""",
        re.X,
    ),
    list("-+0123456789"),
)

Resolver.add_implicit_resolver(
    "tag:yaml.org,2002:merge", re.compile(r"^(?:<<)$"), ["<"]
)

Resolver.add_implicit_resolver(
    "tag:yaml.org,2002:null",
    re.compile(
        r"""^(?: ~
                    |null|Null|NULL
                    | )$""",
        re.X,
    ),
    ["~", "n", "N", ""],
)

Resolver.add_implicit_resolver(
    "tag:yaml.org,2002:timestamp",
    re.compile(
        r"""^(?:[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]
                    |[0-9][0-9][0-9][0-9] -[0-9][0-9]? -[0-9][0-9]?
                     (?:[Tt]|[ \t]+)[0-9][0-9]?
                     :[0-9][0-9] :[0-9][0-9] (?:\.[0-9]*)?
                     (?:[ \t]*(?:Z|[-+][0-9][0-9]?(?::[0-9][0-9])?))?)$""",
        re.X,
    ),
    list("0123456789"),
)

Resolver.add_implicit_resolver("tag:yaml.org,2002:value", re.compile(r"^(?:=)$"), ["="])

# The following resolver is only for documentation purposes. It cannot work
# because plain scalars cannot start with '!', '&', or '*'.
Resolver.add_implicit_resolver(
    "tag:yaml.org,2002:yaml", re.compile(r"^(?:!|&|\*)$"), list("!&*")
)

## loader.py
class BaseLoader(Reader, Scanner, Parser, Composer, BaseConstructor, BaseResolver):
    def __init__(self, stream):
        Reader.__init__(self, stream)
        Scanner.__init__(self)
        Parser.__init__(self)
        Composer.__init__(self)
        BaseConstructor.__init__(self)
        BaseResolver.__init__(self)


class FullLoader(Reader, Scanner, Parser, Composer, FullConstructor, Resolver):
    def __init__(self, stream):
        Reader.__init__(self, stream)
        Scanner.__init__(self)
        Parser.__init__(self)
        Composer.__init__(self)
        FullConstructor.__init__(self)
        Resolver.__init__(self)


class SafeLoader(Reader, Scanner, Parser, Composer, SafeConstructor, Resolver):
    def __init__(self, stream):
        Reader.__init__(self, stream)
        Scanner.__init__(self)
        Parser.__init__(self)
        Composer.__init__(self)
        SafeConstructor.__init__(self)
        Resolver.__init__(self)


class Loader(Reader, Scanner, Parser, Composer, Constructor, Resolver):
    def __init__(self, stream):
        Reader.__init__(self, stream)
        Scanner.__init__(self)
        Parser.__init__(self)
        Composer.__init__(self)
        Constructor.__init__(self)
        Resolver.__init__(self)


# ------------------------------------------------------------------------------
# XXX "Warnings control" is now deprecated. Leaving in the API function to not
# break code that uses it.
# ------------------------------------------------------------------------------
def warnings(settings=None):
    if settings is None:
        return {}


def load(stream, Loader):
    """
    Parse the first YAML document in a stream
    and produce the corresponding Python object.
    """
    loader = Loader(stream)
    try:
        return loader.get_single_data()
    finally:
        loader.dispose()


def load_all(stream, Loader):
    """
    Parse all YAML documents in a stream
    and produce corresponding Python objects.
    """
    loader = Loader(stream)
    try:
        while loader.check_data():
            yield loader.get_data()
    finally:
        loader.dispose()


def safe_load(stream):
    """
    Parse the first YAML document in a stream
    and produce the corresponding Python object.

    Resolve only basic YAML tags. This is known
    to be safe for untrusted input.
    """
    return load(stream, SafeLoader)


def safe_load_all(stream):
    """
    Parse all YAML documents in a stream
    and produce corresponding Python objects.

    Resolve only basic YAML tags. This is known
    to be safe for untrusted input.
    """
    return load_all(stream, SafeLoader)


__all__ = ["load_all", "safe_load_all"]
