// -*- mode: Bluespec; -*-
/**
 * This module collects definitions that are ubiquitous.
 * One day they will become the standard library of Quint.
 */
module basicSpells {
  type Option[a] = Some(a) | None

  /// An annotation for writing preconditions.
  /// - @param __cond condition to check
  /// - @returns true if and only if __cond evaluates to true
  pure def require(__cond: bool): bool = __cond

  run requireTest = all {
    assert(require(4 > 3)),
    assert(not(require(false))),
  }

  /// A convenience operator that returns a string error code,
  ///  if the condition does not hold true.
  ///
  /// - @param __cond condition to check
  /// - @param __error a non-empty error message
  /// - @returns "", when __cond holds true; otherwise __error
  pure def requires(__cond: bool, __error: str): str = {
    if (__cond) "" else __error
  }

  run requiresTest = all {
    assert(requires(4 > 3, "4 > 3") == ""),
    assert(requires(4 < 3, "false: 4 < 3") == "false: 4 < 3"),
  }


  /// Compute the maximum of two integers.
  ///
  /// - @param __i first integer
  /// - @param __j second integer
  /// - @returns the maximum of __i and __j
  pure def max(__i: int, __j: int): int = {
    if (__i > __j) __i else __j
  }

  run maxTest = all {
    assert(max(3, 4) == 4),
    assert(max(6, 3) == 6),
    assert(max(10, 10) == 10),
    assert(max(-3, -5) == -3),
    assert(max(-5, -3) == -3),
  }

  /// Compute the absolute value of an integer
  ///
  /// - @param __i : an integer whose absolute value we are interested in
  /// - @returns |__i|, the absolute value of __i
  pure def abs(__i: int): int = {
    if (__i < 0) -__i else __i
  }

  run absTest = all {
    assert(abs(3) == 3),
    assert(abs(-3) == 3),
    assert(abs(0) == 0),
  }

  /// Remove a set element.
  ///
  /// - @param __set a set to remove an element from
  /// - @param __elem an element to remove
  /// - @returns a new set that contains all elements of __set but __elem
  pure def setRemove(__set: Set[a], __elem: a): Set[a] = {
    __set.exclude(Set(__elem))
  }

  run setRemoveTest = all {
    assert(Set(2, 4) == Set(2, 3, 4).setRemove(3)),
    assert(Set() == Set().setRemove(3)),
  }

  /// Test whether a key is present in a map
  ///
  /// - @param __map a map to query
  /// - @param __key the key to look for
  /// - @returns true if and only __map has an entry associated with __key
  pure def has(__map: a -> b, __key: a): bool = {
    __map.keys().contains(__key)
  }

  run hasTest = all {
    assert(Map(2 -> 3, 4 -> 5).has(2)),
    assert(not(Map(2 -> 3, 4 -> 5).has(6))),
  }

  /// Get the map value associated with a key, or the default,
  /// if the key is not present.
  ///
  /// - @param __map the map to query
  /// - @param __key the key to search for
  /// - @returns the value associated with the key, if __key is
  ///   present in the map, and __default otherwise
  pure def getOrElse(__map: a -> b, __key: a, __default: b): b = {
    if (__map.has(__key)) {
      __map.get(__key)
    } else {
      __default
    }
  }

  run getOrElseTest = all {
    assert(Map(2 -> 3, 4 -> 5).getOrElse(2, 0) == 3),
    assert(Map(2 -> 3, 4 -> 5).getOrElse(7, 11) == 11),
  }

  /// Remove a map entry.
  ///
  /// - @param __map a map to remove an entry from
  /// - @param __key the key of an entry to remove
  /// - @returns a new map that contains all entries of __map
  ///          that do not have the key __key
  pure def mapRemove(__map: a -> b, __key: a): a -> b = {
    __map.keys().setRemove(__key).mapBy(__k => __map.get(__k))
  }

  run mapRemoveTest = all {
    assert(Map(3 -> 4, 7 -> 8) == Map(3 -> 4, 5 -> 6, 7 -> 8).mapRemove(5)),
    assert(Map() == Map().mapRemove(3)),
  }

  /// Removes a set of map entries.
  ///
  /// - @param __map a map to remove entries from
  /// - @param __keys a set of keys for entries to remove from the map
  /// - @returns a new map that contains all entries of __map
  ///          that do not have a key in __keys
  pure def mapRemoveAll(__map: a -> b, __keys: Set[a]): a -> b = {
      __map.keys().exclude(__keys).mapBy(__k => __map.get(__k))
  }

  run mapRemoveAllTest =
      val m = Map(3 -> 4, 5 -> 6, 7 -> 8)
      all {
          assert(m.mapRemoveAll(Set(5, 7)) == Map(3 -> 4)),
          assert(m.mapRemoveAll(Set(5, 99999)) == Map(3 -> 4, 7 -> 8)),
      }

  /// Get the set of values of a map.
  ///
  /// - @param __map a map from type a to type b
  /// - @returns the set of all values in the map
  pure def values(__map: a -> b): Set[b] = {
    __map.keys().map(k => __map.get(k))
  }

  run valuesTest = all {
    assert(values(Map()) == Set()),
    assert(values(Map(1 -> 2, 2 -> 3)) == Set(2, 3)),
    assert(values(Map(1 -> 2, 2 -> 3, 3 -> 2)) == Set(2, 3)),
  }

  /// Whether a set is empty
  ///
  /// - @param s a set of any type
  /// - @returns true iff the set is the empty set
  pure def empty(s: Set[a]): bool = s == Set()

  run emptyTest = all {
    assert(empty(Set()) == true),
    assert(empty(Set(1, 2)) == false),
    assert(empty(Set(Set())) == false),
  }

  pure def listFilter(l: List[a], f: (a) => bool): List[a] =
    l.foldl([], (acc, e) => if (f(e)) acc.append(e) else acc)

  pure def listMap(l: List[a], f: (a) => b): List[b] =
    l.foldl([], (acc, e) => acc.append(f(e)))

  pure def listForall(l: List[a], f: (a) => bool): bool =
    l.foldl(true, (acc, e) => acc and f(e))

  pure def listExists(l: List[a], f: (a) => bool): bool =
    l.foldl(false, (acc, e) => acc or f(e))

  //// Returns a set of the elements in the list.
  ////
  //// - @param l a list
  //// - @returns a set of the elements in l
  pure def toSet(l: List[a]): Set[a] = {
      l.foldl(Set(), (s, e) => s.union(Set(e)))
  }
}
