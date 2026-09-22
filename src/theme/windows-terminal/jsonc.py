"""Small JSONC editor for settings: retain comments outside edited values.

Only JSON plus // comments, /* comments */ and trailing commas is accepted.
Paths are tuples of object keys and array indices. No regex substitution of JSON.
"""
import json
import re


class Document:
    def __init__(self, text):
        self.text = text
        self.spans = {}
        self.ends = {}
        self.i = 0
        self.value = self.parse(())
        self.space()
        if self.i != len(text):
            raise ValueError("Unexpected text after JSON")

    def space(self):
        while self.i < len(self.text):
            match = re.match(r"\s+|//[^\r\n]*|/\*[\s\S]*?\*/", self.text[self.i:])
            if not match:
                return
            self.i += match.end()

    def parse(self, path):
        self.space()
        start = self.i
        char = self.text[self.i:self.i + 1]
        if char in ("{", "["):
            obj = char == "{"
            value = {} if obj else []
            end = "}" if obj else "]"
            self.i += 1
            self.space()
            while self.text[self.i:self.i + 1] != end:
                if obj:
                    key, n = json.JSONDecoder().raw_decode(self.text[self.i:])
                    if not isinstance(key, str) or key in value:
                        raise ValueError("Invalid or duplicate JSON key")
                    self.i += n
                    self.space()
                    if self.text[self.i:self.i + 1] != ":":
                        raise ValueError("Expected colon")
                    self.i += 1
                else:
                    key = len(value)
                item = self.parse(path + (key,))
                if obj:
                    value[key] = item
                else:
                    value.append(item)
                self.space()
                if self.text[self.i:self.i + 1] == end:
                    break
                if self.text[self.i:self.i + 1] != ",":
                    raise ValueError("Expected comma")
                self.i += 1
                self.space()
            self.ends[path] = self.i
            self.i += 1
        else:
            value, n = json.JSONDecoder().raw_decode(self.text[self.i:])
            self.i += n
        self.spans[path] = (start, self.i)
        return value

    def set(self, path, value):
        encoded = json.dumps(value, ensure_ascii=False)
        if path in self.spans:
            start, end = self.spans[path]
            text = self.text[:start] + encoded + self.text[end:]
        else:
            parent = path[:-1]
            container = self.value
            for key in parent:
                container = container[key]
            end = self.ends[parent]
            # Add a separator immediately after the previous value, before comments.
            if container:
                key = list(container)[-1] if isinstance(container, dict) else len(container) - 1
                last = self.spans[parent + (key,)][1]
                between = self.text[last:end]
                clean = re.sub(r"//[^\r\n]*|/\*[\s\S]*?\*/", "", between)
                comma = "" if "," in clean else ","
                prefix = self.text[:last] + comma + self.text[last:end]
            else:
                prefix = self.text[:end]
            item = (json.dumps(path[-1]) + ": " if isinstance(container, dict) else "") + encoded
            text = prefix + "\n    " + item + "\n" + self.text[end:]
        self.__init__(text)
