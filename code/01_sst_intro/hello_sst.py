# Minimal SST configuration: two components exchanging events over one link.
# Uses simpleElementExample.example0 from SST-Elements.
import sst

comp_a = sst.Component("c0", "simpleElementExample.example0")
comp_a.addParams({
    "eventsToSend": 50,
    "eventSize": 32,
})

comp_b = sst.Component("c1", "simpleElementExample.example0")
comp_b.addParams({
    "eventsToSend": 50,
    "eventSize": 32,
})

link = sst.Link("link_c0_c1")
link.connect((comp_a, "port", "1ns"), (comp_b, "port", "1ns"))
