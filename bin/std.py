from pathlib import Path
import sys

path = Path(__file__).resolve().parent
sys.path.insert(0, path)

import input._input as _in
import print._print as _out
import threading

class _std(_out.Format):

    def __init__(
        self,
        ratio=0.4,
        prompt="Type: ",
        text_color=_out.YELLOW,
        prompt_color=_out.BOLD,
        border_color=_out.BOLD_BLUE,
        prompt_background=_out.BLUE_BACKGROUND,
        take_input=True,
    ):
        self.prompt = prompt
        self.prompt_color = prompt_color
        self.prompt_background = prompt_background

        self.user_in = None

        super().__init__(ratio, text_color, border_color)

        if take_input:
            inp = threading.Thread(target=self._input)
            inp.start()

    class print(_out.Format.print):

        prompt = None

        @classmethod
        def right(self, text):
            super().right(text)
            
            if self.prompt is not None:
                print(self.prompt, end="")

        @classmethod
        def left(self, text):
            super().left(text)
            
            if self.prompt is not None:
                print(self.prompt, end="")

    def _input(self):

        text = ""
        self.print.prompt = self.prompt
        while True:
            char = _in.get_char()
            if len(char) > 1:
                if char.lower() == "enter":
                    self.print.right(text)
                    self.user_in = text
                    text = ""

                elif char.lower() == "backspace":
                    text = text[:-1]

                char = ""

            text += char
            out = self.prompt + text
            print(f"\r{_out.CLEAR_LINE}{out}", end="")
            self.print.prompt = out


STD = _std()

if __name__ == "__main__":

    from time import sleep

    texts = [
        "hello",
        "how is your experience?",
        "if bad i need feed back with the exact bug.",
        "Care to give a debug note on the specific line if there is.",
    ]
    while True:
        for text in texts:
            STD.print.left(text)
            sleep(4)
