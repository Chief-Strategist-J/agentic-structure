from typing import Callable, Iterable, List, TypeVar, Tuple

T = TypeVar('T')
U = TypeVar('U')

def map_list(items: Iterable[T], fn: Callable[[T], U]) -> List[U]:
    return [fn(x) for x in items]

def filter_list(items: Iterable[T], pred: Callable[[T], bool]) -> List[T]:
    return [x for x in items if pred(x)]

def partition_list(items: Iterable[T], pred: Callable[[T], bool]) -> Tuple[List[T], List[T]]:
    matching, non_matching = [], []
    for x in items:
        if pred(x): matching.append(x)
        else: non_matching.append(x)
    return matching, non_matching
