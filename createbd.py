#!/usr/bin/env python
# -*- coding: utf-8 -*-"
import ipcalc
import sqlite3
import sys
import os
conn = sqlite3.connect('ovpn.bd')
c = conn.cursor()


def pars():
    files = os.listdir('/etc/openvpn/ccd')
    for x in files:
        f = open('/etc/openvpn/ccd/%s' % x)
        fi = f.read().strip().split()
        c.execute("UPDATE net \
                  SET user = ? \
                  WHERE a = ?", (x, fi[1]))
        conn.commit()
        print(x + " " + fi[1] + "-" + fi[2])
        f.close
    c.execute("UPDATE net SET user = 'system' WHERE id = 1")
    conn.commit()
c.execute("SELECT count(*) FROM sqlite_master WHERE type='table'\
          AND name='net';")
if c.fetchone()[0] == 1:
    print("БД существует!!!")
    pars()
    conn.close()
    sys.exit()
c.execute("CREATE TABLE net ('id' INTEGER PRIMARY KEY AUTOINCREMENT ,\
          'user' TEXT,\
          'a' TEXT,\
          'b' TEXT,\
          'dostup' TEXT)")
d = 1
for x in ipcalc.Network('192.168.193.0/24'):
    if d == 1:
        print("d == 1 ", str(x))
        c.execute("insert into net (a) values ('%s')" % str(x))
        conn.commit()
        idi = str(x)
        d += 1
    elif d == 2:
        print("d == 2", str(x))
        c.execute("update  net \
                  set b = ? \
                  where a = ?", (str(x), idi))
        conn.commit()
        d += 1
    elif d == 3:
        print("")
        d += 1
    elif d == 4:
        print("")
        d = 1
pars()
print("OK!!")
conn.close()
