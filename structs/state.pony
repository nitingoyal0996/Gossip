use ".."

// Define a new State structure
struct val State
  let s: F64
  let w: F64

  // Define an apply method to initialize State
  new val create(state_s: F64, state_w: F64) =>
    s = state_s
    w = state_w

struct val GossipState
  let rumor: String
  let count: F64

  new val create(heard: String, times: F64) =>
    rumor = heard
    count = times