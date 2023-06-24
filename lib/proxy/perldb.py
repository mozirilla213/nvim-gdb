#!/usr/bin/env python3

"""
Run perldb in a pty.

This will allow to inject server commands not exposing them
to a user.
"""

import re
import sys

from .impl import Impl


class PerlDb(Impl):
    """PTY proxy for bashdb."""

    def __init__(self, argv: [str]):
        """ctor."""
        super().__init__("PerlDB", argv)
        self.prompt = re.compile(rb'[\r\n]perldb<\(?\d+\)?> ')

    def get_prompt(self):
        return self.prompt
