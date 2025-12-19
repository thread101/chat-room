import os
import sys


def setup_unix():
    import termios
    import tty

    fd = sys.stdin.fileno()
    settings = termios.tcgetattr(fd)

    def getch():
        tty.setraw(fd)
        try:
            ch = sys.stdin.read(1)
            if ch == "\x1b":  # ESC character
                ch2 = sys.stdin.read(1)
                ch3 = sys.stdin.read(1)

                if ch2 == "[":
                    match (ch3):
                        case "A":
                            return "UP_ARROW"
                        case "B":
                            return "DOWN_ARROW"
                        case "C":
                            return "RIGHT_ARROW"
                        case "D":
                            return "LEFT_ARROW"
                        case "H":
                            return "HOME"
                        case "F":
                            return "END"
                        case "3":
                            if sys.stdin.read(1) == "~":
                                return "DELETE"

            elif ch == "\r":
                return "ENTER"

            elif ch == "\x08" or ch == "\x7f":
                return "BACKSPACE"

            elif ch == "\x03":
                return "CTRL_C"

            elif ch == "\t":
                return "TAB"

        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, settings)

        return ch

    return getch


def setup_ms():
    import msvcrt

    ch = msvcrt.getch()
    if ch == b"\xe0":
        ch2 = msvcrt.getch()
        match (ch2):
            case b"H":
                return "UP_ARROW"
            case b"P":
                return "DOWN_ARROW"
            case b"M":
                return "RIGHT_ARROW"
            case b"K":
                return "LEFT_ARROW"
            case b"G":
                return "HOME"
            case b"O":
                return "END"
            case b"S":
                return "DELETE"

    try:
        decoded = ch.decode("utf-8")
        if decoded == "\x08" or decoded == "\x7f":
            return "BACKSPACE"
        elif decoded == "\r":
            return "ENTER"
        elif decoded == "\t":
            return "TAB"
        elif decoded == "\x1b":
            return "ESC"
        elif decoded == "\x03":
            return "CTRL_C"
        return decoded
    
    except UnicodeDecodeError:
        return str(ch)


if os.name == "nt":
    get_char = setup_ms

else:
    get_char = setup_unix()


if __name__ == "__main__":
    while True:
        char = get_char()
        if char == "q":
            break

        print("got:", char, "\tbytes:", char.encode())