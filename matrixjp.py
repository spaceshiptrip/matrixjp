#!/usr/bin/env python3
import curses, random, time, sys

HALF_WIDTH = "ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝｰ･｡ｧｨｩｪｫｯｬｭｮ"
FULL_WIDTH = "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンー・。ァィゥェォッャュョ"

use_full = ("--full" in sys.argv)
charset = FULL_WIDTH if use_full else HALF_WIDTH

def safe_addstr(scr, y, x, s, attr=0):
    try:
        scr.addstr(y, x, s, attr)
    except curses.error:
        pass  # ignore out-of-bounds or width issues

def main(stdscr):
    curses.curs_set(0)
    stdscr.nodelay(True)
    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_GREEN, -1)  # bright green

    h, w = stdscr.getmaxyx()
    drops = [random.randrange(-h, 0) for _ in range(w)]
    speeds = [random.choice((1,1,1,2)) for _ in range(w)]
    tail = max(4, min(20, h // 12))
    # if full-width chars, avoid last column to prevent overflow
    max_x = w - (2 if use_full else 1)

    while True:
        if stdscr.getch() in (ord('q'), 27):  # q/ESC
            break

        h, w = stdscr.getmaxyx()
        max_x = w - (2 if use_full else 1)
        for x in range(0, max_x):
            y = drops[x]

            # head
            if 0 <= y < h:
                c = random.choice(charset)
                safe_addstr(stdscr, y, x, c, curses.color_pair(1) | curses.A_BOLD)

            # tail (fade-ish)
            for i in range(1, tail):
                yy = y - i
                if 0 <= yy < h:
                    c = random.choice(charset)
                    attr = curses.color_pair(1)
                    if i > tail // 2:
                        attr |= curses.A_DIM
                    safe_addstr(stdscr, yy, x, c, attr)

            # clear behind tail
            clear_y = y - tail
            if 0 <= clear_y < h:
                safe_addstr(stdscr, clear_y, x, ' ')

            # advance
            drops[x] += speeds[x]
            if drops[x] - tail > h:
                drops[x] = random.randrange(-h // 2, 0)
                speeds[x] = random.choice((1,1,2))

        stdscr.refresh()
        time.sleep(0.03)

if __name__ == "__main__":
    curses.wrapper(main)

