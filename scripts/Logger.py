import os
import sys

from enum import Enum

class LogType(Enum):
    no = 0
    imporant = 1
    error = 2
    debug = 3
    warning = 4
    all = 5


MINIMUMLOGLEVEL = LogType.error #Set between 0-5, the lower the number, the less logs


def LOG(message):
    if MINIMUMLOGLEVEL.value >= LogType.imporant.value:
        print(f"LOG: {message}")

def LOGE(message):
    if MINIMUMLOGLEVEL.value >= LogType.error.value:
        print(f"ERROR: {message}")

def LOGD(message):
    if MINIMUMLOGLEVEL.value >= LogType.debug.value:
        print(f"LOGD: {message}")

def LOGW(message):
    if MINIMUMLOGLEVEL.value >= LogType.warning.value:
        print(f"WARNING: {message}")

def LOGA(message):
    if MINIMUMLOGLEVEL.value >= LogType.all.value:
        print(f"LOGA: {message}")