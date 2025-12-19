import os

RED = "\033[31m"
GREEN = "\x1b[32m"
YELLOW = "\033[33m"
BLUE = "\x1b[34m"
BOLD = "\033[1m"
RESET = "\033[0m"
BLUE_BACKGROUND = "\x1b[44m"

BOLD_RED = "\033[31;1m"
BOLD_GREEN = "\x1b[32;1m"
BOLD_YELLOW = "\033[33;1m"
BOLD_BLUE = "\x1b[34;1m"

CLEAR_LINE = "\033[K"
MOVE_CURSOR_LEFT = "\033[1D"
MOVE_CURSOR_RIGHT = "\033[1C"
MOVE_CURSOR_UP = "\033[1A"
MOVE_CURSOR_DOWN = "\033[1B"
SAVE_CURSOR_POSITION = "\033[s"
RESTORE_CURSOR_POSITION = "\033[u"

class Format:

    def __init__(self,
                 ratio=.5,
                 text_color=YELLOW,
                 border_color=BOLD_BLUE,):

        self.print.ratio = ratio
        self.print.text_color = text_color
        self.print.border_color = border_color


    class print:

        ratio = None
        prompt = None
        text_color = None
        prompt_color = None
        border_color = None
        prompt_background = None

        @classmethod
        def _format(self, text:str, position:int):
            text = text.replace("\n", " ")
            view_width = os.get_terminal_size().columns
            text_width = int(view_width*self.ratio)+2 if len(text) >  int(view_width*self.ratio) else len(text) + 1

            t, out = "", "\n"
            for word in text.split():
                word = f"{word} "
                if len(t) + len(word) < text_width:
                        t += word

                else:
                    out += f"{t}{' '*(text_width-len(t))}\n"
                    t = word

            out += f"{t}{' '*(text_width-len(t))}\n"
            out = out.replace("\n", f"{self.border_color} |\n | {self.text_color}")
            out += f"\b\b{RESET}{self.border_color}+-{'-'*text_width}-+{RESET}"

            lines = out.split("\n")
            if position == 1:
                lines[0] = f"\b\b{self.border_color}__{'_'*text_width}__"
                lines[1] = f"\\{lines[1].replace(" | ", "  ")}"
                out = "\n".join(lines)

            elif position == 2:
                padding = ' '*(view_width-text_width-6)
                lines[0] = f"\b\b{padding}{self.border_color}  _{'_'*text_width}___"
                lines[1] = f"{lines[1]}\b /"
                out = f"\n{padding}".join(lines)
                
            return out

        @classmethod
        def right(self, text:str):
            text = self._format(text, 2)
            print(f"\r{text}\n")

        @classmethod
        def left(self, text:str):
            text = self._format(text, 1)
            print(f"\r{text}\n")


if __name__ == "__main__":
    obj = Format()

    text = '''
    Go to dash.teams.cloudflare.com right now, sign up for Zero Trust free plan (card required but won't be charged), and you'll have your local port exposed in under 10 minutes.

    The card requirement is just for identity verification - Cloudflare doesn't charge for the free tier unless you manually upgrade or exceed limits (which are generous).

    Want me to walk you through the exact steps to set up your first tunnel?'''

    obj.print.left(text)
    obj.print.right(text)
    obj.print.right("hello, how are you?")
    
    
    # text = "Want me to walk you through the exact steps to set up your first tunnel?"
    # print(text, end="")
    # while True:
    #     cmd = input()
    #     if cmd == 'd':
    #         print(f"\r{CLEAR_LINE}{MOVE_CURSOR_RIGHT}{text}", end="")
            
    #     elif cmd == 'a':
    #         print(f"\r{CLEAR_LINE}{MOVE_CURSOR_LEFT}{text}", end="")