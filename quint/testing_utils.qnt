module testing_utils {
  import basicSpells.* from "lib/basicSpells"
  import cw_types.* from "lib/cw_types"
  import cw_utils.* from "lib/cw_utils"

  // pure def listToSet(l) = l.foldl(Set(), (s, e) => s.union(Set(e)))

  pure def isOK(result: Result): bool = {
    match result {
      | Ok(_) => true
      | Err(_) => false
    }
  }

  // TODO why can't I match (r1, r2)?
  pure def sameMessages(r1: Result, r2: Result): bool = {
    match r1 {
      | Ok(resp1) => match r2 {
        | Ok(resp2) => resp1.messages == resp2.messages
        | Err(_) => false
      }
      | Err(_) => match r2 {
        | Ok(resp2) => false
        | Err(_) => true
      }
    }
  }

  pure def clearResult(result: Result): Result = {
    match result {
      | Ok(_) => Ok(Response_new)
      | Err(err) => Err(err)
    }
  }

  pure def checkExpectation(r) = isOK(r.given._1)
    ==  isOK(r.expect._1)
    and r.given._2 == r.expect._2
    and sameMessages(r.given._1, r.expect._1)

  pure def failIndices(es) = es.indices().filter(i => not(checkExpectation(es[i])))

  pure def failures(es) = es.select(e => not(checkExpectation(e)))

  pure def score(es) = (es.select(checkExpectation).length(), es.length(), failIndices(es))

  pure def outputs(es) = es.foldl([], (l, e) => l.append((e.given._1, e.given._2)))
}
